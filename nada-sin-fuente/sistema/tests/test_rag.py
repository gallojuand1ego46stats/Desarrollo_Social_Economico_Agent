"""Pruebas del RAG sin Ollama (embeddings y modelo falsos).

Correr desde nada-sin-fuente/sistema/:
    python tests/test_rag.py          # sin instalar nada más
    python -m pytest tests            # si tienen pytest
"""

import hashlib
import json
import re
import sys
import tempfile
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import rag  # noqa: E402


def frag(archivo, apellido, anio, pagina, texto="texto"):
    return {"archivo": archivo, "apellido": apellido, "anio": anio, "ubicacion": str(pagina),
            "texto": texto, "similitud": 0.5}


ECK = "ferry-et-al_2023.pdf"
MON = "monsalvo-herrera-jimenez_2025.pdf"
BON = "bonet-moron_2006.pdf"
DANE = "dane_ipm_2018.pdf"

RECUP = [
    frag(ECK, "Eckersley et al.", 2023, 35),
    frag(ECK, "Eckersley et al.", 2023, 46),
    frag(MON, "Monsalvo Herrera y Jiménez", 2025, 4),
    frag(MON, "Monsalvo Herrera y Jiménez", 2025, 5),
    frag(BON, "Bonet-Morón", 2006, 8),
    frag(DANE, "DANE", 2020, 2),
]


def estados(respuesta, recuperados=RECUP):
    return [c["estado"] for c in rag.verificar_citas(respuesta, recuperados)["citas"]]


# --- Verificador: casos de la auditoría (tabla A4) -------------------------

def test_cita_estandar_ok():
    assert estados("Dato [Eckersley et al., 2023, p. 35].") == ["ok"]


def test_alias_ferry_ok():
    assert estados("Dato [Ferry et al., 2023, p. 35].") == ["ok (alias)"]


def test_alias_dane_2018_ok():
    assert estados("Dato [DANE, 2018, p. 2].") == ["ok (alias)"]


def test_autor_abreviado_ok():
    assert estados("Dato [Monsalvo, 2025, p. 4].") == ["ok (autor abreviado)"]


def test_lista_de_paginas_con_coma():
    assert estados("Dato [Monsalvo Herrera y Jiménez, 2025, p. 4, 5].") == ["ok"]


def test_lista_de_paginas_con_y():
    assert estados("Dato [Monsalvo Herrera y Jiménez, 2025, pp. 4 y 5].") == ["ok"]


def test_rango_de_paginas():
    assert estados("Dato [Monsalvo Herrera y Jiménez, 2025, pp. 4-5].") == ["ok"]


def test_dos_citas_en_un_corchete():
    assert estados("Dato [Eckersley et al., 2023, p. 35; Eckersley et al., 2023, p. 46].") == ["ok", "ok"]


def test_cita_entre_parentesis():
    assert estados("Dato (Bonet-Morón, 2006, p. 8).") == ["ok (formato no estándar: paréntesis)"]


def test_cita_narrativa():
    e = estados("Según Bonet-Morón (2006, p. 8), hay tres pilares.")
    assert len(e) == 1 and e[0].startswith("ok"), e


def test_cita_por_numero_de_fragmento():
    assert estados("Dato [Fragmento 6, p. 2].") == ["ok (formato no estándar: número de fragmento)"]


def test_autor_inventado_invalido():
    assert estados("Dato [Pérez, 2019, p. 4].") == ["inválida: autor/año no está en lo recuperado"]


def test_pagina_no_recuperada_invalida():
    assert estados("Dato [Eckersley et al., 2023, p. 99].") == ["inválida: página/sección no está en lo recuperado"]


def test_lista_con_una_pagina_no_recuperada_invalida():
    assert estados("Dato [Monsalvo Herrera y Jiménez, 2025, pp. 4 y 9].")[0].startswith("inválida")


def test_pagina_1_no_valida_pagina_12():
    r = [frag(ECK, "Eckersley et al.", 2023, 12)]
    assert estados("Dato [Eckersley et al., 2023, p. 1].", r)[0].startswith("inválida")


def test_sin_cita():
    v = rag.verificar_citas("Respuesta sin ninguna cita.", RECUP)
    assert v["sin_citas"] and v["n_citas"] == 0


