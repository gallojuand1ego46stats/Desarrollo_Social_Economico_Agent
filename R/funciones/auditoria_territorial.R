# Funciones para auditoría territorial

#' Calcular cobertura territorial comparando con DIVIPOLA
#'
#' @param inventario Tibble con inventario de bases
#' @param divipola_path Ruta al archivo DIVIPOLA estandarizado (opcional)
#' @return Tibble con cobertura por fuente
calcular_cobertura_territorial <- function(inventario, divipola_path = NULL) {
  # Si se proporciona DIVIPOLA, cargarlo; sino, intentar cargarlo desde el inventario
  if (is.null(divipola_path)) {
    divipola_row <- inventario %>%
      filter(str_detect(archivo, regex("DIVIPOLA", ignore_case = TRUE))) %>%
      slice(1)
    
    if (nrow(divipola_row) == 0) {
      warning("No se encontró archivo DIVIPOLA en el inventario")
      return(tibble(
        fuente = character(),
        municipios = integer(),
        coinciden_divipola = integer(),
        no_coinciden = integer(),
        duplicados = integer(),
        cobertura_pct = numeric(),
        stringsAsFactors = FALSE
      ))
    }
    
    divipola_path <- divipola_row$ruta
  }
  
  # Cargar DIVIPOLA
  divipola <- tryCatch(
    read_csv(divipola_path, show_col_types = FALSE),
    error = function(e) {
      warning(sprintf("Error cargando DIVIPOLA desde %s: %s", divipola_path, e$message))
      return(tibble())
    }
  )
  
  if (nrow(divipola) == 0) {
    warning("DIVIPOLA cargado está vacío")
    return(tibble(
      fuente = character(),
      municipios = integer(),
      coinciden_divipola = integer(),
      no_coinciden = integer(),
      duplicados = integer(),
      cobertura_pct = numeric(),
      stringsAsFactors = FALSE
    ))
  }
  
  # Estandarizar códigos de DIVIPOLA como texto con ceros iniciales
  divipola_limpia <- divipola %>%
    mutate(
      codigo_departamento = str_pad(as.character(`Código Departamento`), width = 2, pad = "0"),
      codigo_municipio = str_pad(as.character(`Código Municipio`), width = 3, pad = "0"),
      divipola = str_c(codigo_departamento, codigo_municipio)
    ) %>%
    select(divipola) %>%
    distinct()
  
  codigos_divipola <- divipola_limpia$divipola
  
  # Inicializar resultados
  resultados <- list()
  
  # Procesar cada fuente en el inventario (excluyendo DIVIPOLA misma)
  for (i in seq_len(nrow(inventario))) {
    fila <- inventario[i, ]
    
    # Saltar DIVIPOLA para evitar autocomparación
    if (str_detect(fila$archivo, regex("DIVIPOLA", ignore_case = TRUE))) {
      next
    }
    
    fuente <- fila$fuente
    archivo <- fila$ruta
    ext <- fila$extension
    
    # Intentar extraer códigos municipales de la fuente
    codigos_fuente <- tryCatch(
      extraer_codigos_municipales(archivo, ext),
      error = function(e) {
        warning(sprintf("Error extrayendo códigos de %s (%s): %s", fila$archivo, fuente, e$message))
        return(character())
      }
    )
    
    if (length(codigos_fuente) == 0) {
      resultados[[fila$archivo]] <- tibble(
        fuente = fuente,
        municipios = 0,
        coinciden_divipola = 0,
        no_coinciden = 0,
        duplicados = 0,
        cobertura_pct = 0,
        stringsAsFactors = FALSE
      )
      next
    }
    
    # Normalizar códigos de la fuente (rellenar ceros iniciales)
    codigos_fuente_norm <- str_pad(codigos_fuente, width = 5, pad = "0")
    
    # Calcular coincidencias
    coinciden <- intersect(codigos_fuente_norm, codigos_divipola)
    solo_fuente <- setdiff(codigos_fuente_norm, codigos_divipola)
    solo_divipola <- setdiff(codigos_divipola, codigos_fuente_norm)
    
    # Contar duplicados en la fuente
    duplicados <- sum(duplicated(codigos_fuente_norm))
    
    # Calcular porcentaje de cobertura
    total_divipola <- length(codigos_divipola)
    cobertura_pct <- if (total_divipola > 0) (length(coinciden) / total_divipola) * 100 else 0
    
    resultados[[fila$archivo]] <- tibble(
      fuente = fuente,
      municipios = length(codigos_fuente_norm),
      coinciden_divipola = length(coinciden),
      no_coinciden = length(solo_fuente),
      duplicados = duplicados,
      cobertura_pct = round(cobertura_pct, 2),
      stringsAsFactors = FALSE
    )
  }
  
  if (length(resultados) == 0) {
    return(tibble(
      fuente = character(),
      municipios = integer(),
      coinciden_divipola = integer(),
      no_coinciden = integer(),
      duplicados = integer(),
      cobertura_pct = numeric(),
      stringsAsFactors = FALSE
    ))
  }
  
  return(bind_rows(resultados))
}

