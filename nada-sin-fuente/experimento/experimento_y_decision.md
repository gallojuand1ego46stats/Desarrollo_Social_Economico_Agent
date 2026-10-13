# Experimento y decisión

## 1. Diseño del experimento

Cada integrante corrió una consulta bibliográfica real de su eje, en dos tratamientos formales:

| Tratamiento | Qué representa | Herramienta usada |
|---|---|---|
| A (control) | Chat sin fuentes ni navegación | Ollama + `qwen2.5-coder` (`ollama run qwen2.5-coder`), sin plugins ni búsqueda |
| B (búsqueda) | Buscador conectado a bases bibliográficas reales | OpenCode (modelo `qwen2.5-coder` vía Ollama), con búsqueda web activa |

### Consulta utilizada (Juan David — eje de contratación)
> "Dame 5 referencias académicas, con DOI, sobre la relación entre
> contratación pública electrónica y reducción de la desigualdad territorial
> en países en desarrollo."

### Consulta de Juan / David (eje de vulnerabilidad / IPM)
Juan Diego definió y ejecutó su propia consulta bibliográfica del eje de
vulnerabilidad (IPM/DANE) con el mismo protocolo: 5 referencias con DOI por
tratamiento (A y B). Sus resultados están en la tabla de la sección 2. David
Sánchez participó en la discusión y revisión del equipo, no ejecutó una consulta
propia.

### 1.1 Sobre el tratamiento C (contexto cerrado con los PDF propios)
La guía de la actividad plantea tres tratamientos. **Corrimos solo dos (A y B)
con consulta bibliográfica**, por restricción de tiempo. El tratamiento C no se
ejecutó con la misma consulta de "dame 5 referencias": ese pedido no tiene
sentido en un sistema de contexto cerrado, que solo puede responder desde los
documentos cargados. Lo que sí hicimos es evaluar ese enfoque de contexto
cerrado sobre NotebookLM con el banco de 15 preguntas (`evaluacion/banco_preguntas.md`:
9 con respuesta y 6 abstenciones, todas correctas). Es evidencia sustituta, no
equivalente: no se midió la misma tarea en los tres tratamientos.

## 2. Tabla de conteos

| Consulta | Tratamiento | Utilizable | Existe pero no dice eso | No existe | Total revisadas |
|---|---|---|---|---|---|
| Juan David (contratación) | A | 0 | 0 | 5 | 5 |
| Juan David (contratación) | B | 4 | 1 | 0 | 5 |
| Juan Diego (vulnerabilidad/IPM) | A | 0 | 0 | 5 | 5 |
| Juan Diego (vulnerabilidad/IPM) | B | 5 | 0 | 0 | 5 |

## 3. Proporción de utilizables por tratamiento, con intervalo de confianza

| Tratamiento | n | Utilizables | Proporción | IC 95% (Wilson) |
|---|---|---|---|---|
| A (sin búsqueda, ambos integrantes) | 10 | 0 | 0% | [0%, 27.8%] |
| B (con búsqueda, ambos integrantes) | 10 | 9 | 90% | [59.6%, 98.2%] |

> Interpretación: el patrón es idéntico en los dos ejes del proyecto (0% sin
> búsqueda, 80-100% con búsqueda), lo que da mayor solidez a la conclusión
> pese al tamaño de muestra pequeño por consulta individual. Agrupando ambos
> integrantes (n=10 por tratamiento), el intervalo de confianza del
> Tratamiento A ni siquiera se acerca a superponerse con el de B — evidencia
> fuerte de que la búsqueda conectada mejora sustancialmente la tasa de
> referencias reales, aunque no la garantiza al 100% (ver fallos JD-1 y JDi-1 en los inventarios).

## 4. Acuerdo de clasificación (Juan David vs. Juan Diego)

Juan David y Juan Diego clasificaron las mismas 10 referencias por separado, sin consultarse
(Juan Diego clasificó a ciegas, solo con los DOI, sin ver títulos ni la
clasificación previa de Juan David).

| # | Juan David | Juan Diego  David Sanchez| Coincide |
|---|---|---|---|
| 1 | Utilizable | Utilizable | Sí |
| 2 | Existe pero no dice eso | Utilizable | No |
| 3 | Utilizable | Utilizable | Sí |
| 4 | Utilizable | Utilizable | Sí |
| 5 | Utilizable | Utilizable | Sí |
| 6 | No existe | No existe | Sí |
| 7 | No existe | Existe pero no dice eso | No |
| 8 | No existe | No existe | Sí |
| 9 | No existe | Existe pero no dice eso | No |
| 10 | No existe | No existe | Sí |

