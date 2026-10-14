# Simple auditoría script to avoid memory issues and long command lines

# Set paths
project_dir <- '.'
datos_dir <- file.path(project_dir, 'datos')
docs_dir <- file.path(project_dir, 'docs')
diccionario_dir <- file.path(docs_dir, 'diccionario')
calidad_dir <- file.path(docs_dir, 'calidad')
metodologia_dir <- file.path(docs_dir, 'metodologia')

# Create directories
dir.create(diccionario_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(calidad_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(metodologia_dir, showWarnings = FALSE, recursive = TRUE)

# Load required libraries
suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(purrr)
  library(janitor)
  library(tibble)
})

# List files
archivos <- list.files(datos_dir, full.names = TRUE)
print(paste('Found', length(archivos), 'files'))

# Create basic inventory
inventario <- data.frame(
  archivo = basename(archivos),
  ruta = archivos,
  extension = tolower(tools::file_ext(basename(archivos))),
  stringsAsFactors = FALSE
)

# Add file info
for(i in 1:nrow(inventario)) {
  info <- file.info(inventario$ruta[i])
  inventario$tamano_KB[i] <- info$size / 1024
  inventario$fecha_mod[i] <- info$mtime
}

# Determine source and year
inventario$fuente <- 'Desconocida'
inventario$anio <- NA
inventario$tipo_info <- 'Desconocido'

for(i in 1:nrow(inventario)) {
  fname <- tolower(inventario$archivo[i])
  if(grepl('divipola', fname)) {
    inventario$fuente[i] <- 'DIVIPOLA'
    inventario$tipo_info[i] <- 'Codigos territorialesEstados Unidos del Norte America'
  } else if(grepl('anexo-censal-pobreza|ipm', fname)) {
    inventario$fuente[i] <- 'DANE/IPM'
    inventario$anio[i] <- 2018
    inventario$tipo_info[i] <- 'Indice de Pobreza Multidimensional'
  } else if(grepl('personas_demografico', fname)) {
    inventario$fuente[i] <- 'CNPV 2018'
    inventario$anio[i] <- 2018
    inventario$tipo_info[i] <- 'Personas - Demografico'
  } else if(grepl('personas_social', fname)) {
    inventario$fuente[i] <- 'CNPV 2018'
    inventario$anio[i] <- 2018
    inventario$tipo_info[i] <- 'Personas - Social'
  } else if(grepl('hogares', fname)) {
    inventario$fuente[i] <- 'CNPV 2018'
    inventario$anio[i] <- 2018
    inventario$tipo_info[i] <- 'Hogares'
  } else if(grepl('viviendas', fname)) {
    inventario$fuente[i] <- 'CNPV 2018'
    inventario$anio[i] <- 2018
    inventario$tipo_info[i] <- 'Viviendas'
  } else {
    inventario$fuente[i] <- 'Otra'
    inventario$tipo_info[i] <- 'Por determinar'
  }
}

# For Excel files, get sheet info
inventario$hojas <- NA
inventario$filas <- NA
inventario$columnas <- NA

for(i in 1:nrow(inventario)) {
  if(inventario$extension[i] %in% c('xls', 'xlsx')) {
    tryCatch({
      sheets <- excel_sheets(inventario$ruta[i])
      inventario$hojas[i] <- length(sheets)
      # Try to get dimensions from first sheet (just a sample to avoid memory issues)
      if(length(sheets) > 0) {
        df_sample <- tryCatch(read_excel(inventario$ruta[i], sheet = sheets[1], n_max = 100), error = function(e) NULL)
        if(!is.null(df_sample)) {
          inventario$columnas[i] <- ncol(df_sample)
          # Note: We're not estimating total rows to avoid memory issues
        }
      }
    }, error = function(e) {
      warning(paste('Error processing', inventario$archivo[i], ':', e$message))
    })
  } else if(inventario$extension[i] == 'csv') {
    tryCatch({
      # Count lines for CSV - but limit to avoid very large files
      if(inventario$tamano_KB[i] < 10000) {  # Less than 10MB
        lineas <- length(readLines(inventario$ruta[i]))
        inventario$filas[i] <- lineas
      } else {
        inventario$filas[i] <- NA  # Too large to count
      }
      # Get columns from first line
      muestra <- read_csv(inventario$ruta[i], n_max = 1, show_col_types = FALSE)
      inventario$columnas[i] <- ncol(muestra)
      inventario$hojas[i] <- 1
    }, error = function(e) {
      warning(paste('Error processing CSV', inventario$archivo[i], ':', e$message))
    })
  }
}

# Save inventory
write.csv(inventario, file.path(diccionario_dir, 'inventario_bases.csv'), row.names = FALSE)
print('Inventory saved')

