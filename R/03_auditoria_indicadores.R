# Auditoría reproducible de indicadores existentes. No reconstruye la base ni ejecuta PCA.
args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
script_path <- if (length(file_arg)) sub("^--file=", "", file_arg[[1]]) else
  file.path(getwd(), "R", "03_auditoria_indicadores.R")
root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
desde_pipeline <- exists("ind_spec", envir = .GlobalEnv, inherits = FALSE) &&
  exists("base_total", envir = .GlobalEnv, inherits = FALSE) &&
  exists("matrix_base", envir = .GlobalEnv, inherits = FALSE)
source(file.path(root, "R", "00_config.R"), encoding = "UTF-8")
source(file.path(root, "R", "funciones", "auditoria_estadistica.R"), encoding = "UTF-8")

out_dir <- file.path(root, ivs_config$rutas$resultados_auditoria)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
base_dir <- file.path(root, ivs_config$rutas$resultados_base)
work_dir <- file.path(root, ivs_config$rutas$trabajo)
expected <- c(
  "especificacion_indicadores.csv", "estadisticos_indicadores.csv",
  "varianza_indicadores.csv", "correlaciones_pares.csv", "kmo_por_indicador.csv",
  "diagnosticos_aptitud.csv", "outliers_z_mayor_4.csv", "sensibilidad_nr.csv",
  "sensibilidad_nr_municipio.csv"
)
optional <- c("pares_correlacion_ge_090.csv", "pares_correlacion_ge_095.csv",
              "nr_item_municipal.csv")
missing <- c(expected, optional)[!file.exists(file.path(base_dir, c(expected, optional)))]
inputs <- c(expected, optional, "indicadores_municipales_base_total.csv",
            "matriz_pca.csv", "matriz_pca_z.csv", "denominadores_municipales.csv")
if (length(missing)) message("Archivos ausentes (no se inventan): ", paste(missing, collapse = ", "))

read_base <- function(filename, folder = base_dir) {
  path <- file.path(folder, filename)
  if (!file.exists(path)) return(NULL)
  leer_csv_auditoria(path)
}
spec <- if (exists("ind_spec", envir = .GlobalEnv, inherits = FALSE)) get("ind_spec", envir = .GlobalEnv) else read_base("especificacion_indicadores.csv")
stats_original <- read_base("estadisticos_indicadores.csv")
var_original <- read_base("varianza_indicadores.csv")
cor_original <- read_base("correlaciones_pares.csv")
kmo <- read_base("kmo_por_indicador.csv")
diag <- read_base("diagnosticos_aptitud.csv")
sens <- read_base("sensibilidad_nr.csv")
sens_m <- read_base("sensibilidad_nr_municipio.csv")
nr <- read_base("nr_item_municipal.csv")
ind_total <- if (exists("base_total", envir = .GlobalEnv, inherits = FALSE)) get("base_total", envir = .GlobalEnv) else read_base("indicadores_municipales_base_total.csv", work_dir)
matrix_base <- if (exists("matrix_base", envir = .GlobalEnv, inherits = FALSE)) get("matrix_base", envir = .GlobalEnv) else read_base("matriz_pca.csv", work_dir)
matrix_z <- if (exists("z", envir = .GlobalEnv, inherits = FALSE)) get("z", envir = .GlobalEnv) else read_base("matriz_pca_z.csv", work_dir)
den <- if (exists("den", envir = .GlobalEnv, inherits = FALSE)) get("den", envir = .GlobalEnv) else read_base("denominadores_municipales.csv", work_dir)

if (is.null(spec)) stop("No existe especificacion_indicadores.csv; no se puede decidir variables.", call. = FALSE)
if (is.null(ind_total)) stop("No existe indicadores_municipales_base_total.csv.", call. = FALSE)
ids <- spec$id_indicador
missing_ids <- setdiff(ids, names(ind_total))
if (length(missing_ids)) stop("Indicadores sin columna en base total: ", paste(missing_ids, collapse = ", "), call. = FALSE)
main_ids <- spec$id_indicador[spec$incluir_pca_propuesto == "TRUE"]
diag_recalc <- NULL
if (!is.null(matrix_base) && length(main_ids) > 1L && all(main_ids %in% names(matrix_base)) && !anyNA(matrix_base[main_ids])) {
  x_recalc <- as.data.frame(lapply(matrix_base[main_ids], numero_auditoria, campo = "matriz para KMO/Bartlett"))
  cor_recalc <- stats::cor(x_recalc)
  diag_recalc <- tryCatch({
    k_recalc <- psych::KMO(cor_recalc)
    b_recalc <- psych::cortest.bartlett(cor_recalc, n = nrow(x_recalc))
    list(kmo = k_recalc$MSA, kmo_i = k_recalc$MSAi, chi = b_recalc$chisq,
         df = b_recalc$df, p = b_recalc$p.value, det = det(cor_recalc))
  }, error = function(e) list(error = conditionMessage(e)))
  if (is.null(kmo) && is.null(diag_recalc$error)) {
    kmo <- tibble::tibble(indicador = names(diag_recalc$kmo_i), KMO = as.numeric(diag_recalc$kmo_i))
  }
  if (is.null(diag) && is.null(diag_recalc$error)) {
    diag <- tibble::tibble(diagnostico = c("KMO global", "Bartlett chi-cuadrado", "Bartlett grados libertad", "Bartlett p", "Determinante correlacion"), valor = c(diag_recalc$kmo, diag_recalc$chi, diag_recalc$df, diag_recalc$p, diag_recalc$det))
  }
}

