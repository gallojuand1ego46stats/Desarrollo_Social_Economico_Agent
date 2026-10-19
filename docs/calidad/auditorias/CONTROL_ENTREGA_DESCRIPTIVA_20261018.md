# Control de entrega del informe metodológico — 18 de octubre de 2026

## Entregable

`docs/informe1_metodologico/Informe1_Metodologico.pdf`, 43 páginas. Compilado desde `main.tex` mediante pdfLaTeX, BibTeX y pasadas finales de pdfLaTeX. La última compilación no registra advertencias LaTeX, citas indefinidas, caracteres ausentes ni desbordamientos. Se revisaron visualmente las tablas, figuras y el nuevo diccionario operativo; las tablas se mantienen dentro de los márgenes y continúan en páginas posteriores con sus encabezados.

SHA-256 del PDF entregado: `1409A39E81CF34D13E562F73C8589183E5E5989E0DBF5B23766DDD73A7408AB1`.

Se conservó respaldo anterior en `tmp/actualizacion_informe_20261018/respaldo/`; `respaldo_sha256.csv` registra sus hashes.

## Verificación reproducible

- `R/06_descriptivos_sensibilidades_ivs.R`: recalcula ocho indicadores, descriptivos y sensibilidades; conserva las fuentes originales. Las ocho fórmulas coinciden con los resultados anteriores a tolerancia 1e-12. No ejecuta PCA ni KMO/Bartlett.
- `R/auxiliares/cotejar_extremos_descriptivos.py`: cotejo independiente de 47 celdas de 43 códigos extremos con el Excel consolidado, todas coincidentes; no elimina observaciones. No equivale a validar el fenómeno en campo ni a cotejar retrospectivamente la antigua lista de 32 municipios.
- `R/auxiliares/verificar_entrega_descriptiva.py`: 34 controles, cero fallos. Contrasta las cuatro filas descriptivas directamente con el CSV, todas las filas numéricas de las tablas generadas con el PDF, el registro de integridad y el log de compilación. Salida: `resultados/descriptivos_sensibilidades_20261018/verificacion_tablas_pdf.csv`. El control numérico de tablas se mantiene tras agregar el diccionario, que no introduce resultados numéricos nuevos.
- `integridad_insumos.csv`: hashes MD5 antes/después idénticos para los insumos y resultados históricos registrados. `integridad_excel_cotejo.csv` añade SHA-256 del libro cotejado. Los datos originales no se modificaron.

Estos controles cubren las tablas nuevas, no constituyen una revisión automatizada de cada cifra histórica en prosa. Las cifras históricas conservan las referencias documentales indicadas en sus secciones.

## Alcance e interpretación

Se separaron 20 áreas no municipalizadas según DIVIPOLA 2018. El ámbito descriptivo principal reúne 1.101 municipios/distritos y San Andrés: 1.102 unidades, sin llamarlas incorrectamente 1.102 municipios administrativos. También se guardan descriptivos para los ámbitos alternativos.

Se incorporaron justificaciones y límites de las ocho candidatas, fórmulas, cuatro descriptivos aprobados, razones agregadas, sensibilidades de pesos y denominadores, correlaciones alternativas, gráficos, matriz conceptual de solapamiento con IPM y un diccionario operativo de cuadros, variables, denominadores, universos y uso analítico. Las fuentes respaldan marcos y definiciones; no prueban automáticamente las reglas normativas elegidas por el equipo.

## Pendientes que permanecen abiertos

1. Confirmar inclusión insular en el universo del futuro PCA; la inclusión descriptiva no congela esa decisión.
2. Validar enlaces territoriales posteriores con SECOP; no se reasignan automáticamente 27493 ni 94663.
3. Evaluar posteriormente componentes, cargas y puntajes bajo las sensibilidades; aquí solo se calcularon valores y correlaciones.
4. Mantener visibles la población condicional de 10V, el carácter experimental de 5PM y la validación parcial con IPM.
5. Acordar la corrección de la instrucción residual de 6PM en el CSV histórico; no se ejecuta, porque 6PM está excluida.

**No se ejecutó PCA ni se construyó el IVS en esta actualización.**

Véase [[ACTUALIZACION_DESCRIPTIVA_20261018]] para decisiones, bibliografía verificada, comandos y archivos, y [[Informe_Metodologico_Obsidian]] para la navegación de la bóveda.