# Create basic variable dictionary (limited to avoid memory issues)
diccionario <- data.frame(
  fuente = character(),
  archivo = character(),
  hoja = character(),
  variable_original = character(),
  descripcion = character(),
  tipo = character(),
  unidad = character(),
  anio = integer(),
  nivel_geografico = character(),
  cobertura = character(),
  na_pct = numeric(),
  candidato_ivs = character(),
  motivo = character(),
  stringsAsFactors = FALSE
)

# Process only smaller files for variable details to avoid memory issues
archivos_procesar <- inventario[inventario$tamano_KB < 5000, ]  # Less than 5MB
print(paste('Processing', nrow(archivos_procesar), 'files for variable details (smaller than 5MB)'))

for(i in 1:nrow(archivos_procesar)) {
  fila <- archivos_procesar[i, ]
  print(paste('Processing:', fila$archivo))
  
  if(fila$extension == 'csv') {
    tryCatch({
      df <- read_csv(fila$ruta, show_col_types = FALSE)
      hoja <- 'datos'
      vars <- names(df)
      for(var in vars) {
        valores <- df[[var]]
        na_pct <- mean(is.na(valores)) * 100
        nuevo <- data.frame(
          fuente = fila$fuente,
          archivo = fila$archivo,
          hoja = hoja,
          variable_original = var,
          descripcion = NA,
          tipo = class(valores)[1],
          unidad = NA,
          anio = fila$anio,
          nivel_geografico = 'Municipal',
          cobertura = NA,
          na_pct = round(na_pct, 2),
          candidato_ivs = 'Por determinar',
          motivo = 'Por determinar',
          stringsAsFactors = FALSE
        )
        diccionario <- rbind(diccionario, nuevo)
      }
      rm(df)
      gc()
    }, error = function(e) {
      warning(paste('Error processing CSV', fila$archivo, ':', e$message))
    })
  } else if(fila$extension %in% c('xls', 'xlsx')) {
    tryCatch({
      sheets <- excel_sheets(fila$ruta)
      # Limit to first few sheets to avoid too much processing
      sheets_to_process <- head(sheets, min(3, length(sheets)))
      for(sh in sheets_to_process) {
        df <- tryCatch(read_excel(fila$ruta, sheet = sh), error = function(e) {
          warning(paste('Error reading sheet', sh, 'in', fila$archivo, ':', e$message))
          return(NULL)
        })
        if(!is.null(df)) {
          hoja <- sh
          vars <- names(df)
          for(var in vars) {
            valores <- df[[var]]
            na_pct <- mean(is.na(valores)) * 100
            nuevo <- data.frame(
              fuente = fila$fuente,
              archivo = fila$archivo,
              hoja = hoja,
              variable_original = var,
              descripcion = NA,
              tipo = class(valores)[1],
              unidad = NA,
              anio = fila$anio,
              nivel_geografico = 'Municipal',
              cobertura = NA,
              na_pct = round(na_pct, 2),
              candidato_ivs = 'Por determinar',
              motivo = 'Por determinar',
              stringsAsFactors = FALSE
            )
            diccionario <- rbind(diccionario, nuevo)
          }
          rm(df)
          gc()
        }
      }
    }, error = function(e) {
      warning(paste('Error processing Excel', fila$archivo, ':', e$message))
    })
  }
}

# Save variable dictionary
if(nrow(diccionario) > 0) {
  write.csv(diccionario, file.path(diccionario_dir, 'diccionario_variables.csv'), row.names = FALSE)
  print(paste('Variable dictionary saved with', nrow(diccionario), 'variables'))
} else {
  # Create empty dictionary with correct columns
  diccionario <- data.frame(
    fuente = character(),
    archivo = character(),
    hoja = character(),
    variable_original = character(),
    descripcion = character(),
    tipo = character(),
    unidad = character(),
    anio = integer(),
    nivel_geografico = character(),
    cobertura = character(),
    na_pct = numeric(),
    candidato_ivs = character(),
    motivo = character(),
    stringsAsFactors = FALSE
  )
  write.csv(diccionario, file.path(diccionario_dir, 'diccionario_variables.csv'), row.names = FALSE)
  print('Empty variable dictionary created')
}

# Create placeholder files for other required outputs
matriz_solapamiento <- data.frame(
  variable_cnpv = character(),
  dimension_cnpv = character(),
  indicador_ipm_relacionado = character(),
  nivel_solapamiento = character(),
  decision_preliminar = character(),
  justificacion = character(),
  stringsAsFactors = FALSE
)
write.csv(matriz_solapamiento, file.path(diccionario_dir, 'matriz_ipm_cnpv.csv'), row.names = FALSE)

