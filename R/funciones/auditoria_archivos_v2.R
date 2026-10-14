# Funciones para auditoría de archivos - Versión 2 con chunking real y checkpointing
# Reemplaza auditoria_archivos.R con implementación robusta

suppressPackageStartupMessages({
  library(data.table)
  library(readxl)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(purrr)
  library(tibble)
  library(janitor)
})

# =============================================================================
# CONFIGURACIÓN Y UTILIDADES DE CHECKPOINTING
# =============================================================================

#' Directorio de checkpoints
get_checkpoint_dir <- function(project_dir) {
  dir <- file.path(project_dir, "temp", "checkpoints")
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  return(dir)
}

#' Generar clave única de checkpoint
checkpoint_key <- function(fuente, archivo, hoja) {
  key <- sprintf("%s_%s_%s", fuente, str_replace_all(archivo, "[^a-zA-Z0-9]", "_"), hoja)
  return(str_replace_all(key, "[^a-zA-Z0-9_]", "_"))
}

#' Guardar estado de checkpoint
save_checkpoint <- function(project_dir, fuente, archivo, hoja, estado, 
                            chunks_completados = 0, filas_procesadas = 0, 
                            total_filas_esperadas = NA, error_msg = NULL) {
  checkpoint_dir <- get_checkpoint_dir(project_dir)
  key <- checkpoint_key(fuente, archivo, hoja)
  file_path <- file.path(checkpoint_dir, paste0(key, ".rds"))
  
  estado_obj <- list(
    fuente = fuente,
    archivo = archivo,
    hoja = hoja,
    estado = estado,  # PENDIENTE, EN_PROCESO, COMPLETO, ERROR, OMITIDO
    chunks_completados = chunks_completados,
    filas_procesadas = filas_procesadas,
    total_filas_esperadas = total_filas_esperadas,
    error_msg = error_msg,
    timestamp = Sys.time(),
    duracion_seg = NA
  )
  
  saveRDS(estado_obj, file_path)
  return(invisible(TRUE))
}

#' Cargar estado de checkpoint
load_checkpoint <- function(project_dir, fuente, archivo, hoja) {
  checkpoint_dir <- get_checkpoint_dir(project_dir)
  key <- checkpoint_key(fuente, archivo, hoja)
  file_path <- file.path(checkpoint_dir, paste0(key, ".rds"))
  
  if (file.exists(file_path)) {
    return(readRDS(file_path))
  }
  return(NULL)
}

#' Verificar si hoja ya fue procesada completamente
is_sheet_complete <- function(project_dir, fuente, archivo, hoja) {
  cp <- load_checkpoint(project_dir, fuente, archivo, hoja)
  return(!is.null(cp) && cp$estado == "COMPLETO")
}

#' Obtener progreso de checkpoint
get_checkpoint_progress <- function(project_dir, fuente, archivo, hoja) {
  cp <- load_checkpoint(project_dir, fuente, archivo, hoja)
  if (is.null(cp)) return(list(chunks = 0, filas = 0))
  return(list(chunks = cp$chunks_completados, filas = cp$filas_procesadas))
}

# =============================================================================
# DETECCIÓN DE ENCABEZADOS (mejorada)
# =============================================================================

