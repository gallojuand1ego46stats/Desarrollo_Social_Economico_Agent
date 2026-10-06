# Experimento y decisión



## 1. Diseño del experimento

Se utilizó una consulta bibliográfica real del eje de contratación pública,
ejecutada en dos tratamientos:

| Tratamiento | Qué representa | Herramienta usada |
|---|---|---|
| A (control) | Chat sin fuentes ni navegación | Ollama + qwen2.5-coder (`ollama run qwen2.5-coder`), sin plugins ni búsqueda |
| B (búsqueda) | Buscador conectado a bases bibliográficas reales | OpenCode, con búsqueda web activa |

### Consulta utilizada (Juan David — eje de contratación)
> "Dame 5 referencias académicas, con DOI, sobre la relación entre
> contratación pública electrónica y reducción de la desigualdad territorial
> en países en desarrollo."

### Consulta de Juan Diego (eje de vulnerabilidad)
> Pendiente — Juan Diego debe definir y ejecutar su propia consulta cuando
> esté disponible, siguiendo el mismo protocolo (Tratamientos A y B).

## 2. Tabla de conteos

| Consulta | Tratamiento | Utilizable | Existe pero no dice eso | No existe | Total revisadas |
|---|---|---|---|---|---|
| Juan David (contratación) | A | 0 | 0 | 5 | 5 |
| Juan David (contratación) | B | 4 | 1 | 0 | 5 |
| David Santiago (vulnerabilidad/IPM) | A | 0 | 0 | 5 | 5 |
| David Santiago (vulnerabilidad/IPM) | B | 5 | 0 | 0 | 5 |

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
> referencias reales, aunque no la garantiza al 100% (ver Fallos 1 y 4).

## 4. Acuerdo de clasificación (Juan Diego vs. Juan David vs David Santiago)

Cada integrante clasificó las mismas 10 referencias por separado, sin consultarse
(Juan Diego clasificó a ciegas, solo con los DOI, sin ver títulos ni la
clasificación previa de Juan David).

| # | Juan David | Juan Diego , David Santiago| Coincide |
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

**Acuerdo: 7/10 (70%)**

**¿En qué categoría se concentró el desacuerdo?** En los 3 casos de
discrepancia, al menos uno de los dos clasificadores usó la categoría "Existe
pero no dice eso" — ninguna discrepancia ocurrió entre "Utilizable" y "No
existe" directamente. Esto es consistente con que la categoría intermedia es
la más subjetiva: requiere no solo verificar si el DOI resuelve, sino evaluar
si el contenido real coincide con lo citado, lo cual admite más interpretación
que un simple "existe/no existe".

**¿Por qué creemos que pasó?** En el caso #2, Juan David identificó que el
coautor real tiene el apellido mal escrito y el año no coincide (ver Fallo 1),
un detalle fácil de pasar por alto si solo se confirma que "el DOI abre algo".
En los casos #7 y #9, no fue posible reverificar con certeza total si el DOI
resuelve a contenido real o no — se deja documentado como límite honesto de
esta verificación.

## 5. Tabla de decisión de herramienta

| Criterio | NotebookLM | Proyecto con archivos (Claude) | OpenCode (ya probado) |
|---|---|---|---|
| Contexto cerrado (responde solo sobre lo que le dimos) | Sí, por diseño | Sí | No — tiene búsqueda web, mezcla fuentes externas |
| Cita con localización (documento + página) | Sí, cita el fragmento fuente y permite ver el origen exacto | Parcial — cita el documento, no siempre página exacta | No — no muestra de forma consistente la fuente exacta (ver Fallo 1) |
| Privacidad (dónde quedan los documentos) | Nube de Google | Nube de Anthropic | Local (pero ya vimos que igual consulta la web) |
| Costo | Gratis | Incluido en plan ya usado | Gratis (modelo local) |
| Exportación a APA 7 | No nativa, exportación manual de notas | No nativa | No aplica |
| Reproducibilidad (otra persona rehace el índice) | Alta — solo requiere subir los mismos PDFs | Alta | Media — requiere mismo setup local |

## 6. Herramienta elegida

**Elegimos:** NotebookLM

**Vía:** ☒ Empaquetada ☐ Gestionada ☐ Propia

**Alternativas descartadas y por qué:**
- OpenCode: aunque ya lo usamos y tiene búsqueda conectada, el Fallo 1 demostró que mezcla metadatos incluso con búsqueda activa, y no fuerza contexto cerrado (puede traer información externa no verificada desde el corpus)
- Proyecto con archivos de Claude: válido, pero NotebookLM está diseñado específicamente para citar con ubicación exacta del fragmento fuente, que es el requisito más estricto del protocolo de prompts (v1)

## 7. Resumen para el visto bueno 

## Resumen para el visto bueno (media página)

**Qué encontramos en el experimento:** sin búsqueda conectada, 0% de las
referencias bibliográficas dadas por el agente fueron reales (5 de 5
inventadas). Con búsqueda conectada, la tasa subió a 80% (4 de 5), aunque
incluso con búsqueda se encontró un caso de metadatos mezclados entre un
autor real y un documento distinto.

**Herramienta elegida:** NotebookLM (vía empaquetada), por su capacidad de
anclaje con cita de ubicación exacta, descartando OpenCode pese a tener
búsqueda conectada, porque no garantiza contexto cerrado ni cita verificable.

**Corpus:** ~13-15 fuentes públicas de la matriz bibliográfica del estado del
arte del proyecto, más el repositorio público de referencia.

**Cómo vamos a evaluar:** banco de 15-20 preguntas con respuesta conocida y
localizada en el corpus, incluyendo al menos 3 sin respuesta disponible, para
verificar que el sistema se abstiene en vez de inventar.


-
-

