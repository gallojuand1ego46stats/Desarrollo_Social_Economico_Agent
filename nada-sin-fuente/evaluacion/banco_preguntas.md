# Banco de evaluación

Sistema evaluado: NotebookLM, corpus de 10 documentos públicos (matriz bibliográfica del Informe 1 + nota metodológica DANE).

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