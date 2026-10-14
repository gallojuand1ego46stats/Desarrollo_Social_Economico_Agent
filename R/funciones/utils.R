# Utils.R
# Funciones auxiliares para la auditoría de bases de datos

#' Clasificar tipo estadístico de una variable
#'
#' @param valores Vector de valores
#' @param tipo_r Tipo de dato en R
#' @return Tipo estadístico como cadena
clasificar_tipo_estadistico <- function(valores, tipo_r) {
  if (is.numeric(valores)) {
    # Determinar si es discreta o continua basada en valores únicos y rango
    vals <- na.omit(valores)
    if (length(vals) == 0) return("desconocido")
    
    # Si todos son enteros y el rango no es muy grande, considerar discreta
    if (all(vals == floor(vals))) {
      rango <- max(vals) - min(vals)
      if (rango < 100 && length(unique(vals)) < 50) {
        return("discreta")
      } else {
        return("continua")
      }
    } else {
      return("continua")
    }
  } else if (is.character(valores) || is.factor(valores)) {
    vals <- na.omit(valores)
    if (length(vals) == 0) return("nominal")
    
    # Verificar si parece una escala ordinal (ej. niveles de educación, rangos de edad)
    # Por ahora, clasificar como nominal a menos que haya indicios de ordinal
    return("nominal")
  } else if (is.logical(valores)) {
    return("binaria")
  } else {
    return("otro")
  }
}

#' Clasificar escala de medición
#'
#' @param valores Vector de valores
#' @param tipo_r Tipo de dato en R
#' @return Escala de medición (nominal, ordinal, intervalo, razón)
clasificar_escala_medicion <- function(valores, tipo_r) {
  tipo_est <- clasificar_tipo_estadistico(valores, tipo_r)
  
  if (tipo_est %in% c("nominal", "binaria")) {
    return("nominal")
  } else if (tipo_est == "ordinal") {
    return("ordinal")
  } else if (tipo_est %in% c("discreta", "continua")) {
    # Determinar si tiene cero absoluto (razón) o no (intervalo)
    # Para simplificar, asumimos razón si los valores son no negativos y tienen sentido de razón
    vals <- na.omit(valores)
    if (length(vals) == 0) return("razon")
    
    # Si todos los valores son no negativos y no hay valores arbitrarios de cero, considerar razón
    if (all(vals >= 0)) {
      # Verificar si cero tiene significado especial (difficile sin contexto)
      # Por ahora, asumimos razón para variables de conteo y medidas físicas
      return("razon")
    } else {
      return("intervalo")
    }
  } else {
    return("nominal")
  }
}

#' Inferir naturaleza de la variable basada en nombre y valores
#'
#' @param nombre Nombre de la variable
#' @param valores Vector de valores
#' @param tipo_r Tipo de dato en R
#' @return Naturaleza como cadena
inferir_naturaleza <- function(nombre, valores, tipo_r) {
  nombre_lower <- tolower(nombre)
  
  # Patrones para diferentes naturalezas
  if (str_detect(nombre_lower, regex("poblacion|personas|habitantes|edad|sexo|nacimientos|muertes|migracion", ignore_case = TRUE))) {
    return("demografica")
  } else if (str_detect(nombre_lower, regex("vivienda|hogar|hogares|casa|inmueble|techo|pared|piso|material|acueducto|alcantarillado|energia|gas|basura|servicio|tenencia|ocupacion", ignore_case = TRUE))) {
    return("vivienda")
  } else if (str_detect(nombre_lower, regex("educacion|escuela|alfabetismo|nivel educativo|asistencia|escuela|licenciatura|grado", ignore_case = TRUE))) {
    return("educacion")
  } else if (str_detect(nombre_lower, regex("salud|enfermedad|mortalidad|natalidad|seguro|hospital|clinica|vacuna", ignore_case = TRUE))) {
    return("salud")
  } else if (str_detect(nombre_lower, regex("trabajo|empleo|desempleo|actividad economica|ingreso|salario|ocupacion|desocupacion|subempleo", ignore_case = TRUE))) {
    return("empleo")
  } else if (str_detect(nombre_lower, regex("pobreza|privacion|desarrollo social|nivel de vida|ipm|indice", ignore_case = TRUE))) {
    return("pobreza")
  } else if (str_detect(nombre_lower, regex("departamento|municipio|codigo|divipola|territorio|zona|region", ignore_case = TRUE))) {
    return("territorial")
  } else if (str_detect(nombre_lower, regex("servicio publico|acueducto|alcantarillado|aseo|energia|gas|internet|telefono", ignore_case = TRUE))) {
    return("servicios_publicos")
  } else {
    return("otra")
  }
}

