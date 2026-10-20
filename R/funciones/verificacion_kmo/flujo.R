# Modulo 6. Orquestacion del cotejo y manejo de fallos.
# La ejecucion calcula primero, compara despues y exporta las diferencias. Ante
# errores registra estado fallido y termina con error, sin declarar aprobacion.

#' Ejecutar el flujo completo de verificacion independiente.
#' @return Lista invisible con resultado y conciliaciones, util desde RStudio.
vk_ejecutar <- function(config) {
  opciones <- options(digits = 17)
  on.exit(options(opciones), add = TRUE)
  dir.create(config$salida, recursive = TRUE, showWarnings = FALSE)
  vk_estado(config, "en_curso", "Reconstruccion independiente iniciada.")

  tryCatch({
    protegidos <- c(config$matriz, config$referencia_global, config$referencia_msa)
    huellas <- vk_huellas(protegidos)
    entrada <- vk_leer_matriz(config)
    resultado <- vk_calcular(entrada$X, config)
    referencias <- vk_referencias(config)
    comparacion <- vk_comparar(resultado, referencias, config)
    vk_exigir(identical(unname(huellas), unname(vk_huellas(protegidos))),
              "La matriz o las referencias cambiaron durante el calculo.")
    vk_exportar(resultado, comparacion, config, huellas, protegidos)
    vk_exigir(comparacion$aprobado, "Existen diferencias superiores a las tolerancias; revise los CSV del cotejo.")
    vk_estado(config, "aprobado", "Cinco controles globales y ocho MSA dentro de tolerancia.")
    cat("Verificacion independiente en R completada.\n")
    cat("Matriz:", resultado$n, "unidades x", resultado$p, "candidatas.\n")
    cat("KMO:", format(resultado$KMO, digits = 12), "\n")
    cat("Bartlett:", format(resultado$chi_cuadrado, digits = 12), "; gl:", resultado$gl, "\n")
    cat("p nominal (texto):", resultado$p_texto, "\n")
    cat("Cotejos globales:", sum(comparacion$global$cumple), "/", nrow(comparacion$global), "\n")
    cat("Cotejos MSA:", sum(comparacion$msa$cumple), "/", nrow(comparacion$msa), "\n")
    invisible(list(resultado = resultado, comparacion = comparacion))
  }, error = function(error) {
    vk_estado(config, "fallido", conditionMessage(error))
    stop(conditionMessage(error), call. = FALSE)
  })
}
