# Banco de evaluación

Sistemas evaluados con las mismas 15 preguntas:
- **Versión 1, NotebookLM**: las respuestas documentadas abajo. Corpus de 10 documentos públicos (matriz bibliográfica del Informe 1 + nota metodológica DANE).
- **Versión 2, RAG propio** (`sistema/rag.py`), evaluado con `qwen2.5-coder` y con `qwen3.5:4b` (modelo final): ver la sección "Resultados con el RAG propio" al final y el reporte completo en `sistema/resultados/`.

## Preguntas CON respuesta en el corpus

### Pregunta 1
- **Pregunta:** ¿Qué tres pilares propone Bonet-Morón (2006) para consolidar la equidad territorial?
- **Respuesta conocida:** Equidad en transferencias, fortalecimiento tributario subnacional, incentivos a la eficiencia del gasto
- **Dónde está:** Documento de Trabajo sobre Economía Regional y Urbana N.º 77, Banco de la República (resumen)
- **Respuesta obtenida:** Coincide exactamente con los 3 pilares
- **¿Sostenida por un fragmento real?:** Sí

### Pregunta 2
- **Pregunta:** ¿Qué encontró Ardila-Rueda (2004) sobre inversión pública y posición relativa de los departamentos?
- **Respuesta conocida:** Persistencia en la distribución del ingreso; la inversión pública afecta la posición relativa
- **Dónde está:** Revista ESPE, Banco de la República
- **Respuesta obtenida:** Describe disparidades estructurales y rol redistributivo del gasto; reconoce honestamente que el resumen disponible no detalla las métricas cuantitativas de cambio en el ranking
- **¿Sostenida por un fragmento real?:** Sí (con limitación reconocida por el propio sistema)

### Pregunta 3
- **Pregunta:** ¿Qué metodología estadística usaron Monsalvo Herrera y Jiménez (2025) para analizar la pobreza en Cundinamarca?
- **Respuesta conocida:** Índice de Morán, LISA, matriz de pesos tipo Queen orden 1, 999 permutaciones, GeoDa/ArcGIS
- **Dónde está:** Novum Jus, 19(2), sección de metodología
- **Respuesta obtenida:** Coincide exactamente — verificado palabra por palabra contra el texto original en Scielo
- **¿Sostenida por un fragmento real?:** Sí

### Pregunta 4
- **Pregunta:** ¿Cuántos municipios y corregimientos se usaron para el cálculo de pobreza municipal del DANE 2018?
- **Respuesta conocida:** 1.102 municipios + 20 corregimientos (1.122 total) — dato que está en el boletín técnico, no en la nota metodológica
- **Dónde está:** Boletín técnico DANE (documento distinto al subido)
- **Respuesta obtenida:** Dice correctamente que el documento subido no incluye esa cifra específica
- **¿Sostenida por un fragmento real?:** Sí (abstención parcial correcta — distingue entre documentos)

### Pregunta 5
- **Pregunta:** ¿Qué estructura de dimensiones e indicadores tiene el IPM censal municipal del DANE?
- **Respuesta conocida:** 5 dimensiones (20% c/u), 15 indicadores, corte k=33.3%
- **Dónde está:** Nota metodológica DANE, Tabla 1
- **Respuesta obtenida:** Coincide exactamente, incluyendo pesos y puntos de corte
- **¿Sostenida por un fragmento real?:** Sí

### Pregunta 6
- **Pregunta:** ¿Qué metodología usaron Arachi et al. (2024) para estudiar cooperación intermunicipal en Italia?
- **Respuesta conocida:** Efectos fijos + estimadores de matching, 50.905 contratos (2012-2020)
- **Dónde está:** Regional Studies, 58(11)
- **Respuesta obtenida:** Coincide exactamente
- **¿Sostenida por un fragmento real?:** Sí

### Pregunta 7
- **Pregunta:** ¿Cuántos contratos analizaron Ferry et al. (2023) en Reino Unido?
- **Respuesta conocida:** 90.000 contratos, autoridades locales, 2015-2019
- **Dónde está:** Regional Studies, 57(10) (en Crossref los autores figuran como Eckersley, Flynn, Lakoma y Ferry)
- **Respuesta obtenida:** Coincide exactamente
- **¿Sostenida por un fragmento real?:** Sí

### Pregunta 8
- **Pregunta:** ¿Para qué se usaron los modelos de clasificación de Figueroa-Gómez y Galpin (2024)?
- **Respuesta conocida:** Clasificación supervisada para identificar licitaciones de interés en SECOP II
- **Dónde está:** SN Computer Science, 5, 87
- **Respuesta obtenida:** Coincide, añade contexto (Universidad Minuto de Dios) no verificado de forma independiente
- **¿Sostenida por un fragmento real?:** Sí (con una mención sin verificar adicional)