#' Detectar fila de encabezado en una muestra de datos
#' Mejorado para manejar formatos CNPV donde el encabezado real está más abajo
detectar_fila_encabezado <- function(muestra) {
  if (nrow(muestra) == 0) return(1)
  
  patrones_encabezado <- c(
    "municipio", "departamento", "codigo", "cod", "variable",
    "categoria", "total", "porcentaje", "frecuencia", "numero",
    "poblacion", "viviendas", "hogares", "personas", "edad",
    "sexo", "nivel", "servicio", "acueducto", "alcantarillado",
    "energia", "gas", "basura", "educacion", "salud", "trabajo",
    "empleo", "desempleo", "pobreza", "privacion", "hacinamiento",
    "material", "pared", "piso", "techo", "tenencia", "ocupacion"
  )
  
  # Examinar más filas para formatos CNPV (hasta 30 filas)
  n_filas_examinar <- min(30, nrow(muestra))
  
  mejor_fila <- 1
  mejor_score <- -1
  
  for (fila in 1:n_filas_examinar) {
    fila_valores <- as.character(unlist(muestra[fila, ]))
    fila_valores_raw <- fila_valores
    fila_valores <- tolower(fila_valores)
    fila_valores <- fila_valores[fila_valores != "" & !is.na(fila_valores)]
    
    # Score 1: coincidencias con patrones de encabezado
    matches <- sum(str_detect(fila_valores, regex(paste(patrones_encabezado, collapse = "|"), ignore_case = TRUE)))
    
    # Score 2: número de valores no vacíos (indicador de fila de datos real)
    n_validos <- sum(!is.na(fila_valores_raw) & fila_valores_raw != "")
    
    # Score 3: proporción de texto corto (nombres de variables típicos)
    prop_texto_corto <- 0
    if (length(fila_valores) > 0) {
      prop_texto_corto <- mean(nchar(fila_valores) <= 30 & nchar(fila_valores) > 0)
    }
    
    # Score combinado: priorizar filas con muchos valores válidos Y patrones de encabezado
    # Para CNPV, la fila de encabezado real tiene muchos valores no vacíos (40+)
    score <- 0
    if (matches >= 2) score <- score + 10
    if (n_validos >= 10) score <- score + n_validos  # Filas con muchos datos = encabezado real
    if (prop_texto_corto > 0.5 && length(unique(fila_valores)) > 3) score <- score + 5
    
    if (score > mejor_score) {
      mejor_score <- score
      mejor_fila <- fila
    }
  }
  
  # Si no se encontró nada convincente, buscar la fila con más valores no vacíos
  if (mejor_score < 5) {
    max_validos <- 0
    for (fila in 1:n_filas_examinar) {
      fila_valores_raw <- as.character(unlist(muestra[fila, ]))
      n_validos <- sum(!is.na(fila_valores_raw) & fila_valores_raw != "")
      if (n_validos > max_validos) {
        max_validos <- n_validos
        mejor_fila <- fila
      }
    }
  }
  
  return(mejor_fila)
}

# =============================================================================
# CONVERSIÓN EXCEL → CSV TEMPORAL (para chunking real)
# =============================================================================

#' Convertir hoja Excel a CSV temporal para procesamiento por chunks
#' 
#' @param file_path Ruta al archivo Excel
#' @param hoja Nombre de la hoja
#' @param fila_encabezado Fila del encabezado (1-indexed)
#' @param temp_dir Directorio para archivos temporales
#' @return Lista con ruta CSV, número de filas, número de columnas, nombres columnas
excel_sheet_to_csv <- function(file_path, hoja, fila_encabezado = 1, temp_dir = NULL) {
  if (is.null(temp_dir)) {
    temp_dir <- file.path(dirname(file_path), "..", "temp", "csv_intermediate")
  }
  dir.create(temp_dir, showWarnings = FALSE, recursive = TRUE)
  
  csv_name <- sprintf("%s_%s.csv", 
                      str_replace_all(basename(file_path), "[^a-zA-Z0-9]", "_"),
                      str_replace_all(hoja, "[^a-zA-Z0-9]", "_"))
  csv_path <- file.path(temp_dir, csv_name)
  
  # Si ya existe el CSV, verificar que sea válido
  if (file.exists(csv_path)) {
    tryCatch({
      test_read <- fread(csv_path, nrows = 1)
      if (ncol(test_read) > 0) {
        # Verificar número de filas
        n_rows <- length(readLines(csv_path, warn = FALSE)) - 1
        return(list(
          csv_path = csv_path,
          n_rows = n_rows,
          n_cols = ncol(test_read),
          col_names = names(test_read),
          from_cache = TRUE
        ))
      }
    }, error = function(e) {
      # CSV corrupto, regenerar
      unlink(csv_path)
    })
  }
  
  # Leer hoja completa y escribir CSV
  message(sprintf("  Convirtiendo hoja '%s' a CSV temporal...", hoja))
  start_time <- Sys.time()
  
  df <- tryCatch(
    read_excel(file_path, sheet = hoja, skip = fila_encabezado - 1),
    error = function(e) {
      warning(sprintf("Error leyendo hoja '%s': %s", hoja, e$message))
      return(NULL)
    }
  )
  
  if (is.null(df) || nrow(df) == 0) {
    warning(sprintf("Hoja '%s' vacía o error de lectura", hoja))
    return(NULL)
  }
  
  # Limpiar nombres de columnas (data.table los usa tal cual)
  original_names <- names(df)
  clean_names <- make.names(original_names, unique = TRUE)
  names(df) <- clean_names
  
  # Escribir CSV con data.table (rápido)
  fwrite(df, csv_path, sep = ",", na = "", quote = TRUE)
  
  elapsed <- round(difftime(Sys.time(), start_time, units = "secs"), 1)
  message(sprintf("  CSV generado: %d filas × %d cols en %ss", nrow(df), ncol(df), elapsed))
  
  return(list(
    csv_path = csv_path,
    n_rows = nrow(df),
    n_cols = ncol(df),
    col_names = clean_names,
    original_names = original_names,
    from_cache = FALSE
  ))
}

