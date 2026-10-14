# Funciones para auditoría especial de IPM

#' Auditoría especial del IPM municipal 2018
#'
#' @param ipm_path Ruta al archivo de IPM
#' @return Lista con resumen de dimensiones/indicadores y variables
auditar_ipm_especial <- function(ipm_path) {
  if (!file.exists(ipm_path)) {
    warning(sprintf("Archivo IPM no encontrado: %s", ipm_path))
    return(list(resumen = tibble(), variables = tibble()))
  }
  
  # Obtener nombres de hojas
  hojas <- tryCatch(
    excel_sheets(ipm_path),
    error = function(e) {
      warning(sprintf("Error obteniendo hojas de IPM: %s", e$message))
      return(character())
    }
  )
  
  if (length(hojas) == 0) {
    warning("No se pudieron obtener las hojas del archivo IPM")
    return(list(resumen = tibble(), variables = tibble()))
  }
  
  # Procesar cada hoja para extraer información de IPM
  resultados <- list()
  
  for (hoja in hojas) {
    # Intentar leer la hoja para entender su estructura
    df_hoja <- tryCatch(
      read_excel(ipm_path, sheet = hoja),
      error = function(e) {
        warning(sprintf("Error leyendo hoja '%s' de IPM: %s", hoja, e$message))
        return(tibble())
      }
    )
    
    if (nrow(df_hoja) == 0) next
    
    # Analizar la hoja para identificar si contiene información de IPM
    # Esta es una simplificación - en una implementación real se haría un análisis más profundo
    resumen_hoja <- analizar_hoja_ipm(df_hoja, hoja)
    if (!is.null(resumen_hoja) && nrow(resumen_hoja) > 0) {
      resultados[[hoja]] <- resumen_hoja
    }
  }
  
  # Combinar resultados
  if (length(resultados) > 0) {
    resumen_combinado <- bind_rows(resultados)
  } else {
    resumen_combinado <- tibble()
  }
  
  # También extraer variables detalladas si es posible
  variables_detalladas <- extraer_variables_ipm_detalladas(ipm_path)
  
  return(list(
    resumen = resumen_combinado,
    variables = variables_detalladas
  ))
}

#' Analizar una hoja de IPM para extraer dimensiones e indicadores
#'
#' @param df Data frame de la hoja
#' @param nombre_hoja Nombre de la hoja
#' @return Tibble con información de dimensiones e indicadores
analizar_hoja_ipm <- function(df, nombre_hoja) {
  if (nrow(df) == 0) return(tibble())
  
  # Esta función tendría que ser personalizada según la estructura específica del IPM
  # Por ahora, devolvemos una estructura básica
  
  # Identificar columnas que podrían ser indicadores
  columnas <- names(df)
  
  # Buscar patrones típicos de IPM
  indicadores_ipm <- c(
    "IPM", "Indice", "Pobreza", "Privacion", "Educacion", 
    "Salud", "Trabajo", "Vivienda", "Internet"
  )
  
  columnas_indicador <- columnas[str_detect(columnas, regex(paste(indicadores_ipm, collapse = "|"), ignore_case = TRUE))]
  
  if (length(columnas_indicador) == 0) {
    # Si no encontramos indicadores obvios, devolver información básica de la hoja
    return(tibble(
      hoja = nombre_hoja,
      dimension = "por_determinar",
      indicador = "hoja_completa",
      variable = "estructura_hoja",
      definicion = sprintf("Hoja '%s' del archivo IPM", nombre_hoja),
      ponderacion = NA_real_,
      cobertura = NA_real_,
      stringsAsFactors = FALSE
    ))
  }
  
  # De lo contrario, crear entradas para cada indicador encontrado
  resultados <- list()
  for (ind in columnas_indicador) {
    resultados[[ind]] <- tibble(
      hoja = nombre_hoja,
      dimension = inferir_dimension_ipm(ind),
      indicador = ind,
      variable = ind,
      definicion = inferir_definicion_ipm(ind),
      ponderacion = NA_real_,  # Se completaría con información específica
      cobertura = NA_real_,    # Se completaría con análisis de datos
      stringsAsFactors = FALSE
    )
  }
  
  if (length(resultados) > 0) {
    return(bind_rows(resultados))
  } else {
    return(tibble())
  }
}

#' Inferir dimensión IPM basado en el nombre del indicador
#'
#' @param indicador Nombre del indicador
#' @return Dimensión IPM
inferir_dimension_ipm <- function(indicador) {
  indicador_lower <- tolower(indicador)
  
  dimensiones <- list(
    educacion = c("educacion", "escuela", "alfabetismo", "grado", "bachiller", "universitario"),
    salud = c("salud", "seguro", "vida", "mortalidad", "natalidad"),
    trabajo = c("trabajo", "empleo", "desempleo", "informal", "cotizante"),
    condiciones_de_vida = c("vivienda", "agua", "sanitario", "energia", "basura", "internet", "hacinamiento", "pared", "piso", "techo"),
    infancia_y_juventud = c("niñez", "juventud", "escuela", "asistencia", "rezago")
  )
  
  for (dim in names(dimensiones)) {
    if (any(str_detect(indicador_lower, regex(paste(dimensiones[[dim]], collapse = "|"), ignore_case = TRUE)))) {
      return(dim)
    }
  }
  
  return("por_determinar")
}

#' Inferir definición IPM basado en el nombre del indicador
#'
#' @param indicador Nombre del indicador
#' @return Definición del indicador
inferir_definicion_ipm <- function(indicador) {
  indicador_lower <- tolower(indicador)
  
  # Definiciones típicas de componentes IPM (simplificadas)
  definiciones <- list(
    "IPM" = "Índice de Pobreza Multidimensional",
    "pobreza" = "Condición de pobreza multidimensional",
    "educacion" = "Acceso y logro educativo",
    "salud" = "Cobertura y acceso a servicios de salud",
    "trabajo" = "Condiciones de empleo y trabajo",
    "vivienda" = "Condiciones de vivienda y servicios públicos",
    "hacinamiento" = "Indicador de hacinamiento en el hogar",
    "sanitario" = "Acceso a servicios sanitarios adecuados",
    "agua" = "Acceso a fuente de agua mejorada",
    "energia" = "Acceso a servicio de energía eléctrica",
    "basura" = "Servicio de recolección de basuras",
    "internet" = "Acceso a servicios de internet",
    "alfabetismo" = "Capacidad de lectura y escritura",
    "rezago_escolar" = "Rezago en la escolaridad según edad",
    "desercion_escolar" = "Tasa de deserción del sistema educativo",
    "mort_infantil" = "Mortalidad en menores de 5 años",
    "desnutricion" = "Prevalencia de desnutrición infantil"
  )
  
  # Buscar coincidencia exacta o parcial
  for (clave in names(definiciones)) {
    if (str_detect(indicador_lower, regex(clave, ignore_case = TRUE))) {
      return(definiciones[[clave]])
    }
  }
  
  return(paste("Definición por determinar para:", indicador))
}

#' Extraer variables detalladas del IPM
#'
#' @param ipm_path Ruta al archivo IPM
#' @return Tibble con variables detalladas
extraer_variables_ipm_detalladas <- function(ipm_path) {
  # Esta función haría un análisis más detallado de las variables del IPM
  # Por ahora, devolvemos una estructura vacía
  return(tibble(
    fuente = character(),
    archivo = character(),
    hoja = character(),
    variable_original = character(),
    descripcion = character(),
    tipo_r = character(),
    tipo_estadistico = character(),
    stringsAsFactors = FALSE
  ))
}