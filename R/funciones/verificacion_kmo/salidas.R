# Modulo 5. Resultados, huellas y registro del entorno.
# Solo se escriben productos del verificador. No se sobrescriben matrices de
# entrada, referencias de R/07, tablas del informe o resultados de PCA.

#' Escribir un CSV UTF-8 sin indices de fila ni dependencia de paquetes externos.
vk_guardar_csv <- function(tabla, nombre, config) {
  utils::write.csv(tabla, file.path(config$salida, nombre), row.names = FALSE,
                   fileEncoding = "UTF-8", na = "")
}

#' Registrar el estado para no confundir una corrida fallida con salidas previas.
vk_estado <- function(config, estado, detalle) {
  tabla <- data.frame(estado = estado, detalle = detalle,
                       fecha_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
                       stringsAsFactors = FALSE)
  vk_guardar_csv(tabla, "estado_verificacion_R.csv", config)
}

#' Publicar las salidas de cotejo; los CSV usan TRUE/FALSE nativos de R.
vk_exportar <- function(resultado, comparacion, config, huellas_antes, protegidos) {
  vk_guardar_csv(comparacion$global, "verificacion_independiente_R.csv", config)
  vk_guardar_csv(comparacion$msa, "verificacion_MSA_R.csv", config)
  resumen <- data.frame(n = resultado$n, p = resultado$p, KMO = resultado$KMO,
    chi_cuadrado = resultado$chi_cuadrado, gl = resultado$gl,
    ln_p_nominal = resultado$ln_p_nominal, log10_p_nominal = resultado$log10_p_nominal,
    p_texto = resultado$p_texto, p_subdesbordamiento = exp(resultado$ln_p_nominal) == 0,
    determinante = resultado$determinante, log_determinante = resultado$log_determinante,
    suma_r2_pares = resultado$suma_r2_pares, suma_parcial2_pares = resultado$suma_parcial2_pares,
    condicion_2 = resultado$condicion_2, minimo_autovalor_validacion = resultado$minimo_autovalor_validacion,
    residuo_inversa = resultado$residuo_inversa, version_R = as.character(getRversion()),
    implementacion = "R base: productos cruzados, solve, LU y cola finita logaritmica")
  vk_guardar_csv(resumen, "resumen_verificacion_R.csv", config)
  saveRDS(resultado, file.path(config$salida, "resumen_verificacion_R.rds"), version = 3L)
  utils::capture.output(utils::sessionInfo(), file = file.path(config$salida, "sessionInfo_verificacion_R.txt"))

  # SHA-256 identifica el codigo, matriz y referencias usados por esta corrida.
  relativos <- c("R/07_kmo_bartlett_candidatas.R", "R/auxiliares/verificar_kmo_bartlett.R", config$modulos)
  archivos <- c(protegidos, file.path(config$raiz, relativos))
  manifest <- data.frame(archivo = substring(archivos, nchar(config$raiz) + 2L),
                         sha256 = unname(vk_huellas(archivos)), stringsAsFactors = FALSE)
  vk_guardar_csv(manifest, "manifest_sha256.csv", config)
  integridad <- data.frame(archivo = substring(protegidos, nchar(config$raiz) + 2L),
                           sha256_antes = unname(huellas_antes),
                           sha256_despues = unname(vk_huellas(protegidos)), stringsAsFactors = FALSE)
  integridad$cumple <- integridad$sha256_antes == integridad$sha256_despues
  vk_guardar_csv(integridad, "integridad_verificacion_R.csv", config)
  vk_exigir(all(integridad$cumple), "Un archivo de entrada o referencia cambio durante el cotejo.")
  invisible(resumen)
}