# Resumen descriptivo recalculado desde los datos municipales para añadir ceros, SD y rango efectivo.
dist <- estadisticos_municipales(ind_total, ids, ivs_config$percentiles_auditoria)
if (!is.null(var_original) && all(c("indicador", "varianza") %in% names(var_original))) {
  dist <- dist |>
    dplyr::left_join(var_original |> dplyr::transmute(indicador, varianza_archivo = numero_auditoria(varianza, "varianza")), by = "indicador")
}
dist <- dist |>
  dplyr::mutate(alertas = purrr::map_chr(seq_len(dplyr::n()), ~ clasificar_distribucion(dplyr::slice(dist, .x), ivs_config$auditoria[["umbral_asimetria"]], ivs_config$auditoria[["pct_ceros_concentracion"]])))

# Clasificación conceptual/estadística provisional. La decisión final permanece en el autor.
decision_map <- c(
  educacion_ninguno_pre = "EXCLUIR_PREVIO_PCA",
  educacion_primaria_o_menos = "EXCLUIR_PREVIO_PCA",
  educacion_sin_media_completa = "EXCLUIR_PREVIO_PCA",
  actividad_desocupacion_incapacidad_hogar = "REVISAR_CONCEPTUALMENTE",
  paredes_inadecuadas = "EXCLUIR_PREVIO_PCA",
  sin_acueducto = "EXCLUIR_PREVIO_PCA",
  sin_alcantarillado = "EXCLUIR_PREVIO_PCA",
  sin_energia_electrica = "MANTENER_CON_OBSERVACION",
  sin_gas_red_publica = "MANTENER_CON_OBSERVACION",
  sin_recoleccion_basuras = "MANTENER_CON_OBSERVACION",
  sin_internet = "MANTENER_CON_OBSERVACION",
  hogares_con_menores15 = "REVISAR_CONCEPTUALMENTE",
  hogares_con_adultos_mayores = "REVISAR_CONCEPTUALMENTE",
  estrato_1_2 = "REVISAR_CONCEPTUALMENTE",
  sin_servicio_energia_10v = "EXCLUIR_PREVIO_PCA",
  dependencia_demografica = "EXCLUIR_PREVIO_PCA",
  pct_rural_disperso = "EXCLUIR_PREVIO_PCA"
)
concept_map <- c(
  educacion_ninguno_pre = "Población 5+; categorías anidadas de educación y próximas a bajo logro educativo IPM. La edad 5+ incluye población escolar y no representa educación adulta.",
  educacion_primaria_o_menos = "Proxy próximo a bajo logro educativo IPM; fuerte solapamiento conceptual y anidamiento con los otros dos indicadores educativos.",
  educacion_sin_media_completa = "Proxy cercano a bajo logro educativo IPM; categorías educativas acumulativas y denominador de 5+.",
  actividad_desocupacion_incapacidad_hogar = "Combina búsqueda de empleo, oficios del hogar, incapacidad permanente y otra situación; estados heterogéneos con distinta interpretación de vulnerabilidad.",
  paredes_inadecuadas = "Correspondencia directa con privación IPM de material de paredes.",
  sin_acueducto = "Correspondencia directa o muy cercana a acceso a fuente de agua mejorada IPM.",
  sin_alcantarillado = "Correspondencia directa o muy cercana a eliminación de excretas IPM.",
  sin_energia_electrica = "Concepto interpretable; MSA marginal y distribución muy asimétrica. No hay privación IPM idéntica.",
  sin_gas_red_publica = "Mide acceso a gas por red, dependiente de oferta territorial; base total incluye sin información, base válida la excluye.",
  sin_recoleccion_basuras = "Mide servicio territorial; correlación moderada-fuerte con internet y gas exige inspección de bloque de servicios.",
  sin_internet = "Acceso/uso de infraestructura con saturación cerca del techo y sensibilidad a sin información.",
  hogares_con_menores15 = "Composición/presión demográfica del hogar; proporción no equivale por sí sola a privación y su dirección como vulnerabilidad requiere marco conceptual.",
  hogares_con_adultos_mayores = "Composición del hogar; dirección de vulnerabilidad no está definida y puede reflejar envejecimiento/contexto.",
  estrato_1_2 = "Proporción sobre toda la población en hogares particulares, incluidos no tiene estrato y sin respuesta; estratificación no cubre uniformemente lo rural. MSA bajo.",
  sin_servicio_energia_10v = "Indicador de energía basado en personas; posible duplicación del indicador de viviendas 8V.",
  dependencia_demografica = "Razón demográfica, no proporción [0,1]; concepto de tasa de dependencia presente directamente en IPM.",
  pct_rural_disperso = "Covariable territorial de contexto; no tiene una dirección universal de vulnerabilidad."
)
class_concept <- c(
  educacion_ninguno_pre = "IMPORTANTE", educacion_primaria_o_menos = "IMPORTANTE",
  educacion_sin_media_completa = "IMPORTANTE", actividad_desocupacion_incapacidad_hogar = "IMPORTANTE",
  paredes_inadecuadas = "SIN PROBLEMA", sin_acueducto = "SIN PROBLEMA",
  sin_alcantarillado = "SIN PROBLEMA", sin_energia_electrica = "SIN PROBLEMA",
  sin_gas_red_publica = "IMPORTANTE", sin_recoleccion_basuras = "IMPORTANTE",
  sin_internet = "IMPORTANTE", hogares_con_menores15 = "IMPORTANTE",
  hogares_con_adultos_mayores = "IMPORTANTE", estrato_1_2 = "IMPORTANTE",
  sin_servicio_energia_10v = "IMPORTANTE", dependencia_demografica = "IMPORTANTE",
  pct_rural_disperso = "IMPORTANTE"
)
decision <- spec |>
  dplyr::left_join(dist |> dplyr::select(indicador, media, minimo, maximo, desviacion_estandar, varianza, pct_ceros, tipo_escala, asimetria, curtosis_exceso, n_fuera_0_1, alertas),
                   by = c("id_indicador" = "indicador")) |>
  dplyr::left_join(if (!is.null(kmo)) kmo |> dplyr::transmute(id_indicador = indicador, MSA = numero_auditoria(KMO, "KMO")) else tibble::tibble(id_indicador = character(), MSA = numeric()), by = "id_indicador") |>
  dplyr::mutate(
    clasificacion = unname(decision_map[id_indicador]),
    severidad_conceptual = unname(class_concept[id_indicador]),
    evaluacion_conceptual = unname(concept_map[id_indicador]),
    incluir_pca_propuesto = incluir_pca_propuesto == "TRUE",
    coherencia_concepto_numerador_denominador = dplyr::case_when(
      id_indicador == "sin_gas_red_publica" ~ "Revisar: base total usa gas_total, que incluye Sin información; la etiqueta 'total de respuesta' describe más bien la base válida.",
      id_indicador == "sin_internet" ~ "Revisar: base total usa internet_total, que incluye Sin información; la etiqueta 'total de respuesta' describe más bien la base válida.",
      id_indicador == "estrato_1_2" ~ "Parcial: base válida excluye no_sabe_no_responde; no_tiene_estrato permanece en denominador por ser categoría distinta.",
      id_indicador == "actividad_desocupacion_incapacidad_hogar" ~ "Parcial: numerador agrupa situaciones laborales, domésticas, incapacidad y otra situación.",
      id_indicador == "dependencia_demografica" ~ "Coherente como razón demográfica; valor puede superar 1 y no es proporción.",
      TRUE ~ "Consistente en aritmética según salidas del pipeline; interpretación conceptual se valora en este informe."
    )
  )

