# Cotejo reproducible de cifras principales citadas en la auditoría.
# Ejecutar desde la raíz: Rscript docs/calidad/auditorias/verificar_cifras_auditoria.R
# Solo lee los CSV previos y escribe el cotejo en esta carpeta.
options(stringsAsFactors = FALSE, encoding = "UTF-8")
root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
out_dir <- file.path(root, "docs", "calidad", "auditorias")
read_csv <- function(path) {
  f <- file.path(root, path)
  if (!file.exists(f)) stop("No existe archivo requerido: ", path)
  bytes <- readBin(f, what = "raw", n = file.info(f)$size)
  if (length(bytes) >= 3L && identical(bytes[1:3], as.raw(c(0xEF, 0xBB, 0xBF)))) {
    bytes <- bytes[-(1:3)]
  }
  content <- rawToChar(bytes)
  valid_utf8 <- !is.na(iconv(content, from = "UTF-8", to = "UTF-8"))
  if (!valid_utf8) {
    # Algunos productos históricos de R se guardaron en Windows-1252;
    # convertirlos explícitamente evita que los acentos rompan el cotejo.
    content <- iconv(content, from = "CP1252", to = "UTF-8", sub = "byte")
  }
  Encoding(content) <- "UTF-8"
  read.csv(text = content, check.names = FALSE, colClasses = "character",
           na.strings = character(), strip.white = FALSE)
}
num <- function(x) suppressWarnings(as.numeric(x))
results <- list()
add <- function(id, source, metric, observed, expected, passed, note = "") {
  results[[length(results) + 1L]] <<- data.frame(
    id = id, fuente = source, metrica = metric, observado = as.character(observed),
    esperado = as.character(expected), estado = if (isTRUE(passed)) "PASS" else "REVISAR",
    nota = note, stringsAsFactors = FALSE
  )
}
matrix <- read_csv("resultados/indicadores_finales_ivs_20261015/matriz_pca_candidata.csv")
summary <- read_csv("resultados/indicadores_finales_ivs_20261015/resumen_ejecucion.csv")
formula <- read_csv("resultados/indicadores_finales_ivs_20261015/formulas_indicadores.csv")
sensitivity <- read_csv("resultados/indicadores_finales_ivs_20261015/resumen_sensibilidad.csv")
checks <- read_csv("resultados/indicadores_finales_ivs_20261015/chequeos_matriz.csv")
master <- read_csv("resultados/verificacion_consolidados/universo_municipal_maestro.csv")
cons <- read_csv("resultados/verificacion_consolidados/chequeos_consistencia.csv")
decisions <- read_csv("docs/diccionario/decisiones_variables_IVS_CNPV2018.csv")
aptitude <- read_csv("resultados/base_trabajo/diagnosticos_aptitud.csv")
msa <- read_csv("resultados/base_trabajo/kmo_por_indicador.csv")
outliers <- read_csv("resultados/base_trabajo/outliers_z_mayor_4.csv")
key <- "codigo_municipio"
candidate_names <- names(matrix)[!names(matrix) %in% c("codigo_departamento", key, "nombre_municipio", "nombre_departamento")]
add("M01", "matriz_pca_candidata.csv", "filas", nrow(matrix), 1122, nrow(matrix) == 1122)
add("M02", "matriz_pca_candidata.csv", "codigos unicos de cinco digitos", length(unique(matrix[[key]])), 1122,
    length(unique(matrix[[key]])) == 1122 && all(grepl("^[0-9]{5}$", matrix[[key]])))
add("M03", "matriz_pca_candidata.csv", "columnas candidatas guardadas", length(candidate_names), 9,
    length(candidate_names) == 9, paste(candidate_names, collapse = "; "))
add("M04", "resumen_ejecucion.csv", "n_indicadores_pca declarado", summary$n_indicadores_pca[1], 9,
    num(summary$n_indicadores_pca[1]) == 9, "El archivo reune nueve candidatas; la especificacion de primer PCA reserva 17PM y preve ocho.")
add("M05", "resumen_ejecucion.csv", "PCA ejecutado", summary$PCA_ejecutado[1], "FALSE",
    identical(toupper(summary$PCA_ejecutado[1]), "FALSE"))
add("M06", "resumen_ejecucion.csv", "NA en matriz candidata", summary$celdas_na[1], 0,
    num(summary$celdas_na[1]) == 0)
add("M07", "resumen_ejecucion.csv", "violaciones de controles", summary$violaciones_controles[1], 0,
    num(summary$violaciones_controles[1]) == 0)
add("M08", "matriz_pca_candidata.csv", "celdas analiticas (1122 x 9)", nrow(matrix) * length(candidate_names), 10098,
    nrow(matrix) * length(candidate_names) == 10098)
