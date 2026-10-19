# Conforma indicadores municipales candidatos y matriz previa al PCA.
# Ejecutar desde la raiz: Rscript R/05_conformar_indicadores_finales.R
# No imputa, no ejecuta PCA y no modifica datos fuente ni salidas historicas.
suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr); library(stringr); library(purrr); library(tibble)
})
options(readr.show_col_types = FALSE, encoding = "UTF-8")
set.seed(20261015)

root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
out <- file.path(root, "resultados/indicadores_finales_ivs_20261015")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
read_txt <- function(path) readr::read_csv(path, col_types = cols(.default = col_character()),
  name_repair = "minimal", show_col_types = FALSE, progress = FALSE, na = c("", "NA"))
num <- function(x) suppressWarnings(readr::parse_number(as.character(x),
  locale = locale(decimal_mark = ".", grouping_mark = ","), na = c("", "NA", "--", "*", "N.D.")))
ratio <- function(n, d) ifelse(!is.na(d) & d > 0, n / d, NA_real_)
write_out <- function(x, name) readr::write_csv(x, file.path(out, name), na = "")
path <- function(name) file.path(root, "datos/intermedio", paste0(name, ".csv"))
message("[1/6] Cargando insumos como texto y verificando universo")
master <- read_txt(file.path(root, "resultados/verificacion_consolidados/universo_municipal_maestro.csv")) |>
  filter(en_ipm == "TRUE", contexto_1PM == "TRUE") |>
  select(codigo_departamento, codigo_municipio, nombre_municipio, nombre_departamento)
stopifnot(nrow(master) == 1122L, !anyDuplicated(master$codigo_municipio),
  all(str_detect(master$codigo_municipio, "^\\d{5}$")),
  all(master$codigo_departamento == str_sub(master$codigo_municipio, 1, 2)))
read_total <- function(nm, cols) {
  x <- read_txt(path(nm))
  if ("area" %in% names(x)) x <- x |> filter(.data$area == "Total")
  if ("sexo" %in% names(x)) x <- x |> filter(sexo == "Total")
  x |> mutate(across(all_of(cols), num))
}
hh <- read_total("hogares_1HM_2HM", c("hogares_total", "hogares_menores15", "hogares_total_2HM", "hogares_adultos_mayores"))
p5 <- read_total("persona_social_5PM", c("total", "no_informa", "trabajo_o_ayudo_en_un_negocio_por_lo_menos_una_hora_sin_que_le_pagaran", "busco_trabajo", "esta_incapacitado_a_permanentemente_para_trabajar"))
p17 <- read_total("persona_demo_17PM", c("total", "ninguno", "preescolar", "primaria_completa", "primaria_incompleta", "secundaria_completa", "secundaria_incompleta", "media_completa", "media_incompleta", "normal_completa", "normal_incompleta", "tecnico", "tecnologico", "universitario", "especializacion_maestria_doctorado", "sin_informacion"))
v6_all <- read_total("viviendas_6V", c("total_total", "total_bloque_ladrillo_piedra_madera_pulida", "total_concreto_vaciado", "total_material_prefabricado", "total_guadua", "total_tapia_bahareque_adobe", "total_madera_burda", "total_cana_vegetales", "total_desecho", "total_sin_paredes")) |> filter(tipo_vivienda == "Total")
v6 <- v6_all |> select(codigo_departamento, codigo_municipio, nombre_municipio, nombre_departamento, tipo_vivienda, total_total, total_guadua, total_tapia_bahareque_adobe, total_madera_burda, total_cana_vegetales, total_desecho, total_sin_paredes)
v8 <- read_total("viviendas_8V", c("viviendas_presentes", "energia_total", "energia_si", "energia_no", "gas_total", "gas_si", "gas_no", "gas_sin_informacion", "internet_total", "internet_si", "internet_no", "internet_sin_informacion"))
v10 <- read_total("viviendas_10V", c("personas_hogares_particulares", "sin_servicio_energia", "no_tiene_estrato", "estrato_1", "estrato_2", "estrato_3", "estrato_4", "estrato_5", "estrato_6", "no_sabe_no_responde"))
sources <- list(hogares = hh, persona_social_5PM = p5, persona_demo_17PM = p17, viviendas_6V = v6, viviendas_8V = v8, viviendas_10V = v10)
for (nm in names(sources)) {
  x <- sources[[nm]]
  if (anyDuplicated(x$codigo_municipio) || !setequal(master$codigo_municipio, x$codigo_municipio)) stop(paste("Universo/llave no coincide en", nm))
}