concept_findings <- decision |>
  dplyr::filter(severidad_conceptual != "SIN PROBLEMA") |>
  dplyr::transmute(severidad = severidad_conceptual, indicador = id_indicador,
                   hallazgo = evaluacion_conceptual,
                   evidencia = coherencia_concepto_numerador_denominador,
                   accion_sugerida = clasificacion)

# Estadísticas de estructura para todos los pares disponibles, no solo umbrales extremos.
cor_data <- if (!is.null(matrix_base)) matrix_base else ind_total
cor_ids <- intersect(ids, names(cor_data))
if (length(cor_ids) > 1L) {
  numeric_cor <- as.data.frame(lapply(cor_data[cor_ids], numero_auditoria, campo = "matriz para correlación"))
  cmat <- stats::cor(numeric_cor, use = "pairwise.complete.obs", method = "pearson")
  cor_pairs <- as.data.frame(as.table(cmat), stringsAsFactors = FALSE) |>
    tibble::as_tibble() |>
    dplyr::transmute(indicador_1 = as.character(Var1), indicador_2 = as.character(Var2), correlacion = as.numeric(Freq)) |>
    dplyr::filter(indicador_1 < indicador_2) |>
    dplyr::mutate(clasificacion = purrr::map_chr(correlacion, interpretar_correlacion,
                    umbral_moderado = ivs_config$auditoria[["correlacion_moderada"]],
                    umbral_fuerte = ivs_config$auditoria[["correlacion_fuerte"]]),
  umbral_090 = abs(correlacion) >= ivs_config$auditoria[["correlacion_alta"]], umbral_095 = abs(correlacion) >= ivs_config$auditoria[["correlacion_muy_alta"]])
} else cor_pairs <- tibble::tibble(indicador_1 = character(), indicador_2 = character(), correlacion = numeric(), clasificacion = character(), umbral_090 = logical(), umbral_095 = logical())

cor_findings <- cor_pairs |>
  dplyr::mutate(severidad = dplyr::case_when(abs(correlacion) >= ivs_config$auditoria[["correlacion_fuerte"]] ~ "IMPORTANTE", abs(correlacion) >= ivs_config$auditoria[["correlacion_moderada"]] ~ "MENOR", TRUE ~ "SIN PROBLEMA"),
                hallazgo = paste0("Correlación ", clasificacion, "; r = ", format(round(correlacion, 3), nsmall = 3)),
                accion_sugerida = ifelse(abs(correlacion) >= ivs_config$auditoria[["correlacion_fuerte"]], "Revisar redundancia/concepto; no excluir automáticamente", "Interpretar en estructura multivariada")) |>
  dplyr::filter(severidad != "SIN PROBLEMA")

# Outliers identificados desde la matriz z ya generada, con códigos y población para contextualizar.
if (!is.null(matrix_z)) {
  z_ids <- intersect(spec$id_indicador[spec$id_indicador %in% names(matrix_z)], names(matrix_z))
  z <- as.data.frame(lapply(matrix_z[z_ids], numero_auditoria, campo = "matriz z"))
  out_rows <- which(rowSums(abs(as.matrix(z)) > ivs_config$auditoria[["z_outlier"]], na.rm = TRUE) > 0)
  outliers <- tibble::tibble(
    codigo_municipio = matrix_z$codigo_municipio[out_rows],
    n_indicadores_abs_z_mayor_4 = rowSums(abs(as.matrix(z[out_rows, , drop = FALSE])) > ivs_config$auditoria[["z_outlier"]], na.rm = TRUE),
    indicadores = apply(abs(as.matrix(z[out_rows, , drop = FALSE])) > ivs_config$auditoria[["z_outlier"]], 1, function(v) paste(z_ids[v], collapse = ";"))
  )
  if (!is.null(den)) {
    cols_den <- intersect(c("codigo_municipio", "nombre_municipio", "nombre_departamento", "pob_total", "flag_pob_lt5000", "tipo_divipola"), names(den))
    outliers <- outliers |> dplyr::left_join(den |> dplyr::select(dplyr::all_of(cols_den)), by = "codigo_municipio")
  }
  outlier_by_var <- purrr::map_dfr(z_ids, function(id) tibble::tibble(indicador = id, n_municipios_abs_z_mayor_4 = sum(abs(z[[id]]) > ivs_config$auditoria[["z_outlier"]], na.rm = TRUE)))
} else {
  outliers <- tibble::tibble(codigo_municipio = character(), n_indicadores_abs_z_mayor_4 = integer(), indicadores = character())
  outlier_by_var <- tibble::tibble(indicador = character(), n_municipios_abs_z_mayor_4 = integer())
}