candidatos_ivs <- data.frame(
  id = integer(),
  variable = character(),
  fuente = character(),
  dimension = character(),
  direccion = character(),
  transformacion = character(),
  justificacion = character(),
  prioridad = character(),
  stringsAsFactors = FALSE
)
write.csv(candidatos_ivs, file.path(diccionario_dir, 'candidatos_ivs.csv'), row.names = FALSE)

cobertura_municipal <- data.frame(
  fuente = character(),
  municipios = integer(),
  coinciden_divipola = integer(),
  no_coinciden = integer(),
  duplicados = integer(),
  cobertura_pct = numeric(),
  stringsAsFactors = FALSE
)
write.csv(cobertura_municipal, file.path(calidad_dir, 'cobertura_municipal.csv'), row.names = FALSE)

# Create README files
readme_diccionario <- c(
  '# Diccionario de Variables',
  '',
  'Este documento contiene el diccionario preliminar de variables extraídas de las bases de datos.',
  '',
  '## Estructura',
  '- **fuente**: origen de los datos (DIVIPOLA, DANE/IPM, CNPV 2018, etc.)',
  '- **archivo**: nombre del archivo',
  '- **hoja**: hoja de cálculo (si aplica)',
  '- **variable_original**: nombre de la variable tal como aparece en los datos',
  '- **descripción**: descripción de lo que mide la variable (por completar)',
  '- **tipo**: tipo de dato (character, numeric, etc.)',
  '- **unidad**: unidad de medida (por completar)',
  '- **año**: año de referencia',
  '- **nivel_geografico**: nivel de agregación (municipal, departamental, etc.)',
  '- **cobertura**: porcentaje o número de municipios con datos',
  '- **na_pct**: porcentaje de valores perdidos',
  '- **candidato_ivs**: indica si la variable es candidata para el Índice de Vulnerabilidad Social (IVS)',
  '- **motivo**: justificación para la inclusión o exclusión como candidato',
  '',
  '## Próximos pasos',
  '1. Completar las descripciones y unidades consultando la documentación original.',
  '2. Evaluar cada variable como candidato al IVS siguiendo los criterios del proyecto.',
  '3. Identificar solapamiento con el IPM municipal.',
  '4. Proponer transformaciones necesarias.',
  '',
  '*Archivo generado automáticamente por el script de auditoría*'
)
writeLines(readme_diccionario, file.path(diccionario_dir, 'README.md'))

readme_calidad <- c(
  '# Auditoría de Datos',
  '',
  '## Resumen Ejecutivo',
  '',
  'Esta sección contiene los resultados de la auditoría preliminar de bases de datos.',
  '',
  '## Archivos procesados',
  paste0('- Total de archivos: ', nrow(inventario)),
  '',
  '## Variables documentadas',
  paste0('- Total de variables en diccionario: ', nrow(diccionario)),
  '',
  '*Archivo generado automáticamente por el script de auditoría*'
)
writeLines(readme_calidad, file.path(calidad_dir, 'auditoria_datos.md'))

readme_metodologia <- c(
  '# Metodología de Selección de Variables para el IVS',
  '',
  '## Criterios Utilizados',
  '',
  'En esta fase preliminar, los criterios son:',
  '',
  '1. **Fundamento conceptual**: La variable debe tener una clara relación teórica con la vulnerabilidad socioeconómica.',
  '2. **Calidad estadística**: Baja proporción de valores perdidos, suficiente variabilidad.',
  '3. **Disponibilidad municipal**: La variable debe estar disponible a nivel municipal para la mayoría de los municipios.',
  '4. **Comparabilidad**: La variable debe ser comparable entre municipios y nel tiempo (si aplica).',
  '5. **Ausencia de duplicación**: Evitar variables que midan lo mismo que otras ya incluidas.',
  '6. **Interpretabilidad**: La variable debe ser fácil de interpretar por usuarios y tomadores de decisión.',
  '',
  '## Clasificación de Variables',
  '',
  'Las variables se clasifican en cinco categorías:',
  '',
  '- **A - Candidata directa al IVS**: Cumple con los criterios anteriores y puede incluirse directamente en el análisis de componentes principales (PCA).',
  '- **B - Candidata después de transformación**: Requiere transformación (ej. proporción, tasa) antes de ser considerada.',
  '- **C - Variable de control/contexto**: Útil para el análisis descriptivo o como control en modelos, pero no componente del IVS.',
  '- **D - Variable para análisis descriptivo**: Información interesante pero no suficientemente justificada para el IVS.',
  '- **E - Excluir**: Por duplicación, mala calidad, cobertura insuficiente, falta de interpretación, etc.',
  '',
  '*Archivo generado automáticamente por el script de auditoría*'
)
writeLines(readme_metodologia, file.path(metodologia_dir, 'seleccion_variables_ivs.md'))

print('Auditoría completada. Archivos creados en:', docs_dir)