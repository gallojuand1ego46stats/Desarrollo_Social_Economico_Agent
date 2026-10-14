# Constructores puros de registros de control; la tabla completa se escribe al cierre.

registro_validacion <- function(nombre, n_evaluado, n_violaciones,
                                tolerancia = "0", evidencia = "") {
  tibble::tibble(
    validacion = nombre,
    n_evaluado = as.integer(n_evaluado),
    n_violaciones = as.integer(n_violaciones),
    estado = ifelse(n_violaciones == 0, "PASS", "FAIL"),
    tolerancia = tolerancia,
    evidencia = evidencia
  )
}

registro_hallazgo <- function(metrica, esperado, obtenido, nota = "") {
  tibble::tibble(
    metrica = metrica,
    esperado = as.character(esperado),
    obtenido = as.character(obtenido),
    estado = ifelse(as.character(esperado) == as.character(obtenido), "PASS", "REVISAR"),
    nota = nota
  )
}

contar_sumas_distintas <- function(datos, columnas, total, tolerancia = 1e-8) {
  faltan <- setdiff(c(columnas, total), names(datos))
  if (length(faltan)) stop("Faltan columnas para reconciliar: ", paste(faltan, collapse = ", "), call. = FALSE)
  suma <- rowSums(datos[, columnas, drop = FALSE], na.rm = FALSE)
  sum(is.na(suma) | is.na(datos[[total]]) | abs(suma - datos[[total]]) > tolerancia)
}

verificar_llave_municipal <- function(datos) {
  requeridas <- c("codigo_municipio", "codigo_departamento")
  faltan <- setdiff(requeridas, names(datos))
  if (length(faltan)) stop("Faltan campos de llave: ", paste(faltan, collapse = ", "), call. = FALSE)
  codigo <- as.character(datos$codigo_municipio)
  depto <- as.character(datos$codigo_departamento)
  !is.na(codigo) & grepl("^[0-9]{5}$", codigo) & !is.na(depto) &
    grepl("^[0-9]{2}$", depto) & depto == substr(codigo, 1L, 2L)
}
