# ============================================================
# 00_ingesta_fuentes.R
# Ingesta reproducible de fuentes oficiales
# Proyecto: Contratacion publica y vulnerabilidad socioeconomica
# ============================================================

# Instalar una sola vez si hace falta:
# install.packages(c("tidyverse", "httr2", "jsonlite", "readxl", "arrow", "sf"))

library(tidyverse)
library(httr2)
library(jsonlite)
library(readxl)

# ------------------------------------------------------------
# Rutas
# ------------------------------------------------------------
dir.create("data/raw/divipola", recursive = TRUE, showWarnings = FALSE)
dir.create("data/raw/dane_ipm", recursive = TRUE, showWarnings = FALSE)
dir.create("data/raw/secop_ii", recursive = TRUE, showWarnings = FALSE)

# ------------------------------------------------------------
# 1. DIVIPOLA - fuente oficial Datos Abiertos Colombia
# ------------------------------------------------------------
url_divipola <- "https://www.datos.gov.co/resource/gdxc-w37w.json?$limit=5000"

divipola <- request(url_divipola) |>
  req_perform() |>
  resp_body_json(simplifyVector = TRUE) |>
  as_tibble()

write_csv(divipola, "data/raw/divipola/divipola_2024_12_30.csv")

cat("DIVIPOLA descargada:", nrow(divipola), "filas\n")

# ------------------------------------------------------------
# 2. DANE - IPM municipal censal 2018
# ------------------------------------------------------------
# El anexo municipal contiene los resultados municipales del IPM.
url_ipm_xlsx <- paste0(
  "https://www.dane.gov.co/files/investigaciones/condiciones_vida/",
  "pobreza/2018/informacion-censal/anexo-censal-pobreza-municipal-2018.xlsx"
)

ipm_path <- "data/raw/dane_ipm/anexo-censal-pobreza-municipal-2018.xlsx"

download.file(url_ipm_xlsx, ipm_path, mode = "wb", quiet = FALSE)

# Inventario inicial de hojas, sin asumir todavía cuál será la hoja final.
hojas_ipm <- excel_sheets(ipm_path)
write_lines(hojas_ipm, "data/raw/dane_ipm/hojas_ipm.txt")

cat("IPM descargado. Hojas disponibles:\n")
print(hojas_ipm)

# ------------------------------------------------------------
# 3. SECOP II - muestra inicial para revisar variables
# ------------------------------------------------------------
# IMPORTANTE: la base completa es muy grande. Primero se descarga
# una muestra controlada para inventariar columnas y tipos.
url_secop_muestra <- paste0(
  "https://www.datos.gov.co/resource/jbjy-vk9h.json?$limit=5000"
)

secop_muestra <- request(url_secop_muestra) |>
  req_perform() |>
  resp_body_json(simplifyVector = TRUE) |>
  as_tibble()

write_csv(secop_muestra, "data/raw/secop_ii/secop_ii_muestra_5000.csv")

# Diccionario preliminar de nombres y tipos observados.
diccionario_secop <- tibble(
  variable = names(secop_muestra),
  clase_r = map_chr(secop_muestra, ~ class(.x)[1]),
  n_no_na = map_int(secop_muestra, ~ sum(!is.na(.x))),
  porcentaje_no_na = map_dbl(secop_muestra, ~ mean(!is.na(.x)) * 100)
)

write_csv(diccionario_secop, "docs/diccionario/diccionario_secop_muestra.csv")

# ------------------------------------------------------------
# 4. Consulta temporal SECOP II: ejemplo para no bajar toda la base
# ------------------------------------------------------------
# Ajustar las fechas despues de verificar cobertura y variables.
# Esta consulta sirve como plantilla para descarga por periodos.
#
# Ejemplo:
# url_secop_periodo <- paste0(
#   "https://www.datos.gov.co/resource/jbjy-vk9h.json?",
#   "$where=fecha_de_firma between '2024-01-01T00:00:00' and '",
#   "2024-12-31T23:59:59'&$limit=50000"
# )
#
# secop_2024 <- request(url_secop_periodo) |>
#   req_perform() |>
#   resp_body_json(simplifyVector = TRUE) |>
#   as_tibble()
#
# write_parquet(secop_2024, "data/raw/secop_ii/secop_ii_2024.parquet")

cat("Ingesta inicial terminada. No se descarga la base SECOP II completa en esta etapa.\n")
