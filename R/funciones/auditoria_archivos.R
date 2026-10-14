# Funciones para auditoría de archivos

#' Contar líneas en un archivo de manera eficiente
#'
#' @param file_path Ruta al archivo
#' @return Número de líneas
count_lines <- function(file_path) {
  if (!file.exists(file_path)) return(NA_integer_)
  
  # En Windows, usar findstr /c:"" para contar líneas
  # Esta aproximación funciona bien para archivos de texto
  tryCatch({
    line_count <- length(readLines(file_path, warn = FALSE))
    return(as.integer(line_count))
  }, error = function(e) {
    warning(sprintf("Error contando líneas en %s: %s", file_path, e$message))
    return(NA_integer_)
  })
}

#' Detectar fila de encabezado en una muestra de datos
#'
#' @param muestra Data frame con muestra inicial de datos
#' @return Número de fila que contiene el encabezado (1-indexed)
detectar_fila_encabezado <- function(muestra) {
  if (nrow(muestra) == 0) return(1)
  
  # Patrones que indican posibles encabezados
  patrones_encabezado <- c(
    "municipio", "departamento", "codigo", "cod", "variable",
    "categoria", "total", "porcentaje", "frecuencia", "numero",
    "poblacion", "viviendas", "hogares", "personas", "edad",
    "sexo", "nivel", "servicio", "acueducto", "alcantarillado",
    "energia", "gas", "basura", "educacion", "salud", "trabajo",
    "empleo", "desempleo", "pobreza", "privacion", "hacinamiento",
    "material", "pared", "piso", "techo", "tenencia", "ocupacion"
  )
  
  # Examinar las primeras 5 filas para encontrar el encabezado
  n_filas_examinar <- min(5, nrow(muestra))
  
  for (fila in 1:n_filas_examinar) {
    fila_valores <- as.character(unlist(muestra[fila, ]))
    fila_valores <- tolower(fila_valores)
    fila_valores <- fila_valores[fila_valores != "" & !is.na(fila_valores)]
    
    # Contar cuántos patrones de encabezado aparecen en esta fila
    matches <- sum(str_detect(fila_valores, regex(paste(patrones_encabezado, collapse = "|"), ignore_case = TRUE)))
    
    # Si encontramos varios patrones de encabezado, probablemente sea la fila de encabezado
    if (matches >= 2) {
      return(fila)
    }
    
    # También considerar filas donde la mayoría de valores son texto corto (posibles nombres de variables)
    if (length(fila_valores) > 0) {
      prop_texto_corto <- mean(nchar(fila_valores) <= 20 & nchar(fila_valores) > 0)
      if (prop_texto_corto > 0.7 && length(unique(fila_valores)) > 2) {
        return(fila)
      }
    }
  }
  
  # Por defecto, asumir que la primera fila es el encabezado
  return(1)
}