# =============================================================================
# PROCESAMIENTO POR CHUNKS REAL (CSV con data.table)
# =============================================================================

#' Procesar CSV en chunks reales con data.table y estadísticas incrementales
#' 
#' @param csv_path Ruta al archivo CSV
#' @param chunk_size Filas por chunk
#' @param info_inventario Info del archivo (fuente, año, etc.)
#' @param hoja Nombre de la hoja
#' @param project_dir Directorio del proyecto (para checkpoints)
#' @return Tibble con estadísticas por variable
procesar_csv_chunks_real <- function(csv_path, chunk_size = 50000, 
                                     info_inventario, hoja = "datos",
                                     project_dir = NULL) {
  
  if (!file.exists(csv_path)) {
    warning(sprintf("CSV no encontrado: %s", csv_path))
    return(tibble())
  }
  
  # Verificar checkpoint existente
  if (!is.null(project_dir)) {
    cp <- load_checkpoint(project_dir, info_inventario$fuente, info_inventario$archivo, hoja)
    if (!is.null(cp) && cp$estado == "COMPLETO") {
      message(sprintf("  Checkpoint: hoja '%s' ya COMPLETA (%d filas)", hoja, cp$filas_procesadas))
      # Cargar resultados previos si existen
      resultado_path <- file.path(get_checkpoint_dir(project_dir), 
                                  paste0(checkpoint_key(info_inventario$fuente, info_inventario$archivo, hoja), "_result.rds"))
      if (file.exists(resultado_path)) {
        return(readRDS(resultado_path))
      }
    }
    save_checkpoint(project_dir, info_inventario$fuente, info_inventario$archivo, hoja, 
                    "EN_PROCESO", chunks_completados = 0, filas_procesadas = 0)
  }
  
  # Leer encabezado para obtener nombres
  header_dt <- fread(csv_path, nrows = 0)
  col_names <- names(header_dt)
  n_cols <- length(col_names)
  
  # Contar filas totales (compatible con Windows)
  total_rows <- length(readLines(csv_path, warn = FALSE)) - 1  # -1 por header
  
  if (total_rows <= 0) {
    warning(sprintf("CSV vacío: %s", csv_path))
    return(tibble())
  }
  
  message(sprintf("  Procesando CSV: %d filas, %d columnas, chunks de %d", 
                  total_rows, n_cols, chunk_size))
  
  # Inicializar acumuladores
  n_total <- 0
  n_validos_vec <- integer(n_cols)
  sum_vec <- numeric(n_cols)
  sum_sq_vec <- numeric(n_cols)
  min_vec <- rep(Inf, n_cols)
  max_vec <- rep(-Inf, n_cols)
  is_numeric_vec <- logical(n_cols)
  valores_unicos_list <- vector("list", n_cols)
  
  # Detectar tipos de columna leyendo primera fila de datos
  first_row <- fread(csv_path, nrows = 1)
  for (j in seq_len(n_cols)) {
    is_numeric_vec[j] <- is.numeric(first_row[[j]])
    valores_unicos_list[[j]] <- character()
  }
  
  # Procesar en chunks usando fread con skip
  chunk_num <- 0
  skip_rows <- 1  # Saltar header
  
  while (TRUE) {
    chunk <- tryCatch(
      fread(csv_path, skip = skip_rows, nrows = chunk_size, header = FALSE),
      error = function(e) {
        warning(sprintf("Error leyendo chunk: %s", e$message))
        return(data.table())
      }
    )
    
    if (nrow(chunk) == 0) break
    
    # Asignar nombres de columnas
    setnames(chunk, col_names)
    
    chunk_num <- chunk_num + 1
    n_total <- n_total + nrow(chunk)
    
    # Procesar cada columna
    for (j in seq_len(n_cols)) {
      col_name <- col_names[j]
      valores <- chunk[[j]]
      
      validos <- !is.na(valores) & valores != ""
      n_validos <- sum(validos)
      n_validos_vec[j] <- n_validos_vec[j] + n_validos
      
      if (is_numeric_vec[j] && n_validos > 0) {
        vals_num <- as.numeric(valores[validos])
        sum_vec[j] <- sum_vec[j] + sum(vals_num, na.rm = TRUE)
        sum_sq_vec[j] <- sum_sq_vec[j] + sum(vals_num^2, na.rm = TRUE)
        min_vec[j] <- min(min_vec[j], min(vals_num, na.rm = TRUE), na.rm = TRUE)
        max_vec[j] <- max(max_vec[j], max(vals_num, na.rm = TRUE), na.rm = TRUE)
      }
      
      # Acumular únicos (con límite para memoria)
      if (length(valores_unicos_list[[j]]) < 5000) {
        uniq_vals <- unique(as.character(valores[validos]))
        valores_unicos_list[[j]] <- c(valores_unicos_list[[j]], uniq_vals)
      }
    }
    
    # Checkpoint cada 10 chunks
    if (chunk_num %% 10 == 0 && !is.null(project_dir)) {
      save_checkpoint(project_dir, info_inventario$fuente, info_inventario$archivo, hoja,
                      "EN_PROCESO", chunks_completados = chunk_num, filas_procesadas = n_total,
                      total_filas_esperadas = total_rows)
    }
    
    # Liberar memoria
    rm(chunk)
    gc()
    
    skip_rows <- skip_rows + chunk_size
    if (skip_rows > total_rows) break
  }
  
  message(sprintf("  Chunks procesados: %d, filas totales: %d", chunk_num, n_total))
  
  # Verificar completitud
  if (n_total != total_rows) {
    warning(sprintf("Filas procesadas (%d) != filas esperadas (%d)", n_total, total_rows))
  }
  
  # Calcular estadísticas finales
  resultados <- list()
  
  for (j in seq_len(n_cols)) {
    col_name <- col_names[j]
    n_validos <- n_validos_vec[j]
    n_missing <- n_total - n_validos
    pct_missing <- if (n_total > 0) (n_missing / n_total) * 100 else 0
    
    # Únicos
    valores_unicos <- unique(valores_unicos_list[[j]])
    n_unicos <- length(valores_unicos)
    pct_unicos <- if (n_validos > 0) (n_unicos / n_validos) * 100 else 0
    
    # Tipo R
    tipo_r <- if (is_numeric_vec[j]) "numeric" else "character"
    
    # Estadísticas base
    estadisticas <- list(
      fuente = info_inventario$fuente,
      archivo = info_inventario$archivo,
      hoja = hoja,
      variable_original = col_name,
      variable_id = sprintf("%s_%s_%s", 
                           info_inventario$fuente,
                           str_replace_all(info_inventario$archivo, "\\.[^.]+$", ""),
                           make.names(col_name)),
      nombre_estandarizado = col_name,
      descripcion = NA_character_,
      tipo_r = tipo_r,
      tipo_estadistico = NA_character_,  # Se llenará después
      escala_medicion = NA_character_,
      naturaleza = NA_character_,
      unidad = NA_character_,
      universo = NA_character_,
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
      identificador = FALSE,
      indicador = FALSE,
      numerador = NA_character_,
      denominador = NA_character_,
      requiere_transformacion = FALSE,
      transformacion_sugerida = NA_character_,
      direccion_vulnerabilidad = "?",
      solapamiento_ipm = "por_determinar",
      candidato_ivs = "por_determinar",
      categoria = "por_determinar",
      justificacion = "Análisis pendiente",
      confianza_clasificacion = "baja",
      stringsAsFactors = FALSE
    )
    
    # Estadísticas para numéricas
    if (is_numeric_vec[j] && n_validos > 0) {
      media <- sum_vec[j] / n_validos
      varianza <- if (n_validos > 1) (sum_sq_vec[j] - (sum_vec[j]^2 / n_validos)) / (n_validos - 1) else 0
      sd <- if (varianza > 0) sqrt(varianza) else 0
      
      estadisticas$media <- media
      estadisticas$varianza <- varianza
      estadisticas$sd <- sd
      estadisticas$min <- if (!is.infinite(min_vec[j])) min_vec[j] else NA_real_
      estadisticas$max <- if (!is.infinite(max_vec[j])) max_vec[j] else NA_real_
      
      if (!is.na(media) && media != 0) {
        estadisticas$cv <- (sd / media) * 100
      }
      
      estadisticas$casi_constante <- (varianza < 1e-10) || (n_unicos <= 1)
      
      # Cuantiles: requeriría segunda pasada o aproximación
      # Por ahora NA - se pueden calcular si es crítico
    }
    
    resultados[[j]] <- tibble(!!!estadisticas)
  }
  
  resultado_final <- bind_rows(resultados)
  
  # Guardar checkpoint final
  if (!is.null(project_dir)) {
    save_checkpoint(project_dir, info_inventario$fuente, info_inventario$archivo, hoja,
                    "COMPLETO", chunks_completados = chunk_num, filas_procesadas = n_total,
                    total_filas_esperadas = total_rows)
    
    # Guardar resultado para reanudación
    resultado_path <- file.path(get_checkpoint_dir(project_dir), 
                                paste0(checkpoint_key(info_inventario$fuente, info_inventario$archivo, hoja), "_result.rds"))
    saveRDS(resultado_final, resultado_path)
  }
  
  return(resultado_final)
}