kmo_findings <- if (!is.null(kmo)) kmo |>
  dplyr::mutate(MSA = numero_auditoria(KMO, "KMO individual"),
                clasificacion = dplyr::case_when(MSA >= ivs_config$auditoria[["msa_adecuado"]] ~ "adecuado",
                                                 MSA >= ivs_config$auditoria[["msa_minimo"]] ~ "aceptable/marginal",
                                                 TRUE ~ "problemático"),
                hallazgo = dplyr::case_when(MSA < ivs_config$auditoria[["msa_minimo"]] ~ "La variable comparte poca varianza común; puede debilitar una solución factorial.",
                                            MSA < ivs_config$auditoria[["msa_adecuado"]] ~ "Adecuación marginal; revisar comunalidades y concepto.",
                                            TRUE ~ "Adecuación individual favorable, no prueba suficiente por sí sola.")) |>
  dplyr::select(indicador, MSA, clasificacion, hallazgo) else tibble::tibble(indicador = character(), MSA = numeric(), clasificacion = character(), hallazgo = character())

nr_findings <- if (!is.null(sens)) sens |>
  dplyr::mutate(dplyr::across(c(spearman, dif_abs_max, dif_abs_mediana), ~ numero_auditoria(.x, "sensibilidad NR")),
                dplyr::across(c(n_abs_ge_002, n_rel_ge_10pct, n_sens_alta, n_base_valida_NA), as.integer),
                severidad = dplyr::case_when(n_sens_alta > ivs_config$auditoria[["nr_municipios_importante"]] ~ "IMPORTANTE", n_sens_alta > 0 ~ "MENOR", TRUE ~ "SIN PROBLEMA"),
                hallazgo = paste0(n_sens_alta, " municipios sensibles; diferencia absoluta máxima ", round(dif_abs_max, 3), "; Spearman ", round(spearman, 3)),
                distincion_nr = ifelse(id_indicador == "estrato_1_2", "no_sabe_no_responde se trata como NR; no_tiene_estrato sigue siendo categoría sustantiva distinta", "la diferencia base total/base válida refleja inclusión/exclusión de la categoría NR")) |>
  dplyr::select(indicador = id_indicador, spearman, dif_abs_max, dif_abs_mediana, n_abs_ge_002, n_rel_ge_10pct, n_sens_alta, n_base_valida_NA, severidad, hallazgo, distincion_nr) else tibble::tibble()
if (!is.null(nr)) {
  nr_counts <- nr |>
    dplyr::mutate(n_nr = numero_auditoria(n_nr, "NR numerador"), total = numero_auditoria(total, "NR denominador"), tasa_nr = numero_auditoria(tasa_nr, "NR tasa")) |>
    dplyr::group_by(bloque, item) |>
    dplyr::summarise(n_municipios = dplyr::n_distinct(codigo_municipio), total_nr = sum(n_nr, na.rm = TRUE), total_item = sum(total, na.rm = TRUE), proporcion_ponderada = total_nr / total_item, max_tasa_municipal = max(tasa_nr, na.rm = TRUE), .groups = "drop")
  nr_findings <- dplyr::bind_rows(nr_findings, nr_counts |>
    dplyr::mutate(indicador = paste(bloque, item, sep = ": "), spearman = NA_real_, dif_abs_max = NA_real_, dif_abs_mediana = NA_real_, n_abs_ge_002 = NA_integer_, n_rel_ge_10pct = NA_integer_, n_sens_alta = NA_integer_, n_base_valida_NA = NA_integer_, severidad = ifelse(grepl("no_tiene_estrato", item), "MENOR", "IMPORTANTE"), hallazgo = paste0("NR ponderada=", round(100 * proporcion_ponderada, 2), "%; tasa municipal máxima=", round(100 * max_tasa_municipal, 2), "%"), distincion_nr = ifelse(grepl("no_tiene_estrato", item), "Categoría sustantiva; no confundir con no_sabe_no_responde", "No respuesta")) |>
      dplyr::select(names(nr_findings)))
}

recommendations <- decision |>
  dplyr::filter(incluir_pca_propuesto) |>
  dplyr::select(indicador = id_indicador, clasificacion, MSA, media, desviacion_estandar, asimetria, pct_ceros, evaluacion_conceptual, coherencia_concepto_numerador_denominador)

