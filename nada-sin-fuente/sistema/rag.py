"""RAG propio de "Nada sin fuente".

Pipeline completo y local:
    PDFs/MD del corpus -> fragmentos con página -> embeddings (Ollama)
    -> índice en disco (numpy) -> recuperación por similitud coseno
    -> respuesta del modelo con cita obligatoria -> verificación de citas.

Uso (desde nada-sin-fuente/sistema/):
    python rag.py indexar
    python rag.py calibrar
    python rag.py manifiesto
    python rag.py preguntar "¿Qué estructura tiene el IPM censal del DANE?"
    python rag.py evaluar --sin-razonamiento
    python rag.py reverificar resultados/<archivo>.json
    python tests/test_rag.py

El modelo generador se cambia con --modelo o con la variable RAG_MODELO,
sin tocar el código.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import unicodedata
from datetime import datetime
from pathlib import Path

import numpy as np

AQUI = Path(__file__).resolve().parent
RAIZ = AQUI.parent  # nada-sin-fuente/
DIR_CORPUS = RAIZ / "corpus" / "papers"
DIR_INDICE = AQUI / "indice"
DIR_RESULTADOS = AQUI / "resultados"
ARCHIVO_FUENTES = AQUI / "fuentes.json"
ARCHIVO_BANCO = AQUI / "banco.json"

MODELO = os.environ.get("RAG_MODELO", "qwen3.5:4b")
MODELO_EMBEDDINGS = os.environ.get("RAG_EMBEDDINGS", "bge-m3")
TOP_K = int(os.environ.get("RAG_TOP_K", "5"))
# Similitud coseno mínima del mejor fragmento para intentar responder.
# Por debajo, el sistema se abstiene SIN llamar al modelo. Hay que calibrarlo
# con el banco (ver README): el valor por defecto es un punto de partida.
UMBRAL = float(os.environ.get("RAG_UMBRAL", "0.45"))
TAM_FRAGMENTO = 900   # caracteres
SOLAPE = 150          # caracteres

VERSION = "2.1"

ABSTENCION = "No encuentro esto en las fuentes del corpus."

PROMPT_SISTEMA = f"""Eres un asistente de investigación que responde EXCLUSIVAMENTE con base en los fragmentos del corpus que se te entregan. No completas información con conocimiento general ni con memoria propia.

