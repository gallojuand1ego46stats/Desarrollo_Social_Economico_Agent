# Verificador numerico independiente de KMO, MSA y Bartlett para ocho candidatas.
#
# Uso desde la raiz del repositorio:
#   Rscript --vanilla R/auxiliares/verificar_kmo_bartlett.R
#
# Tambien puede ejecutarse desde otra carpeta: la raiz se deduce de este archivo.
# En una sesion interactiva:
#   source("R/auxiliares/verificar_kmo_bartlett.R")
#   verificar_kmo_bartlett("ruta/al/repositorio")
#
# Este archivo solo coordina la carga de modulos. No importa ni ejecuta R/07.
# Los calculos se reconstruyen desde el CSV original antes de abrir las cifras
# de referencia. La independencia es de implementacion: ambos flujos usan R y
# pueden compartir las bibliotecas numericas del mismo entorno.

verificar_kmo_bartlett <- function(raiz) {
  raiz <- normalizePath(raiz, winslash = "/", mustWork = TRUE)
  carpeta <- file.path(raiz, "R", "funciones", "verificacion_kmo")
  modulos <- c("configuracion.R", "entrada.R", "calculos.R",
               "comparacion.R", "salidas.R", "flujo.R")

  # Un entorno propio evita sobreescribir funciones del proyecto o de RStudio.
  entorno <- new.env(parent = baseenv())
  for (nombre in modulos) {
    archivo <- file.path(carpeta, nombre)
    if (!file.exists(archivo)) stop("Falta el modulo: ", archivo, call. = FALSE)
    sys.source(archivo, envir = entorno, keep.source = TRUE)
  }
  entorno$vk_ejecutar(entorno$vk_configuracion(raiz))
}

# Al usar source() se define la funcion anterior, sin generar salidas.
# Al ejecutar con Rscript se localiza el archivo de entrada y se inicia el flujo.
if (sys.nframe() == 0L) {
  argumentos <- commandArgs(trailingOnly = FALSE)
  archivo <- sub("^--file=", "", argumentos[grepl("^--file=", argumentos)])
  if (length(archivo) != 1L) stop("No se pudo localizar el archivo ejecutado.")
  archivo <- normalizePath(archivo, winslash = "/", mustWork = TRUE)
  raiz <- dirname(dirname(dirname(archivo)))
  verificar_kmo_bartlett(raiz)
}