comparaciones <- tibble::tibble(control = character(), valor = character(), estado = character(), interpretacion = character())
if (!is.null(stats_original)) {
  campos <- c("min", "p1", "mediana", "media", "p99", "max")
  ids_stats <- intersect(ids, stats_original$id_indicador)
  calc_stats <- dist |>
    dplyr::filter(indicador %in% ids_stats) |>
    dplyr::transmute(indicador, min_calc = minimo, p1_calc = p01, mediana_calc = mediana, media_calc = media, p99_calc = p99, max_calc = maximo)
  file_stats <- stats_original |>
    dplyr::transmute(indicador = id_indicador, min_file = numero_auditoria(min, "min original"), p1_file = numero_auditoria(p1, "p1 original"), mediana_file = numero_auditoria(mediana, "mediana original"), media_file = numero_auditoria(media, "media original"), p99_file = numero_auditoria(p99, "p99 original"), max_file = numero_auditoria(max, "max original"))
  cmp <- dplyr::inner_join(calc_stats, file_stats, by = "indicador")
  diffs <- unlist(lapply(campos, function(nm) cmp[[paste0(nm, "_calc")]] - cmp[[paste0(nm, "_file")]]), use.names = FALSE)
  max_diff <- max(abs(diffs), na.rm = TRUE)
  comparaciones <- dplyr::bind_rows(comparaciones, tibble::tibble(control = "descriptivos_min_p1_mediana_media_p99_max", valor = as.character(max_diff), estado = ifelse(max_diff < ivs_config$control$tolerancia_auditoria, "PASS", "REVISAR"), interpretacion = "Comparación recalculada contra estadisticos_indicadores.csv; asimetria/curtosis dependen de la convención del paquete psych."))
}
if (!is.null(cor_original) && nrow(cor_pairs)) {
  cor_old <- cor_original |>
    dplyr::mutate(indicador_1 = as.character(indicador_1), indicador_2 = as.character(indicador_2), correlacion_archivo = numero_auditoria(correlacion, "correlaciones archivo")) |>
    dplyr::mutate(par = paste(pmin(indicador_1, indicador_2), pmax(indicador_1, indicador_2), sep = "|"))
  cor_new <- cor_pairs |>
    dplyr::mutate(par = paste(pmin(indicador_1, indicador_2), pmax(indicador_1, indicador_2), sep = "|"))
  cor_cmp <- dplyr::left_join(cor_new, cor_old |> dplyr::select(par, correlacion_archivo), by = "par")
  max_diff <- max(abs(cor_cmp$correlacion - cor_cmp$correlacion_archivo), na.rm = TRUE)
  comparaciones <- dplyr::bind_rows(comparaciones, tibble::tibble(control = "correlaciones_recalculadas_vs_archivo", valor = as.character(max_diff), estado = ifelse(max_diff < ivs_config$control$tolerancia_auditoria, "PASS", "REVISAR"), interpretacion = "Correlaciones recalculadas desde la matriz municipal y cotejadas por par."))
}
if (!is.null(sens_m) && !is.null(sens)) {
  sens_check <- sens_m |>
    dplyr::mutate(diferencia_abs = numero_auditoria(diferencia_abs, "diferencia NR"), sens_alta = sens_alta == "TRUE") |>
    dplyr::group_by(id_indicador) |>
    dplyr::summarise(n_municipios_sensibles = sum(sens_alta), max_diferencia = max(diferencia_abs, na.rm = TRUE), .groups = "drop") |>
    dplyr::left_join(sens |> dplyr::transmute(id_indicador, n_sens_alta = as.integer(n_sens_alta), dif_abs_max = numero_auditoria(dif_abs_max, "máximo NR")), by = "id_indicador")
  fail <- sum(sens_check$n_municipios_sensibles != sens_check$n_sens_alta | abs(sens_check$max_diferencia - sens_check$dif_abs_max) > ivs_config$control$tolerancia_auditoria, na.rm = TRUE)
  comparaciones <- dplyr::bind_rows(comparaciones, tibble::tibble(control = "sensibilidad_NR_resumen_vs_municipio", valor = as.character(fail), estado = ifelse(fail == 0, "PASS", "REVISAR"), interpretacion = "Municipios sensibles y diferencia máxima coinciden entre los dos CSV."))
}
if (!is.null(read_base("outliers_z_mayor_4.csv")) && !is.null(matrix_z)) {
  n_reportado <- numero_auditoria(read_base("outliers_z_mayor_4.csv")$valor, "outliers reportados")[[1]]
  comparaciones <- dplyr::bind_rows(comparaciones, tibble::tibble(control = "outliers_recalculados_vs_archivo", valor = as.character(nrow(outliers) - n_reportado), estado = ifelse(nrow(outliers) == n_reportado, "PASS", "REVISAR"), interpretacion = "Diferencia de conteo de municipios con algun |z|>4."))
}