def test_parentesis_sin_pagina_no_es_cita():
    # "(2012-2020)" o "(MPI)" no deben contarse como citas
    assert rag.verificar_citas("Contratos (2012-2020) y el índice (MPI).", RECUP)["n_citas"] == 0


# --- Abstención -------------------------------------------------------------

def test_abstencion_exacta():
    assert rag.es_abstencion("No encuentro esto en las fuentes del corpus.")
    assert rag.es_abstencion('  "No encuentro esto en las fuentes del corpus"  ')


def test_abstencion_mezclada_no_cuenta():
    r = "El presupuesto es 5 millones de euros. No encuentro esto en las fuentes del corpus."
    assert not rag.es_abstencion(r)
    v = rag.verificar_citas(r, RECUP)
    assert v["abstencion_mixta"] and v["sin_citas"]


# --- De punta a punta con modelo falso ---------------------------------------

def _emb(textos):
    out = np.zeros((len(textos), 256), dtype=np.float32)
    for i, t in enumerate(textos):
        for w in re.findall(r"\w+", rag.normalizar(t)):
            if len(w) > 3:
                out[i, int(hashlib.md5(w.encode()).hexdigest(), 16) % 256] += 1
    return out


def _indice():
    fr = [
        {"archivo": ECK, "apellido": "Eckersley et al.", "anio": 2023, "ubicacion": "35",
         "texto": "Analysed about 90,000 contracts awarded by local authorities in the United Kingdom."},
        {"archivo": BON, "apellido": "Bonet-Morón", "anio": 2006, "ubicacion": "8",
         "texto": "Tres pilares: equidad en transferencias, fortalecimiento tributario y eficiencia del gasto."},
    ]
    m = _emb([f["texto"] for f in fr])
    m /= np.linalg.norm(m, axis=1, keepdims=True)
    return m, fr


def test_cabecera_muestra_alias_regresion_p7():
    """P7: la pregunta dice 'Ferry'; la cabecera debe decirle al modelo que es el mismo documento."""
    vistos = {}

    def gen(sistema, usuario, modelo, sin):
        vistos["usuario"] = usuario
        return "Unos 90.000 contratos [Ferry et al., 2023, p. 35]."

    r = rag.responder("¿Cuántos contratos analizaron Ferry et al. (2023) en local authorities contracts?",
                      umbral=0.0, embeber=_emb, generar=gen, indice=_indice())
    assert "también citado como: Ferry et al., 2023" in vistos["usuario"]
    assert r["verificacion_citas"]["citas"][0]["estado"] == "ok (alias)"
    assert "texto" in r["recuperados"][0], "debe guardar el texto que vio el modelo"
    assert r["sin_razonamiento"] is False and r["k"] == rag.TOP_K


def test_evaluar_guarda_corrida_y_textos():
    def gen(sistema, usuario, modelo, sin):
        return "No encuentro esto en las fuentes del corpus."

    with tempfile.TemporaryDirectory() as d:
        salida = rag.evaluar(modelo="falso:1b", umbral=0.0, sin_razonamiento=True, embeber=_emb, generar=gen,
                             indice=_indice(), dir_resultados=Path(d), dir_indice=Path(d) / "no-existe")
        datos = json.loads(salida.with_suffix(".json").read_text(encoding="utf-8"))
        assert datos["corrida"]["sin_razonamiento"] is True
        assert datos["corrida"]["version_rag"] == rag.VERSION
        assert all("texto" in r for f in datos["filas"] for r in f["recuperados"])
        assert "Fragmentos que vio el modelo" in salida.read_text(encoding="utf-8")


if __name__ == "__main__":
    pruebas = [(n, f) for n, f in sorted(globals().items()) if n.startswith("test_") and callable(f)]
    fallas = 0
    for nombre, prueba in pruebas:
        try:
            prueba()
            print(f"ok     {nombre}")
        except Exception as e:  # noqa: BLE001
            fallas += 1
            print(f"FALLA  {nombre}: {e!r}")
    print(f"\n{len(pruebas) - fallas}/{len(pruebas)} pruebas pasaron")
    sys.exit(1 if fallas else 0)
