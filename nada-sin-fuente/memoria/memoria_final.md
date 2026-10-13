# Memoria final — Nada sin fuente

## 1. Diagnóstico

Se ejecutaron 16 pruebas dirigidas (9 en el eje de contratación y 7 en el de vulnerabilidad) para identificar fallos reales de las herramientas de IA que usábamos, antes de construir el sistema final. Los fallos se identifican por su código en los inventarios (JD = Juan David, JDi = Juan Diego):

1. **[JD-1] Referencias con metadatos incorrectos** (OpenCode con búsqueda conectada): de 5 referencias, 1 combinó un autor real con título, año y DOI de un documento distinto ("Santamarina" en vez de Marta Santamaría, 2023 en vez de 2025).
2. **[JD-2] Confusión entre dos datasets reales de SECOP II**: al pedir columnas típicas, el agente mezcló campos de "Procesos SECOP 2" y "Contratos Electrónicos" sin advertirlo.
3. **[JD-3] Bug de vectorización autocorregido** en código de bootstrap BCa (`mean` en vez de `rowMeans`): el propio agente lo detectó antes de entregar un resultado estadísticamente imposible (z₀ = −Inf).
4. **[JDi-1] Código institucional inventado**: ante una pregunta trampa sobre el NBI, el agente dio un código de documento del DANE que no existe, contradiciendo el código correcto que él mismo había dado antes (COM-030-PD-001-r-004, V8).

JD-2 y JD-3 ocurrieron en una sesión de trabajo compartida y aparecen en los dos inventarios como compartidos.

### Patrón observado: confiabilidad distinta según el dominio

En el eje de contratación (SECOP II), 3 de 9 pruebas (≈33 %) produjeron un fallo verificable; en el de vulnerabilidad (IPM/DANE), 1 de 7 (≈14 %). Con muestras tan pequeñas la diferencia no es una conclusión estadística, pero sugiere que la confiabilidad de un agente con búsqueda depende de qué tan documentado públicamente está el dominio: el DANE publica documentación extensa; la estructura de nuestro histórico de SECOP II, no.

## 2. Experimento

Se corrieron 2 de los 3 tratamientos que plantea la guía (A: control sin búsqueda; B: búsqueda conectada), con el mismo modelo (`qwen3.5:4b-mlx`) y consultas bibliográficas reales de los dos ejes:

| Tratamiento | n | Utilizables | Proporción | IC 95 % (Wilson) |
|---|---|---|---|---|
| A (sin búsqueda) | 10 | 0 | 0 % | [0 %, 27,8 %] |
| B (con búsqueda) | 10 | 9 | 90 % | [59,6 %, 98,2 %] |

Sin búsqueda, todas las referencias fueron inventadas. Con búsqueda, el 90 % fueron reales, pero no el 100 % (ver JD-1).

El tratamiento C (contexto cerrado) no se corrió con la misma consulta de "dame referencias", porque esa consulta no tiene sentido en un sistema que solo responde desde documentos cargados. Su evidencia son las evaluaciones del banco de preguntas (sección 4). Es una limitación que declaramos.

**Acuerdo entre clasificadores:** Juan David y Juan Diego clasificaron de forma independiente las mismas 10 referencias. Acuerdo observado 70 %; **κ de Cohen ≈ 0,52** (acuerdo moderado), con IC 95 % bootstrap aproximado [0,13; 0,82], muy amplio por n = 10. Las 3 discrepancias se concentraron en "existe pero no dice eso", la categoría más subjetiva.

## 3. El sistema

### 3.1 Versión 1: NotebookLM (vía empaquetada), hasta el 2026-10-06

Notebook con 10 documentos públicos: 8 de la matriz bibliográfica del Informe 1, la nota metodológica del DANE sobre el IPM censal y el README del repositorio público de referencia. Tres fuentes del Informe 1 quedaron fuera: Salazar et al. (2024), Gutiérrez Vanegas (2024) y Díaz Díez (2023). Protocolo de prompts v1.

### 3.2 Versión 2: RAG propio (vía propia), desde el 2026-10-13

Por orientación del profesor después de la sustentación, reemplazamos NotebookLM por un RAG propio (`sistema/rag.py`), porque con NotebookLM no podíamos ver ni controlar la recuperación, y la vía empaquetada limitaba la nota a 4,8.

- **Recuperación:** los documentos se parten en fragmentos de 900 caracteres con su página; embeddings `bge-m3` (multilingüe) en Ollama; índice local con numpy; se recuperan los 5 fragmentos más parecidos por similitud coseno. El corpus quedó en 834 fragmentos.
- **Generación:** `qwen3.5:4b-mlx` en Ollama, temperatura 0, protocolo de prompts v2: responder solo con los fragmentos, cita `[Apellido, año, p. X]` y abstención explícita.
- **Tres defensas:** contexto cerrado; umbral de similitud (0,45) que abstiene sin llamar al modelo; verificador que comprueba que cada cita apunte a un fragmento recuperado.
- **Corpus:** los mismos 10 documentos, vueltos a descargar el 2026-10-13. Varios ahora son texto completo donde NotebookLM tenía solo el resumen, así que los dos corpus no son idénticos.