**Acuerdo observado: 7/10 (70%)**

**Corrección por azar (kappa de Cohen):** el 70% no descuenta el acuerdo esperado
por casualidad. Con las marginales de las dos tablas (Juan David: 4 Utilizable,
1 Existe pero no dice eso, 5 No existe; Juan Diego: 5, 2, 3), el acuerdo esperado
por azar es p_e = 0,37 y **κ = (0,70 − 0,37)/(1 − 0,37) ≈ 0,52**, acuerdo
moderado (escala de Landis y Koch). Con solo 10 ítems la incertidumbre es grande:
un bootstrap percentil da un IC 95% aproximado de [0,13, 0,82]. Se reporta como
dato exploratorio, no como medida precisa.

**¿En qué categoría se concentró el desacuerdo?** En los 3 casos de
discrepancia, al menos uno de los dos clasificadores usó la categoría "Existe
pero no dice eso" — ninguna discrepancia ocurrió entre "Utilizable" y "No
existe" directamente. Esto es consistente con que la categoría intermedia es
la más subjetiva: requiere no solo verificar si el DOI resuelve, sino evaluar
si el contenido real coincide con lo citado, lo cual admite más interpretación
que un simple "existe/no existe".

**¿Por qué creemos que pasó?** En el caso #2, Juan David identificó que el
coautor real tiene el apellido mal escrito y el año no coincide (ver Fallo JD-1),
un detalle fácil de pasar por alto si solo se confirma que "el DOI abre algo".
En los casos #7 y #9, no fue posible reverificar con certeza total si el DOI
resuelve a contenido real o no — se deja documentado como límite honesto de
esta verificación.

## 5. Tabla de decisión de herramienta

| Criterio | NotebookLM | Proyecto con archivos (Claude) | OpenCode (ya probado) |
|---|---|---|---|
| Contexto cerrado (responde solo sobre lo que le dimos) | Sí, por diseño | Sí | No — tiene búsqueda web, mezcla fuentes externas |
| Cita con localización (documento + página) | Sí, cita el fragmento fuente y permite ver el origen exacto | Parcial — cita el documento, no siempre página exacta | No — no muestra de forma consistente la fuente exacta (ver Fallo JD-1) |
| Privacidad (dónde quedan los documentos) | Nube de Google | Nube de Anthropic | Local (pero ya vimos que igual consulta la web) |
| Costo | Gratis | Incluido en plan ya usado | Gratis (modelo local) |
| Exportación a APA 7 | No nativa, exportación manual de notas | No nativa | No aplica |
| Reproducibilidad (otra persona rehace el índice) | Alta — solo requiere subir los mismos PDFs | Alta | Media — requiere mismo setup local |

## 6. Herramienta elegida

**Elegimos:** RAG propio (`sistema/rag.py`): Ollama con `bge-m3` para embeddings, índice local con numpy y `qwen3.5 : 4b-mlbx` como modelo generador.

**Vía:** ☐ Empaquetada ☐ Gestionada ☒ Propia

**Historia de la decisión:**
- **Versión 1 (hasta la sustentación del 2026-10-06): NotebookLM, vía empaquetada.** Se eligió porque daba contexto cerrado con citas desde el primer día. Sobre ella se corrió el banco de 15 preguntas (15/15).
- **Versión 2 (desde 2026-10-13): RAG propio, vía propia.** Cambiamos por orientación del profesor después de la sustentación. Con NotebookLM no controlábamos ni podíamos auditar la recuperación (qué fragmentos usa, con qué criterio, cuándo decide abstenerse), y la vía empaquetada limitaba la nota a 4,8. Los resultados de los dos sistemas sobre el mismo banco están en la sección 7.

**Qué ganamos con la vía propia:**
- Se guarda exactamente qué fragmentos (documento, página y similitud) vio el modelo en cada respuesta.
- Abstención doble: por umbral de similitud, antes de llamar al modelo, y por regla del prompt.
- Verificación automática de que cada cita apunte a un fragmento recuperado. En v1 la verificación de citas fue en parte circular, hecha con el mismo NotebookLM.
- El modelo generador se cambia con un parámetro (`--modelo`), sin tocar el código.
- Todo corre local, sin claves ni servicios externos.

