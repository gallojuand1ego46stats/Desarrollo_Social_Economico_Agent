# Caso de fallo

El sistema final elegido (NotebookLM) no presentó fallos
de citación en las 15 preguntas del banco de evaluación (ver
`banco_preguntas.md`). El caso de fallo documentado aquí corresponde a la
etapa de diagnóstico (Fase 1 del proyecto), no al sistema final construido —
una distinción que consideramos honesta reportar: el diagnóstico encontró
fallos reales en las herramientas evaluadas inicialmente (OpenCode), lo cual
precisamente justificó la elección de NotebookLM por su arquitectura de
anclaje más estricta.

**Caso seleccionado:** Fallo 2 del inventario — confusión entre dos datasets
reales de SECOP II (ver `inventario_fallos/inventario_juan_david.md`).

**Qué estaba mal:** Al preguntar por columnas típicas de SECOP II sin
especificar contexto, OpenCode (con búsqueda web) mezcló campos reales de dos
datasets distintos de Datos Abiertos Colombia ("Procesos SECOP 2" vs.
"SECOP II - Contratos Electrónicos"), entregando nombres de columnas que no
existen en el dataset que realmente usamos.

**Causa técnica:** Ambigüedad de recuperación — existiendo dos fuentes reales
con nombres casi idénticos, el sistema de búsqueda no distinguió cuál era la
relevante para el contexto del proyecto, y combinó ambas sin advertirlo.

**Cómo lo detectamos:** Comparando la respuesta contra el diccionario oficial
de 79 variables ya auditado en la Fase 2.

**Qué haríamos distinto:** Este hallazgo fue exactamente lo que nos llevó a
exigir, en el protocolo de prompts v1, que el sistema cite el documento
específico de origen y no solo "la web" en general — un requisito que
NotebookLM sí cumple por diseño, a diferencia de OpenCode.
