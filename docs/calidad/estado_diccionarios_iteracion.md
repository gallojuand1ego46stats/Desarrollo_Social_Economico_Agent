# Reporte de Ejecución - Auditoría v2

**Fecha:** 2026-09-22 19:37:30
**Proyecto:** C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent

## Resumen de Procesamiento

| Fuente | Archivo | Hojas | Variables | Estado | Tiempo (min) |
|--------|---------|-------|-----------|--------|--------------|
| DANE/IPM | anexo-censal-pobreza-municipal-2018.xlsx | 6 | 85 | COMPLETO | 0.1 |
| DIVIPOLA | DIVIPOLA-_Códigos_municipios_20260917.csv | 1 | 7 | COMPLETO | 0.0 |
| CNPV 2018 | HOGARES_Cuadros_CNPV_2018.XLSX | 6 | 85 | COMPLETO | 0.1 |
| CNPV 2018 | PERSONAS_DEMOGRAFICO_Cuadros_CNPV_2018.xlsx | 33 | 799 | COMPLETO | 1.1 |
| CNPV 2018 | PERSONAS_SOCIAL_Cuadros_CNPV_2018.XLSX | 22 | 508 | COMPLETO | 3.0 |
| CNPV 2018 | VIVIENDAS_Cuadros_CNPV_2018.XLSX | 20 | 373 | COMPLETO | 0.3 |

## Detalle por Fuente

### DANE/IPM
- **Archivo:** anexo-censal-pobreza-municipal-2018.xlsx
- **Variables documentadas:** 85
- **Hojas procesadas:** 6
- **Estado:** COMPLETO
- **Tiempo:** 0.1 min

### DIVIPOLA
- **Archivo:** DIVIPOLA-_Códigos_municipios_20260917.csv
- **Variables documentadas:** 7
- **Hojas procesadas:** 1
- **Estado:** COMPLETO
- **Tiempo:** 0.0 min

### CNPV 2018
- **Archivo:** HOGARES_Cuadros_CNPV_2018.XLSX
- **Variables documentadas:** 85
- **Hojas procesadas:** 6
- **Estado:** COMPLETO
- **Tiempo:** 0.1 min

### CNPV 2018
- **Archivo:** PERSONAS_DEMOGRAFICO_Cuadros_CNPV_2018.xlsx
- **Variables documentadas:** 799
- **Hojas procesadas:** 33
- **Estado:** COMPLETO
- **Tiempo:** 1.1 min

### CNPV 2018
- **Archivo:** PERSONAS_SOCIAL_Cuadros_CNPV_2018.XLSX
- **Variables documentadas:** 508
- **Hojas procesadas:** 22
- **Estado:** COMPLETO
- **Tiempo:** 3.0 min

### CNPV 2018
- **Archivo:** VIVIENDAS_Cuadros_CNPV_2018.XLSX
- **Variables documentadas:** 373
- **Hojas procesadas:** 20
- **Estado:** COMPLETO
- **Tiempo:** 0.3 min

## Diccionarios Generados

- **ipm**: 85 variables → `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent/docs/diccionario/ipm/diccionario_ipm.csv`, `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent/docs/diccionario/ipm/diccionario_ipm.xlsx`
- **divipola**: 7 variables → `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent/docs/diccionario/divipola/diccionario_divipola.csv`, `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent/docs/diccionario/divipola/diccionario_divipola.xlsx`
- **hogares**: 85 variables → `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent/docs/diccionario/hogares/diccionario_hogares.csv`, `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent/docs/diccionario/hogares/diccionario_hogares.xlsx`
- **personas_demografico**: 799 variables → `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent/docs/diccionario/personas_demografico/diccionario_personas_demografico.csv`, `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent/docs/diccionario/personas_demografico/diccionario_personas_demografico.xlsx`
- **personas_social**: 508 variables → `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent/docs/diccionario/personas_social/diccionario_personas_social.csv`, `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent/docs/diccionario/personas_social/diccionario_personas_social.xlsx`
- **viviendas**: 373 variables → `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent/docs/diccionario/viviendas/diccionario_viviendas.csv`, `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent/docs/diccionario/viviendas/diccionario_viviendas.xlsx`

## Validaciones

- [x] Inventario de bases completado
- [x] Diccionarios por fuente generados (CSV + XLSX)
- [x] Diccionario global consolidado
- [x] Cobertura territorial calculada
- [x] Auditoría IPM realizada
- [x] Matriz de solapamiento inicializada
- [x] Banco de candidatos IVS creado
- [x] Checkpointing implementado
- [x] Chunking real para bases grandes

## Problemas / Pendientes

- Matriz IPM-CNPV: requiere análisis manual
- Candidatos IVS: clasificación preliminar pendiente
- Direcciones de vulnerabilidad: muchas en '?' requieren validación
- Descripciones de variables: todas en NA, requieren completado manual

*Reporte generado automáticamente el 2026-09-22 19:37:30*
