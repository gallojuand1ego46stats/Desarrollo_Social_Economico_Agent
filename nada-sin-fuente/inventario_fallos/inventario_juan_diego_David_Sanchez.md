# Inventario de fallos — Juan Diego Gallo Quintero y David Sanchez


---

## Fallo 1

- **Herramienta:** OpenCode (con búsqueda web conectada, modelo qwen3.5-coder)
- **Qué generó:** Al pedirle los 15 indicadores del NBI (pregunta trampa, el NBI real tiene solo 5 componentes), ignoró la pregunta sobre NBI y respondió con un documento metodológico del IPM, citando el código "DANE-DIMPE-MET-001-2021", versión V1.0, fecha 28 de abril de 2021
- **Qué estaba mal:** Ese código no existe en ninguna fuente oficial verificable. Además, contradice el código real que el mismo agente había dado correctamente en una consulta anterior (COM-030-PD-001-r-004 V8, 31-01-2020) para lo que parece ser el mismo documento. Tampoco corrigió la premisa errónea sobre el NBI
- **Cómo lo detecté:** Verificando el código por búsqueda web — no aparece en ningún resultado, y comparándolo contra la respuesta previa y verificada del mismo agente
- **Qué me costó:** Si hubiera citado este código en el trabajo de Juan Diego, sería una referencia institucional falsa, y además habría dejado pasar que la pregunta original (sobre NBI) nunca se respondió
- **Qué lo habría evitado:** Que el agente mantuviera consistencia entre respuestas (si ya verificó un código antes, no debería generar uno distinto para el mismo documento), y que confirmara explícitamente cuando una pregunta no puede responderse tal como se formuló

---

## Fallo 2

- **Herramienta:** OpenCode (con búsqueda web conectada, modelo qwen3.5-coder)
- **Qué generó:** 10 nombres de columnas "típicas" del dataset de SECOP II
- **Qué estaba mal:** Mezcló dos datasets reales pero distintos de SECOP II en Datos Abiertos Colombia: "Procesos SECOP 2" (el que usó para responder) y "SECOP II - Contratos Electrónicos" (el que realmente usamos en la tesis). 7 de las 10 columnas dadas pertenecen al dataset equivocado y no existen en el nuestro; además inventó "codigo_pci" sin evidencia de que exista
- **Cómo lo detecté:** Comparando contra el diccionario oficial de 79 variables ya revisado, y verificando por búsqueda web cuál dataset real contiene cada campo
- **Qué me costó:** Si no lo detecto, habría buscado columnas como "fase" o "precio_base" en nuestro archivo real, sin encontrarlas, perdiendo tiempo sin saber por qué
- **Qué lo habría evitado:** Que el agente preguntara primero cuál de los dos datasets de SECOP II necesito, en vez de asumir uno

## Fallo 3

- **Herramienta:** OpenCode (modelo qwen3.5-coder), generando código R para bootstrap BCa
- **Qué generó:** En su primer intento, código que usaba `mean(matriz)` en vez de `rowMeans(matriz)` para calcular las 10.000 réplicas bootstrap
- **Qué estaba mal:** Ese error de vectorización colapsó las 10.000 réplicas a un solo valor (el gran promedio), produciendo z₀ = −Inf y límites del intervalo de confianza en NaN — resultados estadísticamente imposibles
- **Cómo lo detecté:** No lo detecté yo — el propio agente ejecutó su código, notó que z₀=−Inf y los límites NaN no tenían sentido, y corrigió el error antes de mostrarme el resultado final; lo reportó explícitamente como "un bug que tuve"
- **Qué me costó:** Nada en este caso, porque el agente se autocorrigió — pero si no hubiera ejecutado su propio código, este bug habría llegado hasta mí sin detectar
- **Qué lo habría evitado:** Pedir siempre que el agente ejecute y valide su propio código numéricamente antes de entregar cualquier resultado estadístico



---

**Firma:** Juan Diego Gallo Quintero David Sanchez Guarnizo
**Fecha:** 02/oct/2026