#' Procesar un data frame completo y extraer estadísticas
#'
#' @param df Data frame a procesar
#' @param nombre_archivo Nombre del archivo origen
#' @param info_inventario Fila del inventario con información básica
#' @param hoja Nombre de la hoja (opcional)
#' @return Tibble con estadísticas de variables
procesar_dataframe_completo <- function(df, nombre_archivo, info_inventario, hoja = NULL) {
  if (is.null(df) || nrow(df) == 0) return(tibble())
  
  # Limpiar nombres de columnas para acceso interno pero mantener originales
  nombres_orig <- names(df)
  df_limpio <- df %>% janitor::clean_names()
  names(df_limpio) <- nombres_orig  # Restaurar nombres originales para referencia
  
  resultados <- list()
  
  # Procesar cada columna
  for (col in seq_along(nombres_orig)) {
    nombre_var <- nombres_orig[col]
    valores <- df[[col]]
    
    # Saltar columnas completamente vacías
    if (all(is.na(valores))) next
    
    # Información básica
    tipo_r <- class(valores)[1]
    n_total <- length(valores)
    n_validos <- sum(!is.na(valores))
    n_missing <- sum(is.na(valores))
    pct_missing <- if (n_total > 0) (n_missing / n_total) * 100 else 0
    
    # Valores únicos
    valores_unicos <- unique(valores[!is.na(valores)])
    n_unicos <- length(valores_unicos)
    pct_unicos <- if (n_validos > 0) (n_unicos / n_validos) * 100 else 0
    
    # Inicializar estadísticas
    estadisticas <- list(
      fuente = info_inventario$fuente,
      archivo = nombre_archivo,
      hoja = ifelse(is.null(hoja), "datos", hoja),
      variable_original = nombre_var,
      variable_id = sprintf("%s_%s_%s", 
                           info_inventario$fuente,
                           str_replace_all(nombre_archivo, "\\.[^.]+$", ""),
                           make.names(nombre_var)),
      nombre_estandarizado = nombre_var,  # Se migliorará posteriormente
      descripcion = NA_character_,  # Por completar manualmente
      tipo_r = tipo_r,
      tipo_estadistico = clasificar_tipo_estadistico(valores, tipo_r),
      escala_medicion = clasificar_escala_medicion(valores, tipo_r),
      naturaleza = inferir_naturaleza(nombre_var, valores, tipo_r),
      unidad = inferir_unidad(nombre_var, valores, tipo_r),
      universo = inferir_universo(nombre_var, valores, tipo_r),
      nivel_geografico = info_inventario$nivel_geografico,
      año_referencia = info_inventario$año,
      n = n_total,
      n_validos = n_validos,
      n_missing = n_missing,
      pct_missing = round(pct_missing, 2),
      n_unicos = n_unicos,
      pct_unicos = round(pct_unicos, 2),
      min = NA_real_,
      p25 = NA_real_,
      mediana = NA_real_,
      media = NA_real_,
      p75 = NA_real_,
      max = NA_real_,
      sd = NA_real_,
      varianza = NA_real_,
      cv = NA_real_,
      asimetria = NA_real_,
      kurtosis = NA_real_,
      outliers_iqr = NA_integer_,
      casi_constante = FALSE,
      identificador = es_identificador(valores, nombre_var),
      indicador = es_indicador(valores, nombre_var, tipo_r),
      numerador = NA_character_,
      denominador = NA_character_,
      requiere_transformacion = necesita_transformacion(valores, nombre_var, tipo_r),
      transformacion_sugerida = sugerir_transformacion(valores, nombre_var, tipo_r),
      direccion_vulnerabilidad = inferir_direccion_vulnerabilidad(nombre_var, valores, tipo_r),
      solapamiento_ipm = "por_determinar",  # Se llenará posteriormente
      candidato_ivs = "por_determinar",     # Se llenará posteriormente
      categoria = "por_determinar",         # Se llenará posteriormente
      justificacion = "Análisis pendiente",
      confianza_clasificacion = "baja",
      stringsAsFactors = FALSE
    )
    
    # Calcular estadísticas para variables numéricas
    if (is.numeric(valores) && !es_identificador(valores, nombre_var)) {
      valores_validos <- valores[!is.na(valores)]
      
      if (length(valores_validos) > 0) {
        estadisticas$min <- min(valores_validos, na.rm = TRUE)
        estadisticas$p25 <- quantile(valores_validos, 0.25, na.rm = TRUE)
        estadisticas$mediana <- median(valores_validos, na.rm = TRUE)
        estadisticas$media <- mean(valores_validos, na.rm = TRUE)
        estadisticas$p75 <- quantile(valores_validos, 0.75, na.rm = TRUE)
        estadisticas$max <- max(valores_validos, na.rm = TRUE)
        estadisticas$sd <- sd(valores_validos, na.rm = TRUE)
        estadisticas$varianza <- var(valores_validos, na.rm = TRUE)
        
        if (!is.na(estadisticas$media) && estadisticas$media != 0) {
          estadisticas$cv <- (estadisticas$sd / estadisticas$media) * 100
        }
        
        # Asimetría y curtosis (solo para muestras suficientemente grandes)
        if (length(valores_validos) >= 10) {
          estadisticas$asimetria <- asimetria(valores_validos)
          estadisticas$kurtosis <- curtosis(valores_validos)
        }
        
        # Outliers por IQR
        q1 <- estadisticas$p25
        q3 <- estadisticas$p75
        iqr <- q3 - q1
        limite_inferior <- q1 - 1.5 * iqr
        limite_superior <- q3 + 1.5 * iqr
        estadisticas$outliers_iqr <- sum(
          valores_validos < limite_inferior | valores_validos > limite_superior,
          na.rm = TRUE
        )
        
        # Variable casi constante
        estadisticas$casi_constante <- (estadisticas$varianza < 1e-10) || 
                                      (n_unicos <= 1) ||
                                      (n_validos > 0 && (n_unicos / n_validos) < 0.01)
      }
    }
    
    # Para variables categóricas, calcular moda
    if (!is.numeric(valores) || es_identificador(valores, nombre_var)) {
      if (n_validos > 0) {
        tabla_freq <- table(valores[!is.na(valores)])
        if (length(tabla_freq) > 0) {
          categoria_dominante <- names(tabla_freq)[which.max(tabla_freq)]
          frecuencia_maxima <- max(tabla_freq)
          estadisticas$pct_unicos <- round((frecuencia_maxima / n_validos) * 100, 2)
        }
      }
    }
    
    resultados[[col]] <- tibble(!!!estadisticas)
  }
  
  if (length(resultados) == 0) return(tibble())
  
  return(bind_rows(resultados))
}

