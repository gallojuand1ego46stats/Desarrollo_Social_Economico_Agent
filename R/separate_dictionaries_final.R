# Script to create separate dictionaries for each base
# Run this from R/ folder

# Set paths
project_dir <- "C:/Users/juand/Projects/Desarrollo_Social_Economico_Agent"
datos_dir <- file.path(project_dir, "datos")
docs_dir <- file.path(project_dir, "docs")
diccionario_dir <- file.path(docs_dir, "diccionario")

# Create main diccionario directory if it doesn't exist
dir.create(diccionario_dir, showWarnings = FALSE, recursive = TRUE)

# Define the bases to process
bases <- list(
  ipm = list(
    file = "anexo-censal-pobreza-municipal-2018.xlsx",
    dir = "ipm",
    name = "IPM Municipal 2018"
  ),
  divipola = list(
    file = "DIVIPOLA-_Códigos_municipios_20260917.csv",
    dir = "divipola",
    name = "DIVIPOLA Códigos Territoriales"
  ),
  hogares = list(
    file = "HOGARES_Cuadros_CNPV_2018.XLSX",
    dir = "hogares",
    name = "CNPV 2018 - Hogares"
  ),
  personas_demografico = list(
    file = "PERSONAS_DEMOGRAFICO_Cuadros_CNPV_2018.xlsx",
    dir = "personas_demografico",
    name = "CNPV 2018 - Personas Demográfico"
  ),
  personas_social = list(
    file = "PERSONAS_SOCIAL_Cuadros_CNPV_2018.XLSX",
    dir = "personas_social",
    name = "CNPV 2018 - Personas Social"
  ),
  viviendas = list(
    file = "VIVIENDAS_Cuadros_CNPV_2018.XLSX",
    dir = "viviendas",
    name = "CNPV 2018 - Viviendas"
  )
)

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

# Ensure openxlsx is installed
if (!requireNamespace("openxlsx", quietly = TRUE)) {
  install.packages("openxlsx")
}
library(openxlsx)

# Function to create directory for a base
create_base_dir <- function(base_dir) {
  dir.create(file.path(diccionario_dir, base_dir), showWarnings = FALSE, recursive = TRUE)
}

# Function to get basic file info
get_file_info <- function(file_path) {
  info <- file.info(file_path)
  list(
    size_kb = info$size / 1024,
    modified = info$mtime
  )
}

# Function to detect header row (simplified version)
detect_header_row <- function(df_sample) {
  if (nrow(df_sample) == 0) return(1)
  
  # Look for rows that look like headers
  header_patterns <- c("municipio", "departamento", "codigo", "variable", "categoria", 
                      "total", "porcentaje", "frecuencia", "numero", "poblacion", 
                      "vivienda", "hogar", "persona", "edad", "sexo", "nivel", 
                      "servicio", "acueducto", "alcantarillado", "energia", "gas", 
                      "basura", "educacion", "salud", "trabajo", "empleo", 
                      "desempleo", "pobreza", "privacion", "hacinamiento",
                      "material", "pared", "piso", "techo", "tenencia", "ocupacion")
  
  n_rows <- min(5, nrow(df_sample))
  for (row in 1:n_rows) {
    row_vals <- as.character(unlist(df_sample[row, ]))
    row_vals <- tolower(row_vals[row_vals != "" & !is.na(row_vals)])
    
    if (length(row_vals) == 0) next
    
    # Count how many header patterns match
    matches <- sum(str_detect(row_vals, regex(paste(header_patterns, collapse = "|"), ignore_case = TRUE)))
    
    if (matches >= 2) {
      return(row)
    }
    
    # Also consider rows with mostly short text (likely variable names)
    if (length(row_vals) > 0) {
      prop_short <- mean(nchar(row_vals) <= 20 & nchar(row_vals) > 0)
      if (prop_short > 0.7 && length(unique(row_vals)) > 2) {
        return(row)
      }
    }
  }
  
  return(1)  # Default to first row
}