message("[2/6] Aplicando formulas aprobadas y sensibilidad de no respuesta")
walls_bad <- v6$total_guadua + v6$total_tapia_bahareque_adobe + v6$total_madera_burda + v6$total_cana_vegetales + v6$total_desecho + v6$total_sin_paredes
strata_known <- v10$estrato_1 + v10$estrato_2 + v10$estrato_3 + v10$estrato_4 + v10$estrato_5 + v10$estrato_6 + v10$no_tiene_estrato
strata_vuln <- v10$estrato_1 + v10$estrato_2 + v10$no_tiene_estrato
gas_valid <- v8$gas_total - v8$gas_sin_informacion
internet_valid <- v8$internet_total - v8$internet_sin_informacion
labor_valid <- p5$total - p5$no_informa
labor_num <- p5$trabajo_o_ayudo_en_un_negocio_por_lo_menos_una_hora_sin_que_le_pagaran + p5$busco_trabajo + 2 * p5$esta_incapacitado_a_permanentemente_para_trabajar
labor_score <- ratio(labor_num, 2 * labor_valid)
labor_score_w1 <- ratio(p5$trabajo_o_ayudo_en_un_negocio_por_lo_menos_una_hora_sin_que_le_pagaran + p5$busco_trabajo + p5$esta_incapacitado_a_permanentemente_para_trabajar, labor_valid)
labor_score_w3 <- ratio(p5$trabajo_o_ayudo_en_un_negocio_por_lo_menos_una_hora_sin_que_le_pagaran + p5$busco_trabajo + 3 * p5$esta_incapacitado_a_permanentemente_para_trabajar, 3 * labor_valid)
labor_sens_total <- ratio(labor_num, 2 * p5$total)
labor_upper_nr <- ratio(labor_num + 2 * p5$no_informa, 2 * p5$total)
edu_cols <- c("ninguno", "preescolar", "primaria_completa", "primaria_incompleta", "secundaria_completa", "secundaria_incompleta", "media_completa", "media_incompleta", "normal_completa", "normal_incompleta", "tecnico", "tecnologico", "universitario", "especializacion_maestria_doctorado", "sin_informacion")
edu_shares <- p17 |> transmute(codigo_municipio, across(all_of(edu_cols), ~ ratio(.x, total), .names = "prop_17PM_{.col}"))
edu_no_media_num <- p17$ninguno + p17$preescolar + p17$primaria_completa + p17$primaria_incompleta + p17$secundaria_completa + p17$secundaria_incompleta + p17$media_incompleta
edu_no_media_plus_normal_num <- edu_no_media_num + p17$normal_incompleta
edu_valid_den <- p17$total - p17$sin_informacion

