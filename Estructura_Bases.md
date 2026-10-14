# Estructura y verificación de las bases del proyecto IVS municipal

## Propósito y alcance

Esta nota pertenece a la bóveda Obsidian del proyecto (la raíz del repositorio contiene `.obsidian/`). Registra la verificación de los libros consolidados CNPV 2018 e IPM 2018 para dejar tablas municipales reproducibles. La tarea se limita a estructura, llaves, cobertura y consistencia interna. No calcula indicadores derivados, no imputa, no ejecuta KMO/Bartlett/PCA ni decide variables del IVS.

**Notas relacionadas:** [[Inicio_Proyecto]] · [[VERIFICACION_CONSOLIDADOS]] · [[Correccion_Estructura_Bases]] · [[Final_Base]]

## Insumos y regla de unión

- `datos/CUADROS_MUNICIPALES_UNIDOS.xlsx`: hojas `HOGARES_MUNICIPAL`, `PERSONA_DEMO`, `PERSONA_SOCIAL`, `VIVIENDAS`, `IPM` y `CONTEXTO`.
- `datos/IPM_2018_organizado_region.xlsx`: hoja municipal ancha, hojas largas, diccionarios, resúmenes y controles.
- `datos/DIVIPOLA-_Códigos_municipios_20260917.csv`: catálogo territorial con coordenadas.
- `docs/diccionario/decisiones_variables_IVS_CNPV2018.csv`: decisiones de clasificación preexistentes.

La llave de cruce es siempre `codigo_municipio`, texto de cinco caracteres; los nombres municipales no se usan para unir. Para fuentes con código local de tres dígitos se antepone el código departamental. Se conservan cuatro campos iniciales en tablas intermedias: departamento, municipio, nombre de municipio y nombre de departamento. Las etiquetas vacías se tratan como ausentes. `Total Nacional` se excluye de tablas municipales y se guarda en `control_nacional.csv`.

## Ejecución y artefactos

El flujo reproducible está en [R/01_verificar_consolidados.R](R/01_verificar_consolidados.R). Lee celdas de Excel como texto, convierte números de manera explícita y registra métricas de conversión. El script genera el inventario, mapa de llaves, cobertura, discrepancias, chequeos, universo maestro y reporte en `resultados/verificacion_consolidados/` y `docs/calidad/auditorias/VERIFICACION_CONSOLIDADOS.md`. Las diez tablas tidy se guardan en `datos/intermedio/` como CSV UTF-8 sin BOM.

Tablas intermedias: `hogares_1HM_2HM.csv`, `persona_demo_17PM.csv`, `persona_social_5PM.csv`, `viviendas_6V.csv`, `viviendas_8V.csv`, `viviendas_10V.csv`, `contexto_1PM.csv`, `contexto_1V.csv`, `ipm_municipal_ancho.csv` y `control_nacional.csv`.

La última ejecución inventarió 14 hojas: seis del consolidado CNPV (incluida la hoja `IPM` vacía) y ocho del libro IPM. Las dimensiones observadas y cada chequeo, incluidos los que fallan, están registrados en `inventario_hojas_columnas.csv` y `chequeos_consistencia.csv`. El mapa del libro es el contrato de lectura; una discrepancia se reporta, no se corrige en silencio.

## Hallazgos verificados y cuestiones por decidir

- El universo de CNPV/IPM tiene 1.122 códigos comunes. DIVIPOLA también contiene 1.122 códigos, pero la intersección con CNPV/IPM es 1.121 y la unión resulta de 1.123 códigos: `27493` aparece solo en DIVIPOLA (Nuevo Belén de Bajirá) y `94663` solo en CNPV/IPM (Mapiripana, sin fila/coordenadas en ese DIVIPOLA). Sus filas y evidencia están en el reporte y `discrepancias.csv`.
- En el universo censal, hay 1.102 códigos con área Cabecera y 930 con Centro poblado. Los flags del maestro son TRUE/FALSE/NA: 1.102/20/1 para Cabecera y 930/192/1 para Centro poblado. Los veinte códigos sin Cabecera coinciden con los veinte `--` de IPM; son 18 áreas no municipalizadas y 94343 Barrancominas y 94663 Mapiripana. Que los dos últimos fueran áreas no municipalizadas en 2018 es una hipótesis, no un dato confirmado. La ausencia de área es una ausencia estructural de combinación, no un dato para imputar.
- Hay diferencias literales de nombres entre IPM y DIVIPOLA; las cuatro documentadas en la ejecución son `13468`, `19760`, `68235` y `76001`. La llave por código permite cruzar sin homologar esos nombres.
- Los bloques 6V/8V y 1V usan códigos de municipio de tres dígitos más departamento; los demás bloques municipales utilizan códigos de cinco dígitos.
- La hoja 17PM está encabezada como `Nivel educativo`; E representa el total y F:T sus quince categorías. El encabezado, categorías y chequeo de suma indican que mide nivel educativo alcanzado, aunque el CSV de decisiones diga “asistencia escolar”. Es una inconsistencia documental reportada, no una decisión sobre inclusión en IVS.
- El 6V registra 1.202 combinaciones de tipo de vivienda ausentes entre las 7.854 posibles; 1PM registra 335 combinaciones de grupo etario ausentes entre 81.244 posibles. Son ausencias estructurales. No se completaron combinaciones ni se imputaron valores.
- 8V se exportó completo; no se seleccionaron ni descartaron columnas por solapamiento con IPM.
- En IPM, `IPM Municipal` e `IPM` se comparan, las privaciones se revisan en rango, y las hojas largas/resúmenes se contrastan contra la hoja ancha. Resultados numéricos reproducibles están en `chequeos_consistencia.csv`.

Decisiones que quedan para el usuario: escoger el universo territorial y el tratamiento de `27493`/`94663`; definir tratamiento de áreas no municipalizadas; decidir cómo manejar filas ausentes estructuralmente; elegir qué columnas de 8V llevar a la fase posterior. No se resolvió ninguna mediante imputación o modificación de datos.

## Integridad y límites

La auditoría calcula MD5 antes y después de la ejecución para los tres insumos. Los valores y la igualdad antes/después se reportan en `VERIFICACION_CONSOLIDADOS.md`; las fuentes no se editan. `OLVIDADOS/` y los scripts archivados no forman parte del flujo. La verificación puede registrar diferencias respecto al contrato como hallazgos; no certifica decisiones metodológicas futuras ni construye el IVS.

## Siguiente paso

Revisar con el usuario las decisiones territoriales y de cobertura, fijar un universo de análisis documentado y, en una etapa posterior autorizada, definir variables y transformaciones antes de cualquier análisis multivariado.
