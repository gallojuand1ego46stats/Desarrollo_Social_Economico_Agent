# Decisión sobre los diccionarios y selección de hojas del IVS

> Registro de decisión del autor. La revisión manual aquí descrita se documenta a partir de la instrucción del proyecto; no se reabrieron los libros fuente durante esta edición.

## Motivo

Los diccionarios generados automáticamente y la extracción inicial de variables desde las hojas de Excel producían nombres/estructuras que no coincidían de forma fiable con las variables originales de las bases. Los encabezados y diseños de las hojas requerían interpretación por hoja. Por ese motivo, esos productos automáticos no se consideran la fuente autoritativa para decidir qué variables alimentan el Índice de Vulnerabilidad Socioeconómica (IVS).

## Revisión manual

Las seis bases del proyecto (los cuatro cuadros CNPV, el insumo IPM y DIVIPOLA) y sus hojas pertinentes se revisaron manualmente, hoja por hoja, siguiendo los criterios de [`seleccion_variables_ivs.md`](../metodologia/seleccion_variables_ivs.md): unidad municipal, pertinencia conceptual, posibilidad de formar indicadores, cobertura/calidad y solapamiento con IPM. La tabla siguiente detalla las hojas CNPV seleccionadas como candidatas o contexto; DIVIPOLA mantiene su función de referencia territorial y el IPM organizado es el bloque socioeconómico central.

| Base de origen | Hojas seleccionadas | Uso |
|---|---|---|
| `datos/HOGARES_Cuadros_CNPV_2018.XLSX` | `1HM`, `2HM` | Hojas municipales candidatas para derivar indicadores de estructura del hogar. |
| `datos/PERSONAS_DEMOGRAFICO_Cuadros_CNPV_2018.xlsx` | `17PM` | Hoja municipal candidata. |
| `datos/PERSONAS_SOCIAL_Cuadros_CNPV_2018.XLSX` | `5PM` | Hoja municipal candidata. |
| `datos/VIVIENDAS_Cuadros_CNPV_2018.XLSX` | `6V_MPIO`, `8V_MPIO`, `10V_MPIO` | Hojas municipales candidatas. |
| `datos/PERSONAS_DEMOGRAFICO_Cuadros_CNPV_2018.xlsx` | `1PM` | Contexto/denominadores; no candidata directa al PCA. |
| `datos/VIVIENDAS_Cuadros_CNPV_2018.XLSX` | `1V_MPIO` | Contexto/denominador; no candidata directa al PCA. |

La selección y su motivo, notas de transformación y verificaciones pendientes se registran en [`decisiones_variables_IVS_CNPV2018.csv`](decisiones_variables_IVS_CNPV2018.csv). Los datos de hojas candidatas se reunieron en `datos/CUADROS_MUNICIPALES_UNIDOS.xlsx`. El IPM DANE se organizó aparte en `datos/IPM_2018_organizado_region.xlsx`.

## Consecuencias para el análisis

- Usar la tabla CSV de decisiones como registro vigente de inclusión/contexto/descarte, junto con la metodología enlazada.
- Tratar diccionarios anteriores como artefactos auxiliares hasta reconciliar sus nombres de campo con las variables originales; no usarlos sin esa comprobación para definir el IVS.
- Antes del PCA, derivar indicadores municipales documentando para cada uno variable fuente, fórmula, numerador, denominador, orientación de vulnerabilidad y regla de faltantes.
- Mantener por separado las hojas de contexto y los agregados IPM que se reserven para validación; no incorporarlos automáticamente como componentes del índice.
- No alterar los libros bajo `datos/` como parte de esta decisión.

## Enlaces del vault Obsidian

La bóveda del proyecto está en la raíz del repositorio (carpeta `.obsidian/`). Esta nota se conecta con las notas y registros canónicos del vault mediante enlaces Markdown relativos:

- [Resumen general del proyecto](../../Resumen_General.md)
- [Decisiones de variables IVS CNPV 2018](decisiones_variables_IVS_CNPV2018.csv)
- [Metodología de selección de variables IVS](../metodologia/seleccion_variables_ivs.md)
- [Índice de diccionarios](README.md)