base <- master |>
  left_join(hh |> transmute(codigo_municipio, n_hogares=hogares_total, n_hogares_menores=hogares_menores15, n_hogares_mayores=hogares_total_2HM, n_hogares_con_mayores=hogares_adultos_mayores), by="codigo_municipio") |>
  left_join(p5 |> transmute(codigo_municipio, p5_total=total, p5_no_informa=no_informa, p5_trabajo_no_remunerado=trabajo_o_ayudo_en_un_negocio_por_lo_menos_una_hora_sin_que_le_pagaran, p5_busco_trabajo=busco_trabajo, p5_incapacidad=esta_incapacitado_a_permanentemente_para_trabajar), by="codigo_municipio") |>
  left_join(v6 |> transmute(codigo_municipio, v6_total=total_total, v6_guadua=total_guadua, v6_tapia_bahareque_adobe=total_tapia_bahareque_adobe, v6_madera_burda=total_madera_burda, v6_cana_vegetales=total_cana_vegetales, v6_desecho=total_desecho, v6_sin_paredes=total_sin_paredes), by="codigo_municipio") |>
  left_join(v8 |> transmute(codigo_municipio, energia_total, energia_no, gas_total, gas_no, gas_nr=gas_sin_informacion, internet_total, internet_no, internet_nr=internet_sin_informacion), by="codigo_municipio") |>
  left_join(v10 |> transmute(codigo_municipio, v10_total=personas_hogares_particulares, sin_servicio_energia, no_tiene_estrato, estrato_1, estrato_2, estrato_3, estrato_4, estrato_5, estrato_6, no_sabe_no_responde), by="codigo_municipio") |>
  left_join(p17 |> transmute(codigo_municipio, p17_total=total, p17_sin_informacion=sin_informacion), by="codigo_municipio") |>
  mutate(
    hogares_menores15 = ratio(n_hogares_menores, n_hogares),
    hogares_adultos_mayores = ratio(n_hogares_con_mayores, n_hogares_mayores),
    paredes_precarias_6V = ratio(v6_guadua + v6_tapia_bahareque_adobe + v6_madera_burda + v6_cana_vegetales + v6_desecho + v6_sin_paredes, v6_total),
    sin_energia_8V = ratio(energia_no, energia_total),
    sin_gas_8V = ratio(gas_no, gas_valid), sin_gas_8V_sobre_total = ratio(gas_no, gas_total),
    sin_internet_8V = ratio(internet_no, internet_valid), sin_internet_8V_sobre_total = ratio(internet_no, internet_total),
    estratos_1_2_o_sin_estrato_10V = ratio(estrato_1 + estrato_2 + no_tiene_estrato, strata_known),
    estratos_1_2_o_sin_estrato_10V_sobre_total = ratio(estrato_1 + estrato_2 + no_tiene_estrato, v10_total),
    actividad_vulnerabilidad_10mas_5PM = labor_score,
    actividad_5PM_peso1 = labor_score_w1, actividad_5PM_peso3 = labor_score_w3,
    actividad_5PM_sobre_total = labor_sens_total, actividad_5PM_cota_superior_nr = labor_upper_nr,
    gas_no_respuesta_sobre_total = ratio(gas_nr, gas_total), internet_no_respuesta_sobre_total = ratio(internet_nr, internet_total),
    no_sabe_no_responde_10V_sobre_total = ratio(no_sabe_no_responde, v10_total),
    sin_servicio_energia_10V_sobre_total = ratio(sin_servicio_energia, v10_total),
    `17PM_no_informa_sobre_total` = ratio(p17_sin_informacion, p17_total)
    ,sin_media_completa_17PM = ratio(edu_no_media_num, p17_total)
    ,sin_media_completa_17PM_base_valida = ratio(edu_no_media_num, edu_valid_den)
    ,sin_media_completa_17PM_con_normal_incompleta = ratio(edu_no_media_plus_normal_num, p17_total)
    ,sin_media_completa_17PM_con_normal_incompleta_base_valida = ratio(edu_no_media_plus_normal_num, edu_valid_den)
  ) |>
  left_join(edu_shares, by="codigo_municipio")
write_out(base, "indicadores_municipales_y_denominadores.csv")