#' Inferir unidad de medida
#'
#' @param nombre Nombre de la variable
#' @param valores Vector de valores
#' @param tipo_r Tipo de dato en R
#' @return Unidad como cadena
inferir_unidad <- function(nombre, valores, tipo_r) {
  nombre_lower <- tolower(nombre)
  
  # Patrones comunes de unidades
  if (str_detect(nombre_lower, regex("porcentaje|pct|%", ignore_case = TRUE))) {
    return("%")
  } else if (str_detect(nombre_lower, regex("por mil|per thousand|\\\\\\\\%", ignore_case = TRUE))) {
    return("por mil")
  } else if (str_detect(nombre_lower, regex("por cien|per hundred", ignore_case = TRUE))) {
    return("por cien")
  } else if (str_detect(nombre_lower, regex("ratio|razon|proporcion", ignore_case = TRUE))) {
    return("proporcion")
  } else if (str_detect(nombre_lower, regex("tasa|rate", ignore_case = TRUE))) {
    return("tasa")
  } else if (str_detect(nombre_lower, regex("aos?|years?|edad", ignore_case = TRUE))) {
    return("años")
  } else if (str_detect(nombre_lower, regex("metros?|m2|metros cuadrados|area", ignore_case = TRUE))) {
    return("metros cuadrados")
  } else if (str_detect(nombre_lower, regex("pesos?|cop|moneda|valor|costo|gasto|ingreso", ignore_case = TRUE))) {
    return("pesos colombianos")
  } else if (str_detect(nombre_lower, regex("numero|numero de|count|cantidad|total", ignore_case = TRUE))) {
    return("conteo")
  } else if (str_detect(nombre_lower, regex("densidad|poblacion por km2", ignore_case = TRUE))) {
    return("personas/km²")
  } else {
    return("no especificada")
  }
}

#' Inferir universo al que se refiere la variable
#'
#' @param nombre Nombre de la variable
#' @param valores Vector de valores
#' @param tipo_r Tipo de dato en R
#' @return Universo como cadena
inferir_universo <- function(nombre, valores, tipo_r) {
  nombre_lower <- tolower(nombre)
  
  if (str_detect(nombre_lower, regex("poblacion|personas|habitantes", ignore_case = TRUE))) {
    return("personas")
  } else if (str_detect(nombre_lower, regex("vivienda|viviendas|casa|hogar|hogares|inmueble", ignore_case = TRUE))) {
    return("viviendas")
  } else if (str_detect(nombre_lower, regex("hogar|hogares|familia", ignore_case = TRUE))) {
    return("hogares")
  } else if (str_detect(nombre_lower, regex("edad|anos?|a[0-9]", ignore_case = TRUE))) {
    return("personas por edad")
  } else if (str_detect(nombre_lower, regex("servicio|acueducto|alcantarillado|energia|gas|basura", ignore_case = TRUE))) {
    return("viviendas o hogares con servicio")
  } else if (str_detect(nombre_lower, regex("educacion|escuela|alfabetismo", ignore_case = TRUE))) {
    return("personas")
  } else if (str_detect(nombre_lower, regex("trabajo|empleo|desempleo", ignore_case = TRUE))) {
    return("personas en edad laboral")
  } else {
    return("no especificado")
  }
}

#' Determinar si una variable es un identificador
#'
#' @param valores Vector de valores
#' @param nombre Nombre de la variable
#' @return Lógico
es_identificador <- function(valores, nombre) {
  if (length(valores) == 0) return(FALSE)
  
  nombre_lower <- tolower(nombre)
  
  # Patrones de identificadores
  id_patterns <- c("codigo", "cod", "id", "identifier", "clave", "llave")
  
  if (any(str_detect(nombre_lower, regex(paste(id_patterns, collapse = "|"), ignore_case = TRUE)))) {
    return(TRUE)
  }
  
  # Alta cardinalidad y bajo porcentaje de missing pueden indicar identificador
  vals <- na.omit(valores)
  if (length(vals) > 0) {
    prop_unicos <- length(unique(vals)) / length(vals)
    if (prop_unicos > 0.95 && length(vals) > 10) {
      return(TRUE)
    }
  }
  
  return(FALSE)
}

#' Determinar si una variable es un indicador potencial
#'
#' @param valores Vector de valores
#' @param nombre Nombre de la variable
#' @param tipo_r Tipo de dato en R
#' @return Lógico
es_indicador <- function(valores, nombre, tipo_r) {
  # No es indicador si es identificador claro
  if (es_identificador(valores, nombre)) return(FALSE)
  
  # Las variables numéricas con variabilidad son buenos indicadores
  if (is.numeric(valores)) {
    vals <- na.omit(valores)
    if (length(vals) > 1) {
      # Verificar que no sea casi constante
      if (var(vals, na.rm = TRUE) > 1e-10) {
        return(TRUE)
      }
    }
  }
  
  # Las variables categóricas con pocas categorías pueden ser indicadores
  if (!is.numeric(valores)) {
    vals <- na.omit(valores)
    if (length(vals) > 0) {
      n_unicos <- length(unique(vals))
      if (n_unicos >= 2 && n_unicos <= 10) {  # Rango razonable para categorías
        return(TRUE)
      }
    }
  }
  
  return(FALSE)
}