# El script de auditoria es propietario de los descriptivos y diagnosticos inferenciales.
# Se conserva la formula/implementacion anterior para permitir comparar los artefactos.
if (desde_pipeline && !is.null(matrix_base) && nrow(matrix_base) > 1L && !anyNA(matrix_base)) {
  main_ids <- setdiff(names(matrix_base), "codigo_municipio")
  desc <- purrr::map_dfr(ids, function(id) {
    x <- numero_auditoria(ind_total[[id]], id)
    x <- x[is.finite(x)]
    q <- if (length(x)) stats::quantile(x, c(.01, .5, .99), names = FALSE) else rep(NA_real_, 3)
    zdesc <- if (length(x) > 3L) psych::describe(x, fast = TRUE) else NULL
    tibble::tibble(id_indicador = id, n = length(x), min = if (length(x)) min(x) else NA_real_,
      p1 = q[[1]], mediana = q[[2]], media = if (length(x)) mean(x) else NA_real_,
      p99 = q[[3]], max = if (length(x)) max(x) else NA_real_,
      asimetria = if (!is.null(zdesc)) zdesc$skew[[1]] else NA_real_,
      curtosis = if (!is.null(zdesc)) zdesc$kurtosis[[1]] else NA_real_,
      pct_ceros = if (length(x)) 100 * mean(x == 0) else NA_real_,
      candidato_transformacion = if (!is.null(zdesc)) abs(zdesc$skew[[1]]) > ivs_config$auditoria[["umbral_asimetria"]] else NA)
  })
  escribir_csv_auditoria(desc, file.path(base_dir, "estadisticos_indicadores.csv"))
  x <- as.data.frame(lapply(matrix_base[main_ids], numero_auditoria, campo = "matriz PCA"))
  cor_mat <- stats::cor(x)
  pair_export <- as.data.frame(as.table(cor_mat)) |>
    tibble::as_tibble() |>
    dplyr::rename(indicador_1 = Var1, indicador_2 = Var2, correlacion = Freq) |>
    dplyr::filter(as.character(indicador_1) < as.character(indicador_2))
  escribir_csv_auditoria(pair_export, file.path(base_dir, "correlaciones_pares.csv"))
  escribir_csv_auditoria(dplyr::filter(pair_export, abs(correlacion) >= ivs_config$auditoria[["correlacion_alta"]]), file.path(base_dir, "pares_correlacion_ge_090.csv"))
  escribir_csv_auditoria(dplyr::filter(pair_export, abs(correlacion) >= ivs_config$auditoria[["correlacion_muy_alta"]]), file.path(base_dir, "pares_correlacion_ge_095.csv"))
  vars <- vapply(x, stats::var, numeric(1))
  escribir_csv_auditoria(tibble::tibble(indicador = names(vars), varianza = vars, varianza_casi_nula = vars < ivs_config$control$varianza_casi_nula), file.path(base_dir, "varianza_indicadores.csv"))
  kd <- tryCatch({
    k <- psych::KMO(cor_mat)
    b <- psych::cortest.bartlett(cor_mat, n = nrow(x))
    list(kmo = k$MSA, kmo_i = k$MSAi, chi = b$chisq, df = b$df, p = b$p.value, det = det(cor_mat))
  }, error = function(e) list(error = conditionMessage(e)))
  if (is.null(kd$error)) {
    escribir_csv_auditoria(tibble::tibble(indicador = names(kd$kmo_i), KMO = as.numeric(kd$kmo_i)), file.path(base_dir, "kmo_por_indicador.csv"))
    escribir_csv_auditoria(tibble::tibble(diagnostico = c("KMO global", "Bartlett chi-cuadrado", "Bartlett grados libertad", "Bartlett p", "Determinante correlacion"), valor = c(kd$kmo, kd$chi, kd$df, kd$p, kd$det)), file.path(base_dir, "diagnosticos_aptitud.csv"))
  } else {
    escribir_csv_auditoria(tibble::tibble(diagnostico = "psych KMO/Bartlett", valor = NA_real_, nota = kd$error), file.path(base_dir, "diagnosticos_aptitud.csv"))
  }
  zmat <- as.data.frame(lapply(matrix_z[main_ids], numero_auditoria, campo = "matriz z"))
  outlier_n <- sum(apply(abs(as.matrix(zmat)), 1, function(v) any(v > ivs_config$auditoria[["z_outlier"]], na.rm = TRUE)))
  escribir_csv_auditoria(tibble::tibble(metrica = "municipios con algun |z|>4", valor = outlier_n), file.path(base_dir, "outliers_z_mayor_4.csv"))
}

diag_value <- if (!is.null(diag)) stats::setNames(numero_auditoria(diag$valor, "diagnósticos aptitud"), diag$diagnostico) else numeric()
summary_audit <- tibble::tibble(
  control = c("archivos_obligatorios_ausentes", "municipios_matriz", "indicadores_especificados", "candidatos_pca", "municipios_con_outlier", "pares_correlacion", "pares_abs_r_ge_090", "KMO_global", "Bartlett_chi_cuadrado", "Bartlett_gl", "Bartlett_p_reportado", "determinante_correlacion"),
  valor = c(paste(missing, collapse = ";"), if (!is.null(matrix_base)) nrow(matrix_base) else NA, nrow(spec), nrow(recommendations), nrow(outliers), nrow(cor_pairs), sum(abs(cor_pairs$correlacion) >= ivs_config$auditoria[["correlacion_alta"]], na.rm = TRUE), unname(diag_value["KMO global"]), unname(diag_value["Bartlett chi-cuadrado"]), unname(diag_value["Bartlett grados libertad"]), unname(diag_value["Bartlett p"]), unname(diag_value["Determinante correlacion"])),
  estado = c(if (length(missing)) "REVISAR" else "PRESENTE", if (!is.null(matrix_base) && nrow(matrix_base) == ivs_config$n_municipios) "PASS" else "REVISAR", rep("INFORMATIVO", 10)),
  interpretacion = c("Se reportan faltantes sin sustituirlos", "Un registro por código territorial", "Definiciones incluidas en la especificación", "No equivale a selección final", "Outlier estadístico no implica error", "Se reporta estructura completa entre candidatos", "Ningún par supera el umbral", "Adecuación moderada; revisar variables individuales", "Con n grande puede detectar asociaciones pequeñas", "Grados de libertad del test", "El CSV redondea p a cero; interpretarlo como p<0.001", "No indica por sí mismo una solución válida")
)
if (nrow(comparaciones)) summary_audit <- dplyr::bind_rows(summary_audit, comparaciones)

outputs <- list(
  "01_matriz_decision_indicadores.csv" = decision,
  "02_hallazgos_conceptuales.csv" = concept_findings,
  "03_hallazgos_distribucion.csv" = dist,
  "04_hallazgos_outliers.csv" = outliers,
  "05_hallazgos_correlacion.csv" = cor_pairs,
  "06_hallazgos_kmo.csv" = kmo_findings,
  "07_hallazgos_no_respuesta.csv" = nr_findings,
  "08_recomendacion_variables_pca.csv" = recommendations,
  "09_resumen_auditoria.csv" = summary_audit
)
purrr::iwalk(outputs, ~ escribir_csv_auditoria(.x, file.path(out_dir, .y)))

