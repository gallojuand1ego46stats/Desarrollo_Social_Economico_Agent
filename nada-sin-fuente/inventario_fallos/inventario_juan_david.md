# Inventario de fallos — Juan David Parada Fonseca


---

## Fallo 1

- **Herramienta:** OpenCode (con búsqueda web conectada, modelo qwen3.5-coder)
- **Qué generó:** 5 referencias académicas con DOI sobre contratación pública electrónica y desigualdad territorial
- **Qué estaba mal:** La referencia #2 mezcla datos reales con incorrectos: coautora real es "Marta Santamaría" (no "Santamarina"), título real distinto, año real 2025 (no 2023), DOI no corresponde al documento
- **Cómo lo detecté:** Verificando cada dato (autor, DOI, año) con búsquedas independientes
- **Qué me costó:** Sin esto, habría citado en mi tesis un documento con metadatos falsos — error difícil de detectar después
- **Qué lo habría evitado:** Que el sistema mostrara el link exacto de origen de cada dato, no solo el dato ya "armado"

---

## Fallo 2

- **Herramienta:** OpenCode (con búsqueda web conectada, modelo qwen3.5-coder)
- **Qué generó:** 10 nombres de columnas "típicas" del dataset de SECOP II
- **Qué estaba mal:** Mezcló dos datasets reales pero distintos de SECOP II en Datos Abiertos Colombia: "Procesos SECOP 2" (el que usó para responder) y "SECOP II - Contratos Electrónicos" (el que realmente usamos en la tesis). 7 de las 10 columnas dadas pertenecen al dataset equivocado y no existen en el nuestro; además inventó "codigo_pci" sin evidencia de que exista
- **Cómo lo detecté:** Comparando contra el diccionario oficial de 79 variables ya revisado, y verificando por búsqueda web cuál dataset real contiene cada campo
- **Qué me costó:** Si no lo detecto, habría buscado columnas como "fase" o "precio_base" en nuestro archivo real, sin encontrarlas, perdiendo tiempo sin saber por qué
- **Qué lo habría evitado:** Que el agente preguntara primero cuál de los dos datasets de SECOP II necesito, en vez de asumir uno

---

## Fallo 3

- **Herramienta:** OpenCode (modelo qwen3.5-coder), generando código R para bootstrap BCa
- **Qué generó:** En su primer intento, código que usaba `mean(matriz)` en vez de `rowMeans(matriz)` para calcular las 10.000 réplicas bootstrap
- **Qué estaba mal:** Ese error de vectorización colapsó las 10.000 réplicas a un solo valor (el gran promedio), produciendo z₀ = −Inf y límites del intervalo de confianza en NaN — resultados estadísticamente imposibles
- **Cómo lo detecté:** No lo detecté yo — el propio agente ejecutó su código, notó que z₀=−Inf y los límites NaN no tenían sentido, y corrigió el error antes de mostrarme el resultado final; lo reportó explícitamente como "un bug que tuve"
- **Qué me costó:** Nada en este caso, porque el agente se autocorrigió — pero si no hubiera ejecutado su propio código (o si yo le hubiera pedido "solo dame el código, no lo ejecutes"), este bug habría llegado hasta mí sin detectar
- **Qué lo habría evitado:** Pedir siempre que el agente ejecute y valide su propio código numéricamente (por ejemplo, verificando que z₀ sea finito y los límites no sean NaN) antes de entregar cualquier resultado estadístico, en vez de confiar en el código "tal como se ve"

---

**Firma:** Juan David Parada Fonseca
**Fecha:** 30/09/2026