#' Procesar archivo CSV en chunks para evitar sobrecarga de memoria
#'
#' @param file_path Ruta al archivo CSV
#' @param chunk_size Tamaño del chunk para lectura
#' @return Tibble con estadísticas agregadas
procesar_csv_chunks <- function(file_path, chunk_size = 10000) {
  if (!file.exists(file_path)) return(tibble())
  
  # Abrir conexión para lectura en chunks
  con <- file(file_path, "r")
  on.exit(close(con))
  
  # Leer encabezado
  encabezado <- readLines(con, n = 1)
  if (length(encabezado) == 0) {
    warning(sprintf("Archivo CSV vacío: %s", file_path))
    return(tibble())
  }
  
  nombres_col <- str_split(encabezado, ",")[[1]]
  nombres_col <- str_trim(nombres_col)
  
  # Inicializar acumuladores para estadísticas
  n_total <- 0
  n_validos_vec <- integer(length(nombres_col))
  sum_vec <- numeric(length(nombres_col))
  sum_sq_vec <- numeric(length(nombres_col))
  min_vec <- rep(Inf, length(nombres_col))
  max_vec <- rep(-Inf, length(nombres_col))
  valores_unicos_list <- vector("list", length(nombres_col))
  
  # Procesar en chunks
  chunk_num <- 0
  while (TRUE) {
    chunk <- read_csv(con, n_max = chunk_size, col_names = FALSE, 
                      show_col_types = FALSE, progress = FALSE)
    if (nrow(chunk) == 0) break
    
    chunk_num <- chunk_num + 1
    n_total <- n_total + nrow(chunk)
    
    # Procesar cada columna en el chunk
    for (col in seq_along(nombres_col)) {
      if (col > ncol(chunk)) next  # Saltar si el chunk tiene menos columnas
      
      valores <- chunk[[col]]
      
      # Contar válidos
      validos <- !is.na(valores)
      n_validos_vec[col] <- n_validos_vec[col] + sum(validos)
      
      # Para numéricos, acumular sumas
      if (is.numeric(valores)) {
        valores_validos <- valores[validos]
        if (length(valores_validos) > 0) {
          sum_vec[col] <- sum_vec[col] + sum(valores_validos, na.rm = TRUE)
          sum_sq_vec[col] <- sum_sq_vec[col] + sum(valores_validos^2, na.rm = TRUE)
          min_vec[col] <- min(min_vec[col], min(valores_validos, na.rm = TRUE), na.rm = TRUE)
          max_vec[col] <- max(max_vec[col], max(valores_validos, na.rm = TRUE), na.rm = TRUE)
        }
      }
      
      # Para únicos, mantener muestra (limitada para evitar memoria excesiva)
      # En una implementación real, se usaría un algoritmo de conteo aproximado
      # Pero por simplicidad, guardamos todos los únicos si no son muchos
      valores_unicos <- unique(valores[!is.na(valores)])
      if (length(valores_unicos) < 1000) {  # Límite arbitrario para evitar explosión de memoria
        valores_unicos_list[[col]] <- c(valores_unicos_list[[col]], valores_unicos)
      }
    }
    
    # Liberar memoria del chunk
    rm(chunk)
    gc()
  }
  
  # Calcular estadísticas finales
  resultados <- list()
  
  for (col in seq_along(nombres_col)) {
    nombre_var <- nombres_col[col]
    n_validos <- n_validos_vec[col]
    n_missing <- n_total - n_validos
    pct_missing <- if (n_total > 0) (n_missing / n_total) * 100 else 0
    
    # Calcular únicos de la muestra (aproximación)
    valores_unicos <- unique(unlist(valores_unicos_list[col]))
    n_unicos <- length(valores_unicos)
    pct_unicos <- if (n_validos > 0) (n_unicos / n_validos) * 100 else 0
    
    # Calcular media y varianza a partir de sumas acumuladas
    media <- if (n_validos > 0) sum_vec[col] / n_validos else NA_real_
    varianza <- if (n_validos > 1) (sum_sq_vec[col] - (sum_vec[col]^2 / n_validos)) / (n_validos - 1) else NA_real_
    sd <- if (!is.na(varianza) && varianza >= 0) sqrt(varianza) else NA_real_
    
    resultados[[col]] <- tibble(
      fuente = "por_determinar",  # Se llenará basado en el archivo
      archivo = basename(file_path),
      hoja = "datos",
      variable_original = nombre_var,
      variable_id = sprintf("%s_%s_%s", 
                           "por_determinar",
                           str_replace_all(basename(file_path), "\\.[^.]+$", ""),
                           make.names(nombre_var)),
      nombre_estandarizado = nombre_var,
      descripcion = NA_character_,
      tipo_r = "numeric",  # Asumimos numérico para CSV genérico, se mejorará
      tipo_estadistico = "continua",
      escala_medicion = "razon",
      naturaleza = "por_determinar",
      unidad = "por_determinar",
      universo = "por_determinar",
      nivel_geografico = "Municipal",
      año_referencia = NA_integer_,
      n = n_total,
      n_validos = n_validos,
      n_missing = n_missing,
      pct_missing = round(pct_missing, 2),
      n_unicos = n_unicos,
      pct_unicos = round(pct_unicos, 2),
      min = if (!is.infinite(min_vec[col])) min_vec[col] else NA_real_,
      p25 = NA_real_,  # Requeriría más trabajo para calcular en chunks
      mediana = NA_real_,
      media = if (!is.na(media)) media else NA_real_,
      p75 = NA_real_,
      max = if (!is.infinite(max_vec[col])) max_vec[col] else NA_real_,
      sd = if (!is.na(sd)) sd else NA_real_,
      varianza = if (!is.na(varianza)) varianza else NA_real_,
      cv = if (!is.na(sd) && !is.na(media) && media != 0) (sd / media) * 100 else NA_real_,
      asimetria = NA_real_,
      kurtosis = NA_real_,
      outliers_iqr = NA_integer_,
      casi_constante = (is.na(varianza) || varianza < 1e-10),
      identificador = FALSE,  # Se evaluará mejor con más información
      indicador = !is.na(media),  # Simplificado
      numerador = NA_character_,
      denominador = NA_character_,
      requiere_transformacion = FALSE,
      transformacion_sugerida = NA_character_,
      direccion_vulnerabilidad = "?",
      solapamiento_ipm = "por_determinar",
      candidato_ivs = "por_determinar",
      categoria = "por_determinar",
      justificacion = "Estadísticos básicos calculados por chunks",
      confianza_clasificacion = "media",
      stringsAsFactors = FALSE
    )
  }
  
  return(bind_rows(resultados))
}

