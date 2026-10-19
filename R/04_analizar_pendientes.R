# Punto de entrada modular para auditorías metodológicas complementarias.
# Ejecutar desde la raíz: Rscript R/04_analizar_pendientes.R
# Cada módulo genera una carpeta versionada y no sobrescribe auditorías previas.

root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
if (!file.exists(file.path(root, "R/00_config.R"))) {
  stop("Ejecute Rscript desde la raíz del repositorio.")
}

message("[1/1] Auditoría de 10V, gas/internet 8V y materiales de pared 6V")
source(file.path(root, "R/04_auditoria_estrato_paredes.R"), local = globalenv())

message("Auditoría finalizada. 6PM no se incorpora según decisión del autor.")
