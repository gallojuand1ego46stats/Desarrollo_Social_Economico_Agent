# Parametros editables de la base final del IVS (referencia CNPV 2018).
ivs_config <- list(
  anio_referencia = 2018L,
  n_municipios = 1122L,
  rutas = list(
    datos = "datos",
    intermedios = "datos/intermedio",
    trabajo = "datos/trabajo",
    verificacion = "resultados/verificacion_consolidados",
    resultados_base = "resultados/base_trabajo",
    resultados_auditoria = "resultados/auditoria_estadistica"
  ),
  archivos_intermedios = c(
    "contexto_1PM.csv", "contexto_1V.csv", "control_nacional.csv",
    "hogares_1HM_2HM.csv", "persona_demo_17PM.csv", "persona_social_5PM.csv",
    "viviendas_6V.csv", "viviendas_8V.csv", "viviendas_10V.csv",
    "ipm_municipal_ancho.csv"
  ),
  archivo_universo = "universo_municipal_maestro.csv",
  umbrales_nr = c(gt_5 = 0.05, gt_10 = 0.10, gt_20 = 0.20),
  sensibilidad = c(delta_absoluta = 0.02, delta_relativa = 0.10),
  percentiles_auditoria = c(0.01, 0.25, 0.50, 0.75, 0.99),
  control = list(
    tolerancia_suma = 1e-8,
    etiqueta_tolerancia_suma = "1e-8",
    tolerancia_ipm = 1e-10,
    tolerancia_auditoria = 1e-10,
    proporcion_minima = 0,
    proporcion_maxima = 1,
    varianza_casi_nula = 1e-8
  ),
  auditoria = c(
    z_outlier = 4.0,
    msa_adecuado = 0.70,
    msa_minimo = 0.50,
    umbral_asimetria = 2.0,
    pct_ceros_concentracion = 50.0,
    nr_municipios_importante = 100,
    correlacion_moderada = 0.40,
    correlacion_fuerte = 0.70,
    correlacion_alta = 0.90,
    correlacion_muy_alta = 0.95
  ),
  cobertura_baja = c(
    actividad_personas_10mas = 0.90,
    hogares_menores15 = 0.90,
    hogares_adultos_60mas = 0.95
  ),
  ejecutar_pca = FALSE,
  ejecutar_bootstrap = FALSE,
  crosswalk_aplica_solo_enlace_secop = TRUE
)
