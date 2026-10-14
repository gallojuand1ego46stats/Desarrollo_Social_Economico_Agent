# Funciones puras para resumir y clasificar los resultados del pipeline de indicadores.

leer_csv_auditoria <- function(path) {
  readr::read_csv(
    path,
    col_types = readr::cols(.default = readr::col_character()),
    locale = readr::locale(encoding = "UTF-8"),
    na = c("", "NA"),
    name_repair = "minimal",
    show_col_types = FALSE,
    progress = FALSE
  )
}

numero_auditoria <- function(x, campo) {
  if (is.numeric(x)) return(as.double(x))
  valor <- suppressWarnings(readr::parse_double(
    as.character(x),
    locale = readr::locale(decimal_mark = ".", grouping_mark = ",")
  ))
  invalido <- !is.na(x) & is.na(valor)
  if (any(invalido)) {
    stop("Valores no numericos en ", campo, ": ",
         paste(unique(x[invalido]), collapse = ", "), call. = FALSE)
  }
  valor
}

requerir_columnas <- function(datos, columnas, fuente) {
  faltan <- setdiff(columnas, names(datos))
  if (length(faltan)) {
    stop("Faltan columnas en ", fuente, ": ", paste(faltan, collapse = ", "),
         call. = FALSE)
  }
  invisible(TRUE)
}

estadisticos_municipales <- function(datos, indicadores, percentiles = c(0.01, 0.25, 0.50, 0.75, 0.99)) {
  purrr::map_dfr(indicadores, function(id) {
    x <- numero_auditoria(datos[[id]], id)
    x <- x[is.finite(x)]
    qs <- stats::quantile(x, probs = percentiles,
                          na.rm = TRUE, names = FALSE, type = 7)
    media <- mean(x)
    sd_x <- stats::sd(x)
    skew <- if (length(x) > 2L && is.finite(sd_x) && sd_x > 0) {
      mean((x - media)^3) / sd_x^3
    } else NA_real_
    kurt <- if (length(x) > 3L && is.finite(sd_x) && sd_x > 0) {
      mean((x - media)^4) / sd_x^4 - 3
    } else NA_real_
    tibble::tibble(
      indicador = id,
      n = length(x),
      minimo = min(x),
      p01 = qs[[1]],
      p25 = qs[[2]],
      mediana = qs[[3]],
      media = media,
      p75 = qs[[4]],
      p99 = qs[[5]],
      maximo = max(x),
      desviacion_estandar = sd_x,
      varianza = stats::var(x),
      asimetria = skew,
      curtosis_exceso = kurt,
      pct_ceros = 100 * mean(x == 0),
      tipo_escala = if (id == "dependencia_demografica") "razon" else "proporcion",
      n_fuera_0_1 = if (id == "dependencia_demografica") NA_integer_ else sum(x < 0 | x > 1),
      rango_efectivo_p01_p99 = qs[[5]] - qs[[1]]
    )
  })
}

clasificar_distribucion <- function(fila, umbral_asimetria = 2, pct_ceros_concentracion = 50) {
  problemas <- character()
  if (!is.na(fila$n_fuera_0_1) && fila$n_fuera_0_1 > 0) problemas <- c(problemas, "fuera de [0,1]")
  if (fila$desviacion_estandar <= sqrt(.Machine$double.eps)) {
    problemas <- c(problemas, "varianza casi nula")
  }
  if (abs(fila$asimetria) > umbral_asimetria) {
    problemas <- c(problemas, "asimetria alta")
  }
  if (fila$pct_ceros >= pct_ceros_concentracion) problemas <- c(problemas, "al menos 50% de ceros")
  if (length(problemas)) paste(problemas, collapse = "; ") else "sin alerta automatica"
}

interpretar_correlacion <- function(r, umbral_moderado = 0.40, umbral_fuerte = 0.70) {
  if (is.na(r)) return("no calculable")
  a <- abs(r)
  nivel <- if (a >= umbral_fuerte) "fuerte" else if (a >= umbral_moderado) "moderada" else "debil"
  paste(nivel, if (r < 0) "negativa" else "positiva")
}

escribir_csv_auditoria <- function(datos, path) {
  readr::write_csv(datos, path, na = "")
  invisible(path)
}