## 4. Evaluación

Banco de 15 preguntas: 9 con respuesta conocida (P1–P9) y 6 sin respuesta en el corpus (A–F), corrido sobre los dos sistemas.

| | NotebookLM (v1) | RAG propio (v2) |
|---|---|---|
| Conducta correcta | 15/15 · [79,6 %, 100 %] | 14/15 · [70,2 %, 98,8 %] |
| Con respuesta | 9/9 | 8/9 · [56,5 %, 98,0 %] |
| Abstenciones | 6/6 | 6/6 · [61,0 %, 100 %] |
| Citas que no apuntan a un fragmento recuperado | no medible | 0 |
| Auditoría de qué texto usó | No | Sí |

Intervalos de Wilson al 95 %. Con n = 15 se solapan: **no podemos afirmar que un sistema sea mejor que el otro.** Lo que cambia es que en el RAG cada respuesta queda auditada (fragmentos, página y similitud) en `sistema/resultados/`.

**Hallazgos del RAG:**
- **El único fallo (P7)** fue una abstención falsa: la pregunta decía "Ferry et al." y el documento está registrado como "Eckersley et al." (autores según Crossref). Con el autor correcto respondió bien. Es un error por exceso de cautela, no una alucinación, y viene de un error de cita del Informe 1. Está documentado en `evaluacion/caso_de_fallo.md`.
- **El umbral no separa los grupos:** las similitudes de preguntas con respuesta (0,482–0,686) y sin respuesta (0,407–0,539) se solapan. Solo la pregunta E se abstuvo por umbral; las otras cinco abstenciones dependieron de que el modelo obedeciera el prompt. La similitud sola no basta para decidir cuándo abstenerse.
- **Respuestas fieles pero incompletas:** P3 (no menciona Moran, Queen ni las 999 permutaciones), P5 (falta el corte k = 33,3 %) y P9 (faltan las 264 entidades y el Poisson).
- **3 respuestas sin cita en el formato pedido** (P1, P3, P8). En P1 la cita era correcta pero en otro formato y el verificador no la reconoció: es una limitación del verificador.

**Límites de la evaluación:** n pequeño; banco escrito por el mismo equipo que armó el corpus; umbral fijado mirando el mismo banco; fidelidad calificada por los autores. La auditoría cruzada con un equipo par queda pendiente de la asignación del profesor.

## 5. Qué corregimos de nuestro propio anteproyecto

Al construir la tabla de trazabilidad (`tabla_trazabilidad.md`) revisamos 14 afirmaciones del Informe 1:

- **Verificación directa del contenido:** 5 (filas 4, 8, 10, 13, 14).
- **Solo contra NotebookLM:** 7 (filas 1, 2, 3, 5, 6, 7, 9). No cuentan como verificación independiente, porque NotebookLM era la herramienta evaluada.
- **Pendientes o parciales:** 2. Gutiérrez Vanegas (2024) no se ubicó; Díaz Díez (2023) existe, pero la frase "carácter transaccional" no se confirmó.
- **Errores del Informe 1 hallados:** "Arachia" debe ser **Arachi**; "Ferry et al. (2023), 57(11)" figura en Crossref como **Eckersley, Flynn, Lakoma y Ferry, 57(10)**. Este segundo error es justamente el que causó el fallo P7 del RAG.

## 6. Declaración de uso de IA

**Herramientas usadas:**
- Claude (Anthropic): diagnóstico, diseño del experimento, verificación de referencias, redacción y construcción del código del RAG propio.
- OpenCode y Ollama con `qwen3.5:4b-mlx`: objetos de prueba en el diagnóstico y el experimento.
- NotebookLM (Google): sistema versión 1.
- RAG propio con `bge-m3` y `qwen3.5:4b-mlx` en Ollama: sistema versión 2.

**Qué NO delegamos en la IA:** la verificación final de cada DOI y dato cuantitativo se contrastó contra fuentes primarias (páginas oficiales, Crossref, SciELO, abstracts originales), y la fidelidad de las respuestas del banco la calificamos nosotros.

**Qué tuvimos que corregir de lo que generó:**
- Un enlace a un documento del Banco de la República generado por Claude estaba mal formado y se corrigió tras verificar.
- El primer verificador de citas del RAG solo reconoce el formato `[Apellido, año, p. X]`; lo dejamos documentado como limitación en vez de ocultarlo.

**Verificaciones hechas por Claude el 2026-10-06:** metadatos de Eckersley et al. y Arachi et al. (Crossref), página de Salazar et al. y existencia de Díaz Díez. El equipo debe confirmarlas en las páginas de los editores.