message("[3/6] Generando matriz previa al PCA, banco educativo y formulas")
pca_vars <- c("hogares_menores15", "hogares_adultos_mayores", "paredes_precarias_6V", "sin_energia_8V", "sin_gas_8V", "sin_internet_8V", "estratos_1_2_o_sin_estrato_10V", "actividad_vulnerabilidad_10mas_5PM", "sin_media_completa_17PM")
pca <- base |> select(codigo_departamento, codigo_municipio, nombre_municipio, nombre_departamento, all_of(pca_vars))
edu_bank <- base |> select(codigo_departamento, codigo_municipio, nombre_municipio, nombre_departamento, starts_with("prop_17PM_"))
write_out(pca, "matriz_pca_candidata.csv")
write_out(edu_bank, "candidatas_17PM_descriptivas.csv")
z_values <- as_tibble(scale(as.data.frame(pca[pca_vars]), center=TRUE, scale=TRUE))
z <- bind_cols(pca |> select(codigo_departamento, codigo_municipio, nombre_municipio, nombre_departamento), z_values)
write_out(z, "matriz_pca_candidata_z.csv")
write_out(tibble(indicador=pca_vars, media=map_dbl(pca_vars, ~mean(pca[[.x]])), desviacion_estandar=map_dbl(pca_vars, ~sd(pca[[.x]]))), "parametros_z_pca.csv")
formula <- tribble(
 ~indicador, ~numerador, ~denominador, ~orientacion, ~estado_en_pca, ~nota,
  "hogares_menores15", "Hogares con menores de 15 a\u00f1os", "Hogares totales 1HM", "Positiva", "Incluido candidato", "Carga potencial de cuidado; no equivale a dependencia econ\u00f3mica.",
 "hogares_adultos_mayores", "Hogares con personas de 60+", "Hogares totales 2HM", "Positiva", "Incluido candidato", "Proxy de carga potencial de cuidado; edad no demuestra dependencia funcional.",
  "paredes_precarias_6V", "Guadua + tapia/bahareque/adobe + madera burda + ca\u00f1a/vegetales + desecho + sin paredes", "Total viviendas tipo Total 6V", "Positiva", "Incluido candidato", "Seis categor\u00edas agregadas por decisi\u00f3n del autor.",
  "sin_energia_8V", "Viviendas sin energ\u00eda", "Total de viviendas ocupadas presentes (8V)", "Positiva", "Incluido candidato", "Indicador separado de gas e internet.",
  "sin_gas_8V", "Viviendas sin gas por red", "Total gas - sin informaci\u00f3n gas", "Positiva", "Incluido candidato", "La no respuesta se conserva y se prueba con total como denominador alternativo.",
  "sin_internet_8V", "Viviendas sin internet", "Total internet - sin informaci\u00f3n internet", "Positiva", "Incluido candidato", "La no respuesta se conserva y se prueba con total como denominador alternativo.",
  "estratos_1_2_o_sin_estrato_10V", "Personas estrato 1 + estrato 2 + no tiene estrato", "Estratos 1 a 6 + no tiene estrato", "Positiva", "Incluido candidato", "No sabe/no responde y sin servicio de energ\u00eda quedan separados; estrato clasifica inmuebles para servicios, no mide directamente ingreso.",
  "actividad_vulnerabilidad_10mas_5PM", "No remunerado + busc\u00f3 trabajo + 2 x incapacidad permanente", "2 x (poblaci\u00f3n 10+ - no informa)", "Positiva", "Incluido candidato, indicador experimental", "Agregado municipal de personas 10+; no es actividad del hogar ni tasa oficial de desempleo.",
  "sin_media_completa_17PM", "Ninguno + preescolar + primaria completa/incompleta + secundaria completa/incompleta + media incompleta", "Poblacion total de 5+", "Positiva", "Incluido candidato exploratorio", "Normal incompleta queda fuera de la formula principal; se calcula como sensibilidad. Normal completa se excluye. Edad 5+ puede confundir la comparacion municipal.",
  "prop_17PM_[categoria]", "Proporci\u00f3n de cada una de las 15 categor\u00edas educativas, incluida sin informaci\u00f3n", "Poblaci\u00f3n 5+ total", "Descriptiva; candidata pendiente", "Fuera de matriz hasta definir tratamiento composicional", "Quince categor\u00edas suman 1 y reflejan estructura etaria; no introducir todas crudas al PCA."
)
write_out(formula, "formulas_indicadores.csv")

