"""RAG propio de "Nada sin fuente".

Pipeline completo y local:
    PDFs/MD del corpus -> fragmentos con página -> embeddings (Ollama)
    -> índice en disco (numpy) -> recuperación por similitud coseno
    -> respuesta del modelo con cita obligatoria -> verificación de citas.

Uso (desde nada-sin-fuente/sistema/):
    python rag.py indexar
    python rag.py calibrar
    python rag.py preguntar "¿Qué estructura tiene el IPM censal del DANE?"
    python rag.py evaluar

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

ABSTENCION = "No encuentro esto en las fuentes del corpus."

PROMPT_SISTEMA = f"""Eres un asistente de investigación que responde EXCLUSIVAMENTE con base en los fragmentos del corpus que se te entregan. No completas información con conocimiento general ni con memoria propia.

Reglas:
1. Toda afirmación lleva cita con el formato [Apellido, año, p. X], usando SOLO el apellido, año y página que aparecen en la cabecera de cada fragmento.
2. Si la página no se puede determinar, usa [Apellido, año, ubicación no verificada].
3. Si los fragmentos no contienen la respuesta, responde únicamente: "{ABSTENCION}"
4. No inventes autores, años, páginas, cifras ni DOI. No cites fuentes que no estén en los fragmentos.
5. Responde en español, de forma breve."""


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


def construir_contexto(recuperados: list[dict]) -> str:
    bloques = []
    for i, f in enumerate(recuperados, 1):
        ubic = f["ubicacion"]
        cab = f"[Fragmento {i}] {f['apellido']}, {f['anio']}, " + (f"p. {ubic}" if ubic.isdigit() else ubic)
        bloques.append(f"{cab}\n{f['texto']}")
    return "\n\n".join(bloques)


def coincide_ubicacion(citada: str, recuperada: str) -> bool:
    """Página: igualdad exacta (o dentro de un rango "3-4"). Sección: el nombre aparece."""
    if recuperada.isdigit():
        paginas = re.findall(r"\d+", citada)
        if len(paginas) == 2 and re.search(r"\d+\s*[-–]\s*\d+", citada):
            return int(paginas[0]) <= int(recuperada) <= int(paginas[1])
        return paginas == [recuperada]
    return normalizar(citada).strip("«» ") in normalizar(recuperada)


PATRON_CITA = re.compile(r"\[([^\[\],]+?),\s*(\d{4}),\s*([^\]]+)\]")


def verificar_citas(respuesta: str, recuperados: list[dict]) -> dict:
    """Cada cita [Apellido, año, p. X] debe corresponder a un fragmento recuperado.

    Esto detecta citas inventadas (autor, año o página que no estaban en el
    contexto). No prueba que el contenido sea fiel: eso lo revisa una persona.
    """
    validas = {(normalizar(f["apellido"]), str(f["anio"]), f["ubicacion"]) for f in recuperados}
    autores = {(normalizar(f["apellido"]), str(f["anio"])) for f in recuperados}
    citas, malas = [], []
    for apellido, anio, ubic in PATRON_CITA.findall(respuesta):
        ubic = ubic.strip()
        pagina = re.sub(r"^p+\.\s*", "", ubic)
        clave_autor = (normalizar(apellido), anio)
        if clave_autor not in autores:
            estado = "autor/año no está en lo recuperado"
        elif "no verificada" in ubic:
            estado = "ok (ubicación no verificada)"
        elif any(coincide_ubicacion(pagina, v[2]) for v in validas if (v[0], v[1]) == clave_autor):
            estado = "ok"
        else:
            estado = "página/sección no está en lo recuperado"
        cita = {"cita": f"[{apellido}, {anio}, {ubic}]", "estado": estado}
        citas.append(cita)
        if not estado.startswith("ok"):
            malas.append(cita)
    abstencion = ABSTENCION.lower().rstrip(".") in respuesta.lower()
    return {
        "n_citas": len(citas),
        "citas": citas,
        "citas_invalidas": malas,
        "sin_citas": (len(citas) == 0 and not abstencion),
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

    abstuvo = ABSTENCION.lower().rstrip(".") in respuesta.lower()
    return {
        "pregunta": pregunta,
        "respuesta": respuesta,
        "se_abstuvo": abstuvo,
        "via_abstencion": via if abstuvo else None,
        "modelo": modelo,
        "umbral": umbral,
        "similitud_max": round(mejor, 4),
        "recuperados": [
            {k_: f[k_] for k_ in ("archivo", "apellido", "anio", "ubicacion")} | {"similitud": round(f["similitud"], 4)}
            for f in recuperados
        ],
        "verificacion_citas": verificar_citas(respuesta, recuperados),
    }


# ---------------------------------------------------------------------------
# 3. Evaluar con el banco de preguntas
# ---------------------------------------------------------------------------

def etiqueta(correcta):
    return "manual" if correcta is None else ("ok" if correcta else "REVISAR")


def evaluar(modelo: str = None, umbral: float = None, sin_razonamiento: bool = False,
            embeber=embeber_ollama, generar=generar_ollama, indice=None,
            dir_resultados: Path = DIR_RESULTADOS) -> Path:
    with open(ARCHIVO_BANCO, encoding="utf-8") as f:
        banco = json.load(f)["preguntas"]
    indice = indice or cargar_indice()
    modelo = modelo or MODELO
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
            # La fidelidad del contenido la califica una persona en el .md.
            "conducta_correcta_auto": None if esperado_abst is None else r["se_abstuvo"] == esperado_abst,
        })
        print(f"{p['id']:>3}  sim={r['similitud_max']:.3f}  "
              f"{'ABSTIENE' if r['se_abstuvo'] else 'RESPONDE'}  "
              f"{etiqueta(filas[-1]['conducta_correcta_auto'])}")

    dir_resultados.mkdir(parents=True, exist_ok=True)
    sello = datetime.now().strftime("%Y-%m-%d_%H%M")
    nombre = f"evaluacion_{re.sub(r'[^A-Za-z0-9.]+', '-', modelo)}_{sello}"
    with open(dir_resultados / f"{nombre}.json", "w", encoding="utf-8") as f:
        json.dump(filas, f, ensure_ascii=False, indent=1)

    juzgables = [f for f in filas if f["conducta_correcta_auto"] is not None]
    ok = sum(f["conducta_correcta_auto"] for f in juzgables)
    citas_malas = sum(len(f["verificacion_citas"]["citas_invalidas"]) for f in filas)
    sin_citas = sum(f["verificacion_citas"]["sin_citas"] for f in filas)
    lineas = [
        f"# Evaluación del RAG propio — {modelo}",
        "",
        f"- Fecha: {datetime.now().isoformat(timespec='minutes')}",
        f"- Modelo generador: `{modelo}` · Embeddings: `{MODELO_EMBEDDINGS}` · Umbral: {filas[0]['umbral']} · k = {TOP_K}",
        f"- Conducta correcta (abstenerse / responder), chequeo automático: **{ok}/{len(juzgables)}** (P4 se califica a mano)",
        f"- Citas que no corresponden a un fragmento recuperado: **{citas_malas}**",
        f"- Respuestas sin ninguna cita (y sin abstención): **{sin_citas}**",
        "",
        "> El chequeo automático solo mira si se abstuvo cuando debía y si las citas apuntan a fragmentos reales.",
        "> Que el contenido sea fiel lo califica una persona: llenar la columna **Fiel (S/N)**.",
        "",
        "| ID | Tipo | Sim. máx. | Conducta | Citas inválidas | Fiel (S/N) | Calificó |",
        "|---|---|---|---|---|---|---|",
    ]
    for f in filas:
        lineas.append(
            f"| {f['id']} | {f['tipo']} | {f['similitud_max']:.3f} | "
            f"{'abstiene' if f['se_abstuvo'] else 'responde'} ({etiqueta(f['conducta_correcta_auto'])}) | "
            f"{len(f['verificacion_citas']['citas_invalidas'])} |  |  |")
    lineas += ["", "## Respuestas", ""]
    for f in filas:
        lineas += [
            f"### {f['id']}. {f['pregunta']}",
            f"- **Respuesta conocida:** {f['respuesta_conocida'] or '— (debe abstenerse)'}",
            f"- **Respuesta del sistema:** {f['respuesta']}",
            "- **Fragmentos recuperados:** " + "; ".join(
                f"{r['apellido']} {r['anio']}, {r['ubicacion']} ({r['similitud']:.2f})" for r in f["recuperados"]),
        ]
        if f["verificacion_citas"]["citas_invalidas"]:
            lineas.append("- **Citas inválidas:** " + "; ".join(
                f"{c['cita']} → {c['estado']}" for c in f["verificacion_citas"]["citas_invalidas"]))
        lineas.append("")
    salida = dir_resultados / f"{nombre}.md"
    salida.write_text("\n".join(lineas), encoding="utf-8")
    print(f"\nConducta correcta (auto): {ok}/{len(juzgables)} · citas inválidas: {citas_malas}")
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


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main(argv=None):
    ap = argparse.ArgumentParser(description="RAG propio — Nada sin fuente")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("indexar", help="Lee corpus/papers y construye el índice")
    sub.add_parser("calibrar", help="Similitudes del banco y umbral sugerido (sin modelo generador)")
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