# =============================================================================
# PROCESAMIENTO COMPLETO DE HOJA (con decisión automática de estrategia)
# =============================================================================

#' Leer hoja Excel con manejo correcto de encabezados complejos (CNPV)
#' 
#' @param file_path Ruta al archivo Excel
#' @param hoja Nombre de la hoja
#' @param fila_encabezado Fila donde está el encabezado (1-indexed)
#' @return Lista con df (data.frame), original_names, n_rows, n_cols
leer_hoja_excel_con_encabezado <- function(file_path, hoja, fila_encabezado) {
  # 1. Leer la fila de encabezado SIN usarla como nombres de columna
  # Esto nos da los valores reales de la fila de encabezado
  header_row <- tryCatch(
    read_excel(file_path, sheet = hoja, skip = fila_encabezado - 1, n_max = 1, col_names = FALSE),
    error = function(e) {
      warning(sprintf("Error leyendo fila de encabezado de '%s': %s", hoja, e$message))
      return(NULL)
    }
  )
  
  if (is.null(header_row) || ncol(header_row) == 0) {
    return(NULL)
  }
  
  # Extraer nombres originales de la fila de encabezado
  original_names <- as.character(unlist(header_row[1, ]))
  # Reemplazar NA/valores vacíos con nombres generados
  original_names[is.na(original_names) | original_names == ""] <- paste0("V", seq_along(original_names))[is.na(original_names) | original_names == ""]
  # Limpiar nombres para uso interno (unique, sin caracteres especiales)
  clean_names <- make.names(original_names, unique = TRUE)
  
  # 2. Leer TODOS los datos saltando la fila de encabezado (col_names = FALSE)
  df_data <- tryCatch(
    read_excel(file_path, sheet = hoja, skip = fila_encabezado, col_names = FALSE),
    error = function(e) {
      warning(sprintf("Error leyendo datos de '%s': %s", hoja, e$message))
      return(NULL)
    }
  )
  
  if (is.null(df_data) || nrow(df_data) == 0) {
    return(NULL)
  }
  
  # Asegurar que tenemos el mismo número de columnas
  n_data_cols <- ncol(df_data)
  n_header_cols <- length(clean_names)
  
  if (n_data_cols != n_header_cols) {
    # Ajustar si hay discrepancia (común en CNPV por celdas combinadas)
    if (n_data_cols > n_header_cols) {
      # Más columnas en datos que en header - agregar nombres genéricos
      extra <- n_data_cols - n_header_cols
      start_idx <- n_header_cols + 1
      end_idx <- n_data_cols
      clean_names <- c(clean_names, paste0("V", start_idx:end_idx))
      original_names <- c(original_names, paste0("V", start_idx:end_idx))
    } else if (n_data_cols < n_header_cols) {
      # Menos columnas en datos - truncar nombres
      clean_names <- clean_names[1:n_data_cols]
      original_names <- original_names[1:n_data_cols]
    }
  }
  
  # Asignar nombres limpios
  names(df_data) <- clean_names
  
  return(list(
    df = df_data,
    original_names = original_names,
    clean_names = clean_names,
    n_rows = nrow(df_data),
    n_cols = ncol(df_data)
  ))
}