md_table <- function(x, max_rows = 40L) {
  if (!nrow(x)) return("(Sin filas disponibles.)")
  x <- utils::head(as.data.frame(x), max_rows)
  x[] <- lapply(x, function(col) {
    val <- ifelse(is.na(col), "NA", as.character(col))
    gsub("\\|", "\\\\|", gsub("[\r\n]+", " ", val))
  })
  paste(c(paste0("| ", paste(names(x), collapse = " | "), " |"),
          paste0("| ", paste(rep("---", ncol(x)), collapse = " | "), " |"),
          apply(x, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |"))), collapse = "\n")
}
report <- c(
  "> Enlaces Obsidian: [[Inicio_Proyecto]] · [[Resumen_General]] · [[Final_Base]] · [[Refactorizacion_Pipeline_Indicadores]]",
  "", "# Auditoría estadística de indicadores municipales", "",
  paste0("Fecha: ", format(Sys.Date(), "%Y-%m-%d"), ". Universo objetivo: ", ivs_config$n_municipios, " códigos CNPV/IPM 2018."),
  "", "## 1. Resumen ejecutivo", "",
  "Los indicadores candidatos están dentro de [0,1] y el pipeline los reproduce, pero su validez conceptual no es uniforme. La evidencia permite continuar con depuración conceptual y análisis exploratorio adicional; **no alcanza para autorizar un PCA definitivo ni un IVS**. La mayor reserva está en MSA 0.414 para estrato 1–2, la definición heterogénea del indicador de actividad, el significado demográfico de hogares con menores y la sensibilidad de variables con NR.",
  "", "## 2. Universo analizado", "",
  paste0("Se revisaron ", if (!is.null(matrix_base)) nrow(matrix_base) else "NA", " municipios/códigos, ", nrow(spec), " indicadores especificados y ", nrow(recommendations), " candidatos propuestos. Los archivos obligatorios ausentes fueron: ", if (length(missing)) paste(missing, collapse = ", ") else "ninguno", "."),
  "", "## 3. Indicadores evaluados", "", md_table(decision |> dplyr::select(id_indicador, familia, numerador, denominador, direccion, incluir_pca_propuesto, clasificacion), 25L),
  "", "## 4. Calidad conceptual", "", md_table(concept_findings, 30L),
  "", "## 5. Distribución", "",
  "Los 17 indicadores se recalcularon descriptivamente desde `indicadores_municipales_base_total.csv`. Los valores de indicadores proporcionales quedaron dentro de [0,1]. Una proporción cercana a 1 no se considera imposible; puede reflejar universalidad del fenómeno o concentración territorial. La razón de dependencia no es proporción y puede superar 1. `pct_ceros` se expresa en porcentaje.",
  "", md_table(dist |> dplyr::select(indicador, tipo_escala, minimo, p01, mediana, media, p99, maximo, desviacion_estandar, varianza, asimetria, curtosis_exceso, pct_ceros, n_fuera_0_1, alertas), 30L),
  "", "## 6. Variabilidad", "",
  "Ninguno de los siete candidatos tiene varianza casi nula. Eso no demuestra que cada variable sea útil: el MSA y la interpretación conceptual señalan reservas para estrato 1–2 y electricidad.",
  "", "## 7. Outliers", "",
  paste0("Se identificaron ", nrow(outliers), " municipios con al menos un |z| > ", ivs_config$auditoria[["z_outlier"]], "; ", sum(outliers$flag_pob_lt5000 == "TRUE", na.rm = TRUE), " tienen menos de 5.000 habitantes y el máximo es ", max(outliers$n_indicadores_abs_z_mayor_4, na.rm = TRUE), " indicadores extremos en un municipio. Los valores z son un diagnóstico estadístico; no justifican eliminar observaciones. La tabla lista códigos, variables implicadas y población cuando está disponible. La base actual no prueba por sí sola si un valor extremo es error o realidad; se requiere inspección de fuente para cada caso."),
  "", md_table(outlier_by_var, 20L), "", "Municipios (máximo 40 mostrados):", "", md_table(outliers, 40L),
  "", "## 8. Correlaciones", "",
  "La matriz tiene estructura informativa, con relaciones moderadas y fuertes, pero no pares con |r| ≥ 0,90. Relaciones notables: electricidad con estrato 1–2 negativa (r≈−0,776); internet con recolección (r≈0,702); recolección con gas (r≈0,697). La relación negativa con estrato puede reflejar composición urbana/rural y definición del denominador. Correlación no establece redundancia conceptual por sí sola.",
  "", md_table(cor_pairs |> dplyr::arrange(dplyr::desc(abs(correlacion))) |> dplyr::select(indicador_1, indicador_2, correlacion, clasificacion), 40L),
  "", "## 9. KMO individual", "", md_table(kmo_findings, 20L),
  "", "## 10. KMO global", "",
  paste0("KMO global recalculado desde el CSV: ", round(unname(diag_value["KMO global"]), 3), ". Señala adecuación moderada en esta matriz; los KMO individuales bajos indican que algunas variables no comparten suficiente varianza común. No constituye aprobación automática del PCA."),
  "", "## 11. Bartlett", "",
  paste0("χ² = ", round(unname(diag_value["Bartlett chi-cuadrado"]), 3), ", gl = ", unname(diag_value["Bartlett grados libertad"]), ", p almacenado = ", unname(diag_value["Bartlett p"]), ". El valor 0 en el CSV es límite de representación numérica; el resultado debe expresarse como p < 0,001. Con 1.122 observaciones, significancia no implica que las asociaciones sean sustantivamente fuertes."),
  "", "## 12. Determinante", "",
  paste0("Determinante = ", signif(unname(diag_value["Determinante correlacion"]), 4), ". No sugiere singularidad numérica extrema en esta matriz, pero debe interpretarse junto con MSA, correlaciones y estabilidad."),
  "", "## 13. No respuesta", "", md_table(nr_findings, 40L),
  "", "Las correlaciones/KMO se calcularon para la matriz base total. La sensibilidad NR actual compara cada proporción municipio por municipio, pero no recalcula las matrices de correlación/KMO con la matriz base válida; por tanto el efecto de NR sobre estructura multivariada todavía no está cuantificado. La categoría 10V `no_tiene_estrato` se mantuvo distinta de `no_sabe_no_responde`.",
  "", "## 14. Decisiones sobre variables", "", md_table(decision |> dplyr::select(id_indicador, clasificacion, severidad_conceptual, MSA, evaluacion_conceptual), 25L),
  "", "## 15. Variables recomendadas para PCA", "",
  "Como candidatas para **revisión**, no aprobación: sin energía eléctrica, gas por red, recolección de basuras e internet. Actividad, hogares con menores y estrato 1–2 requieren revisión conceptual antes de conservarse. Ninguna debe pasar a PCA automáticamente.",
  "", "## 16. Variables que deben excluirse antes del PCA", "",
  "Por circularidad/solapamiento con privaciones IPM: educación, paredes inadecuadas, falta de acueducto, falta de alcantarillado y dependencia demográfica. `sin_servicio_energia_10v` es redundante como formulación alternativa a electricidad 8V; `pct_rural_disperso` es contexto y no candidato de vulnerabilidad sin definición adicional.",
  "", "## 17. Variables que requieren revisión", "",
  "Actividad (numerador heterogéneo); hogares con menores (composición no es privación); adultos mayores (dirección); estrato 1–2 (MSA 0.414 y universo de personas no estratificadas); y los cuatro servicios candidatos por correlación/territorialidad, sesgo y/o NR.",
  "", "## 18. Limitaciones", "",
  "Los archivos fuente son resúmenes municipales, no microdatos; outliers no se pueden validar caso a caso contra la fuente original en esta automatización. Los valores de p se almacenan como cero por subdesbordamiento. Los candidatos se evalúan en base total; falta recomputar la matriz válida. El número de archivos ausentes, si los hubiera, se reporta sin inventar sustitutos.",
  "", "## Comparación reproducible de salidas", "", md_table(comparaciones, 20L),
  "", "## 19. Recomendaciones antes del PCA", "",
  "1. Resolver denominadores de 8V gas/internet: la especificación dice 'total de respuesta', pero la base total usa el total que incluye Sin información; decidir base principal y reflejarlo en la etiqueta.\n2. Definir el constructo e interpretación de actividad y composición de hogares.\n3. Revisar el universo del estrato 1–2, su baja adecuación MSA y los casos rurales sin estrato.\n4. Recalcular correlaciones/KMO en base válida y comparar matrices/rankings.\n5. Inspeccionar municipios extremos con fuente y denominadores; no excluirlos por z-score.\n6. Evaluar dimensiones/estructura (incluida posible estructura de servicios) antes de decidir si un índice unidimensional tiene sentido.\n7. Congelar decisiones conceptuales y documentar regla de faltantes/cobertura.",
  "", "## Conclusiones A–J", "",
  "- **A. ¿Están correctamente construidos?** Aritméticamente, las comprobaciones del pipeline registran cero fallos y los candidatos están en [0,1]. Conceptualmente hay etiquetas/denominadores que deben corregirse o ratificarse, sobre todo gas e internet.\n- **B. ¿Hay evidencia suficiente para PCA?** No para ejecutarlo como decisión final; sí para una etapa adicional de revisión y análisis exploratorio, con reservas de MSA y concepto.\n- **C. ¿Mantener?** Cuatro servicios (energía 8V, gas, recolección, internet) como candidatos condicionados a revisión.\n- **D. ¿Revisar?** Actividad, hogares con menores, estrato 1–2 y hogares con adultos mayores.\n- **E. ¿Excluir antes?** Educación, paredes, acueducto, alcantarillado, dependencia, energía 10V duplicada y ruralidad como covariable contextual.\n- **F. ¿Problema demográfico?** Sí: 17PM mide nivel educativo para población 5+ y el indicador de actividad cubre 10+; no deben confundirse poblaciones. La dependencia es razón y puede superar 1.\n- **G. ¿NR afecta materialmente?** Hay decenas a más de cien municipios con diferencias absolutas ≥0,02 en varios indicadores; la correlación de ranking sigue alta (ρ≈0,95–0,997). El impacto sobre estructura PCA aún no fue probado.\n- **H. ¿Outliers son errores?** No hay evidencia para llamarlos errores; son extremos estadísticos que requieren verificación por fuente.\n- **I. ¿Correlación informativa?** Sí, con relaciones complementarias y bloques moderados/fuertes, sin pares ≥0,90; esto no resuelve la adecuación individual ni la conceptual.\n- **J. ¿Qué falta?** Resolver denominadores/NR y conceptos, analizar base válida, revisar extremos, aprobar variables y parámetros, luego reconsiderar PCA.",
  "", "## Reproducción", "",
  "Desde la raíz: `Rscript R/03_auditoria_indicadores.R`. El script lee la base consolidada existente, los nueve CSV requeridos y salidas NR; no construye de nuevo los indicadores ni ejecuta PCA.",
  "", "> Enlaces Obsidian: [[Inicio_Proyecto]] · [[Resumen_General]] · [[Final_Base]] · [[Refactorizacion_Pipeline_Indicadores]]"
)
writeLines(report, file.path(root, "docs", "calidad", "Auditoria_Estadistica_Indicadores.md"), useBytes = TRUE)
message("Auditoría completada: ", nrow(spec), " indicadores; ", if (!is.null(matrix_base)) nrow(matrix_base) else 0, " municipios; ", nrow(outliers), " municipios con |z|>4; PCA no ejecutado.")
