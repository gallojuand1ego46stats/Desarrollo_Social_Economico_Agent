# Sensibilidad de estrato 10V y distribucion de materiales 6V.
# Lee solo CSV intermedios y escribe en una carpeta de ejecucion nueva.

required_packages <- c("readr", "dplyr", "tidyr", "stringr", "tibble", "janitor")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages)) stop("Faltan paquetes: ", paste(missing_packages, collapse = ", "))

source("R/funciones/solucion_pendientes.R", local = FALSE)
root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
if (!file.exists(file.path(root, "R/00_config.R"))) stop("Ejecute el script desde la raiz del repositorio.")
source(file.path(root, "R/00_config.R"), local = FALSE)

input_files <- c("datos/intermedio/viviendas_10V.csv", "datos/intermedio/viviendas_6V.csv", "datos/intermedio/viviendas_8V.csv")
if (any(!file.exists(file.path(root, input_files)))) stop("Falta un CSV intermedio requerido.")
out_root <- file.path(root, "resultados/solucion_pendientes")
dir.create(out_root, recursive = TRUE, showWarnings = FALSE)
base_name <- paste0("estructura_10V_6V_", format(Sys.Date(), "%Y%m%d"))
out_dir <- file.path(out_root, paste0(base_name, "_v01"))
i <- 1L
while (dir.exists(out_dir)) {
  i <- i + 1L
  out_dir <- file.path(out_root, paste0(base_name, "_v", sprintf("%02d", i)))
}
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

hash_before <- unname(tools::md5sum(file.path(root, input_files)))
message("[1/4] Sensibilidad 10V, preservando no tiene estrato y no sabe/no responde...")
estrato <- solucion_estrato_10v(solucion_read_csv_text(file.path(root, input_files[1])))
estrato_resumen <- dplyr::bind_rows(
  solucion_resumen_indicador(estrato, "tasa_estrato_1_2_sobre_total", "Estratos 1-2 / personas censadas"),
  solucion_resumen_indicador(estrato, "tasa_vulnerabilidad_operativa_con_no_estrato_sobre_total", "Estratos 1-2 + no tiene estrato / personas censadas"),
  solucion_resumen_indicador(estrato, "tasa_vulnerabilidad_operativa_base_valida", "Estratos 1-2 + no tiene estrato / personas con respuesta valida"),
  solucion_resumen_indicador(estrato, "tasa_vulnerabilidad_entre_clasificados", "Estratos 1-2 + no tiene estrato / personas con estrato o sin estrato"),
  solucion_resumen_indicador(estrato, "tasa_vulnerabilidad_cota_superior_nr", "Cota superior: desconocidos cuentan como vulnerables"),
  solucion_resumen_indicador(estrato, "tasa_estrato_1_2_entre_estratos_asignados", "Estratos 1-2 / personas en estratos 1-6"),
  solucion_resumen_indicador(estrato, "tasa_sin_servicio_energia", "Sin servicio de energía / personas censadas"),
  solucion_resumen_indicador(estrato, "tasa_no_tiene_estrato", "No tiene estrato / personas censadas"),
  solucion_resumen_indicador(estrato, "tasa_no_sabe_no_responde", "No sabe/no responde / personas censadas")
)
estrato_control <- tibble::tibble(
  n_unidades = nrow(estrato),
  n_duplicados_codigo = sum(duplicated(estrato$codigo_municipio)),
  n_violaciones_total_vs_suma_BV_CD = sum(!estrato$valida_suma_categorias, na.rm = TRUE),
  n_delta_abs_ge_002 = sum(estrato$delta_abs_base_total_vs_valida >= ivs_config$sensibilidad[["delta_absoluta"]], na.rm = TRUE),
  n_delta_clasificados_ge_002 = sum(estrato$delta_abs_total_vs_clasificados >= ivs_config$sensibilidad[["delta_absoluta"]], na.rm = TRUE),
  n_delta_rel_ge_10pct = sum(estrato$diferencia_relativa_total_vs_valida >= ivs_config$sensibilidad[["delta_relativa"]], na.rm = TRUE),
  max_delta_absoluta = max(estrato$delta_abs_base_total_vs_valida, na.rm = TRUE),
  max_delta_total_vs_clasificados = max(estrato$delta_abs_total_vs_clasificados, na.rm = TRUE),
  spearman_base_total_vs_valida = stats::cor(
    estrato$tasa_vulnerabilidad_operativa_con_no_estrato_sobre_total,
    estrato$tasa_vulnerabilidad_operativa_base_valida,
    method = "spearman", use = "complete.obs"
  ),
  spearman_total_vs_clasificados = stats::cor(
    estrato$tasa_vulnerabilidad_operativa_con_no_estrato_sobre_total,
    estrato$tasa_vulnerabilidad_entre_clasificados,
    method = "spearman", use = "complete.obs"
  ),
  nr_ponderada = sum(estrato$no_sabe_no_responde, na.rm = TRUE) /
    sum(estrato$personas_hogares_particulares, na.rm = TRUE)
)