#' Procesar hoja de Excel en chunks
#'
#' @param file_path Ruta al archivo Excel
#' @param hoja Nombre de la hoja
#' @param fila_encabezado Fila donde comienza el encabezado (1-indexed)
#' @param chunk_size Tamaño del chunk
#' @return Tibble con estadísticas
procesar_excel_chunks <- function(file_path, hoja, fila_encabezado, chunk_size = 10000) {
  # Implementación simplificada - en una versión completa se usaría
  # lectura en chunks de Excel, pero readxl no lo soporta directamente
  # Por ahora, procesamos completamente pero con límite de tamaño
  warning(sprintf("Procesamiento en chunks para Excel no completamente implementado. Leyendo hoja '%s' completa.", hoja))
  
  df <- tryCatch(
    read_excel(file_path, sheet = hoja, skip = fila_encabezado - 1),
    error = function(e) {
      warning(sprintf("Error leyendo hoja '%s' en %s: %s", hoja, file_path, e$message))
      return(tibble())
    }
  )
  
  if (nrow(df) == 0) return(tibble())
  
  # Procesar como data frame completo
  return(procesar_dataframe_completo(df, basename(file_path), 
                                   tibble(
                                     fuente = "por_determinar",
                                     archivo = basename(file_path),
                                     extensión = "xlsx",
                                     tamaño_KB = file.info(file_path)$size / 1024,
                                     año = 2018,
                                     tipo_informacion = "Por determinar",
                                     nivel_geografico = "Municipal",
                                     filas_total = nrow(df),
                                     columnas_total = ncol(df),
                                     hojas = 1,
                                     uso_potencial = "Por determinar"
                                   ), hoja))
}