**Qué perdimos o qué cuesta más:**
- Hay que mantener el código, el índice y el corpus en disco.
- Lo calibramos nosotros (umbral 0,45, k = 5, fragmentos de 900 caracteres): son decisiones nuestras que pueden estar mal ajustadas.
- El modelo local (`qwen2.5-coder`, 7B) es más pequeño que el de NotebookLM.

**Alternativas descartadas y por qué:**
- **OpenCode con búsqueda web:** el fallo JD-1 mostró que mezcla metadatos aun con búsqueda activa, y no fuerza contexto cerrado: puede traer información externa no verificada.
- **Proyecto con archivos de Claude (vía gestionada):** daba contexto cerrado, pero, igual que NotebookLM, no permite ver ni controlar la recuperación.
- **NotebookLM (vía empaquetada):** fue la versión 1. Se reemplazó por las razones de arriba, pero se conserva como punto de comparación.

## 7. Sistema final: RAG propio (actualización 2026-10-13)

Por orientación del profesor después de la sustentación, el sistema final pasó de NotebookLM (vía empaquetada) a un RAG propio (`sistema/rag.py`): embeddings `bge-m3` en Ollama, índice local con numpy, modelo generador `qwen2.5-coder`, temperatura 0, top-5 fragmentos, umbral de similitud 0,45 y verificador automático de citas. El protocolo pasó a v2 (`protocolo_prompts/v2.md`).

### 7.1 Resultados con el mismo banco de 15 preguntas

| | NotebookLM (v1) | RAG propio (v2) |
|---|---|---|
| Conducta correcta | 15/15 · Wilson [79,6 %, 100 %] | 14/15 · Wilson [70,2 %, 98,8 %] |
| Con respuesta (P1–P9) | 9/9 | 8/9 · Wilson [56,5 %, 98,0 %] |
| Abstenciones (A–F) | 6/6 | 6/6 · Wilson [61,0 %, 100 %] |
| Citas que no apuntan a un fragmento recuperado | no medible | 0 |
| Se puede auditar qué texto usó | No | Sí (fragmentos y similitud por respuesta) |

Con n = 15 los intervalos se solapan: **no se puede afirmar que un sistema sea mejor que el otro.** Lo que sí cambia es la auditabilidad.

Reporte completo: `sistema/resultados/evaluacion_qwen2.5-coder_2026-10-13_*.md`.

### 7.2 El único fallo: P7

La P7 pregunta por "Ferry et al. (2023)", pero el documento está registrado como "Eckersley et al. (2023)" (autores según Crossref). El sistema se abstuvo. Al repetir la pregunta con "Eckersley et al." respondió correctamente (90.000 contratos, cita válida a la p. 35). Es una **abstención falsa causada por el error de cita del Informe 1**: el sistema prefirió no suponer que eran el mismo documento. Es un error por exceso de cautela, no una alucinación.

### 7.3 Lo que aprendimos del umbral

Las similitudes de las preguntas con respuesta (0,482–0,686) y sin respuesta (0,407–0,539) se solapan: ningún umbral separa los dos grupos. Con 0,45 solo la pregunta E se abstuvo por umbral; las otras cinco abstenciones dependieron de que el modelo obedeciera la regla del prompt. **La similitud sola no basta para decidir cuándo abstenerse**; por eso el sistema usa doble defensa.

### 7.4 Limitaciones

- El corpus del RAG no es idéntico al de NotebookLM: los PDF se volvieron a descargar el 2026-10-13 y varios ahora son texto completo, donde antes solo había resumen (ver `corpus/README_PROCEDENCIA.md`).
- El umbral se fijó mirando el mismo banco con el que se evalúa.
- 3 respuestas no usaron el formato de cita pedido (P1, P3, P8). En la P1 la cita era correcta pero en otro formato, "(2006, p. 8)", y el verificador no la reconoce: es una limitación del verificador.
- Respuestas fieles pero incompletas: P3 (no menciona Moran, Queen ni 999 permutaciones), P5 (falta el corte k = 33,3 %) y P9 (faltan las 264 entidades y el Poisson).
- La fidelidad del contenido la calificaron los autores, sin auditoría cruzada.

### Desición: 

Después de realizadas la pruebas con NotebookLM y RAG propio hemos visto las limitaciones de NotebookLM al momento de efectuar un n grande de citas o referencias y se ha comprobado que este tiene difeente tipo de fallos probado con diferentes bancos de preguntas, así que para nuestro fin como artículo se decide usar un modelo RAG bajo el modelo ollama. 