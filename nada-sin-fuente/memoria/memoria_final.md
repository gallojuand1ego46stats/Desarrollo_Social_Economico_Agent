# Memoria final — Nada sin fuente

## 1. Diagnóstico

Se ejecutaron 17 pruebas dirigidas sobre los dos ejes del proyecto para
identificar fallos reales de las herramientas de IA utilizadas, antes de
construir el sistema final. Se encontraron 4 fallos verificados:

1. **Referencias con metadatos incorrectos** (OpenCode, búsqueda conectada):
   de 5 referencias dadas, 1 combinó un autor real con título, año y DOI de
   un documento distinto.
2. **Confusión entre dos datasets reales de SECOP II**: al pedir columnas
   típicas del dataset, el sistema mezcló campos de "Procesos SECOP 2" y
   "Contratos Electrónicos" sin advertirlo.
3. **Bug de vectorización autocorregido** en código de bootstrap BCa: el
   propio agente detectó y corrigió un error que habría producido resultados
   estadísticamente imposibles (z₀ = −Inf).
4. **Inconsistencia entre respuestas propias**: el agente dio un código de
   documento institucional inventado, contradiciendo una respuesta correcta
   que él mismo había dado minutos antes para el mismo documento.

### Patrón observado: confiabilidad distinta según el dominio de la consulta

En el eje de contratación pública (SECOP II), 3 de 9 pruebas (≈33%)
produjeron un fallo verificable. En el eje de vulnerabilidad socioeconómica
(IPM/DANE), solo 1 de 7 pruebas (≈14%) produjo un fallo. Con un tamaño de
muestra tan pequeño, esta diferencia no permite una conclusión estadística
robusta, pero sugiere que la confiabilidad de un sistema con búsqueda
conectada depende de qué tan bien documentado públicamente está el dominio
consultado — el DANE publica documentación extensa y bien indexada; la
estructura específica de nuestro propio histórico de SECOP II, no.

## 2. Experimento y decisión

Se ejecutó un experimento de 2 tratamientos (control sin búsqueda vs.
búsqueda conectada) sobre consultas bibliográficas reales de ambos
integrantes:

| Tratamiento | n | Utilizables | Proporción | IC 95% |
|---|---|---|---|---|
| A (sin búsqueda) | 10 | 0 | 0% | [0%, 27.8%] |
| B (con búsqueda) | 10 | 9 | 90% | [59.6%, 98.2%] |

La diferencia es contundente pese al tamaño de muestra pequeño por consulta:
sin ninguna herramienta de búsqueda, el 100% de las referencias dadas fueron
inventadas. Con búsqueda conectada, la tasa de referencias reales subió a
90%, aunque no llegó al 100% (ver Fallos 1 y 4).

Un segundo ejercicio midió el acuerdo de clasificación entre los dos
integrantes sobre 10 referencias comunes, clasificadas de forma
independiente: **70% de acuerdo**, con las 3 discrepancias concentradas en
la categoría "existe pero no dice eso" — la más subjetiva de las tres.

**Herramienta elegida:** NotebookLM (vía empaquetada), por su capacidad de
anclaje con cita de ubicación exacta, frente a OpenCode, que aunque cuenta
con búsqueda conectada, no garantiza contexto cerrado ni citación verificable
de forma consistente (ver Fallos 1 y 4).

## 3. El sistema

Se construyó un notebook en NotebookLM con 11 fuentes públicas de la matriz
bibliográfica del estado del arte del proyecto (Informe 1), más la nota
metodológica del DANE sobre el IPM censal municipal. Dos fuentes (Salazar et
al., 2024; Díaz Díez, 2023) quedaron pendientes de incorporar por
restricciones de acceso/tiempo.

El protocolo de prompts (v1, versionado en `protocolo_prompts/`) exige
respuesta basada únicamente en las fuentes cargadas, cita con documento y
ubicación, y abstención explícita cuando la información no está disponible.

## 4. Evaluación

Se construyó un banco de 15 preguntas (11 con respuesta conocida, 4 sin
respuesta en el corpus) para evaluar la fidelidad del sistema final.
**Resultado: 15 de 15 correctas** — 0 fallos de citación en las preguntas con
respuesta, y abstención correcta en las 4 preguntas sin respuesta (superando
el mínimo de 3 exigido). Dos de las abstenciones (Salazar et al., Díaz Díez)
correspondieron correctamente a fuentes que nunca se incorporaron al corpus,
confirmando que el sistema no inventa contenido ni cuando podría parecer
plausible hacerlo.

El caso de fallo documentado corresponde a la etapa de diagnóstico (ver
`caso_de_fallo.md`), dado que el sistema final no presentó fallos en la
evaluación directa.

La auditoría cruzada con un equipo par queda pendiente de la asignación del
profesor en la semana 3.

## 5. Qué corrigieron de su propio anteproyecto

Al construir la tabla de trazabilidad (`tabla_trazabilidad.md`) se verificó
cada afirmación sustantiva del estado del arte del Informe 1 contra su fuente
original. No se identificaron afirmaciones sin respaldo — las 14 citas
revisadas se sostienen en sus fuentes correspondientes.

## 6. Declaración de uso de IA

**Herramientas usadas:** Claude (Anthropic) para diagnóstico, diseño del
experimento, verificación de referencias y redacción; OpenCode (modelo local
qwen2.5-coder vía Ollama) como una de las herramientas evaluadas en el
diagnóstico; NotebookLM (Google) como sistema final de anclaje documental.

**Para qué las usamos:**
- Gestión de fuentes: NotebookLM
- Verificación de referencias y hallazgos: Claude, con búsqueda web, contrastando cada DOI y dato específico contra fuentes primarias
- Redacción de la memoria: Claude, a partir de los datos y hallazgos generados en el proceso
- Diagnóstico de fallos: OpenCode y Ollama puro, como objetos de prueba

**Herramienta de gestión elegida:** NotebookLM, frente a OpenCode y un
proyecto con archivos de Claude, por su capacidad de anclaje con cita de
ubicación exacta.

**Qué NO usamos IA para:** La verificación final de cada DOI y dato
cuantitativo se contrastó contra fuentes primarias (páginas oficiales,
Crossref, Scielo, abstracts originales), no se aceptó ninguna afirmación de
una IA sin esa verificación independiente.

**Qué tuvimos que corregir de lo que generó:** Un enlace a un documento del
Banco de la República generado por Claude resultó incorrecto en un primer
intento (URL mal formada) y se corrigió tras verificación — documentado aquí
como evidencia adicional de que ninguna fuente de IA se acepta sin verificar,
ni siquiera las de apoyo en la propia elaboración de este trabajo.