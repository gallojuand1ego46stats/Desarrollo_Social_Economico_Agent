# Funciones para analizar pendientes sin reescribir las salidas historicas.

solucion_parse_num <- function(x) {
  suppressWarnings(readr::parse_number(
    as.character(x),
    locale = readr::locale(decimal_mark = ".", grouping_mark = ","),
    na = c("", "NA", "N.A.", "N.D.", "--", "*")
  ))
}

solucion_tasa <- function(numerador, denominador) {
  dplyr::if_else(is.na(denominador) | denominador <= 0, NA_real_, numerador / denominador)
}

solucion_read_csv_text <- function(path) {
  readr::read_csv(
    path,
    col_types = readr::cols(.default = readr::col_character()),
    name_repair = "minimal",
    show_col_types = FALSE,
    progress = FALSE
  )
}

solucion_clean_label <- function(x) {
  janitor::make_clean_names(stringr::str_squish(as.character(x)))
}

solucion_extract_codes <- function(departamento, municipio) {
  dep <- stringr::str_match(as.character(departamento), "^\\s*(\\d{2})_")[, 2]
  muni5 <- stringr::str_match(as.character(municipio), "^\\s*(\\d{5})_")[, 2]
  muni3 <- stringr::str_match(as.character(municipio), "^\\s*(\\d{3})_")[, 2]
  dep_from_muni <- stringr::str_sub(muni5, 1, 2)
  dep <- dplyr::coalesce(dep, dep_from_muni)
  codigo <- dplyr::coalesce(muni5, ifelse(!is.na(dep) & !is.na(muni3), paste0(dep, muni3), NA_character_))
  tibble::tibble(codigo_departamento = dep, codigo_municipio = codigo)
}

solucion_estrato_10v <- function(x) {
  x |>
    dplyr::filter(area == "Total") |>
    dplyr::mutate(dplyr::across(
      c(personas_hogares_particulares, sin_servicio_energia, no_tiene_estrato, estrato_1, estrato_2, estrato_3,
        estrato_4, estrato_5, estrato_6, no_sabe_no_responde), solucion_parse_num
    )) |>
    dplyr::mutate(
      estratos_bajos = estrato_1 + estrato_2,
      personas_estratos_1a6 = estrato_1 + estrato_2 + estrato_3 + estrato_4 + estrato_5 + estrato_6,
      numerador_con_no_estrato = estratos_bajos + no_tiene_estrato,
      denominador_conocido = personas_hogares_particulares - no_sabe_no_responde,
      denominador_estrato_o_no_estrato = personas_estratos_1a6 + no_tiene_estrato,
      tasa_estrato_1_2_sobre_total = solucion_tasa(estratos_bajos, personas_hogares_particulares),
      tasa_vulnerabilidad_operativa_con_no_estrato_sobre_total = solucion_tasa(numerador_con_no_estrato, personas_hogares_particulares),
      tasa_vulnerabilidad_operativa_base_valida = solucion_tasa(numerador_con_no_estrato, denominador_conocido),
      tasa_vulnerabilidad_entre_clasificados = solucion_tasa(numerador_con_no_estrato, denominador_estrato_o_no_estrato),
      tasa_vulnerabilidad_cota_superior_nr = solucion_tasa(numerador_con_no_estrato + no_sabe_no_responde, personas_hogares_particulares),
      tasa_estrato_1_2_entre_estratos_asignados = solucion_tasa(estratos_bajos, personas_estratos_1a6),
      tasa_sin_servicio_energia = solucion_tasa(sin_servicio_energia, personas_hogares_particulares),
      tasa_no_tiene_estrato = solucion_tasa(no_tiene_estrato, personas_hogares_particulares),
      tasa_no_sabe_no_responde = solucion_tasa(no_sabe_no_responde, personas_hogares_particulares),
      delta_abs_base_total_vs_valida = abs(tasa_vulnerabilidad_operativa_con_no_estrato_sobre_total - tasa_vulnerabilidad_operativa_base_valida),
      delta_abs_total_vs_clasificados = abs(tasa_vulnerabilidad_operativa_con_no_estrato_sobre_total - tasa_vulnerabilidad_entre_clasificados),
      diferencia_relativa_total_vs_valida = dplyr::if_else(
        is.na(tasa_vulnerabilidad_operativa_base_valida) | tasa_vulnerabilidad_operativa_base_valida == 0,
        NA_real_, delta_abs_base_total_vs_valida / abs(tasa_vulnerabilidad_operativa_base_valida)
      ),
      valida_suma_categorias = personas_hogares_particulares ==
        (sin_servicio_energia + no_tiene_estrato + personas_estratos_1a6 + no_sabe_no_responde)
    )
}

solucion_materiales_6v <- function(x) {
  material_cols <- setdiff(grep("^total_", names(x), value = TRUE), "total_total")
  x |>
    dplyr::filter(tipo_vivienda == "Total") |>
    dplyr::select(codigo_departamento, codigo_municipio, nombre_municipio, nombre_departamento, total_total, dplyr::all_of(material_cols)) |>
    tidyr::pivot_longer(dplyr::all_of(material_cols), names_to = "variable_fuente", values_to = "conteo") |>
    dplyr::mutate(
      material = stringr::str_remove(variable_fuente, "^total_"),
      conteo = solucion_parse_num(conteo),
      total_total = solucion_parse_num(total_total),
      proporcion_viviendas = solucion_tasa(conteo, total_total)
    )
}

solucion_resumen_indicador <- function(x, columna, etiqueta) {
  v <- x[[columna]]
  v <- v[is.finite(v)]
  tibble::tibble(
    indicador = etiqueta,
    n_municipios = length(v),
    media = if (length(v)) mean(v) else NA_real_,
    mediana = if (length(v)) stats::median(v) else NA_real_,
    p95 = if (length(v)) as.numeric(stats::quantile(v, 0.95, names = FALSE)) else NA_real_,
    maximo = if (length(v)) max(v) else NA_real_
  )
}