Reglas:
1. Toda afirmación lleva cita con el formato [Apellido, año, p. X], usando SOLO el apellido, año y página que aparecen en la cabecera de cada fragmento.
2. Si la página no se puede determinar, usa [Apellido, año, ubicación no verificada].
3. Si los fragmentos no contienen la respuesta, responde únicamente: "{ABSTENCION}"
4. No inventes autores, años, páginas, cifras ni DOI. No cites fuentes que no estén en los fragmentos.
5. Si la pregunta nombra un documento por uno de los nombres que aparecen como "también citado como" en una cabecera, es ese mismo documento: responde con él y cítalo con el nombre principal de la cabecera.
6. Responde en español, de forma breve."""


# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------

def normalizar(texto: str) -> str:
    """Minúsculas y sin tildes, para comparar apellidos."""
    texto = unicodedata.normalize("NFKD", texto)
    texto = "".join(c for c in texto if not unicodedata.combining(c))
    return texto.lower().strip()


def cargar_fuentes() -> dict:
    with open(ARCHIVO_FUENTES, encoding="utf-8") as f:
        return json.load(f)["fuentes"]


def alias_de(archivo: str, fuentes: dict | None = None) -> list[tuple[str, str]]:
    """Nombres alternativos de un documento: [(apellido, año), ...]."""
    fuentes = fuentes if fuentes is not None else cargar_fuentes()
    ficha = fuentes.get(archivo, {})
    return [(a["apellido"], str(a["anio"])) for a in ficha.get("alias", [])]


def sha256_archivo(ruta: Path) -> str | None:
    import hashlib
    if not ruta.exists():
        return None
    h = hashlib.sha256()
    with open(ruta, "rb") as f:
        for bloque in iter(lambda: f.read(1 << 20), b""):
            h.update(bloque)
    return h.hexdigest()


def digest_modelo(nombre: str) -> str | None:
    """Digest del modelo en Ollama, para saber exactamente qué versión respondió."""
    try:
        import ollama
        for m in ollama.list()["models"]:
            n = m.get("model") if isinstance(m, dict) else getattr(m, "model", None)
            d = m.get("digest") if isinstance(m, dict) else getattr(m, "digest", None)
            if n in (nombre, f"{nombre}:latest"):
                return d
    except Exception:
        return None
    return None


def es_abstencion(respuesta: str) -> bool:
    """Abstención solo si la respuesta ES la frase (no si la contiene junto a otro contenido)."""
    limpiar = lambda t: re.sub(r"[\s\"'“”«»*.]+", " ", normalizar(t)).strip()
    return limpiar(respuesta) == limpiar(ABSTENCION)


def quitar_razonamiento(texto: str) -> str:
    """Algunos modelos (p. ej. Qwen 3.x) devuelven <think>...</think>."""
    return re.sub(r"<think>.*?</think>", "", texto, flags=re.DOTALL).strip()


# ---------------------------------------------------------------------------
# Conexión con Ollama (aislada para poder probar sin Ollama)
# ---------------------------------------------------------------------------

def embeber_ollama(textos: list[str], modelo: str = None) -> np.ndarray:
    import ollama
    resp = ollama.embed(model=modelo or MODELO_EMBEDDINGS, input=textos)
    return np.array(resp["embeddings"], dtype=np.float32)


def generar_ollama(sistema: str, usuario: str, modelo: str, sin_razonamiento: bool = False) -> str:
    import ollama
    kwargs = {}
    if sin_razonamiento:
        kwargs["think"] = False
    resp = ollama.chat(
        model=modelo,
        messages=[{"role": "system", "content": sistema},
                  {"role": "user", "content": usuario}],
        options={"temperature": 0},
        **kwargs,
    )
    return quitar_razonamiento(resp["message"]["content"])


# ---------------------------------------------------------------------------
# 1. Indexar
# ---------------------------------------------------------------------------

def leer_documento(ruta: Path) -> list[tuple[str, str]]:
    """Devuelve [(ubicación, texto)]. Para PDF la ubicación es el número de página."""
    if ruta.suffix.lower() == ".pdf":
        from pypdf import PdfReader
        lector = PdfReader(str(ruta))
        return [(str(i + 1), (p.extract_text() or "")) for i, p in enumerate(lector.pages)]
    # .md / .txt: se divide por encabezados para tener una ubicación citable
    texto = ruta.read_text(encoding="utf-8", errors="ignore")
    secciones, actual, titulo = [], [], "inicio"
    for linea in texto.splitlines():
        if linea.startswith("#"):
            if actual:
                secciones.append((f"sección «{titulo}»", "\n".join(actual)))
            titulo, actual = linea.lstrip("# ").strip(), []
        else:
            actual.append(linea)
    if actual:
        secciones.append((f"sección «{titulo}»", "\n".join(actual)))
    return secciones


def fragmentar(texto: str, tam: int = TAM_FRAGMENTO, solape: int = SOLAPE) -> list[str]:
    texto = re.sub(r"\s+", " ", texto).strip()
    if not texto:
        return []
    trozos, inicio = [], 0
    while inicio < len(texto):
        fin = min(inicio + tam, len(texto))
        if fin < len(texto):  # cortar en un espacio para no partir palabras
            corte = texto.rfind(" ", inicio + tam // 2, fin)
            fin = corte if corte != -1 else fin
        trozos.append(texto[inicio:fin].strip())
        if fin >= len(texto):
            break
        inicio = max(fin - solape, inicio + 1)
    return trozos


def indexar(embeber=embeber_ollama, dir_corpus: Path = DIR_CORPUS, dir_indice: Path = DIR_INDICE) -> dict:
    fuentes = cargar_fuentes()
    archivos = sorted(p for p in dir_corpus.glob("*") if p.suffix.lower() in {".pdf", ".md", ".txt"})
    if not archivos:
        sys.exit(f"No hay documentos en {dir_corpus}. Copia ahí los PDFs del corpus (ver README).")

    fragmentos, sin_ficha = [], []
    for ruta in archivos:
        ficha = fuentes.get(ruta.name)
        if ficha is None:
            sin_ficha.append(ruta.name)
            continue
        for ubicacion, texto in leer_documento(ruta):
            for trozo in fragmentar(texto):
                fragmentos.append({
                    "archivo": ruta.name,
                    "apellido": ficha["apellido"],
                    "anio": ficha["anio"],
                    "ubicacion": ubicacion,
                    "texto": trozo,
                })
    if sin_ficha:
        print("AVISO: estos archivos no están en fuentes.json y NO se indexaron:", ", ".join(sin_ficha))
    if not fragmentos:
        sys.exit("No se extrajo texto. ¿Los PDFs son escaneados (imagen)? Revisa el README.")

    vectores = []
    for i in range(0, len(fragmentos), 32):
        lote = [f["texto"] for f in fragmentos[i:i + 32]]
        vectores.append(embeber(lote))
    matriz = np.vstack(vectores).astype(np.float32)
    matriz /= np.linalg.norm(matriz, axis=1, keepdims=True) + 1e-12

    dir_indice.mkdir(parents=True, exist_ok=True)
    np.save(dir_indice / "vectores.npy", matriz)
    with open(dir_indice / "fragmentos.json", "w", encoding="utf-8") as f:
        json.dump(fragmentos, f, ensure_ascii=False, indent=1)
    meta = {
        "fecha": datetime.now().isoformat(timespec="seconds"),
        "modelo_embeddings": MODELO_EMBEDDINGS,
        "documentos": sorted({f["archivo"] for f in fragmentos}),
        "n_fragmentos": len(fragmentos),
        "tam_fragmento": TAM_FRAGMENTO,
        "solape": SOLAPE,
    }
    with open(dir_indice / "meta.json", "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=1)
    print(f"Índice creado: {len(meta['documentos'])} documentos, {len(fragmentos)} fragmentos.")
    return meta


# ---------------------------------------------------------------------------
# 2. Recuperar y responder
# ---------------------------------------------------------------------------

def cargar_indice(dir_indice: Path = DIR_INDICE):
    if not (dir_indice / "vectores.npy").exists():
        sys.exit("No existe el índice. Corre primero: python rag.py indexar")
    matriz = np.load(dir_indice / "vectores.npy")
    with open(dir_indice / "fragmentos.json", encoding="utf-8") as f:
        fragmentos = json.load(f)
    return matriz, fragmentos


def recuperar(pregunta: str, matriz, fragmentos, embeber=embeber_ollama, k: int = TOP_K):
    q = embeber([pregunta])[0]
    q = q / (np.linalg.norm(q) + 1e-12)
    sims = matriz @ q
    orden = np.argsort(-sims)[:k]
    return [dict(fragmentos[i], similitud=float(sims[i])) for i in orden]


def construir_contexto(recuperados: list[dict], fuentes: dict | None = None) -> str:
    fuentes = fuentes if fuentes is not None else cargar_fuentes()
    bloques = []
    for i, f in enumerate(recuperados, 1):
        ubic = f["ubicacion"]
        cab = f"[Fragmento {i}] {f['apellido']}, {f['anio']}, " + (f"p. {ubic}" if ubic.isdigit() else ubic)
        alias = alias_de(f["archivo"], fuentes)
        if alias:
            cab += " (también citado como: " + "; ".join(f"{a}, {y}" for a, y in alias) + ")"
        bloques.append(f"{cab}\n{f['texto']}")
    return "\n\n".join(bloques)


def paginas_citadas(ubic: str) -> list[int] | None:
    """'p. 4' -> [4]; 'pp. 4-5' -> [4, 5]; 'p. 4, 5' o 'pp. 4 y 5' -> [4, 5]. None si no es página."""
    if not re.search(r"\d", ubic) or re.search(r"secci", normalizar(ubic)):
        return None
    paginas = []
    for a, b in re.findall(r"(\d+)\s*(?:[-–]\s*(\d+))?", ubic):
        a = int(a)
        paginas.extend(range(a, int(b) + 1) if b else [a])
    return paginas


def coincide_ubicacion(citada: str, recuperada: str) -> bool:
    """True si la página recuperada está entre las citadas (o la sección coincide)."""
    if recuperada.isdigit():
        pags = paginas_citadas(citada)
        return bool(pags) and int(recuperada) in pags
    return normalizar(citada).strip("«» ") in normalizar(recuperada)


# Una cita "Autor, año, ubicación" dentro de [] o (), o "Autor (año, ubicación)".
PATRON_GRUPO = re.compile(r"[\[(]([^\[\]()]*?\d{4}[^\[\]()]*?)[\])]")
PATRON_PIEZA = re.compile(r"^\s*([^,\d][^,]*?),\s*(\d{4})\s*(?:,\s*(.+?))?\s*$")
PATRON_FRAGMENTO = re.compile(r"^\s*Fragmento\s+(\d+)\s*,\s*(.+?)\s*$", re.IGNORECASE)
PATRON_NARRATIVA = re.compile(r"([A-ZÁÉÍÓÚÑ][\w\-áéíóúñÁÉÍÓÚÑ.]+(?:\s+(?:et al\.|y|[A-ZÁÉÍÓÚÑ][\w\-áéíóúñ.]+))*)\s*\((\d{4}),\s*([^)]+)\)")
# Compatibilidad con la v2.0 (solo el formato estándar).
PATRON_CITA = re.compile(r"\[([^\[\],]+?),\s*(\d{4}),\s*([^\]]+)\]")


def _extraer_citas(respuesta: str) -> list[tuple[str, str, str | None, str | None, str]]:
    """[(texto_original, autor, año, ubicación, formato)] en todos los formatos que conocemos.
    formato: 'corchete' (el pedido), 'parentesis', 'narrativa' o 'fragmento' (autor = '#n')."""
    citas, ocupado = [], []
    for m in PATRON_NARRATIVA.finditer(respuesta):
        citas.append((m.group(0), m.group(1), m.group(2), m.group(3), "narrativa"))
        ocupado.append(m.span())
    for m in re.finditer(r"\[([^\[\]]+)\]|\(([^()]+)\)", respuesta):
        if any(a <= m.start() < b for a, b in ocupado):
            continue
        corchete = m.group(1) is not None
        cuerpo = m.group(1) if corchete else m.group(2)
        for pieza in cuerpo.split(";"):
            fr = PATRON_FRAGMENTO.match(pieza)
            if fr:
                citas.append((pieza.strip(), f"#{fr.group(1)}", None, fr.group(2), "fragmento"))
                continue
            pm = PATRON_PIEZA.match(pieza)
            if pm and (corchete or re.search(r"\bp+\.", pieza)):
                citas.append((pieza.strip(), pm.group(1), pm.group(2), pm.group(3),
                              "corchete" if corchete else "parentesis"))
    return citas


def verificar_citas(respuesta: str, recuperados: list[dict], fuentes: dict | None = None) -> dict:
    """Cada cita debe corresponder a un fragmento recuperado (autor o alias, año y página).

    Estados:
      ok                         formato estándar y todo coincide
      ok (autor abreviado)       p. ej. "Monsalvo" por "Monsalvo Herrera y Jiménez"
      ok (alias)                 p. ej. "Ferry et al." por "Eckersley et al."
      ok (formato no estándar)   cita entre paréntesis o por número de fragmento
      inválida: ...              autor/año o página que no estaban en lo recuperado

    Esto detecta citas que no apuntan a texto recuperado. NO prueba que el
    contenido sea fiel: eso lo califica una persona.
    """
    fuentes = fuentes if fuentes is not None else cargar_fuentes()
    docs = {}  # (archivo) -> {"nombres": {(nombre_norm, año): tipo}, "paginas": set, "secciones": [..]}
    for f in recuperados:
        d = docs.setdefault(f["archivo"], {"nombres": {}, "paginas": set(), "secciones": []})
        d["nombres"][(normalizar(f["apellido"]), str(f["anio"]))] = "principal"
        for a, y in alias_de(f["archivo"], fuentes):
            d["nombres"][(normalizar(a), y)] = "alias"
        if f["ubicacion"].isdigit():
            d["paginas"].add(int(f["ubicacion"]))
        else:
            d["secciones"].append(normalizar(f["ubicacion"]))

    def buscar_doc(autor: str, anio: str):
        # "Según Bonet-Morón" -> prueba también quitando palabras del inicio.
        palabras = autor.split()
        for i in range(len(palabras)):
            d, tipo = _buscar(" ".join(palabras[i:]), anio)
            if d is not None:
                return d, tipo
        return None, None

    def _buscar(autor: str, anio: str):
        a = normalizar(autor).rstrip(".")
        for archivo, d in docs.items():
            for (nombre, y), tipo in d["nombres"].items():
                if y != anio:
                    continue
                if a == nombre.rstrip("."):
                    return d, tipo
                base = re.sub(r"\s+et al\.?$", "", nombre).strip()
                if a == base or (len(a) >= 4 and (nombre.startswith(a + " ") or base.startswith(a + " "))):
                    return d, "abreviado"
        return None, None

    citas, malas = [], []
    for original, autor, anio, ubic, formato in _extraer_citas(respuesta):
        if autor.startswith("#"):
            n = int(autor[1:])
            if 1 <= n <= len(recuperados):
                f = recuperados[n - 1]
                pags = paginas_citadas(ubic or "")
                ok = (not pags) or (f["ubicacion"].isdigit() and all(p == int(f["ubicacion"]) for p in pags))
                estado = "ok (formato no estándar: número de fragmento)" if ok else "inválida: página no coincide con el fragmento"
            else:
                estado = "inválida: ese número de fragmento no existe"
        else:
            d, tipo = buscar_doc(autor, anio)
            if d is None:
                estado = "inválida: autor/año no está en lo recuperado"
            elif ubic and "no verificada" in normalizar(ubic):
                estado = "ok (ubicación no verificada)"
            else:
                pags = paginas_citadas(ubic or "")
                if pags is None:
                    ok = (not ubic) or any(normalizar(ubic).strip("«» ") in s_ for s_ in d["secciones"])
                else:
                    ok = all(p in d["paginas"] for p in pags)
                if not ok:
                    estado = "inválida: página/sección no está en lo recuperado"
                elif tipo == "abreviado":
                    estado = "ok (autor abreviado)"
                elif tipo == "alias":
                    estado = "ok (alias)"
                elif formato == "parentesis":
                    estado = "ok (formato no estándar: paréntesis)"
                elif formato == "narrativa":
                    estado = "ok (formato no estándar: cita narrativa)"
                else:
                    estado = "ok"
        cita = {"cita": original, "estado": estado}
        citas.append(cita)
        if estado.startswith("inválida"):
            malas.append(cita)

    abstencion = es_abstencion(respuesta)
    validas = [c for c in citas if c["estado"].startswith("ok")]
    return {
        "n_citas": len(citas),
        "citas": citas,
        "citas_invalidas": malas,
        "citas_formato_no_estandar": [c for c in validas if c["estado"] != "ok"],
        "sin_citas": (len(validas) == 0 and not abstencion),
        "abstencion_mixta": (not abstencion) and normalizar(ABSTENCION).rstrip(".") in normalizar(respuesta),
    }


def responder(pregunta: str, modelo: str = None, umbral: float = None, k: int = None,
              sin_razonamiento: bool = False, embeber=embeber_ollama, generar=generar_ollama,
              indice=None) -> dict:
    modelo = modelo or MODELO
    umbral = UMBRAL if umbral is None else umbral
    matriz, fragmentos = indice or cargar_indice()
    recuperados = recuperar(pregunta, matriz, fragmentos, embeber, k or TOP_K)
    mejor = recuperados[0]["similitud"] if recuperados else 0.0

    if mejor < umbral:
        respuesta, via = ABSTENCION, "umbral"
    else:
        usuario = f"Fragmentos del corpus:\n\n{construir_contexto(recuperados)}\n\nPregunta: {pregunta}"
        respuesta = quitar_razonamiento(generar(PROMPT_SISTEMA, usuario, modelo, sin_razonamiento))
        via = "modelo"

    abstuvo = es_abstencion(respuesta)
    return {
        "pregunta": pregunta,
        "respuesta": respuesta,
        "se_abstuvo": abstuvo,
        "via_abstencion": via if abstuvo else None,
        "modelo": modelo,
        "umbral": umbral,
        "k": k or TOP_K,
        "sin_razonamiento": sin_razonamiento,
        "similitud_max": round(mejor, 4),
        # Se guarda el TEXTO de cada fragmento: así se puede auditar después
        # qué vio el modelo, sin tener que volver a correr nada.
        "recuperados": [
            {k_: f[k_] for k_ in ("archivo", "apellido", "anio", "ubicacion", "texto")}
            | {"similitud": round(f["similitud"], 4)}
            for f in recuperados
        ],
        "verificacion_citas": verificar_citas(respuesta, recuperados),
    }


# ---------------------------------------------------------------------------
# 3. Evaluar con el banco de preguntas
# ---------------------------------------------------------------------------

def etiqueta(correcta):
    return "manual" if correcta is None else ("ok" if correcta else "REVISAR")


def metadatos_corrida(modelo: str, umbral: float, k: int, sin_razonamiento: bool,
                     dir_indice: Path = DIR_INDICE) -> dict:
    meta_indice = {}
    if (dir_indice / "meta.json").exists():
        meta_indice = json.loads((dir_indice / "meta.json").read_text(encoding="utf-8"))
    return {
        "version_rag": VERSION,
        "fecha": datetime.now().isoformat(timespec="seconds"),
        "modelo": modelo,
        "digest_modelo": digest_modelo(modelo),
        "modelo_embeddings": MODELO_EMBEDDINGS,
        "digest_embeddings": digest_modelo(MODELO_EMBEDDINGS),
        "sin_razonamiento": sin_razonamiento,
        "temperatura": 0,
        "umbral": umbral,
        "k": k,
        "sha256_fragmentos": sha256_archivo(dir_indice / "fragmentos.json"),
        "sha256_vectores": sha256_archivo(dir_indice / "vectores.npy"),
        "sha256_banco": sha256_archivo(ARCHIVO_BANCO),
        "sha256_fuentes": sha256_archivo(ARCHIVO_FUENTES),
        "indice": meta_indice,
    }


def evaluar(modelo: str = None, umbral: float = None, sin_razonamiento: bool = False,
            embeber=embeber_ollama, generar=generar_ollama, indice=None,
            dir_resultados: Path = DIR_RESULTADOS, dir_indice: Path = DIR_INDICE) -> Path:
    with open(ARCHIVO_BANCO, encoding="utf-8") as f:
        banco = json.load(f)["preguntas"]
    indice = indice or cargar_indice(dir_indice)
    modelo = modelo or MODELO
    umbral = UMBRAL if umbral is None else umbral
    corrida = metadatos_corrida(modelo, umbral, TOP_K, sin_razonamiento, dir_indice)
    filas = []
    for p in banco:
        r = responder(p["pregunta"], modelo, umbral, None, sin_razonamiento, embeber, generar, indice)
        # P4 es una abstención parcial (el dato está en otro documento del DANE):
        # su conducta no se puede juzgar automáticamente.
        esperado_abst = {"sin_respuesta": True, "con_respuesta": False}.get(p["tipo"])
        filas.append(r | {
            "id": p["id"],
            "tipo": p["tipo"],
            "respuesta_conocida": p.get("respuesta_conocida"),
            # Chequeo automático solo de la CONDUCTA (abstenerse o no).
            # La fidelidad del contenido la califica una persona.
            "conducta_correcta_auto": None if esperado_abst is None else r["se_abstuvo"] == esperado_abst,
            "fiel": None, "califico": None, "fecha_calificacion": None,
        })
        v = r["verificacion_citas"]
        print(f"{p['id']:>3}  sim={r['similitud_max']:.3f}  "
              f"{'ABSTIENE' if r['se_abstuvo'] else 'RESPONDE'}  "
              f"{etiqueta(filas[-1]['conducta_correcta_auto'])}"
              + ("  ¡ABSTENCIÓN MEZCLADA CON CONTENIDO!" if v["abstencion_mixta"] else ""))

    dir_resultados.mkdir(parents=True, exist_ok=True)
    sello = datetime.now().strftime("%Y-%m-%d_%H%M")
    nombre = f"evaluacion_{re.sub(r'[^A-Za-z0-9.]+', '-', modelo)}_v{VERSION}_{sello}"
    with open(dir_resultados / f"{nombre}.json", "w", encoding="utf-8") as f:
        json.dump({"corrida": corrida, "filas": filas}, f, ensure_ascii=False, indent=1)

    juzgables = [f for f in filas if f["conducta_correcta_auto"] is not None]
    ok = sum(f["conducta_correcta_auto"] for f in juzgables)
    citas_malas = sum(len(f["verificacion_citas"]["citas_invalidas"]) for f in filas)
    formato = sum(len(f["verificacion_citas"]["citas_formato_no_estandar"]) for f in filas)
    sin_citas = [f["id"] for f in filas if f["verificacion_citas"]["sin_citas"]]
    mixtas = [f["id"] for f in filas if f["verificacion_citas"]["abstencion_mixta"]]
    c = corrida
    lineas = [
        f"# Evaluación del RAG propio — {modelo} (rag.py v{VERSION})",
        "",
        f"- Fecha: {c['fecha']}",
        f"- Modelo generador: `{modelo}` (digest `{(c['digest_modelo'] or 'no disponible')[:12]}`) · "
        f"razonamiento {'desactivado' if sin_razonamiento else 'activado'} · temperatura 0",
        f"- Embeddings: `{MODELO_EMBEDDINGS}` (digest `{(c['digest_embeddings'] or 'no disponible')[:12]}`) · "
        f"umbral {umbral} · k = {TOP_K}",
        f"- Índice: {c['indice'].get('n_fragmentos', '?')} fragmentos · sha256 fragmentos `{(c['sha256_fragmentos'] or '?')[:12]}`",
        "",
        "## Resumen automático",
        "",
        f"- **Conducta** (abstenerse / responder cuando corresponde): **{ok}/{len(juzgables)}** (P4 se califica a mano)",
        f"- **Citas inválidas** (no apuntan a un fragmento recuperado): **{citas_malas}**",
        f"- **Citas válidas en formato no estándar** (autor abreviado, alias, paréntesis, número de fragmento): **{formato}**",
        f"- **Respuestas sin ninguna cita válida** (sin contar abstenciones): **{len(sin_citas)}**" + (f" ({', '.join(sin_citas)})" if sin_citas else ""),
        f"- **Abstenciones mezcladas con contenido**: **{len(mixtas)}**" + (f" ({', '.join(mixtas)})" if mixtas else ""),
        "",
        "> Conducta, formato de cita y fidelidad son cosas distintas. Lo automático solo mide las dos primeras.",
        "> La **fidelidad** la califica una persona contra el texto de los fragmentos (incluido abajo): llenar Fiel, Calificó y Fecha.",
        "",
        "| ID | Tipo | Sim. máx. | Conducta | Citas inválidas | Formato no estándar | Sin cita | Fiel (S/P/N) | Calificó | Fecha |",
        "|---|---|---|---|---|---|---|---|---|---|",
    ]
    for f in filas:
        v = f["verificacion_citas"]
        lineas.append(
            f"| {f['id']} | {f['tipo']} | {f['similitud_max']:.3f} | "
            f"{'abstiene' if f['se_abstuvo'] else 'responde'} ({etiqueta(f['conducta_correcta_auto'])}) | "
            f"{len(v['citas_invalidas'])} | {len(v['citas_formato_no_estandar'])} | "
            f"{'sí' if v['sin_citas'] else 'no'} |  |  |  |")
    lineas += ["", "## Respuestas", ""]
    for f in filas:
        v = f["verificacion_citas"]
        lineas += [
            f"### {f['id']}. {f['pregunta']}",
            f"- **Respuesta conocida:** {f['respuesta_conocida'] or '— (debe abstenerse)'}",
            f"- **Respuesta del sistema:** {f['respuesta']}",
        ]
        if v["citas"]:
            lineas.append("- **Citas:** " + "; ".join(f"`{x['cita']}` → {x['estado']}" for x in v["citas"]))
        lineas += ["", "<details><summary>Fragmentos que vio el modelo</summary>", ""]
        for n, r in enumerate(f["recuperados"], 1):
            texto = r["texto"].replace("\n", " ")
            lineas.append(f"**[{n}] {r['apellido']} {r['anio']}, {r['ubicacion']} (sim. {r['similitud']:.3f})** — {texto}")
            lineas.append("")
        lineas += ["</details>", ""]
    salida = dir_resultados / f"{nombre}.md"
    salida.write_text("\n".join(lineas), encoding="utf-8")
    print(f"\nConducta (auto): {ok}/{len(juzgables)} · citas inválidas: {citas_malas} · "
          f"formato no estándar: {formato} · sin cita: {len(sin_citas)}")
    print(f"Resultados: {salida}")
    return salida


def calibrar(embeber=embeber_ollama, indice=None) -> float | None:
    """Solo recuperación (sin modelo generador): muestra la similitud máxima de
    cada pregunta del banco y sugiere un umbral entre los dos grupos.

    Ojo: calibrar con el mismo banco que luego se evalúa sobreajusta el umbral.
    Hay que declararlo, o calibrar con preguntas distintas.
    """
    with open(ARCHIVO_BANCO, encoding="utf-8") as f:
        banco = json.load(f)["preguntas"]
    matriz, fragmentos = indice or cargar_indice()
    grupos = {"con_respuesta": [], "sin_respuesta": []}
    for p in banco:
        mejor = recuperar(p["pregunta"], matriz, fragmentos, embeber, 1)[0]
        print(f"{p['id']:>3}  {p['tipo']:<18}  sim={mejor['similitud']:.3f}  → {mejor['apellido']}, {mejor['ubicacion']}")
        if p["tipo"] in grupos:
            grupos[p["tipo"]].append(mejor["similitud"])
    lo, hi = min(grupos["con_respuesta"]), max(grupos["sin_respuesta"])
    if lo > hi:
        sugerido = round((lo + hi) / 2, 3)
        print(f"\nLos grupos se separan: umbral sugerido = {sugerido} (entre {hi:.3f} y {lo:.3f})")
        return sugerido
    print(f"\nLos grupos se solapan (mín. con respuesta {lo:.3f} ≤ máx. sin respuesta {hi:.3f}).")
    print("Ningún umbral separa todo: la abstención dependerá también del modelo (regla 3 del prompt).")
    return None


def manifiesto(dir_corpus: Path = DIR_CORPUS, dir_indice: Path = DIR_INDICE,
               salida: Path = RAIZ / "corpus" / "MANIFIESTO.md") -> Path:
    """Escribe corpus/MANIFIESTO.md: huella (SHA-256), páginas, caracteres extraídos y
    fragmentos de cada archivo indexado. Permite comprobar después que el corpus es el mismo."""
    fuentes = cargar_fuentes()
    fragmentos = []
    if (dir_indice / "fragmentos.json").exists():
        fragmentos = json.loads((dir_indice / "fragmentos.json").read_text(encoding="utf-8"))
    lineas = [
        "# Manifiesto del corpus indexado",
        "",
        f"Generado con `python rag.py manifiesto` el {datetime.now().isoformat(timespec='minutes')} (rag.py v{VERSION}).",
        "Los archivos no se suben al repositorio; este manifiesto permite verificar que el corpus local es el mismo.",
        "",
        "| Archivo | Cita | SHA-256 (12) | Páginas o secciones | Caracteres extraídos | Fragmentos | Texto completo o resumen |",
        "|---|---|---|---|---|---|---|",
    ]
    for ruta in sorted(p for p in dir_corpus.glob("*") if p.suffix.lower() in {".pdf", ".md", ".txt"}):
        ficha = fuentes.get(ruta.name)
        partes = leer_documento(ruta)
        chars = sum(len(t) for _, t in partes)
        n_frag = sum(1 for f in fragmentos if f["archivo"] == ruta.name)
        cita = f"{ficha['apellido']}, {ficha['anio']}" if ficha else "**sin ficha: no indexado**"
        lineas.append(f"| `{ruta.name}` | {cita} | `{sha256_archivo(ruta)[:12]}` | {len(partes)} | {chars:,} | {n_frag} | (anotar) |")
    lineas += ["", f"Total de fragmentos en el índice: {len(fragmentos)}.", ""]
    salida.write_text("\n".join(lineas), encoding="utf-8")
    print(f"Manifiesto escrito en {salida}")
    return salida


def reverificar(ruta_json: Path) -> dict:
    """Vuelve a pasar el verificador actual sobre las respuestas YA guardadas de
    una evaluación (no llama a ningún modelo: las respuestas no cambian)."""
    datos = json.loads(Path(ruta_json).read_text(encoding="utf-8"))
    filas = datos["filas"] if isinstance(datos, dict) else datos
    resumen = {"invalidas": 0, "formato_no_estandar": 0, "sin_cita": [], "abstencion_mixta": []}
    for f in filas:
        v = verificar_citas(f["respuesta"], f["recuperados"])
        resumen["invalidas"] += len(v["citas_invalidas"])
        resumen["formato_no_estandar"] += len(v["citas_formato_no_estandar"])
        if v["sin_citas"]:
            resumen["sin_cita"].append(f["id"])
        if v["abstencion_mixta"]:
            resumen["abstencion_mixta"].append(f["id"])
        for c in v["citas"]:
            print(f"{f['id']:>3}  {c['cita']}  →  {c['estado']}")
    print(f"\nVerificador v{VERSION} sobre {Path(ruta_json).name}: "
          f"citas inválidas {resumen['invalidas']} · formato no estándar {resumen['formato_no_estandar']} · "
          f"sin cita {resumen['sin_cita'] or 'ninguna'} · abstención mezclada {resumen['abstencion_mixta'] or 'ninguna'}")
    return resumen


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main(argv=None):
    ap = argparse.ArgumentParser(description="RAG propio — Nada sin fuente")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("indexar", help="Lee corpus/papers y construye el índice")
    sub.add_parser("calibrar", help="Similitudes del banco y umbral sugerido (sin modelo generador)")
    sub.add_parser("manifiesto", help="Escribe corpus/MANIFIESTO.md (huella, páginas y fragmentos de cada archivo)")
    rv = sub.add_parser("reverificar", help="Re-aplica el verificador de citas a un .json de resultados ya guardado")
    rv.add_argument("archivo_json")
    p = sub.add_parser("preguntar", help="Hace una pregunta al corpus")
    p.add_argument("pregunta")
    e = sub.add_parser("evaluar", help="Corre el banco de preguntas")
    for s in (p, e):
        s.add_argument("--modelo", default=None, help=f"Modelo de Ollama (por defecto {MODELO})")
        s.add_argument("--umbral", type=float, default=None, help=f"Similitud mínima (por defecto {UMBRAL})")
        s.add_argument("--sin-razonamiento", action="store_true",
                       help="Desactiva el modo 'thinking' (útil con Qwen 3.x)")
    p.add_argument("--k", type=int, default=None, help=f"Fragmentos a recuperar (por defecto {TOP_K})")
    p.add_argument("--json", action="store_true", help="Imprime el resultado completo en JSON")
    a = ap.parse_args(argv)

    if a.cmd == "indexar":
        indexar()
    elif a.cmd == "calibrar":
        calibrar()
    elif a.cmd == "manifiesto":
        manifiesto()
    elif a.cmd == "reverificar":
        reverificar(Path(a.archivo_json))
    elif a.cmd == "preguntar":
        r = responder(a.pregunta, a.modelo, a.umbral, a.k, a.sin_razonamiento)
        if a.json:
            print(json.dumps(r, ensure_ascii=False, indent=1))
        else:
            print(r["respuesta"])
            print(f"\n— similitud máx. {r['similitud_max']} · modelo {r['modelo']}")
            for c in r["verificacion_citas"]["citas"]:
                print(f"  {c['cita']}: {c['estado']}")
    elif a.cmd == "evaluar":
        evaluar(a.modelo, a.umbral, a.sin_razonamiento)


if __name__ == "__main__":
    main()