#' Extraer códigos municipales de un archivo
#'
#' @param file_path Ruta al archivo
#' @param extension Extensión del archivo (csv, xls, xlsx)
#' @return Vector de códigos municipales encontrados
extraer_codigos_municipales <- function(file_path, extension) {
  if (!file.exists(file_path)) return(character())
  
  # Intentar identificar columnas que puedan contener códigos municipales
  # Esta es una versión simplificada - en una implementación real sería más sofisticada
  
  if (extension == "csv") {
    # Leer solo las primeras 1000 filas para buscar columnas de código
    muestra <- tryCatch(
      read_csv(file_path, n_max = 1000, show_col_types = FALSE),
      error = function(e) {
        warning(sprintf("Error leyendo muestra CSV de %s: %s", file_path, e$message))
        return(tibble())
      }
    )
  } else if (extension %in% c("xls", "xlsx")) {
    # Obtener hojas
    hojas <- tryCatch(
      excel_sheets(file_path),
      error = function(e) {
        warning(sprintf("Error obteniendo hojas de %s: %s", file_path, e$message))
        return(character())
      }
    )
    
    if (length(hojas) == 0) return(character())
    
    # Leer la primera hoja (o la que parezca más relevante) para buscar códigos
    muestra <- tryCatch(
      read_excel(file_path, sheet = hojas[1], n_max = 1000),
      error = function(e) {
        warning(sprintf("Error leyendo muestra Excel de %s: %s", file_path, e$message))
        return(tibble())
      }
    )
  } else {
    return(character())
  }
  
  if (nrow(muestra) == 0) return(character())
  
  # Buscar columnas que puedan ser códigos municipales
  columnas <- names(muestra)
  
  # Patrones para códigos territoriales
  patrones_codigo <- c(
    "codigo", "cod", "municipio", "municip", "divipola", 
    "departamento", "depto", "dpio"
  )
  
  # Columnas que coinciden con patrones de código
  columnas_codigo <- columnas[str_detect(columnas, regex(paste(patrones_codigo, collapse = "|"), ignore_case = TRUE))]
  
  # Si no encontramos columnas obvias, buscar columnas con 5 caracteres (como códigos DIVIPOLA)
  if (length(columnas_codigo) == 0) {
    # Verificar longitud de caracteres en las primeras filas no nulas
    longitudes <- sapply(muestra, function(col) {
      vals <- na.omit(as.character(col))
      if (length(vals) == 0) return(0)
      # Moda de longitud (simplificada: tomar la primera longitud que aparece más de 5 veces)
      longitudes_vals <- nchar(vals)
      if (length(longitudes_vals) == 0) return(0)
      tab <- table(longitudes_vals)
      if (length(tab) == 0) return(0)
      as.numeric(names(tab)[which.max(tab)])
    })
    
    columnas_codigo <- columnas[longitudes == 5]
  }
  
  # Extraer valores de las columnas identificadas
  codigos <- character()
  for (col in columnas_codigo) {
    vals <- muestra[[col]]
    vals_char <- as.character(vals)
    # Limpiar: eliminar espacios, puntos, guiones, etc. y quedarnos con dígitos
    vals_limpio <- gsub("[^0-9]", "", vals_char)
    # Filtrar aquellos que tienen exactamente 5 digits (codigo de municipio DIVIPOLA)
    vals_5dig <- vals_limpio[nchar(vals_limpio) == 5]
    codigos <- c(codigos, vals_5dig)
  }
  
  # Eliminar duplicados y valores vacíos
  codigos <- unique(codigos[nzchar(codigos)])
  
  return(codigos)
}