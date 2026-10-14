# Lectura, coercion explicita y escritura de tablas del proyecto.

leer_csv_texto <- function(path) {
  readr::read_csv(
    path,
    col_types = readr::cols(.default = readr::col_character()),
    locale = readr::locale(encoding = "UTF-8"),
    na = c("", "NA"),
    trim_ws = FALSE,
    name_repair = "minimal",
    show_col_types = FALSE,
    progress = FALSE
  )
}

parse_numero <- function(x, contexto) {
  numero <- suppressWarnings(readr::parse_double(
    as.character(x),
    locale = readr::locale(decimal_mark = ".", grouping_mark = ",")
  ))
  invalido <- !is.na(x) & is.na(numero)
  if (any(invalido)) {
    stop("No convierte a numero en ", contexto, ": ",
         paste(unique(x[invalido]), collapse = ", "), call. = FALSE)
  }
  numero
}

convertir_columnas_numericas <- function(datos, columnas, tabla) {
  faltan <- setdiff(columnas, names(datos))
  if (length(faltan)) {
    stop("Columnas inexistentes en ", tabla, ": ", paste(faltan, collapse = ", "), call. = FALSE)
  }
  for (nombre in columnas) datos[[nombre]] <- parse_numero(datos[[nombre]], paste(tabla, nombre))
  datos
}

escribir_csv <- function(datos, directorio, nombre, na = "") {
  readr::write_csv(datos, file.path(directorio, nombre), na = na)
  invisible(datos)
}

hash_archivos <- function(paths, root) {
  tibble::tibble(
    archivo = substring(paths, nchar(root) + 2L),
    md5 = unname(tools::md5sum(paths))
  )
}