message("[2/4] Materiales de pared 6V por categoria; no se impone una agrupacion...")
v6 <- solucion_read_csv_text(file.path(root, input_files[2]))
paredes <- solucion_materiales_6v(v6)
paredes_resumen <- paredes |>
  dplyr::group_by(material) |>
  dplyr::summarise(
    n_municipios = sum(!is.na(proporcion_viviendas)),
    media_proporcion = mean(proporcion_viviendas, na.rm = TRUE),
    mediana_proporcion = stats::median(proporcion_viviendas, na.rm = TRUE),
    varianza_proporcion = stats::var(proporcion_viviendas, na.rm = TRUE),
    n_municipios_cero = sum(conteo == 0, na.rm = TRUE),
    .groups = "drop"
  )
material_cols <- setdiff(grep("^total_", names(v6), value = TRUE), "total_total")
paredes_control <- v6 |>
  dplyr::filter(tipo_vivienda == "Total") |>
  dplyr::mutate(dplyr::across(dplyr::all_of(c("total_total", material_cols)), solucion_parse_num)) |>
  dplyr::mutate(
    suma_materiales = rowSums(dplyr::across(dplyr::all_of(material_cols)), na.rm = TRUE),
    diferencia_abs = abs(total_total - suma_materiales)
  ) |>
  dplyr::summarise(
    n_unidades = dplyr::n(),
    n_violaciones = sum(is.na(diferencia_abs) | diferencia_abs != 0),
    diferencia_absoluta_maxima = max(diferencia_abs, na.rm = TRUE)
  )

message("[3/4] Sensibilidad por no respuesta de gas e internet en 8V...")
v8 <- solucion_read_csv_text(file.path(root, input_files[3])) |>
  dplyr::filter(area == "Total") |>
  dplyr::mutate(dplyr::across(c(gas_total, gas_si, gas_no, gas_sin_informacion,
    internet_total, internet_si, internet_no, internet_sin_informacion), solucion_parse_num)) |>
  dplyr::mutate(
    gas_tasa_si_total = solucion_tasa(gas_si, gas_total),
    gas_tasa_si_base_valida = solucion_tasa(gas_si, gas_total - gas_sin_informacion),
    gas_delta_abs = abs(gas_tasa_si_total - gas_tasa_si_base_valida),
    gas_suma_valida = gas_si + gas_no + gas_sin_informacion == gas_total,
    internet_tasa_si_total = solucion_tasa(internet_si, internet_total),
    internet_tasa_si_base_valida = solucion_tasa(internet_si, internet_total - internet_sin_informacion),
    internet_delta_abs = abs(internet_tasa_si_total - internet_tasa_si_base_valida),
    internet_suma_valida = internet_si + internet_no + internet_sin_informacion == internet_total
  )