### Pregunta 9
- **Pregunta:** ¿Qué dice Rodriguez-Plesa et al. (2022) sobre contratación pública sostenible?
- **Respuesta conocida:** Índice de Contratación Verde y de Equidad Social, 264 gobiernos locales, regresión de Poisson
- **Dónde está:** Journal of Cleaner Production, 338
- **Respuesta obtenida:** Coincide exactamente — verificado contra el abstract oficial
- **¿Sostenida por un fragmento real?:** Sí

## Preguntas SIN respuesta en el corpus (mínimo 3 — aquí hay 6)

### Pregunta A
- **Pregunta:** ¿Qué dice el corpus sobre la tasa de desempleo en Venezuela en 2023?
- **Por qué no tiene respuesta:** Fuera del alcance geográfico y temático del corpus
- **Respuesta obtenida:** Se abstuvo correctamente, ofreció resumen de lo que sí cubre el corpus
- **¿Se abstuvo o inventó?:** Se abstuvo correctamente

### Pregunta B
- **Pregunta:** ¿Cuál es el presupuesto de contratación pública de México en 2023?
- **Por qué no tiene respuesta:** No hay fuentes sobre México en el corpus
- **Respuesta obtenida:** Se abstuvo correctamente
- **¿Se abstuvo o inventó?:** Se abstuvo correctamente

### Pregunta C
- **Pregunta:** ¿Qué dice el corpus sobre IA en auditoría de contratos públicos?
- **Por qué no tiene respuesta:** Las fuentes de IA/ML en el corpus tratan clasificación de licitaciones, no auditoría
- **Respuesta obtenida:** Se abstuvo correctamente, distinguió bien los temas relacionados pero distintos
- **¿Se abstuvo o inventó?:** Se abstuvo correctamente

### Pregunta D
- **Pregunta:** ¿Cuántos municipios de Colombia tienen población menor a 5.000 habitantes?
- **Por qué no tiene respuesta:** El corpus no tiene un listado nacional por rangos de población
- **Respuesta obtenida:** Se abstuvo correctamente
- **¿Se abstuvo o inventó?:** Se abstuvo correctamente

### Pregunta E
- **Pregunta:** ¿Qué es VigIA según Salazar et al. (2024) y qué datos usa?
- **Por qué no tiene respuesta:** La fuente es real y está en el Informe 1, pero nunca se subió al notebook (ausencia de fuente, no de tema)
- **Respuesta obtenida:** Respondió que no estaba en el corpus
- **¿Se abstuvo o inventó?:** Se abstuvo correctamente

### Pregunta F
- **Pregunta:** ¿Qué plantea Díaz Díez (2023) sobre el carácter transaccional de SECOP II?
- **Por qué no tiene respuesta:** Igual que E: fuente real del Informe 1, nunca subida al notebook
- **Respuesta obtenida:** Respondió que no estaba en el corpus
- **¿Se abstuvo o inventó?:** Se abstuvo correctamente

> Nota: E y F son una prueba más débil de abstención que A–D, porque ahí la información simplemente no existía en el notebook; A–D prueban que el sistema no inventa sobre temas cercanos pero ausentes.

## Resumen

- **15 preguntas evaluadas = 9 con respuesta + 6 sin respuesta**
- **9 con respuesta:** las 9 sostenidas por un fragmento real. Dos matices que no ocultamos: en P2 el propio sistema reconoció que el resumen no detalla las métricas; en P8 añadió un contexto (afiliación del autor) que no verificamos de forma independiente
- **6 sin respuesta:** las 6 con abstención correcta (el mínimo exigido era 3)
- **Resultado:** 15/15 conductas correctas; IC 95% de Wilson para 15/15 = [79.6%, 100%] (9/9: [70.1%, 100%]; 6/6: [61.0%, 100%])
- **Límites:** n pequeño; las preguntas las escribió el mismo equipo que armó el corpus (riesgo de preguntas "fáciles"); la evaluación la hicieron los autores, sin auditoría cruzada
- **Conclusión:** en esta muestra NotebookLM fue fiel y se abstuvo cuando debía; no es evidencia de que nunca falle

## Resultados con el RAG propio + `qwen2.5-coder` (2026-10-13)

Mismas 15 preguntas, corridas con `python rag.py evaluar` (modelo `qwen2.5-coder`, embeddings `bge-m3`, umbral 0,45, k = 5). Reporte completo con respuestas, fragmentos recuperados y similitudes: `sistema/resultados/evaluacion_qwen2.5-coder_2026-10-13_1302.md`.

