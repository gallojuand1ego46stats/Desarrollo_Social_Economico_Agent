# Modulo 2. Lectura estricta y validacion de la matriz censal.
# Las llaves se leen como texto para conservar ceros iniciales. No se imputan
# valores, no se eliminan filas y no se usa correlacion por pares disponibles.

#' Leer un CSV UTF-8, con o sin BOM, conservando nombres y contenido como texto.
vk_leer_csv <- function(archivo) {
  vk_exigir(file.exists(archivo), paste("No existe el archivo:", archivo))
  # encoding marca las cadenas UTF-8 sin convertirlas al juego de caracteres
  # local. fileEncoding intentaria esa conversion y podria truncar municipios
  # con tildes en una sesion configurada en locale C. Se elimina un BOM opcional
  # solo del primer encabezado; los contenidos y codigos quedan intactos.
  datos <- utils::read.csv(archivo, colClasses = "character", check.names = FALSE,
                           encoding = "UTF-8", na.strings = c("", "NA"))
  names(datos)[1L] <- sub("^\ufeff", "", names(datos)[1L], useBytes = TRUE)
  vk_exigir(!anyDuplicated(names(datos)), paste("Columnas duplicadas en:", archivo))
  datos
}

#' Convertir una columna de texto a numeros finitos, sin ocultar errores de origen.
vk_numeros <- function(texto, nombre) {
  valores <- suppressWarnings(as.numeric(texto))
  vk_exigir(all(is.finite(valores)),
            paste("Valores ausentes, no numericos o infinitos en:", nombre))
  valores
}

#' Validar y extraer la matriz n por p del ambito principal.
#' @param config Lista devuelta por vk_configuracion().
#' @return Lista con matriz numerica X y vector de codigos territoriales.
vk_leer_matriz <- function(config) {
  datos <- vk_leer_csv(config$matriz)
  columnas <- c(config$metadatos, config$variables)
  vk_exigir(identical(names(datos), columnas),
            "La matriz no tiene exactamente los metadatos y las ocho candidatas acordadas.")
  vk_exigir(nrow(datos) == config$n_esperado, "Se esperaban exactamente 1.102 filas.")
  codigos <- datos$codigo_municipio
  vk_exigir(!anyNA(codigos) && all(grepl("^[0-9]{5}$", codigos)),
            "Los codigos territoriales deben tener cinco digitos y no contener NA.")
  vk_exigir(!anyDuplicated(codigos), "La matriz contiene codigos territoriales duplicados.")

  X <- vapply(config$variables, function(v) vk_numeros(datos[[v]], v),
              numeric(config$n_esperado))
  vk_exigir(ncol(X) == config$p_esperado, "Se esperaban ocho columnas numericas.")
  vk_exigir(all(X >= 0 & X <= 1), "Los indicadores deben estar en el intervalo [0,1].")
  dispersion <- apply(X, 2L, stats::sd)
  vk_exigir(all(is.finite(dispersion) & dispersion > 0),
            "Todas las candidatas deben tener variacion positiva.")
  list(X = X, codigos = codigos)
}

#' Calcular huellas SHA-256 de los archivos de entrada y referencia.
#' Requiere una version de R que exporte tools::sha256sum (R 4.6.0 comprobado).
#' No usa programas externos, Python ni paquetes instalados por el usuario.
vk_huellas <- function(archivos) {
  vk_exigir("sha256sum" %in% getNamespaceExports("tools"),
            "Esta version de R no ofrece tools::sha256sum; utilice R 4.6.0 o posterior.")
  vk_exigir(all(file.exists(archivos)), "Faltan archivos para el control de integridad.")
  huellas <- tools::sha256sum(archivos)
  vk_exigir(!anyNA(huellas), "No se pudieron calcular todas las huellas SHA-256.")
  huellas
}