servicios_8v_resumen <- dplyr::bind_rows(
  solucion_resumen_indicador(v8, "gas_tasa_si_total", "Gas: Sí / total; NR permanece en denominador"),
  solucion_resumen_indicador(v8, "gas_tasa_si_base_valida", "Gas: Sí / (total - sin información)"),
  solucion_resumen_indicador(v8, "internet_tasa_si_total", "Internet: Sí / total; NR permanece en denominador"),
  solucion_resumen_indicador(v8, "internet_tasa_si_base_valida", "Internet: Sí / (total - sin información)")
)
servicios_8v_control <- tibble::tibble(
  n_municipios = nrow(v8),
  n_violaciones_suma_gas = sum(!v8$gas_suma_valida, na.rm = TRUE),
  n_violaciones_suma_internet = sum(!v8$internet_suma_valida, na.rm = TRUE),
  n_delta_gas_ge_002 = sum(v8$gas_delta_abs >= 0.02, na.rm = TRUE),
  n_delta_internet_ge_002 = sum(v8$internet_delta_abs >= 0.02, na.rm = TRUE),
  max_delta_gas = max(v8$gas_delta_abs, na.rm = TRUE),
  max_delta_internet = max(v8$internet_delta_abs, na.rm = TRUE),
  rho_gas = stats::cor(v8$gas_tasa_si_total, v8$gas_tasa_si_base_valida, method = "spearman", use = "complete.obs"),
  rho_internet = stats::cor(v8$internet_tasa_si_total, v8$internet_tasa_si_base_valida, method = "spearman", use = "complete.obs"),
  nr_gas_ponderada = sum(v8$gas_sin_informacion, na.rm = TRUE) / sum(v8$gas_total, na.rm = TRUE),
  nr_internet_ponderada = sum(v8$internet_sin_informacion, na.rm = TRUE) / sum(v8$internet_total, na.rm = TRUE)
)

hash_after <- unname(tools::md5sum(file.path(root, input_files)))
integridad <- tibble::tibble(archivo = input_files, md5 = hash_before, sin_cambio = hash_before == hash_after)
readr::write_csv(estrato, file.path(out_dir, "sensibilidad_10V_estrato_por_municipio.csv"))
readr::write_csv(estrato_resumen, file.path(out_dir, "sensibilidad_10V_estrato_resumen.csv"))
readr::write_csv(estrato_control, file.path(out_dir, "sensibilidad_10V_estrato_controles.csv"))
readr::write_csv(paredes, file.path(out_dir, "materiales_pared_6V_por_municipio.csv"))
readr::write_csv(paredes_resumen, file.path(out_dir, "materiales_pared_6V_resumen.csv"))
readr::write_csv(paredes_control, file.path(out_dir, "control_suma_materiales_6V.csv"))
readr::write_csv(v8, file.path(out_dir, "sensibilidad_8V_gas_internet_por_municipio.csv"))
readr::write_csv(servicios_8v_resumen, file.path(out_dir, "sensibilidad_8V_gas_internet_resumen.csv"))
readr::write_csv(servicios_8v_control, file.path(out_dir, "sensibilidad_8V_gas_internet_controles.csv"))
readr::write_csv(integridad, file.path(out_dir, "integridad_insumos.csv"))
readr::write_csv(tibble::tibble(estado = "COMPLETO", fecha = Sys.time()), file.path(out_dir, "estado_ejecucion.csv"))

message("[4/4] Finalizado")
cat("Unidades evaluadas:", estrato_control$n_unidades, "\n")
cat("Violaciones BU = suma BV:CD:", estrato_control$n_violaciones_total_vs_suma_BV_CD, "\n")
cat("Duplicados municipales 10V:", estrato_control$n_duplicados_codigo, "\n")
cat("Violaciones suma materiales 6V:", paredes_control$n_violaciones, "\n")
cat("Violaciones suma categorías gas/internet:", servicios_8v_control$n_violaciones_suma_gas + servicios_8v_control$n_violaciones_suma_internet, "\n")
cat("Municipios con diferencia gas >= 0.02:", servicios_8v_control$n_delta_gas_ge_002, "\n")
cat("Municipios con diferencia internet >= 0.02:", servicios_8v_control$n_delta_internet_ge_002, "\n")
cat("Cambios >= 0.02:", estrato_control$n_delta_abs_ge_002, "\n")
cat("Cambio maximo:", format(estrato_control$max_delta_absoluta, digits = 6), "\n")
cat("Cambio maximo vs universo clasificado:", format(estrato_control$max_delta_total_vs_clasificados, digits = 6), "\n")
cat("Spearman total vs valida:", format(estrato_control$spearman_base_total_vs_valida, digits = 6), "\n")
cat("Hashes insumos estables:", all(integridad$sin_cambio), "\n")
cat("Salida:", normalizePath(out_dir, winslash = "/"), "\n")