#' Procesar una hoja Excel usando la estrategia óptima
#' 
#' @param file_path Ruta al archivo Excel
#' @param hoja Nombre de la hoja
#' @param info_inventario Info del archivo
#' @param project_dir Directorio del proyecto
#' @param umbral_grande Umbral de filas para considerar "grande" (default 50000)
#' @param chunk_size Tamaño de chunk para CSV
#' @return Tibble con estadísticas
procesar_hoja_excel <- function(file_path, hoja, info_inventario, 
                                project_dir = NULL, 
                                umbral_grande = 50000,
                                chunk_size = 50000) {
  
  message(sprintf("  Procesando hoja: '%s'", hoja))
  
  # 1. Leer muestra para detectar encabezado (sin nombres de columna)
  muestra <- tryCatch(
    read_excel(file_path, sheet = hoja, n_max = 100, col_names = FALSE),
    error = function(e) {
      warning(sprintf("Error leyendo muestra de '%s': %s", hoja, e$message))
      return(NULL)
    }
  )
  
  if (is.null(muestra) || nrow(muestra) == 0) {
    warning(sprintf("Hoja '%s' vacía en muestra", hoja))
    return(tibble())
  }
  
  fila_encabezado <- detectar_fila_encabezado(muestra)
  message(sprintf("    Fila de encabezado detectada: %d", fila_encabezado))
  
  # 2. Leer la hoja completa con manejo correcto de encabezados
  hoja_data <- leer_hoja_excel_con_encabezado(file_path, hoja, fila_encabezado)
  
  if (is.null(hoja_data)) {
    warning(sprintf("No se pudo leer hoja '%s'", hoja))
    return(tibble())
  }
  
  df_count <- hoja_data$df
  original_names <- hoja_data$original_names
  clean_names <- hoja_data$clean_names
  n_rows <- hoja_data$n_rows
  n_cols <- hoja_data$n_cols
  
  message(sprintf("    Filas detectadas: %d, Columnas: %d", n_rows, n_cols))
  
  # 3. Decidir estrategia
  if (n_rows <= umbral_grande) {
    # PEQUEÑA/MEDIANA: procesar directamente en memoria
    message(sprintf("    Estrategia: PROCESAMIENTO COMPLETO EN MEMORIA (%d filas)", n_rows))
    
    resultado <- procesar_dataframe_completo(df_count, basename(file_path), info_inventario, hoja)
    
    # Actualizar nombres originales en resultado
    if (nrow(resultado) > 0) {
      resultado$variable_original <- original_names[match(resultado$variable_original, clean_names)]
    }
    
    return(resultado)
    
  } else {
    # GRANDE: convertir a CSV y procesar por chunks
    message(sprintf("    Estrategia: CONVERSIÓN A CSV + CHUNKING REAL (%d filas)", n_rows))
    
    temp_dir <- file.path(dirname(file_path), "..", "temp", "csv_intermediate")
    dir.create(temp_dir, showWarnings = FALSE, recursive = TRUE)
    
    csv_name <- sprintf("%s_%s.csv", 
                        str_replace_all(basename(file_path), "[^a-zA-Z0-9]", "_"),
                        str_replace_all(hoja, "[^a-zA-Z0-9]", "_"))
    csv_path <- file.path(temp_dir, csv_name)
    
    message(sprintf("    Escribiendo CSV temporal..."))
    fwrite(df_count, csv_path, sep = ",", na = "", quote = TRUE)
    rm(df_count)
    gc()
    
    # Procesar CSV en chunks
    resultado <- procesar_csv_chunks_real(csv_path, chunk_size, info_inventario, hoja, project_dir)
    
    # Restaurar nombres originales en resultado
    if (nrow(resultado) > 0) {
      resultado$variable_original <- original_names[match(resultado$variable_original, clean_names)]
    }
    
    return(resultado)
  }
}