#' Determinar si una variable necesita transformación
#'
#' @param valores Vector de valores
#' @param nombre Nombre de la variable
#' @param tipo_r Tipo de dato en R
#' @return Lógico
necesita_transformacion <- function(valores, nombre, tipo_r) {
  # Las variables de conteo absoluto suelen necesitar transformación a proporciones/tasas
  if (is.numeric(valores)) {
    nombre_lower <- tolower(nombre)
    conteo_patterns <- c("numero", "numero de", "total", "suma", "cantidad", "count")
    
    if (any(str_detect(nombre_lower, regex(paste(conteo_patterns, collapse = "|"), ignore_case = TRUE)))) {
      # Verificar si ya es una tasa o proporción
      if (!str_detect(nombre_lower, regex("porcentaje|pct|%|ratio|proporcion|tasa|rate|por mil|por cien", ignore_case = TRUE))) {
        return(TRUE)
      }
    }
  }
  
  return(FALSE)
}

#' Sugerir transformación para una variable
#'
#' @param valores Vector de valores
#' @param nombre Nombre de la variable
#' @param tipo_r Tipo de dato en R
#' @return Cadena con la transformación sugerida
sugerir_transformacion <- function(valores, nombre, tipo_r) {
  if (!necesita_transformacion(valores, nombre, tipo_r)) {
    return(NA_character_)
  }
  
  nombre_lower <- tolower(nombre)
  
  # Sugerir denominadores comunes basado en el nombre
  if (str_detect(nombre_lower, regex("vivienda|viviendas|casa|inmueble", ignore_case = TRUE))) {
    return("proporcion sobre total_viviendas")
  } else if (str_detect(nombre_lower, regex("hogar|hogares|familia", ignore_case = TRUE))) {
    return("proporcion sobre total_hogares")
  } else if (str_detect(nombre_lower, regex("persona|poblacion|habitante", ignore_case = TRUE))) {
    return("proporcion sobre total_poblacion")
  } else if (str_detect(nombre_lower, regex("servicio|acueducto|alcantarillado|energia|gas|basura", ignore_case = TRUE))) {
    return("proporcion sobre viviendas_con_servicio_posible")  # Necesitaría contexto
  } else {
    return("transformacion_por_determinar")
  }
}

#' Inferir dirección de vulnerabilidad
#'
#' @param nombre Nombre de la variable
#' @param valores Vector de valores
#' @param tipo_r Tipo de dato en R
#' @return "+" (mayor valor = mayor vulnerabilidad), "-" (mayor valor = menor vulnerabilidad), "?" (pendiente)
inferir_direccion_vulnerabilidad <- function(nombre, valores, tipo_r) {
  nombre_lower <- tolower(nombre)
  
  # Variables que indican mejoras (mayor valor = menos vulnerabilidad)
  mej_patterns <- c(
    "acceso", "cobertura", "servicio", "acueducto", "alcantarillado", 
    "energia", "electricidad", "gas", "basura", "recoleccion",
    "educacion", "escuela", "alfabetismo", "aprobacion", "promocion",
    "salud", "seguro", "vacuna", "atencion", "hospital",
    "trabajo", "empleo", "ingreso", "salario", "ocupacion",
    "viviendo", "propietario", "formal"
  )
  
  # Variables que indican privaciones (mayor valor = más vulnerabilidad)
  priv_patterns <- c(
    "pobreza", "privacion", "insatisfaccion", "carencia", "deficiencia",
    "hacinamiento", "inadecuado", "inadequado", "sin", "carece",
    "desempleo", "paro", "inactivo", "analfabetismo", "no asistente",
    "no aprobado", "desercion", "reprobado", "inseguridad",
    "violencia", "delito", "contaminacion"
  )
  
  if (any(str_detect(nombre_lower, regex(paste(mej_patterns, collapse = "|"), ignore_case = TRUE)))) {
    return("-")  # Mayor valor = mejor condición = menos vulnerabilidad
  } else if (any(str_detect(nombre_lower, regex(paste(priv_patterns, collapse = "|"), ignore_case = TRUE)))) {
    return("+")  # Mayor valor = peor condición = más vulnerabilidad
  } else {
    return("?")  # Pendiente de validación conceptual
  }
}

#' Calcular asimetría (skewness)
#'
#' @param x Vector numérico
#' @return Asimetría
asimetria <- function(x) {
  if (length(x) < 3) return(NA_real_)
  n <- length(x)
  mean_x <- mean(x, na.rm = TRUE)
  sd_x <- sd(x, na.rm = TRUE)
  if (sd_x == 0) return(0)
  sum((x - mean_x)^3, na.rm = TRUE) / (n * sd_x^3)
}

#' Curtosis (exceso de curtosis)
#'
#' @param x Vector numérico
#' @return Curtosis
curtosis <- function(x) {
  if (length(x) < 4) return(NA_real_)
  n <- length(x)
  mean_x <- mean(x, na.rm = TRUE)
  sd_x <- sd(x, na.rm = TRUE)
  if (sd_x == 0) return(0)
  sum((x - mean_x)^4, na.rm = TRUE) / (n * sd_x^4) - 3
}