# Function to process a single base
process_base <- function(base_key, base_info) {
  cat("Processing:", base_info$name, "\n")
  file_path <- file.path(datos_dir, base_info$file)
  
  if (!file.exists(file_path)) {
    warning(paste("File not found:", file_path))
    return(NULL)
  }
  
  # Create directory for this base
  base_dir <- file.path(diccionario_dir, base_info$dir)
  create_base_dir(base_dir)
  
  # Get file info
  file_info <- get_file_info(file_path)
  
  # Determine file extension
  ext <- tolower(tools::file_ext(base_info$file))
  
  # Get sheets
  if (ext %in% c("xls", "xlsx")) {
    sheets <- excel_sheets(file_path)
  } else if (ext == "csv") {
    sheets <- "datos"
  } else {
    stop("Unsupported file format")
  }
  
  cat("  Found", length(sheets), "sheets\n")
  
  # Initialize dictionary
  dictionary <- list()
  
  # Process each sheet
  for (sheet in sheets) {
    cat("  Processing sheet:", sheet, "\n")
    
    # Read a sample to detect header
    sample_size <- 100
    df_sample <- tryCatch(
      if (ext %in% c("xls", "xlsx")) {
        read_excel(file_path, sheet = sheet, n_max = sample_size)
      } else if (ext == "csv") {
        read_csv(file_path, n_max = sample_size, show_col_types = FALSE)
      },
      error = function(e) {
        warning(paste("Error reading sample for sheet", sheet, ":", e$message))
        return(NULL)
      }
    )
    
    if (is.null(df_sample) || nrow(df_sample) == 0) {
      warning(paste("Could not read sample for sheet", sheet))
      next
    }
    
    # Detect header row
    header_row <- detect_header_row(df_sample)
    cat("    Detected header row:", header_row, "\n")
    
    # Read the full sheet with proper header
    df <- tryCatch(
      if (ext %in% c("xls", "xlsx")) {
        if (header_row > 1) {
          read_excel(file_path, sheet = sheet, skip = header_row - 1)
        } else {
          read_excel(file_path, sheet = sheet)
        }
      } else if (ext == "csv") {
        read_csv(file_path, show_col_types = FALSE)
      },
      error = function(e) {
        warning(paste("Error reading sheet", sheet, ":", e$message))
        return(NULL)
      }
    )
    
    if (is.null(df) || nrow(df) == 0) {
      warning(paste("Sheet", sheet, "resulted in empty data"))
      next
    }
    
    # Clean column names for internal use but keep originals
    orig_names <- names(df)
    clean_names <- make.names(orig_names, unique = TRUE)
    names(df) <- clean_names  # For internal processing
    
    # Process each column/variable
    for (col_idx in seq_along(orig_names)) {
      var_name <- orig_names[col_idx]
      values <- df[[col_idx]]
      
      # Skip if all values are NA
      if (all(is.na(values))) next
      
      # Basic stats
      n_total <- length(values)
      n_valid <- sum(!is.na(values))
      n_missing <- sum(is.na(values))
      pct_missing <- if (n_total > 0) (n_missing / n_total) * 100 else 0
      
      # Unique values
      unique_vals <- unique(values[!is.na(values)])
      n_unique <- length(unique_vals)
      pct_unique <- if (n_valid > 0) (n_unique / n_valid) * 100 else 0
      
      # Determine types
      type_r <- class(values)[1]
      
      # Initialize variable entry
      var_entry <- list(
        fuente = base_info$name,
        archivo = base_info$file,
        hoja = sheet,
        variable_original = var_name,
        variable_id = paste(base_info$dir, make.names(var_name), sep = "_"),
        nombre_estandarizado = var_name,  # Will be improved later
        descripcion = NA_character_,
        tipo_r = type_r,
        tipo_estadistico = NA_character_,
        escala_medicion = NA_character_,
        naturaleza = NA_character_,
        unidad = NA_character_,
        universo = NA_character_,
        nivel_geografico = "Municipal",
        ano_referencia = ifelse(base_info$name == "DIVIPOLA Códigos Territoriales", NA, 2018),
        n = n_total,
        n_validos = n_valid,
        n_missing = n_missing,
        pct_missing = round(pct_missing, 2),
        n_unicos = n_unique,
        pct_unicos = round(pct_unique, 2),
        min = NA_real_,
        p01 = NA_real_,
        p05 = NA_real_,
        p25 = NA_real_,
        mediana = NA_real_,
        p75 = NA_real_,
        p95 = NA_real_,
        p99 = NA_real_,
        max = NA_real_,
        media = NA_real_,
        sd = NA_real_,
        varianza = NA_real_,
        cv = NA_real_,
        asimetria = NA_real_,
        kurtosis = NA_real_,
        outliers_iqr = NA_integer_,
        casi_constante = NA,
        identificador = NA,
        indicador = NA,
        conteo = NA,
        proporcion = NA,
        porcentaje = NA,
        tasa = NA,
        razon = NA,
        indice = NA,
        codigo_territorial = NA,
        numerador = NA_character_,
        denominador = NA_character_,
        requiere_transformacion = NA,
        transformacion_sugerida = NA_character_,
        direccion_vulnerabilidad = NA_character_,
        solapamiento_ipm = NA_character_,
        posible_uso = NA_character_,
        candidato_ivs = NA_character_,
        categoria_uso = NA_character_,
        justificacion = "Análisis pendiente",
        confianza_clasificacion = "baja",
        requiere_revision = TRUE,
        observaciones = NA_character_,
        stringsAsFactors = FALSE
      )
      
      # Fill in statistical properties for numeric variables
      if (is.numeric(values) && !all(is.na(values))) {
        valid_vals <- values[!is.na(values)]
        
        if (length(valid_vals) > 0) {
          var_entry$min <- min(valid_vals, na.rm = TRUE)
          var_entry$p01 <- quantile(valid_vals, 0.01, na.rm = TRUE)
          var_entry$p05 <- quantile(valid_vals, 0.05, na.rm = TRUE)
          var_entry$p25 <- quantile(valid_vals, 0.25, na.rm = TRUE)
          var_entry$mediana <- median(valid_vals, na.rm = TRUE)
          var_entry$p75 <- quantile(valid_vals, 0.75, na.rm = TRUE)
          var_entry$p95 <- quantile(valid_vals, 0.95, na.rm = TRUE)
          var_entry$p99 <- quantile(valid_vals, 0.99, na.rm = TRUE)
          var_entry$max <- max(valid_vals, na.rm = TRUE)
          var_entry$media <- mean(valid_vals, na.rm = TRUE)
          var_entry$sd <- sd(valid_vals, na.rm = TRUE)
          var_entry$varianza <- var(valid_vals, na.rm = TRUE)
          
          if (!is.na(var_entry$media) && var_entry$media != 0) {
            var_entry$cv <- (var_entry$sd / var_entry$media) * 100
          }
          
          # Skewness and kurtosis (for sample size >= 3)
          if (length(valid_vals) >= 3) {
            m3 <- mean((valid_vals - var_entry$media)^3, na.rm = TRUE)
            m4 <- mean((valid_vals - var_entry$media)^4, na.rm = TRUE)
            if (var_entry$sd > 0) {
              var_entry$asimetria <- m3 / (var_entry$sd^3)
              var_entry$kurtosis <- (m4 / (var_entry$sd^4)) - 3
            }
          }
          
          # Outliers via IQR
          q1 <- var_entry$p25
          q3 <- var_entry$p75
          iqr <- q3 - q1
          lower_bound <- q1 - 1.5 * iqr
          upper_bound <- q3 + 1.5 * iqr
          var_entry$outliers_iqr <- sum(valid_vals < lower_bound | valid_vals > upper_bound, na.rm = TRUE)
          
          # Nearly constant
          var_entry$casi_constante <- (var_entry$varianza < 1e-10) || (n_unique <= 1)
        }
      }
      
      # For categorical variables, get mode
      if (!is.numeric(values) || all(is.na(values))) {
        if (n_valid > 0) {
          vals_cat <- values[!is.na(values)]
          if (length(vals_cat) > 0) {
            tbl <- table(vals_cat)
            if (length(tbl) > 0) {
              mode_val <- names(tbl)[which.max(tbl)]
              mode_freq <- max(tbl)
              # We'll store this in observaciones for now
              var_entry$observaciones <- paste("Modo:", mode_val, "(frecuencia:", mode_freq, ")")
            }
          }
        }
      }
      
      # Determine if it's an identifier
      var_entry$identificador <- (
        grepl("(codigo|cod|id|identifier|clave|llave)", tolower(var_name), ignore.case = TRUE) ||
        (n_unique / n_valid > 0.95 && n_valid > 10)
      )
      
      # Determine if it's a territorial code (specifically for DIVIPOLA)
      var_entry$codigo_territorial <- (
        base_info$dir == "divipola" && 
          grepl("(codigo|departamento|municipio)", tolower(var_name), ignore.case = TRUE)
      )
      
      # Determine if it's a count variable
      var_entry$conteo <- (
        is.numeric(values) && 
          grepl("(numero|total|cantidad|count|sum)", tolower(var_name), ignore.case = TRUE) &&
          !grepl("(porcentaje|pct|%|ratio|proporcion|tasa|rate|por mil|por cien)", tolower(var_name), ignore.case = TRUE)
      )
      
      # Determine if it's a proportion/percentage/rate
      var_entry$proporcion <- grepl("(proporcion|prop|ratio)", tolower(var_name), ignore.case = TRUE)
      var_entry$porcentaje <- grepl("(porcentaje|pct|%)", tolower(var_name), ignore.case = TRUE)
      var_entry$tasa <- grepl("(tasa|rate)", tolower(var_name), ignore.case = TRUE)
      var_entry$razon <- grepl("(razon|reason)", tolower(var_name), ignore.case = TRUE)
      var_entry$indice <- grepl("(indice|index)", tolower(var_name), ignore.case = TRUE)
      
      # Determine if it's an indicator (not an identifier, has variability)
      var_entry$indicador <- !var_entry$identificador && 
        (!is.numeric(values) || (is.numeric(values) && !var_entry$casi_constante && n_valid > 1))
      
      # Suggest transformation for count variables
      if (var_entry$conteo && !var_entry$proporcion && !var_entry$porcentaje && !var_entry$tasa) {
        var_entry$requiere_transformacion <- TRUE
        # Suggest common denominators based on variable name
        if (grepl("vivienda", tolower(var_name))) {
          var_entry$transformacion_sugerida <- "proporcion sobre total_viviendas"
        } else if (grepl("hogar", tolower(var_name))) {
          var_entry$transformacion_sugerida <- "proporcion sobre total_hogares"
        } else if (grepl("persona|poblacion", tolower(var_name))) {
          var_entry$transformacion_sugerida <- "proporcion sobre total_poblacion"
        } else {
          var_entry$transformacion_sugerida <- "transformacion_por_determinar"
        }
      } else {
        var_entry$requiere_transformacion <- FALSE
      }
      
      # Infer vulnerability direction
      var_entry$direccion_vulnerabilidad <- "?"
      name_lower <- tolower(var_name)
      
      # Variables that indicate improvements (higher value = less vulnerability)
      improvement_patterns <- c(
        "acceso", "cobertura", "servicio", "acueducto", "alcantarillado", 
        "energia", "electricidad", "gas", "basura", "recoleccion",
        "educacion", "escuela", "alfabetismo", "aprobacion", "promocion",
        "salud", "seguro", "vacuna", "atencion", "hospital",
        "trabajo", "empleo", "ingreso", "salario", "ocupacion",
        "viviendo", "propietario", "formal"
      )
      
      # Variables that indicate deprivations (higher value = more vulnerability)
      deprivation_patterns <- c(
        "pobreza", "privacion", "insatisfaccion", "carencia", "deficiencia",
        "hacinamiento", "inadecuado", "inadequado", "sin", "carece",
        "desempleo", "paro", "inactivo", "analfabetismo", "no asistente",
        "no aprobado", "desercion", "reprobado", "inseguridad",
        "violencia", "delito", "contaminacion"
      )
      
      if (any(str_detect(name_lower, regex(paste(improvement_patterns, collapse = "|"), ignore_case = TRUE)))) {
        var_entry$direccion_vulnerabilidad <- "-"
      } else if (any(str_detect(name_lower, regex(paste(deprivation_patterns, collapse = "|"), ignore_case = TRUE)))) {
        var_entry$direccion_vulnerabilidad <- "+"
      }
      
      # Add to dictionary
      dictionary[[length(dictionary) + 1]] <- var_entry
    }
  }
  
  # Convert list to data frame
  if (length(dictionary) > 0) {
    # Convert list of lists to data frame
    dict_df <- bind_rows(dictionary)
    
    # Save as CSV
    csv_path <- file.path(base_dir, paste0("diccionario_", base_info$dir, ".csv"))
    write.csv(dict_df, csv_path, row.names = FALSE, fileEncoding = "UTF-8")
    cat("  Saved CSV to:", csv_path, "\n")
    
    # Save as XLSX with multiple sheets
    xlsx_path <- file.path(base_dir, paste0("diccionario_", base_info$dir, ".xlsx"))
    
    # Create workbook
    wb <- createWorkbook()
    
    # Sheet 1: Dictionary
    addWorksheet(wb, "DICCIONARIO")
    writeData(wb, "DICCIONARIO", dict_df)
    
    # Sheet 2: Summary
    summary_df <- data.frame(
      Item = c(
        "Total Hojas Procesadas", "Total Variables", "Variables Numéricas",
        "Variables Categóricas", "Identificadores", "Códigos Territoriales",
        "Conteos", "Proporciones", "Tasas", "Índices", "Variables con Missing Alto",
        "Variables que Requieren Transformación", "Variables que Requieren Revisión"
      ),
      Valor = c(
        length(unique(dict_df$hoja)),
        nrow(dict_df),
        sum(!is.na(dict_df$tipo_r) & dict_df$tipo_r %in% c("numeric", "integer")),
        sum(!is.na(dict_df$tipo_r) & !(dict_df$tipo_r %in% c("numeric", "integer"))),
        sum(dict_df$identificador == TRUE, na.rm = TRUE),
        sum(dict_df$codigo_territorial == TRUE, na.rm = TRUE),
        sum(dict_df$conteo == TRUE, na.rm = TRUE),
        sum(dict_df$proporcion == TRUE, na.rm = TRUE),
        sum(dict_df$tasa == TRUE, na.rm = TRUE),
        sum(dict_df$indice == TRUE, na.rm = TRUE),
        sum(dict_df$pct_missing > 50, na.rm = TRUE),
        sum(dict_df$requiere_transformacion == TRUE, na.rm = TRUE),
        sum(dict_df$requiere_revision == TRUE, na.rm = TRUE)
      )
    )
    addWorksheet(wb, "RESUMEN")
    writeData(wb, "RESUMEN", summary_df)
    
    # Sheet 3: Relevant Variables (potential for IVS)
    relevant_df <- dict_df[
      dict_df$candidato_ivs %in% c("si", "revisar") | 
        dict_df$categoria_uso %in% c("A", "B", "C") |
        !is.na(dict_df$direccion_vulnerabilidad) & dict_df$direccion_vulnerabilidad != "?",
      c("variable_original", "hoja", "descripcion", "tipo_r", "tipo_estadistico", 
        "nivel_geografico", "unidad", "pct_missing", "candidato_ivs", 
        "categoria_uso", "direccion_vulnerabilidad", "solapamiento_ipm",
        "requiere_transformacion", "transformacion_sugerida")
    ]
    if (nrow(relevant_df) > 0) {
      addWorksheet(wb, "VARIABLES_RELEVANTES")
      writeData(wb, "VARIABLES_RELEVANTES", relevant_df)
    }
    
    # Sheet 4: Problems
    problems_df <- dict_df[
      dict_df$requiere_revision == TRUE |
        dict_df$pct_missing > 80 |
        dict_df$casi_constante == TRUE |
        is.na(dict_df$descripcion),
      c("variable_original", "hoja", "descripcion", "tipo_r", "pct_missing", 
        "casi_constante", "requiere_revision", "observaciones")
    ]
    if (nrow(problems_df) > 0) {
      addWorksheet(wb, "PROBLEMAS")
      writeData(wb, "PROBLEMAS", problems_df)
    }
    
    # Sheet 5: Methodology
    methodology_text <- c(
      "Metodología de creación del diccionario:",
      "",
      "1. Lectura de archivos: Se procesó cada hoja del archivo original.",
      "2. Detección de encabezados: Se identificó automáticamente la fila de encabezado.",
      "3. Tipificación: Se determinó el tipo de dato en R y el tipo estadístico.",
      "4. Estadísticas: Se calcularon métricas descriptivas para variables numéricas.",
      "5. Identificación: Se marcaron identificadores, códigos territoriales y variables de conteo.",
      "6. Transformaciones: Se sugirieron transformaciones para variables de conteo absoluto.",
      "7. Dirección de vulnerabilidad: Se infirió conceptual mente si el valor aumenta o disminuye la vulnerabilidad.",
      "8. Solapamiento con IPM: Se marcó para revisión manual posterior.",
      "",
      "Columnas clave:",
      "- variable_original: Nombre tal como aparece en los datos",
      "- nombre_estandarizado: Nombre propuesto (actualmente igual al original)",
      "- descripcion: Qué mide la variable (por completar manualmente)",
      "- tipo_r: Tipo de dato en R (character, numeric, etc.)",
      "- tipo_estadistico: Clasificación estadística (nominal, ordinal, continua, etc.)",
      "- naturaleza: Categoría temática (demografica, socioeconomica, vivienda, etc.)",
      "- unidad: Unidad de medida",
      "- nivel_geografico: Nivel de agregación (municipal, departamental)",
      "- pct_missing: Porcentaje de valores perdidos",
      "- candidato_ivs: si/no/revisar - indicación preliminar de uso en IVS",
      "- categoria_uso: A/B/C/D/E - clasificación de uso potencial",
      "- direccion_vulnerabilidad: + (mayor valor = más vulnerabilidad), - (mayor valor = menos vulnerabilidad), ? (pendiente)",
      "- requiere_transformacion: si la variable necesita transformación para ser útil",
      "- transformacion_sugerida: cómo transformarla sugerido",
      "- solapamiento_ipm: nivel de solapamiento conceptual con IPM (requiere revisión manual)",
      "",
      "NOTA: Este diccionario es para revisión manual. No se han realizado transformaciones",
      "sobre los datos originales. Todas las decisiones de inclusión en el IVS se tomarán",
      "en una fase posterior basada en análisis conceptual y estadístico."
    )
    addWorksheet(wb, "METODOLOGIA")
    writeData(wb, "METODOLOGIA", data.frame(Linea = methodology_text), colNames = FALSE)
    
    # Save workbook
    saveWorkbook(wb, xlsx_path, overwrite = TRUE)
    cat("  Saved XLSX to:", xlsx_path, "\n")
  } else {
    warning("No variables found for this base")
  }
  
  cat("  Completed processing", base_info$name, "\n\n")
  return(base_info$dir)
}

