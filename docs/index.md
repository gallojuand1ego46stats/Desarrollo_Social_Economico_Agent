# Desarrollo Social y Económico

Proyecto de análisis territorial de vulnerabilidad socioeconómica municipal con datos agregados del CNPV 2018. La comparación con contratación pública de SECOP II es una etapa posterior del proyecto.

## Estado al 18 de octubre de 2026

Se auditaron los consolidados CNPV/IPM y se calcularon ocho indicadores candidatos, descriptivos y sensibilidades. El IPM se reserva como contraste externo. El PCA exploratorio, el IVS validado y la integración con SECOP II continúan pendientes; los resultados actuales no constituyen un índice final.

## Documentos principales

- [Informe metodológico v2.1 (PDF)](informe1_metodologico/Informe1_Metodologico.pdf)
- [Actualización descriptiva: decisiones, fuentes y salidas](calidad/auditorias/ACTUALIZACION_DESCRIPTIVA_20261018.md)
- [Control de entrega y verificaciones](calidad/auditorias/CONTROL_ENTREGA_DESCRIPTIVA_20261018.md)
- [Auditoría de los consolidados](calidad/auditorias/VERIFICACION_CONSOLIDADOS.md)
- [Fórmulas de los indicadores candidatos](metodologia/Formulas_indicadores_IVS_candidatos_2026-10-15.md)
- [Diccionario de decisiones de variables](diccionario/decisiones_variables_IVS_CNPV2018.csv)

## Código y resultados

Los scripts reproducibles están en `R/`. El flujo vigente de análisis utiliza los libros fuente y las tablas intermedias agregadas de `datos/`; los controles, matrices candidatas y sensibilidades están en `resultados/`. `data/` conserva una estructura de ingesta inicial y es el destino de `R/00_ingesta_fuentes.R`; no es la carpeta de las tablas utilizadas por `R/06`.

La actualización del 18 de octubre se recalcula con `Rscript R/06_descriptivos_sensibilidades_ivs.R` desde la raíz del repositorio, usando R 4.6.0 y tablas intermedias versionadas. El cotejo independiente en Python requiere `openpyxl==3.1.5` (`requirements-analysis.txt`). Este flujo no reconstruye desde los libros Excel, no ejecuta PCA y no calcula un IVS. El flujo de GitHub Actions construye el sitio de documentación, no ejecuta el análisis estadístico. El alcance, las limitaciones y los archivos de cada etapa se describen en el informe metodológico.