# =============================================================================
# PROCESAMIENTO CSV DIRECTO (para DIVIPOLA)
# =============================================================================

procesar_csv_directo <- function(file_path, info_inventario, project_dir = NULL, chunk_size = 50000) {
  message(sprintf("  Procesando CSV: %s", basename(file_path)))
  
  # Verificar checkpoint
  if (!is.null(project_dir)) {
    cp <- load_checkpoint(project_dir, info_inventario$fuente, info_inventario$archivo, "datos")
    if (!is.null(cp) && cp$estado == "COMPLETO") {
      message("  Checkpoint: CSV ya COMPLETO")
      resultado_path <- file.path(get_checkpoint_dir(project_dir), 
                                  paste0(checkpoint_key(info_inventario$fuente, info_inventario$archivo, "datos"), "_result.rds"))
      if (file.exists(resultado_path)) {
        return(readRDS(resultado_path))
      }
    }
  }
  
  # Leer header
  header_dt <- fread(file_path, nrows = 0)
  col_names <- names(header_dt)
  n_cols <- length(col_names)
  
  # Contar filas (compatible con Windows)
  total_rows <- length(readLines(file_path, warn = FALSE)) - 1
  
  if (total_rows <= 10000) {
    # Pequeño: leer completo
    df <- fread(file_path)
    original_names <- names(df)
    clean_names <- make.names(original_names, unique = TRUE)
    names(df) <- clean_names
    attr(df, "original_names") <- original_names
    resultado <- procesar_dataframe_completo(df, basename(file_path), info_inventario, "datos")
    if (nrow(resultado) > 0) {
      resultado$variable_original <- original_names[match(resultado$variable_original, clean_names)]
    }
    return(resultado)
  } else {
    # Grande: chunking
    return(procesar_csv_chunks_real(file_path, chunk_size, info_inventario, "datos", project_dir))
  }
}

# =============================================================================
# FUNCIONES ORIGINALES MANTENIDAS (procesar_dataframe_completo, etc.)
# =============================================================================

# Las funciones procesar_dataframe_completo, count_lines, etc. se mantienen del archivo original
# Se cargan desde utils.R y auditoria_archivos.R original