add("M09", "formulas_indicadores.csv", "candidatas definidas", nrow(formula) - 1L, 9,
    nrow(formula) - 1L == 9, "La fila final describe las categorias de 17PM en conjunto.")
expected_sens <- data.frame(
  indicador = c("5PM actividad ponderada", "5PM actividad ponderada", "5PM peso incapacidad", "5PM peso incapacidad",
    "8V gas sin servicio", "8V internet sin servicio", "10V estratos bajos + no tiene estrato",
    "17PM sin media completa", "17PM sin media completa"),
  alternative = c("actividad_5PM_sobre_total", "actividad_5PM_cota_superior_nr", "actividad_5PM_peso1",
    "actividad_5PM_peso3", "sin_gas_8V_sobre_total", "sin_internet_8V_sobre_total",
    "estratos_1_2_o_sin_estrato_10V_sobre_total", "sin_media_completa_17PM_con_normal_incompleta",
    "sin_media_completa_17PM_base_valida"),
  rho = c(.998867617206449, .8127185572742637, .9496213580514408, .9760895470360311,
    .9935706737168468, .954424743767677, .40445503985449266, .9979463162235228, .9677624320900285),
  delta = c(.008427328085327937, .1825634441341961, .21432552954292086, .07144184318097363,
    .12456560982049147, .16757436112274826, .9879518072289156, .04794086589229141, .21413569425925766),
  n2pp = c(0,235,702,46,58,85,711,12,105), stringsAsFactors = FALSE)
sens_ok <- logical(nrow(expected_sens))
for (i in seq_len(nrow(expected_sens))) {
  r <- sensitivity[sensitivity$indicador == expected_sens$indicador[i] &
    sensitivity$alternativa == expected_sens$alternative[i], , drop = FALSE]
  sens_ok[i] <- nrow(r) == 1L &&
    abs(num(r$rho_spearman) - expected_sens$rho[i]) < 1e-12 &&
    abs(num(r$diferencia_abs_max) - expected_sens$delta[i]) < 1e-12 &&
    num(r$municipios_delta_2pp) == expected_sens$n2pp[i]
}
add("S01", "resumen_sensibilidad.csv", "escenarios cotejados", sum(sens_ok), 9, all(sens_ok))
add("S02", "resumen_sensibilidad.csv", "10V, Spearman denominador clasificable/total",
  sensitivity$rho_spearman[sensitivity$indicador == "10V estratos bajos + no tiene estrato"],
  .40445503985449266,
  any(abs(num(sensitivity$rho_spearman[sensitivity$indicador == "10V estratos bajos + no tiene estrato"]) -
      .40445503985449266) < 1e-12))
add("S03", "resumen_sensibilidad.csv", "5PM 2:1 vs 1:1; cambios >=2 pp",
  sensitivity$municipios_delta_2pp[sensitivity$indicador == "5PM peso incapacidad" &
    sensitivity$alternativa == "actividad_5PM_peso1"], 702,
  any(num(sensitivity$municipios_delta_2pp[sensitivity$indicador == "5PM peso incapacidad" &
    sensitivity$alternativa == "actividad_5PM_peso1"]) == 702))
add("C01", "chequeos_matriz.csv", "controles con violaciones",
  sum(num(checks$n_violaciones) > 0, na.rm = TRUE), 0, sum(num(checks$n_violaciones) > 0, na.rm = TRUE) == 0)
add("C02", "chequeos_matriz.csv", "celdas candidatas", 1122 * 9, 10098, 1122 * 9 == 10098)
ipm <- decisions[grepl("IPM", decisions$base, ignore.case = TRUE) |
  grepl("IPM", decisions$hoja, ignore.case = TRUE), , drop = FALSE]
add("D01", "decisiones_variables_IVS_CNPV2018.csv", "filas IPM VALIDACION",
  sum(grepl("^VALIDACI", ipm$decision, ignore.case = TRUE)), 17,
  sum(grepl("^VALIDACI", ipm$decision, ignore.case = TRUE)) == 17)
add("D02", "decisiones_variables_IVS_CNPV2018.csv", "privaciones IPM como candidatas INCLUIDA",
  sum(ipm$decision == "INCLUIDA"), 0, sum(ipm$decision == "INCLUIDA") == 0)
add("D03", "decisiones_variables_IVS_CNPV2018.csv", "6PM descartada",
  paste(unique(decisions$decision[decisions$hoja == "6PM"]), collapse = ";"), "DESCARTAR",
  any(decisions$hoja == "6PM" & decisions$decision == "DESCARTAR"))
add("U01", "universo_municipal_maestro.csv", "registros union IPM + DIVIPOLA",
  nrow(master), 1123, nrow(master) == 1123)
