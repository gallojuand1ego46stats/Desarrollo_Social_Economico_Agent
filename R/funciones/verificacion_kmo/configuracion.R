# Modulo 1. Contrato de datos, rutas y tolerancias del cotejo.
# Las decisiones numericas se concentran aqui para que una modificacion quede
# visible. Las tolerancias son absolutas y mantienen las de la verificacion previa.

#' Construir la configuracion del verificador.
#' @param raiz Carpeta absoluta del repositorio.
#' @return Lista con rutas, columnas esperadas, dimensiones y tolerancias.
vk_configuracion <- function(raiz) {
  variables <- c(
    "hogares_menores15", "hogares_adultos_mayores", "paredes_precarias_6V",
    "sin_energia_8V", "sin_gas_8V", "sin_internet_8V",
    "estratos_1_2_o_sin_estrato_10V", "actividad_vulnerabilidad_10mas_5PM"
  )
  salida_relativa <- "resultados/kmo_bartlett_20261020"
  list(
    raiz = raiz,
    matriz = file.path(raiz, "resultados/descriptivos_sensibilidades_20261018",
                       "matriz_ocho_municipal_e_insular_0_1.csv"),
    salida = file.path(raiz, salida_relativa),
    referencia_global = file.path(raiz, salida_relativa, "diagnosticos_por_ambito.csv"),
    referencia_msa = file.path(raiz, salida_relativa, "msa_por_indicador.csv"),
    escenario = "municipal_e_insular",
    metodo = "pearson",
    metadatos = c("codigo_departamento", "codigo_municipio",
                  "nombre_municipio", "nombre_departamento"),
    variables = variables,
    etiquetas = c("1HM", "2HM", "6V", "Energia", "Gas", "Internet", "10V", "5PM"),
    n_esperado = 1102L,
    p_esperado = 8L,
    tolerancia = c(KMO = 1e-12, MSA = 1e-12, chi_cuadrado = 1e-8,
                   ln_p_nominal = 1e-8, log_determinante = 1e-12,
                   estructura = 1e-12, residuo_inversa = 1e-10),
    modulos = file.path("R/funciones/verificacion_kmo",
                       c("configuracion.R", "entrada.R", "calculos.R",
                         "comparacion.R", "salidas.R", "flujo.R"))
  )
}

#' Exigir una condicion escalar y mostrar un error legible.
#' NA o un vector no se aceptan como aprobacion accidental de un control.
vk_exigir <- function(condicion, mensaje) {
  if (!isTRUE(condicion)) stop(mensaje, call. = FALSE)
  invisible(TRUE)
}
