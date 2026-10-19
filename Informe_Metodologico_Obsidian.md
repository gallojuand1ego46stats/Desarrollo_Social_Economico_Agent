---
title: Contratación pública y vulnerabilidad socioeconómica municipal en Colombia
date: 2026-10-18
tags:
  - metodologia
  - IVS
  - CNPV2018
  - PCA
---

# Contratación pública y vulnerabilidad socioeconómica municipal en Colombia

Nota de navegación de la bóveda Obsidian. El documento académico completo está en [Informe 1 Metodológico (PDF)](docs/informe1_metodologico/Informe1_Metodologico.pdf), con su fuente modular [main.tex](docs/informe1_metodologico/main.tex) y la bibliografía [referencias.bib](docs/informe1_metodologico/referencias.bib).

## Actualización al 18 de octubre de 2026

El PDF enlazado corresponde a la versión 2.1, con decisiones consolidadas, justificación específica y límites por indicador, descriptivos de 1HM, 6V, energía y 10V, sensibilidades de fórmulas y correlaciones y un diccionario operativo de cuadros y variables, sus universos, denominadores y usos analíticos. Esta actualización no ejecutó PCA. La clasificación histórica separa veinte ANM; la tabla principal distingue 1.101 municipios/distritos y San Andrés. La inclusión insular en el PCA definitivo sigue pendiente.

- [[docs/calidad/auditorias/ACTUALIZACION_DESCRIPTIVA_20261018|Decisiones, evidencia, fuentes y reproducción de la actualización]].
- [[docs/calidad/auditorias/CONTROL_ENTREGA_DESCRIPTIVA_20261018|Control de entrega del PDF]].
- Script: `R/06_descriptivos_sensibilidades_ivs.R`.
- Resultados: `resultados/descriptivos_sensibilidades_20261018/`.

## Estado histórico al 15 de octubre de 2026

- Se verificaron los libros consolidados del CNPV/IPM y se generaron tablas intermedias con `codigo_municipio` como llave.
- Se calcularon nueve indicadores candidatos en escala 0–1 y una matriz z sobre 1.122 códigos territoriales.
- El capítulo 8 del informe presenta, por orden de etapa, las fórmulas de auditoría estructural, indicadores, controles, sensibilidad y pruebas KMO/MSA y Bartlett; separa los valores de la matriz histórica de los diagnósticos pendientes para las ocho candidatas acordadas.
- El primer PCA exploratorio se plantea con ocho indicadores; `sin_media_completa_17PM` queda reservada para sensibilidad por la composición etaria del denominador de 5+.
- Las áreas no municipalizadas se analizarán por separado. La matriz candidata completa aún contiene esos códigos y debe delimitarse el universo municipal antes del PCA.
- La corrida reporta 1.122 observaciones completas, cero faltantes y cero violaciones de los controles aritméticos programados. Estos controles no equivalen a validación conceptual o estadística del IVS.
- PCA, IVS final, validación externa con IPM e integración SECOP II 2026 siguen pendientes.

## Decisiones y archivos de trabajo

- [[Solucion_pendientes]] — decisiones acordadas, análisis y pendientes.
- [[docs/metodologia/Formulas_indicadores_IVS_candidatos_2026-10-15|Fórmulas de indicadores candidatos]] — definiciones, denominadores y sensibilidad.
- [[docs/diccionario/decisiones_variables_IVS_CNPV2018|Diccionario de decisiones de variables]].
- [[docs/calidad/auditorias/VERIFICACION_CONSOLIDADOS|Auditoría de los consolidados]].
- [[Resumen_General]] — estado general y navegación del proyecto.

## Productos reproducibles

- `R/01_verificar_consolidados.R`
- `R/05_conformar_indicadores_finales.R`
- `resultados/verificacion_consolidados/`
- `resultados/indicadores_finales_ivs_20261015/`

La matriz z actual contiene nueve columnas. Para el primer PCA se deberá seleccionar las ocho acordadas, volver a estandarizarlas sobre el universo municipal final y documentar el escenario separado de las áreas no municipalizadas.
