# Pruebas sencillas de regresion y reglas metodologicas. Ejecutar desde la raiz del repo.
root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(dplyr))
source(file.path(root, "R", "00_config.R"), encoding = "UTF-8")
source(file.path(root, "R", "funciones", "io.R"), encoding = "UTF-8")
source(file.path(root, "R", "funciones", "validacion.R"), encoding = "UTF-8")

trabajo <- file.path(root, ivs_config$rutas$trabajo)
salidas <- file.path(root, ivs_config$rutas$resultados_base)
base <- leer_csv_texto(file.path(trabajo, "indicadores_municipales_base_total.csv"))
matriz <- leer_csv_texto(file.path(trabajo, "matriz_pca.csv"))
den <- leer_csv_texto(file.path(trabajo, "denominadores_municipales.csv"))
spec <- leer_csv_texto(file.path(salidas, "especificacion_indicadores.csv"))
conteos <- leer_csv_texto(file.path(salidas, "auditoria_conteos.csv"))
nr <- leer_csv_texto(file.path(salidas, "nr_item_municipal.csv"))

stopifnot(nrow(base) == ivs_config$n_municipios)
stopifnot(nrow(matriz) == ivs_config$n_municipios)
stopifnot(!anyDuplicated(base$codigo_municipio), !anyDuplicated(matriz$codigo_municipio))
stopifnot(all(verificar_llave_municipal(base)), all(verificar_llave_municipal(den)))
stopifnot(identical(base$codigo_municipio, matriz$codigo_municipio))

ids <- spec$id_indicador
candidatos <- spec$id_indicador[spec$incluir_pca_propuesto == "TRUE"]
stopifnot(length(ids) == 17L, length(candidatos) == 7L)
stopifnot(all(ids %in% names(base)), all(candidatos %in% names(matriz)))
for (id in candidatos) {
  x <- parse_numero(matriz[[id]], paste("matriz", id))
  stopifnot(all(is.finite(x)), all(x >= ivs_config$control$proporcion_minima),
            all(x <= ivs_config$control$proporcion_maxima))
}

negativos <- as.integer(vapply(conteos$negativos, function(x) parse_numero(x, "negativos"), numeric(1)))
no_enteros <- as.integer(vapply(conteos$no_enteros, function(x) parse_numero(x, "no enteros"), numeric(1)))
stopifnot(all(negativos == 0L), all(no_enteros == 0L))
stopifnot(any(nr$item == "no_sabe_no_responde"), any(grepl("no_tiene_estrato", nr$item)))
stopifnot(any(den$flag_denominador_cero == "FALSE"))

# Pruebas de borde para utilidades compartidas.
bad_key <- tibble::tibble(codigo_departamento = c("05", "05"), codigo_municipio = c("05001", "5001"))
stopifnot(identical(verificar_llave_municipal(bad_key), c(TRUE, FALSE)))
toy <- data.frame(a = c(1, 2), b = c(2, 2), total = c(3, 5))
stopifnot(contar_sumas_distintas(toy, c("a", "b"), "total") == 1L)
stopifnot(inherits(try(parse_numero(c("1", "N.D."), "test no numerico"), silent = TRUE), "try-error"))

message("PASS: universo, llave, candidatos, rangos, conteos, NR y utilidades.")