message("[4/6] Ejecutando controles reproducibles de universo, sumas, rangos y faltantes")
sum_17 <- p17 |> mutate(suma_cat = rowSums(across(all_of(edu_cols)), na.rm = FALSE))
sum_5_cols <- c("no_informa", "trabajo_por_lo_menos_una_hora_en_una_actividad_que_le_genero_algun_ingreso", "trabajo_o_ayudo_en_un_negocio_por_lo_menos_una_hora_sin_que_le_pagaran", "no_trabajo_pero_tenia_un_empleo_trabajo_o_negocio_por_el_que_recibe_ingresos", "busco_trabajo", "vivio_de_jubilacion_pension_o_renta", "estudio", "realizo_oficios_del_hogar", "esta_incapacitado_a_permanentemente_para_trabajar", "estuvo_en_otra_situacion")
p5all <- read_total("persona_social_5PM", c("total", sum_5_cols)) |> mutate(suma_cat = rowSums(across(all_of(sum_5_cols)), na.rm = FALSE))
checks <- tribble(
 ~chequeo, ~n_evaluado, ~n_violaciones, ~tolerancia, ~evidencia,
 "Cobertura/unicidad municipios por fuente", 1122L, sum(map_int(sources, ~nrow(.x) - n_distinct(.x$codigo_municipio))), "exacta", "Cada fuente tiene los mismos 1.122 codigos del universo IPM/CNPV.",
  "17PM total = suma de 15 categorias educativas", nrow(sum_17), sum(abs(sum_17$total - sum_17$suma_cat) > 0.5, na.rm=TRUE), "0.5 persona", "Verifica distribucion educativa completa, incluida no informacion.",
  "Indicador 17PM sin media completa dentro de rango", nrow(p17), sum(ratio(edu_no_media_num, p17$total) < 0 | ratio(edu_no_media_num, p17$total) > 1, na.rm=TRUE), "[0,1]", "Fórmula principal excluye Normal incompleta y Normal completa.",
  "Proporciones 17PM suman 1", nrow(edu_bank), sum(abs(rowSums(edu_bank |> select(starts_with("prop_17PM_")), na.rm=FALSE) - 1) > 1e-10, na.rm=TRUE), "1e-10", "Las quince categorias usan el mismo denominador de poblacion 5+.",
  "5PM total = suma de categorias incl. no informa", nrow(p5all), sum(abs(p5all$total - p5all$suma_cat) > 0.5, na.rm=TRUE), "0.5 persona", "Control de consistencia del agregado 5PM.",
  "6V total = suma nueve materiales", nrow(v6_all), sum(abs(v6_all$total_total - rowSums(v6_all |> select(starts_with("total_") & !matches("^total_total$")), na.rm=FALSE)) > 0.5, na.rm=TRUE), "0.5 vivienda", "Verifica total por tipo contra todos los materiales.",
  "10V total = suma categorias BU:CD", nrow(v10), sum(abs(v10$personas_hogares_particulares - (v10$sin_servicio_energia + v10$no_tiene_estrato + v10$estrato_1 + v10$estrato_2 + v10$estrato_3 + v10$estrato_4 + v10$estrato_5 + v10$estrato_6 + v10$no_sabe_no_responde)) > 0.5, na.rm=TRUE), "0.5 persona", "Identidad publicada en 10V.",
  "8V energia total = si + no", nrow(v8), sum(abs(v8$energia_total - v8$energia_si - v8$energia_no) > 0.5, na.rm=TRUE), "0.5 vivienda", "Control de suma de categorias de servicio.",
  "8V gas total = si + no + sin informacion", nrow(v8), sum(abs(v8$gas_total - v8$gas_si - v8$gas_no - v8$gas_sin_informacion) > 0.5, na.rm=TRUE), "0.5 vivienda", "Control de suma de categorias de servicio.",
  "8V internet total = si + no + sin informacion", nrow(v8), sum(abs(v8$internet_total - v8$internet_si - v8$internet_no - v8$internet_sin_informacion) > 0.5, na.rm=TRUE), "0.5 vivienda", "Control de suma de categorias de servicio.",
  "10V suma del denominador de estratos conocidos", nrow(v10), sum(abs(strata_known - (v10$estrato_1+v10$estrato_2+v10$estrato_3+v10$estrato_4+v10$estrato_5+v10$estrato_6+v10$no_tiene_estrato)) > 0.5, na.rm=TRUE), "0.5 persona", "Denominador incluye estratos 1-6 y no tiene estrato; excluye no respuesta y no servicio.",
  "PCA candidatos en rango [0,1]", nrow(pca)*length(pca_vars), sum(unlist(pca[pca_vars]) < 0 | unlist(pca[pca_vars]) > 1, na.rm=TRUE), "[0,1]", "No implica validacion psicometrica ni ejecucion de PCA."
)
checks <- bind_rows(checks, map_dfr(pca_vars, function(v) tibble(chequeo=paste("NA",v), n_evaluado=nrow(pca), n_violaciones=sum(is.na(pca[[v]])), tolerancia="0 NA para matriz completa", evidencia="No se imputa; esta columna requiere resolver cobertura si hay NA.")))
write_out(checks, "chequeos_matriz.csv")
write_out(tibble(indicador=pca_vars, n_validos=map_int(pca_vars, ~sum(!is.na(pca[[.x]]))), n_na=map_int(pca_vars, ~sum(is.na(pca[[.x]])))), "cobertura_indicadores_pca.csv")
sens <- base |> select(codigo_municipio, nombre_municipio, actividad_vulnerabilidad_10mas_5PM, actividad_5PM_peso1, actividad_5PM_peso3, actividad_5PM_sobre_total, actividad_5PM_cota_superior_nr, sin_gas_8V, sin_gas_8V_sobre_total, sin_internet_8V, sin_internet_8V_sobre_total, estratos_1_2_o_sin_estrato_10V, estratos_1_2_o_sin_estrato_10V_sobre_total, sin_media_completa_17PM, sin_media_completa_17PM_base_valida, sin_media_completa_17PM_con_normal_incompleta, sin_media_completa_17PM_con_normal_incompleta_base_valida, gas_no_respuesta_sobre_total, internet_no_respuesta_sobre_total, all_of("17PM_no_informa_sobre_total"), no_sabe_no_responde_10V_sobre_total) |>
  mutate(delta_actividad_total=actividad_5PM_sobre_total-actividad_vulnerabilidad_10mas_5PM,
    amplitud_cota_actividad=actividad_5PM_cota_superior_nr-actividad_5PM_sobre_total,
    delta_gas=sin_gas_8V_sobre_total-sin_gas_8V, delta_internet=sin_internet_8V_sobre_total-sin_internet_8V,
    delta_10V_total=estratos_1_2_o_sin_estrato_10V_sobre_total-estratos_1_2_o_sin_estrato_10V)
