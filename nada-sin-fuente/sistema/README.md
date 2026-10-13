# Sistema — RAG propio (vía propia)

Reemplaza a NotebookLM (vía empaquetada) como sistema final, por orientación del profesor. NotebookLM queda documentado como la primera versión y como punto de comparación: se corre el **mismo banco de 15 preguntas** sobre los dos.

Todo corre local en el Mac: Ollama (modelo generador + modelo de embeddings), índice en disco con numpy. No hay claves ni servicios externos.

## Cómo funciona

```
corpus/papers/*.pdf|.md
   → texto por página (pypdf)                          rag.py: leer_documento
   → fragmentos de 900 caracteres, solape de 150       rag.py: fragmentar
   → embeddings con Ollama (bge-m3, multilingüe)       rag.py: indexar
   → índice en sistema/indice/ (vectores.npy + fragmentos.json)
pregunta
   → embedding → similitud coseno → top-5 fragmentos   rag.py: recuperar
   → si la similitud máxima < umbral: se abstiene sin llamar al modelo
   → si no: el modelo responde SOLO con esos fragmentos, cita [Apellido, año, p. X]
   → verificador: cada cita debe apuntar a un fragmento recuperado   rag.py: verificar_citas
```

Las tres defensas contra la alucinación, y qué familia atacan:

| Defensa | Dónde | Familia que ataca |
|---|---|---|
| Contexto cerrado: el modelo solo ve fragmentos del corpus | `responder` + `PROMPT_SISTEMA` | Búsqueda (inventar fuentes) |
| Umbral de similitud: si nada se parece a la pregunta, se abstiene sin preguntarle al modelo | `UMBRAL` | Búsqueda / abstención |
| Verificador de citas: marca citas con autor, año o página que no estaban en lo recuperado | `verificar_citas` | Anclaje (citas deformadas) |

El verificador comprueba que la cita **apunte** a un fragmento real; no comprueba que el contenido sea fiel. Eso lo califica una persona en el reporte de evaluación.

## Instalación (una vez, en el Mac)

```bash
cd nada-sin-fuente/sistema
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

ollama pull bge-m3            # embeddings (multilingüe: preguntas en español, papers en inglés)
ollama pull qwen3.5:4b        # modelo generador (final)
```

## Poner el corpus

Copiar los 10 archivos del corpus (los mismos que se subieron a NotebookLM) a `nada-sin-fuente/corpus/papers/`, con **exactamente** los nombres de `corpus/README_PROCEDENCIA.md`:

```
ardila-rueda_2004.pdf            bonet-moron_2006.pdf
arachi-et-al_2024.pdf            ferry-et-al_2023.pdf
sarter_2024.pdf                  rodriguez-plesa-et-al_2022.pdf
figueroa-gomez-galpin_2024.pdf   monsalvo-herrera-jimenez_2025.pdf
dane_ipm_2018.pdf                repo_desarrollo_social_y_economico.md
```

Si un archivo tiene otro nombre, se renombra o se ajusta `fuentes.json`. Un archivo que no esté en `fuentes.json` **no se indexa** (el sistema avisa). Esa carpeta no se sube a GitHub (derechos de las editoriales; ver `.gitignore`).

Si un PDF es escaneado (imagen), pypdf no extrae texto y ese documento queda vacío: revisar el conteo de fragmentos que imprime `indexar`.

## Uso

```bash
python rag.py indexar                       # construye el índice (repetir si cambia el corpus)
python rag.py calibrar                      # similitudes del banco y umbral sugerido (no usa el modelo generador)
python rag.py preguntar "¿Qué estructura tiene el IPM censal municipal del DANE?"
python rag.py evaluar                       # corre las 15 preguntas y escribe el reporte
```

`evaluar` deja en `sistema/resultados/` un `.json` con todo y un `.md` con la tabla para calificar a mano la columna **Fiel (S/N)**. Ese `.md` es la evidencia que va a la memoria.

## Cambiar de modelo

No hay que tocar el código:

```bash
python rag.py evaluar --sin-razonamiento                 # modelo por defecto: qwen3.5:4b
python rag.py evaluar --modelo qwen2.5-coder             # otro modelo, sin tocar el código
# o para toda la sesión:
export RAG_MODELO=qwen3.5:4b
```

`--sin-razonamiento` apaga el modo "thinking" de Qwen 3.x (más rápido y sin texto extra). Cada evaluación queda en un archivo con el nombre del modelo, así que los resultados de modelos distintos no se mezclan.

## Parámetros

| Variable de entorno | Por defecto | Qué controla |
|---|---|---|
| `RAG_MODELO` | `qwen3.5:4b` | Modelo generador de Ollama |
| `RAG_EMBEDDINGS` | `bge-m3` | Modelo de embeddings (si se cambia, hay que volver a indexar) |
| `RAG_TOP_K` | `5` | Fragmentos que se le pasan al modelo |
| `RAG_UMBRAL` | `0.45` | Similitud mínima para intentar responder |

El umbral de 0,45 es un punto de partida, no un valor medido. Se ajusta con `calibrar`. Calibrarlo con el mismo banco que luego se evalúa lo sobreajusta: si se hace así, hay que declararlo en la memoria.

## Importante

- Ninguna clave dentro del código.
- No se reproduce el fragmento con credenciales del README del repo anterior (ver `corpus/README_PROCEDENCIA.md`): revisar que `repo_desarrollo_social_y_economico.md` no las contenga antes de indexar.