| ID | Conducta | Fiel | Observación |
|---|---|---|---|
| P1 | Responde | Sí | Los 3 pilares correctos; cita en formato distinto "(2006, p. 8)" |
| P2 | Responde | Sí | Cita válida [Ardila-Rueda, 2004, p. 3] |
| P3 | Responde | Sí, incompleta | Menciona LISA; no Moran, Queen ni 999 permutaciones. Sin cita |
| P4 | Se abstiene | Sí | La cifra no está en la nota metodológica (abstención parcial correcta) |
| P5 | Responde | Sí, incompleta | 5 dimensiones, 15 indicadores, 20 %; falta k = 33,3 % |
| P6 | Responde | Sí | Efectos fijos, matching, 50.905 contratos; cita válida |
| P7 | Se abstiene | **No** | Abstención falsa: la pregunta dice "Ferry", el documento es "Eckersley et al." Ver `caso_de_fallo.md` |
| P8 | Responde | Sí | Coincide; sin cita |
| P9 | Responde | Sí, general | Correcta; no da 264 entidades ni Poisson. Cita válida |
| A–F | Se abstienen | Sí | E por umbral (0,407); A, B, C, D y F por la regla del prompt |

- **Conducta correcta: 14/15**, IC 95 % de Wilson [70,2 %, 98,8 %] (NotebookLM: 15/15, [79,6 %, 100 %]). Los intervalos se solapan: con n = 15 no se puede afirmar que un sistema sea mejor.
- **Citas que no apuntan a un fragmento recuperado: 0.**
- La columna "Fiel" la calificaron los autores; confirmar antes de entregar.

## Resultados con el RAG propio + `qwen3.5:4b`, modelo final (2026-10-13)

Mismo banco, índice, umbral y prompt; solo cambia el modelo generador (`python rag.py evaluar --modelo qwen3.5:4b --sin-razonamiento`). Reporte completo: `sistema/resultados/evaluacion_qwen3.5-4b_2026-10-13_1704.md`.

| ID | Conducta | Fiel | Observación |
|---|---|---|---|
| P1 | Responde | Sí | Los 3 pilares; cita válida [Bonet-Morón, 2006, p. 8] |
| P2 | Responde | Por verificar | Agrega cifras (Antioquia 17 %, Valle y Cundinamarca 9,5 %, Bogotá 1,3 %) citando p. 21 y p. 35, ambas recuperadas. Contrastar con el PDF |
| P3 | Responde | Parcial | LISA e IPM; no Moran, Queen ni 999 permutaciones. Cita con autor abreviado [Monsalvo, 2025, p. 4]: página correcta (falso positivo del verificador v2.0; válida con el v2.1) |
| P4 | Se abstiene | Sí | Abstención parcial correcta |
| P5 | Responde | Sí | Completa: 5 dimensiones con nombres, 20 %, 15 indicadores, k = 33,3 %. Cita en formato no estándar "[Fragmento 2, p. 2]" |
| P6 | Responde | Sí | Efectos fijos, matching, 50.905 contratos. Cita con autor abreviado [Arachi, 2024, p. 1]: página correcta (falso positivo del verificador v2.0; válida con el v2.1) |
| P7 | Se abstiene | **No** | Misma abstención falsa que con `qwen2.5-coder` (Ferry vs. Eckersley) |
| P8 | Responde | Parcial | Escribe "licencias" donde el texto dice "licitaciones" y omite SECOP II y el carácter supervisado. Sin cita. La afiliación a la Corporación Universitaria Minuto de Dios aparece en la página del editor (revisión con IA, 2026-10-13; confirmar) |
| P9 | Responde | Por verificar | Tres citas válidas (p. 7, 1 y 5); contrastar el contenido de la p. 7 con el PDF |
| A–F | Se abstienen | Sí | E por umbral; A, B, C, D y F por la regla del prompt |

- **Conducta correcta: 14/15**, igual que con `qwen2.5-coder`. IC 95 % de Wilson [70,2 %, 98,8 %].
- **Citas inválidas: 0** con el verificador v2.1 (`python rag.py reverificar`). El v2.0 había marcado 2 (P3 y P6), pero eran falsos positivos: autor abreviado con la página correcta. Con el v2.1 quedan 4 citas válidas en formato no estándar (P3, P5 ×2, P6) y 1 respuesta sin cita (P8).
- P2 y P9 quedan "por verificar" hasta contrastarlas con los PDF; la columna "Fiel" la confirman los autores.
- Conducta (8/9 respondió cuando debía) no es lo mismo que fidelidad: de esas 8 respuestas, 3 son fieles (P1, P5, P6), 2 parciales (P3, P8) y 2 están por verificar (P2, P9); P4 es abstención parcial correcta.

