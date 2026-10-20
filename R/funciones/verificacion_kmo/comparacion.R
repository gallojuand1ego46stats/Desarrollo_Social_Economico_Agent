# Modulo 4. Lectura de referencias y conciliacion por nombres de indicador.
# Las referencias se abren DESPUES de reconstruir las estadisticas. Asi no se
# utilizan las cifras de R/07 para producir el resultado independiente.

#' Leer una referencia global unica y alinear MSA por nombre, nunca por posicion.
vk_referencias <- function(config) {
  globales <- vk_leer_csv(config$referencia_global)
  requeridas <- c("escenario", "metodo", "n", "p", "KMO", "chi_cuadrado",
                  "gl", "ln_p_nominal", "log_determinante")
  vk_exigir(all(requeridas %in% names(globales)), "Faltan columnas en la referencia global.")
  seleccion <- which(globales$escenario == config$escenario & globales$metodo == config$metodo)
  vk_exigir(length(seleccion) == 1L, "La referencia municipal e insular Pearson debe ser unica.")
  global <- globales[seleccion, , drop = FALSE]
  numeros <- stats::setNames(vapply(requeridas[-c(1, 2)], function(v) vk_numeros(global[[v]], v),
                             numeric(1L)), requeridas[-c(1, 2)])
  vk_exigir(numeros[["n"]] == config$n_esperado && numeros[["p"]] == config$p_esperado,
            "La referencia no corresponde a 1.102 unidades y ocho candidatas.")
  vk_exigir(numeros[["gl"]] == 28, "La referencia Bartlett no tiene 28 grados de libertad.")

  tabla_msa <- vk_leer_csv(config$referencia_msa)
  vk_exigir(all(c("indicador", "MSA") %in% names(tabla_msa)), "Faltan columnas en la referencia MSA.")
  vk_exigir(nrow(tabla_msa) == config$p_esperado && !anyDuplicated(tabla_msa$indicador) &&
              setequal(tabla_msa$indicador, config$variables), "La referencia MSA no contiene las ocho variables unicas.")
  orden <- match(config$variables, tabla_msa$indicador)
  msa <- stats::setNames(vk_numeros(tabla_msa$MSA[orden], "MSA de referencia"), config$variables)
  list(global = numeros, msa = msa)
}

#' Crear un control escalar con error absoluto y tolerancia explicita.
vk_control <- function(nombre, calculado, referencia, tolerancia) {
  error <- abs(calculado - referencia)
  data.frame(control = nombre, calculado = calculado, referencia = referencia,
             error_absoluto = error, tolerancia = tolerancia,
             cumple = is.finite(error) && error <= tolerancia,
             row.names = NULL, stringsAsFactors = FALSE)
}

#' Conciliar cinco controles globales y los ocho MSA individuales.
vk_comparar <- function(resultado, referencias, config) {
  tol <- config$tolerancia
  diferencias_msa <- abs(resultado$MSA - referencias$msa)
  global <- do.call(rbind, list(
    vk_control("KMO", resultado$KMO, referencias$global[["KMO"]], tol[["KMO"]]),
    vk_control("MSA_max_abs", max(diferencias_msa), 0, tol[["MSA"]]),
    vk_control("chi_cuadrado", resultado$chi_cuadrado, referencias$global[["chi_cuadrado"]], tol[["chi_cuadrado"]]),
    vk_control("ln_p_nominal", resultado$ln_p_nominal, referencias$global[["ln_p_nominal"]], tol[["ln_p_nominal"]]),
    vk_control("log_determinante", resultado$log_determinante, referencias$global[["log_determinante"]], tol[["log_determinante"]])
  ))
  individual <- data.frame(indicador = config$variables, etiqueta = config$etiquetas,
    calculado = unname(resultado$MSA), referencia = unname(referencias$msa),
    error_absoluto = unname(diferencias_msa), tolerancia = tol[["MSA"]],
    cumple = unname(diferencias_msa <= tol[["MSA"]]), stringsAsFactors = FALSE)
  list(global = global, msa = individual,
       aprobado = all(global$cumple) && all(individual$cumple))
}
