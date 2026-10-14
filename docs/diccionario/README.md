# Diccionario de Variables - Auditoría Robusta v2

Este documento contiene el diccionario estadístico y conceptual de variables extraídas
de las bases de datos del proyecto, generado mediante un proceso robusto con:
- Procesamiento completo de todas las hojas
- Chunking real para bases grandes (CSV intermedio + data.table)
- Checkpointing y reanudación
- Clasificación estadística automática

## Estructura de Directorios

- `ipm/` - Diccionario de ipm
- `divipola/` - Diccionario de divipola
- `hogares/` - Diccionario de hogares
- `personas_demografico/` - Diccionario de personas_demografico
- `personas_social/` - Diccionario de personas_social
- `viviendas/` - Diccionario de viviendas

## Columnas del Diccionario

- **fuente**: origen de los datos (DIVIPOLA, DANE/IPM, CNPV 2018, etc.)
- **archivo**: nombre del archivo
- **hoja**: hoja de cálculo (si aplica)
- **variable_original**: nombre de la variable tal como aparece en los datos
- **variable_id**: identificador técnico único
- **nombre_estandarizado**: nombre propuesto siguiendo estándares de nomenclatura
- **descripcion**: descripción de lo que mide la variable (por completar manualmente)
- **tipo_r**: tipo de dato en R (character, numeric, integer, logical)
- **tipo_estadístico**: clasificación estadística (nominal, ordinal, discreta, continua, binaria)
- **escala_medicion**: nominal, ordinal, intervalo, razon
- **naturaleza**: demografica, socioeconomica, vivienda, hogar, educacion, salud, empleo, servicios_publicos, territorial, pobreza, otra
- **unidad**: unidad de medida
- **universo**: población o fenómeno al que se refiere
- **nivel_geografico**: nivel de agregación (municipal, departamental, etc.)
- **año_referencia**: año de referencia de los datos
- **n**: número total de observaciones
- **n_validos**: número de observaciones no perdidas
- **n_missing**: número de observaciones perdidas
- **pct_missing**: porcentaje de valores perdidos
- **n_unicos**: número de valores únicos
- **pct_unicos**: porcentaje de valores únicos sobre el total
- **min, p25, mediana, media, p75, max**: estadísticas de posición (numéricas)
- **sd**: desviación estándar
- **varianza**: varianza
- **cv**: coeficiente de variación (sd/media)
- **asimetria**: coeficiente de asimetría
- **kurtosis**: coeficiente de curtosis
- **outliers_iqr**: número de outliers detectados por método IQR
- **casi_constante**: TRUE si la varianza es cercana a cero
- **identificador**: TRUE si la variable actúa como identificador
- **indicador**: TRUE si la variable es un indicador potencial
- **numerador**: variable sugerida como numerador para transformación
- **denominador**: variable sugerida como denominador para transformación
- **requiere_transformacion**: TRUE si necesita transformación para ser útil
- **transformacion_sugerida**: descripción de la transformación sugerida
- **direccion_vulnerabilidad**: + (mayor valor = mayor vulnerabilidad), - (mayor valor = menor vulnerabilidad), ? (pendiente)
- **solapamiento_ipm**: nivel de solapamiento conceptual con IPM (ninguno, bajo, medio, alto, por_determinar)
- **candidato_ivs**: clasificación preliminar (A, B, C, D, E, por_determinar)
- **categoria**: categoría final de uso (A-E, por_determinar)
- **justificacion**: explicación de la clasificación
- **confianza_clasificacion**: nivel de confianza en la clasificación (alta, media, baja)

*Generado: 2026-09-22 19:37:30*