write_out(sens, "sensibilidad_no_respuesta_municipal.csv")
sens_summary <- tribble(
  ~indicador, ~base, ~alternativa,
  "5PM actividad ponderada", "actividad_vulnerabilidad_10mas_5PM", "actividad_5PM_sobre_total",
  "5PM actividad ponderada", "actividad_vulnerabilidad_10mas_5PM", "actividad_5PM_cota_superior_nr",
  "5PM peso incapacidad", "actividad_vulnerabilidad_10mas_5PM", "actividad_5PM_peso1",
  "5PM peso incapacidad", "actividad_vulnerabilidad_10mas_5PM", "actividad_5PM_peso3",
  "8V gas sin servicio", "sin_gas_8V", "sin_gas_8V_sobre_total",
  "8V internet sin servicio", "sin_internet_8V", "sin_internet_8V_sobre_total",
  "10V estratos bajos + no tiene estrato", "estratos_1_2_o_sin_estrato_10V", "estratos_1_2_o_sin_estrato_10V_sobre_total"
  ,"17PM sin media completa", "sin_media_completa_17PM", "sin_media_completa_17PM_con_normal_incompleta"
  ,"17PM sin media completa", "sin_media_completa_17PM", "sin_media_completa_17PM_base_valida"
) |>
  rowwise() |>
  mutate(n= nrow(.env$base), rho_spearman=cor(.env$base[[.data$base]], .env$base[[.data$alternativa]], method="spearman", use="complete.obs"),
    diferencia_abs_max=max(abs(.env$base[[.data$base]]-.env$base[[.data$alternativa]]),na.rm=TRUE),
    municipios_delta_2pp=sum(abs(.env$base[[.data$base]]-.env$base[[.data$alternativa]])>=0.02,na.rm=TRUE)) |>
  ungroup() |>
  select(indicador, base, alternativa, n, rho_spearman, diferencia_abs_max, municipios_delta_2pp)
write_out(sens_summary, "resumen_sensibilidad.csv")

message("[5/6] Resumen numerico y salidas interpretables")
summary <- tibble(
  n_municipios=nrow(master), n_indicadores_pca=length(pca_vars), n_prop_17PM_descriptivas=length(edu_cols), n_candidatas_educativas_en_pca=1L,
  municipios_matriz_completa=sum(complete.cases(pca[pca_vars])), celdas_na=sum(is.na(pca[pca_vars])),
  violaciones_controles=sum(checks$n_violaciones, na.rm=TRUE), `6PM_incluido`=FALSE, PCA_ejecutado=FALSE,
  nota="Matriz de candidatos orientados y escalados conceptualmente; falta validacion y seleccion final. No imputada; PCA no ejecutado.")
write_out(summary, "resumen_ejecucion.csv")
message("[6/6] Listo. Resultados en: ", out)
message("Municipios: ", nrow(master), " | Indicadores candidatos PCA: ", length(pca_vars),
  " | municipios completos: ", summary$municipios_matriz_completa,
  " | celdas NA: ", summary$celdas_na, " | violaciones de controles: ", summary$violaciones_controles)