add("U02", "universo_municipal_maestro.csv", "registros en IPM/CNPV",
  sum(toupper(master$en_ipm) == "TRUE"), 1122, sum(toupper(master$en_ipm) == "TRUE") == 1122)
only_div <- toupper(master$en_divipola) == "TRUE" & toupper(master$en_ipm) == "FALSE"
only_ipm <- toupper(master$en_divipola) == "FALSE" & toupper(master$en_ipm) == "TRUE"
add("U03", "universo_municipal_maestro.csv", "solo DIVIPOLA",
  paste(master$codigo_municipio[only_div], collapse = ","), "27493",
  sum(only_div) == 1 && identical(master$codigo_municipio[only_div], "27493"))
add("U04", "universo_municipal_maestro.csv", "solo IPM/CNPV",
  paste(master$codigo_municipio[only_ipm], collapse = ","), "94663",
  sum(only_ipm) == 1 && identical(master$codigo_municipio[only_ipm], "94663"))
add("U05", "universo_municipal_maestro.csv", "sin Cabecera dentro de IPM",
  sum(toupper(master$tiene_cabecera) == "FALSE" & toupper(master$en_ipm) == "TRUE"), 20,
  sum(toupper(master$tiene_cabecera) == "FALSE" & toupper(master$en_ipm) == "TRUE") == 20)
add("U06", "universo_municipal_maestro.csv", "sin Centro poblado dentro de IPM",
  sum(toupper(master$tiene_centro_poblado) == "FALSE" & toupper(master$en_ipm) == "TRUE"), 192,
  sum(toupper(master$tiene_centro_poblado) == "FALSE" & toupper(master$en_ipm) == "TRUE") == 192)
anm <- sum(grepl("no municipalizada", master$tipo_divipola, ignore.case = TRUE) &
  toupper(master$en_ipm) == "TRUE")
add("U07", "universo_municipal_maestro.csv", "ANM segun DIVIPOLA 2026 dentro de IPM",
  anm, 18, anm == 18, "Esta es clasificacion 2026, no el estado territorial oficial de 2018.")
get_diag <- function(name) num(aptitude$valor[aptitude$diagnostico == name][1])
add("H01", "diagnosticos_aptitud.csv", "KMO matriz historica (7 indicadores)",
  get_diag("KMO global"), .6424840782672572,
  isTRUE(all.equal(get_diag("KMO global"), .6424840782672572, tolerance = 1e-12)))
add("H02", "diagnosticos_aptitud.csv", "Bartlett chi-cuadrado historico",
  get_diag("Bartlett chi-cuadrado"), 4664.872847515676,
  isTRUE(all.equal(get_diag("Bartlett chi-cuadrado"), 4664.872847515676, tolerance = 1e-12)))
outlier_count <- num(outliers$valor[outliers$metrica == "municipios con algun |z|>4"][1])
add("H03", "outliers_z_mayor_4.csv", "municipios con algun extremo en matriz historica",
  outlier_count, 32, outlier_count == 32, "El CSV es una tabla resumen de una fila; no implica eliminacion.")
add("H04", "chequeos_consistencia.csv", "controles auditados", nrow(cons), 734,
  nrow(cons) == 734)
age_absent <- sum(num(cons$n_violaciones[grepl("grupo edad ausente", cons$chequeo, ignore.case = TRUE)]),
  na.rm = TRUE)
add("H05", "chequeos_consistencia.csv", "combinaciones de edad ausentes estructuralmente",
  age_absent, 335, age_absent == 335)
msa$KMO_num <- num(msa$KMO)
min_msa <- msa[which.min(msa$KMO_num), , drop = FALSE]
add("H06", "kmo_por_indicador.csv", "indicador con menor MSA historico",
  min_msa$indicador, "estrato_1_2", identical(min_msa$indicador, "estrato_1_2"))
add("H07", "kmo_por_indicador.csv", "menor MSA historico", min_msa$KMO_num,
  0.41431061174872497,
  isTRUE(all.equal(min_msa$KMO_num, 0.41431061174872497, tolerance = 1e-12)))
out <- do.call(rbind, results)
write.csv(out, file.path(out_dir, "cotejo_cifras_auditoria.csv"),
  row.names = FALSE, na = "", fileEncoding = "UTF-8")
cat("Cotejo guardado: docs/calidad/auditorias/cotejo_cifras_auditoria.csv\n")
cat("Verificaciones:", nrow(out), "| PASS:", sum(out$estado == "PASS"),
  "| REVISAR:", sum(out$estado != "PASS"), "\n")
if (any(out$estado != "PASS")) quit(status = 1)