# Process each base
processed_bases <- list()
for (base_key in names(bases)) {
  base_info <- bases[[base_key]]
  result <- tryCatch(
    process_base(base_key, base_info),
    error = function(e) {
      warning(paste("Error processing base", base_info$name, ":", e$message))
      return(NULL)
    }
  )
  if (!is.null(result)) {
    processed_bases[[base_key]] <- result
  }
}

# Create general README
readme_content <- c(
  "# Diccionario de Variables por Base",
  "",
  "Este documento contiene los diccionarios estadísticos separados para cada una de las",
  "seis bases de datos del proyecto. Cada base tiene su propio directorio con archivos",
  "CSV y XLSX que contienen la documentación detallada de sus variables.",
  "",
  "## Estructura de Directorios",
  "",
  foreach(base_key = names(bases)) {
    base_info <- bases[[base_key]]
    sprintf("- `%s/` - %s", base_info$dir, base_info$name)
  },
  "",
  "## Contenido de Cada Diccionario",
  "",
  "Cada diccionario contiene las siguientes hojas (en el archivo XLSX):",
  "",
  "1. **DICCIONARIO**: Todas las variables con su caracterización estadística completa",
  "2. **RESUMEN**: Estadísticas generales sobre el diccionario",
  "3. **VARIABLES_RELEVANTES**: Variables potencialmente relacionadas con vulnerabilidad",
  "4. **PROBLEMAS**: Variables que requieren atención especial",
  "5. **METODOLOGIA**: Explicación de cómo se creó el diccionario",
  "",
  "## Columnas del Diccionario",
  "",
  "Cada diccionario contiene las siguientes columnas:",
  "",
  "- **fuente**: Nombre descriptivo de la base",
  "- **archivo**: Nombre del archivo original",
  "- **hoja**: Hoja de cálculo donde se encontró la variable",
  "- **variable_original**: Nombre tal como aparece en los datos",
  "- **variable_id**: Identificador técnico único",
  "- **nombre_estandarizado**: Nombre propuesto siguiendo estándares de nomenclatura",
  "- **descripcion**: Descripción de lo que mide la variable",
  "- **tipo_r**: Tipo de dato en R (character, numeric, integer, logical)",
  "- **tipo_estadistico**: Clasificación estadística (nominal, ordinal, discreta, continua, proporcion, porcentaje, tasa, razon, conteo, indice, identificador, codigo_territorial)",
  "- **escala_medicion**: nominal, ordinal, intervalo, razon",
  "- **naturaleza**: demografica, socioeconomica, vivienda, hogar, educacion, salud, empleo_trabajo, servicios_publicos, territorial, pobreza, social, otra",
  "- **unidad**: Unidad de medida",
  "- **universo**: Población o fenómeno al que se refiere",
  "- **nivel_geografico**: nivel de agregación (municipal, departamental, etc.)",
  "- **ano_referencia**: Año de referencia de los datos",
  "- **n**: Número total de observaciones",
  "- **n_validos**: Número de observaciones no perdidas",
  "- **n_missing**: Número de observaciones perdidas",
  "- **pct_missing**: Porcentaje de valores perdidos",
  "- **n_unicos**: Número de valores únicos",
  "- **pct_unicos**: Porcentaje de valores únicos sobre el total",
  "- **min, p01, p05, p25, mediana, p75, p95, p99, max**: Estadísticas de posición",
  "- **media**: Media aritmética",
  "- **sd**: Desviación estándar",
  "- **varianza**: Varianza",
  "- **cv**: Coeficiente de variación (sd/media)",
  "- **asimetria**: Coeficiente de asimetría",
  "- **kurtosis**: Coeficiente de curtosis",
  "- **outliers_iqr**: Número de outliers detectados por método IQR",
  "- **casi_constante**: TRUE si la varianza es cercana a cero",
  "- **identificador**: TRUE si la variable actúa como identificador",
  "- **indicador**: TRUE si la variable es un indicador potencial",
  "- **conteo**: TRUE si la variable representa un conteo absoluto",
  "- **proporcion**: TRUE si la variable ya es una proporción",
  "- **porcentaje**: TRUE si la variable ya es un porcentaje",
  "- **tasa**: TRUE si la variable ya es una tasa",
  "- **razon**: TRUE si la variable ya es una razón",
  "- **indice**: TRUE si la variable ya es un índice",
  "- **codigo_territorial**: TRUE si la variable es un código territorial (DIVIPOLA)",
  "- **numerador**: Variable sugerida como numerador para transformación",
  "- **denominador**: Variable sugerida como denominador para transformación",
  "- **requiere_transformacion**: TRUE si necesita transformación para ser útil",
  "- **transformacion_sugerida**: Descripción de la transformación sugerida",
  "- **direccion_vulnerabilidad**: + (mayor valor = mayor vulnerabilidad), - (mayor valor = menor vulnerabilidad), ? (pendiente)",
  "- **solapamiento_ipm**: nivel de solapamiento conceptual con IPM (alto, medio, bajo, ninguno, requiere_revision)",
  "- **posible_uso**: clasificación preliminar de uso (candidato_ivs, control, descriptiva, identificador, codigo_territorial, posible_transformacion, excluir_tecnicamente, requiere_revision)",
  "- **candidato_ivs**: si/no/revisar - indicación preliminar de uso en IVS",
  "- **categoria_uso**: A/B/C/D/E - clasificación de uso potencial",
  "- **justificacion**: explicación de la clasificación",
  "- **confianza_clasificacion**: nivel de confianza en la clasificación (alta, media, baja)",
  "- **requiere_revision**: TRUE si requiere revisión manual de definición o uso",
  "- **observaciones**: notas adicionales sobre la variable",
  "",
  "## Próximos Pasos",
  "",
  "1. Revisar manualmente cada diccionario (preferiblemente los archivos XLSX) para:",
  "   - Completar las descripciones y unidades",
  "   - Validar las clasificaciones estadísticas y conceptuales",
  "   - Determinar el uso apropiado de cada variable",
  "",
  "2. Después de la revisión manual, proceder con:",
  "   - Análisis de solapamiento entre IPM y variables del CNPV",
  "   - Selección de variables para el IVS basada en criterios conceptuales y estadísticos",
  "   - Aplicación de transformaciones sugeridas",
  "   - Construcción de la base analítica para el IVS",
  "",
  "*Documentación generada automáticamente*"
)
writeLines(readme_content, file.path(diccionario_dir, "README.md"))

