# Caso de fallo

**Sistema:** RAG propio, versión 2 (`sistema/rag.py`, embeddings `bge-m3`). El fallo ocurrió igual con los dos modelos generadores evaluados: `qwen2.5-coder` y `qwen3.5:4b` (final).
**Evidencia:** pregunta P7 en `sistema/resultados/evaluacion_qwen2.5-coder_2026-10-13_1302.md` y en `sistema/resultados/evaluacion_qwen3.5-4b_2026-10-13_1704.md`.

**Qué estaba mal:** A la pregunta "¿Cuántos contratos analizaron Ferry et al. (2023) en Reino Unido?" el sistema respondió "No encuentro esto en las fuentes del corpus.", aunque el documento sí está en el corpus y contiene la respuesta (más de 90.000 contratos de autoridades locales). Es una **abstención falsa**.

**Causa técnica:** Desajuste de nombre entre la pregunta y la ficha del documento. En `sistema/fuentes.json` el documento está registrado como "Eckersley et al. (2023)", porque Crossref lista a Eckersley, Flynn, Lakoma y Ferry como autores. Los cinco fragmentos recuperados eran todos de ese documento (similitud máxima 0,50, por encima del umbral de 0,45), así que la recuperación funcionó. Pero el modelo vio fragmentos de "Eckersley" y una pregunta sobre "Ferry", y como el protocolo v2 le prohíbe citar fuentes que no estén en los fragmentos, no asumió que fueran el mismo documento y se abstuvo.

El origen está en nuestro propio anteproyecto: el Informe 1 citaba "Ferry et al. (2023)", que es el error de cita que encontramos al construir la tabla de trazabilidad (fila 5).

**Cómo lo detectamos:** El chequeo automático del banco lo marcó como "REVISAR" (pregunta con respuesta que terminó en abstención). Repetimos la misma pregunta con el autor correcto, "Eckersley et al. (2023)", y el sistema (con `qwen2.5-coder`) respondió "90.000 contratos" con una cita válida a la página 35, que el verificador confirmó. Que el fallo se repita idéntico con `qwen3.5:4b` confirma que la causa es el nombre del autor y no el modelo.

**Por qué importa:** Es un fallo por exceso de cautela, el opuesto a una alucinación: el sistema prefirió no responder antes que suponer una equivalencia de autores que no estaba en el texto. Para nosotros es el fallo menos dañino, pero sigue siendo un fallo: alguien que use la cita del Informe 1 tal como estaba no obtiene la respuesta.

**Qué haríamos distinto:**
1. Corregir la cita en el Informe 1 (Eckersley, Flynn, Lakoma y Ferry, 2023, 57(10)).
2. Registrar en `fuentes.json` los nombres alternativos de cada documento (por ejemplo "Ferry et al." como alias de "Eckersley et al.") e incluirlos en la cabecera de los fragmentos, para que el modelo pueda reconocer las dos formas de citarlo.

## Fallo de referencia de la etapa de diagnóstico

Antes de construir el sistema, el fallo más representativo fue **JD-2**: OpenCode con búsqueda web mezcló columnas de dos datasets reales de SECOP II ("Procesos SECOP 2" y "SECOP II - Contratos Electrónicos") sin advertirlo. Fue una ambigüedad de recuperación: dos fuentes reales con nombres casi idénticos. Lo detectamos comparando contra el diccionario oficial de variables del dataset que usamos. Ese fallo es una de las razones por las que el protocolo exige citar el documento específico de origen.