# Print summary
cat("\n" + "="*50 + "\n")
cat("RESUMEN DE PROCESAMIENTO\n")
cat("="*50 + "\n")

summary_df <- data.frame(
  Base = character(),
  Archivo = character(),
  Hojas = integer(),
  Variables = integer(),
  Variables_Numericas = integer(),
  Variables_Categoricas = integer(),
  Identificadores = integer(),
  Codigos_Territoriales = integer(),
  Conteos = integer(),
  Proporciones = integer(),
  Tasas = integer(),
  Indices = integer(),
  Requieren_Revision = integer(),
  stringsAsFactors = FALSE
)

for (base_key in names(bases)) {
  base_info <- bases[[base_key]]
  base_dir <- file.path(diccionario_dir, base_info$dir)
  
  # Try to read the CSV to get stats
  csv_path <- file.path(base_dir, paste0("diccionario_", base_info$dir, ".csv"))
  
  if (file.exists(csv_path)) {
    dict_data <- read.csv(csv_path, stringsAsFactors = FALSE)
    
    hoja_count <- length(unique(dict_data$hoja))
    var_count <- nrow(dict_data)
    num_count <- sum(!is.na(dict_data$tipo_r) & dict_df$tipo_r %in% c("numeric", "integer"))
    cat_count <- sum(!is.na(dict_data$tipo_r) & !(dict_data$tipo_r %in% c("numeric", "integer")))
    id_count <- sum(dict_data$identificador == TRUE, na.rm = TRUE)
    terr_count <- sum(dict_data$codigo_territorial == TRUE, na.rm = TRUE)
    count_count <- sum(dict_data$conteo == TRUE, na.rm = TRUE)
    prop_count <- sum(dict_data$proporcion == TRUE, na.rm = TRUE)
    rate_count <- sum(dict_data$tasa == TRUE, na.rm = TRUE)
    index_count <- sum(dict_data$indice == TRUE, na.rm = TRUE)
    review_count <- sum(dict_data$requiere_revision == TRUE, na.rm = TRUE)
    
    summary_df <- rbind(summary_df, data.frame(
      Base = base_info$name,
      Archivo = base_info$file,
      Hojas = hoja_count,
      Variables = var_count,
      Variables_Numericas = num_count,
      Variables_Categoricas = cat_count,
      Identificadores = id_count,
      Codigos_Territoriales = terr_count,
      Conteos = count_count,
      Proporciones = prop_count,
      Tasas = rate_count,
      Indices = index_count,
      Requieren_Revision = review_count,
      stringsAsFactors = FALSE
    ))
  } else {
    # If CSV doesn't exist, add empty row
    summary_df <- rbind(summary_df, data.frame(
      Base = base_info$name,
      Archivo = base_info$file,
      Hojas = NA,
      Variables = NA,
      Variables_Numericas = NA,
      Variables_Categoricas = NA,
      Identificadores = NA,
      Codigos_Territoriales = NA,
      Conteos = NA,
      Proporciones = NA,
      Tasas = NA,
      Indices = NA,
      Requieren_Revision = NA,
      stringsAsFactors = FALSE
    ))
  }
}

print(summary_df)
cat("\nProcesamiento completado. Los diccionarios se encuentran en:", diccionario_dir, "\n")