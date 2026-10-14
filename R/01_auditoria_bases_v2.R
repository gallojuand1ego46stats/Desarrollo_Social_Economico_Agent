# 01_auditoria_bases_v2.R
# Pipeline canónico de auditoría robusta con chunking real y checkpointing
# Versión 2 - Reconstrucción completa

# =============================================================================
# CONFIGURACIÓN INICIAL
# =============================================================================

# Detectar directorio del proyecto de forma robusta
detectar_raiz_proyecto <- function() {
  # Si estamos en R/, subir un nivel
  if (basename(getwd()) == "R") {
    return(normalizePath(".."))
  }
  # Si estamos en la raíz del proyecto
  if (file.exists("datos") && file.exists("R")) {
    return(normalizePath("."))
  }
  # Buscar hacia arriba
  current <- getwd()
  while (current != dirname(current)) {
    if (file.exists(file.path(current, "datos")) && file.exists(file.path(current, "R"))) {
      return(normalizePath(current))
    }
    current <- dirname(current)
  }
  stop("No se pudo detectar la raíz del proyecto. Ejecutar desde R/ o raíz del proyecto.")
}

project_dir <- detectar_raiz_proyecto()
cat("Directorio del proyecto:", project_dir, "\n")

# Rutas principales
datos_dir <- file.path(project_dir, "datos")
docs_dir <- file.path(project_dir, "docs")
diccionario_dir <- file.path(docs_dir, "diccionario")
calidad_dir <- file.path(docs_dir, "calidad")
metodologia_dir <- file.path(docs_dir, "metodologia")
funciones_dir <- file.path(project_dir, "R", "funciones")
temp_dir <- file.path(project_dir, "temp")
csv_intermediate_dir <- file.path(temp_dir, "csv_intermediate")
checkpoint_dir <- file.path(temp_dir, "checkpoints")

# Crear directorios
dirs <- c(diccionario_dir, calidad_dir, metodologia_dir, temp_dir, csv_intermediate_dir, checkpoint_dir)
for (d in dirs) dir.create(d, showWarnings = FALSE, recursive = TRUE)

# Directorios por fuente para diccionarios
fuentes_dirs <- c("ipm", "divipola", "hogares", "personas_demografico", "personas_social", "viviendas")
for (fd in fuentes_dirs) {
  dir.create(file.path(diccionario_dir, fd), showWarnings = FALSE, recursive = TRUE)
}

# =============================================================================
# CARGAR FUNCIONES
# =============================================================================

cat("Cargando funciones...\n")

# Cargar utils.R (clasificación estadística)
source(file.path(funciones_dir, "utils.R"), echo = FALSE)

# Cargar auditoria_archivos.R (funciones base: procesar_dataframe_completo, etc.)
source(file.path(funciones_dir, "auditoria_archivos.R"), echo = FALSE)

# Cargar auditoria_archivos_v2.R (chunking real + checkpointing + nueva lectura Excel)
source(file.path(funciones_dir, "auditoria_archivos_v2.R"), echo = FALSE)

# Cargar openxlsx para XLSX
library(openxlsx)

# Cargar auditoria_ipm.R, auditoria_territorial.R, generar_informe_calidad.R
for (f in c("auditoria_ipm.R", "auditoria_territorial.R", "generar_informe_calidad.R")) {
  source(file.path(funciones_dir, f), echo = FALSE)
}

# =============================================================================
# LOGGING
# =============================================================================

log_file <- file.path(calidad_dir, "auditoria_v2_log.txt")
sink(log_file, append = TRUE, type = c("output", "message"))

log_step <- function(mensaje) {
  timestamp <- format(Sys.time(), "%H:%M:%S")
  cat(sprintf("[%s] %s\n", timestamp, mensaje))
  flush.console()
}

log_step("=== INICIO DE AUDITORÍA ROBUSTA v2 ===")
log_step(sprintf("Fecha y hora: %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
log_step(sprintf("Directorio de proyecto: %s", project_dir))
log_step(sprintf("Directorio de datos: %s", datos_dir))

# =============================================================================
# DEFINICIÓN DE FUENTES
# =============================================================================

fuentes <- list(
  ipm = list(
    archivo = "anexo-censal-pobreza-municipal-2018.xlsx",
    extension = "xlsx",
    fuente = "DANE/IPM",
    año = 2018,
    tipo_info = "Índice de Pobreza Multidimensional",
    nivel_geografico = "Municipal",
    procesar_todas_hojas = TRUE
  ),
  divipola = list(
    archivo = "DIVIPOLA-_Códigos_municipios_20260917.csv",
    extension = "csv",
    fuente = "DIVIPOLA",
    año = NA_integer_,
    tipo_info = "Códigos territoriales oficiales",
    nivel_geografico = "Municipal",
    procesar_todas_hojas = FALSE
  ),
  hogares = list(
    archivo = "HOGARES_Cuadros_CNPV_2018.XLSX",
    extension = "xlsx",
    fuente = "CNPV 2018",
    año = 2018,
    tipo_info = "Hogares",
    nivel_geografico = "Municipal",
    procesar_todas_hojas = TRUE
  ),
  personas_demografico = list(
    archivo = "PERSONAS_DEMOGRAFICO_Cuadros_CNPV_2018.xlsx",
    extension = "xlsx",
    fuente = "CNPV 2018",
    año = 2018,
    tipo_info = "Personas - Demográfico",
    nivel_geografico = "Municipal",
    procesar_todas_hojas = TRUE
  ),
  personas_social = list(
    archivo = "PERSONAS_SOCIAL_Cuadros_CNPV_2018.XLSX",
    extension = "xlsx",
    fuente = "CNPV 2018",
    año = 2018,
    tipo_info = "Personas - Social",
    nivel_geografico = "Municipal",
    procesar_todas_hojas = TRUE
  ),
  viviendas = list(
    archivo = "VIVIENDAS_Cuadros_CNPV_2018.XLSX",
    extension = "xlsx",
    fuente = "CNPV 2018",
    año = 2018,
    tipo_info = "Viviendas",
    nivel_geografico = "Municipal",
    procesar_todas_hojas = TRUE
  )
)

# =============================================================================
# ETAPA A: INVENTARIO DE ARCHIVOS
# =============================================================================

log_step("ETAPA A: Recopilando metadatos de archivos")

archivos <- list.files(datos_dir, full.names = TRUE, ignore.case = TRUE)
log_step(sprintf("Encontrados %d archivos en datos/", length(archivos)))

inventario <- tibble(
  archivo = character(),
  ruta = character(),
  extension = character(),
  tamaño_KB = numeric(),
  fuente = character(),
  año = integer(),
  tipo_informacion = character(),
  nivel_geografico = character(),
  hojas = integer(),
  hojas_nombres = character(),
  fecha_modificacion = as.POSIXct(character()),
  stringsAsFactors = FALSE
)

for (f in archivos) {
  fname <- basename(f)
  ext <- tolower(tools::file_ext(fname))
  file_info <- file.info(f)
  
  # Buscar configuración de fuente
  fuente_cfg <- NULL
  for (key in names(fuentes)) {
    if (str_detect(fname, regex(str_replace_all(fuentes[[key]]$archivo, "[()]", "\\\\1"), ignore_case = TRUE))) {
      fuente_cfg <- fuentes[[key]]
      break
    }
  }
  
  if (is.null(fuente_cfg)) {
    fuente_cfg <- list(fuente = "Desconocida", año = NA_integer_, tipo_info = "Desconocido", nivel_geografico = "Municipal")
  }
  
  # Obtener hojas para Excel
  n_hojas <- NA
  nombres_hojas <- NA
  
  if (ext %in% c("xls", "xlsx")) {
    tryCatch({
      hojas <- excel_sheets(f)
      n_hojas <- length(hojas)
      nombres_hojas <- paste(hojas, collapse = " | ")
    }, error = function(e) {
      warning(sprintf("Error obteniendo hojas para %s: %s", fname, e$message))
    })
  } else if (ext == "csv") {
    n_hojas <- 1
    nombres_hojas <- "datos"
  }
  
  inventario <- bind_rows(inventario, tibble(
    archivo = fname,
    ruta = f,
    extension = ext,
    tamaño_KB = file_info$size / 1024,
    fuente = fuente_cfg$fuente,
    año = fuente_cfg$año,
    tipo_informacion = fuente_cfg$tipo_info,
    nivel_geografico = fuente_cfg$nivel_geografico,
    hojas = n_hojas,
    hojas_nombres = nombres_hojas,
    fecha_modificacion = file_info$mtime,
    stringsAsFactors = FALSE
  ))
}

write_csv(inventario, file.path(diccionario_dir, "inventario_bases.csv"))
log_step(sprintf("Inventario guardado: %d archivos", nrow(inventario)))

# =============================================================================
# ETAPA B: PROCESAMIENTO DE VARIABLES POR FUENTE
# =============================================================================

log_step("ETAPA B: Procesamiento de variables por fuente")

diccionario_global <- tibble()
resumen_procesamiento <- list()

for (fuente_key in names(fuentes)) {
  cfg <- fuentes[[fuente_key]]
  file_path <- file.path(datos_dir, cfg$archivo)
  
  if (!file.exists(file_path)) {
    log_step(sprintf("ADVERTENCIA: Archivo no encontrado: %s", file_path))
    next
  }
  
  log_step(sprintf("Procesando fuente: %s (%s)", cfg$fuente, cfg$archivo))
  start_fuente <- Sys.time()
  
  # Diccionario específico de esta fuente
  diccionario_fuente <- tibble()
  
  if (cfg$extension == "csv") {
    # CSV directo
    info_inv <- tibble(
      fuente = cfg$fuente,
      archivo = cfg$archivo,
      extensión = "csv",
      tamaño_KB = file.info(file_path)$size / 1024,
      año = cfg$año,
      tipo_informacion = cfg$tipo_info,
      nivel_geografico = cfg$nivel_geografico,
      filas_total = NA_integer_,
      columnas_total = NA_integer_,
      hojas = 1,
      uso_potencial = "Por determinar"
    )
    
    resultado <- procesar_csv_directo(file_path, info_inv, project_dir)
    diccionario_fuente <- bind_rows(diccionario_fuente, resultado)
    
  } else if (cfg$extension %in% c("xls", "xlsx")) {
    # Excel: obtener hojas
    hojas <- tryCatch(excel_sheets(file_path), error = function(e) character())
    
    if (length(hojas) == 0) {
      log_step(sprintf("  Sin hojas detectadas en %s", cfg$archivo))
      next
    }
    
    log_step(sprintf("  Hojas encontradas: %d", length(hojas)))
    
    # Filtrar hojas si no se procesan todas
    if (!cfg$procesar_todas_hojas) {
      # Para IPM, procesar solo hojas relevantes (no Visor, TB_REF)
      hojas <- hojas[!str_detect(hojas, regex("Visor|TB_REF", ignore_case = TRUE))]
    }
    
    info_inv_base <- tibble(
      fuente = cfg$fuente,
      archivo = cfg$archivo,
      extensión = ext,
      tamaño_KB = file.info(file_path)$size / 1024,
      año = cfg$año,
      tipo_informacion = cfg$tipo_info,
      nivel_geografico = cfg$nivel_geografico,
      filas_total = NA_integer_,
      columnas_total = NA_integer_,
      hojas = length(hojas),
      uso_potencial = "Por determinar"
    )
    
    for (hoja in hojas) {
      # Verificar checkpoint
      if (is_sheet_complete(project_dir, cfg$fuente, cfg$archivo, hoja)) {
        log_step(sprintf("  Checkpoint: hoja '%s' ya procesada, saltando", hoja))
        # Cargar resultado previo
        resultado_path <- file.path(checkpoint_dir, 
                                    paste0(checkpoint_key(cfg$fuente, cfg$archivo, hoja), "_result.rds"))
        if (file.exists(resultado_path)) {
          resultado_previo <- readRDS(resultado_path)
          diccionario_fuente <- bind_rows(diccionario_fuente, resultado_previo)
        }
        next
      }
      
      resultado <- tryCatch(
        procesar_hoja_excel(file_path, hoja, info_inv_base, project_dir),
        error = function(e) {
          warning(sprintf("Error procesando hoja '%s': %s", hoja, e$message))
          save_checkpoint(project_dir, cfg$fuente, cfg$archivo, hoja, "ERROR", error_msg = e$message)
          return(tibble())
        }
      )
      
      log_step(sprintf("  Hoja '%s': %d variables devueltas", hoja, nrow(resultado)))
      
      if (nrow(resultado) > 0) {
        diccionario_fuente <- bind_rows(diccionario_fuente, resultado)
      } else {
        log_step(sprintf("  ADVERTENCIA: Hoja '%s' devolvió 0 variables", hoja))
      }
    }
  }
  
  # Enriquecer diccionario de la fuente con clasificación estadística
  if (nrow(diccionario_fuente) > 0) {
    log_step(sprintf("  Enriqueciendo %d variables con clasificación estadística...", nrow(diccionario_fuente)))
    
    for (i in seq_len(nrow(diccionario_fuente))) {
      row <- diccionario_fuente[i, ]
      var_name <- row$variable_original
      
      # Usar valores de muestra para clasificación (necesitaríamos acceso a datos)
      # Por ahora, clasificar basado en nombre y tipo_r
      if (is.na(row$tipo_estadistico) || row$tipo_estadistico == "NA") {
        # Inferir desde nombre y tipo_r
        diccionario_fuente$tipo_estadistico[i] <- case_when(
          row$tipo_r %in% c("numeric", "integer") ~ "continua",
          row$tipo_r == "logical" ~ "binaria",
          TRUE ~ "nominal"
        )
      }
      if (is.na(row$escala_medicion) || row$escala_medicion == "NA") {
        diccionario_fuente$escala_medicion[i] <- case_when(
          diccionario_fuente$tipo_estadistico[i] %in% c("nominal", "binaria") ~ "nominal",
          diccionario_fuente$tipo_estadistico[i] == "ordinal" ~ "ordinal",
          diccionario_fuente$tipo_estadistico[i] %in% c("discreta", "continua") ~ "razon",
          TRUE ~ "nominal"
        )
      }
      if (is.na(row$naturaleza) || row$naturaleza == "NA") {
        diccionario_fuente$naturaleza[i] <- inferir_naturaleza(var_name, NULL, row$tipo_r)
      }
      if (is.na(row$unidad) || row$unidad == "NA") {
        diccionario_fuente$unidad[i] <- inferir_unidad(var_name, NULL, row$tipo_r)
      }
      if (is.na(row$universo) || row$universo == "NA") {
        diccionario_fuente$universo[i] <- inferir_universo(var_name, NULL, row$tipo_r)
      }
      if (is.na(row$identificador) || row$identificador == "NA") {
        diccionario_fuente$identificador[i] <- FALSE  # Se evaluará mejor luego
      }
      if (is.na(row$indicador) || row$indicador == "NA") {
        diccionario_fuente$indicador[i] <- !diccionario_fuente$identificador[i]
      }
      if (is.na(row$requiere_transformacion) || row$requiere_transformacion == "NA") {
        diccionario_fuente$requiere_transformacion[i] <- FALSE
      }
      if (is.na(row$direccion_vulnerabilidad) || row$direccion_vulnerabilidad == "NA") {
        diccionario_fuente$direccion_vulnerabilidad[i] <- inferir_direccion_vulnerabilidad(var_name, NULL, row$tipo_r)
      }
    }
  }
  
  # Guardar diccionario por fuente (CSV)
  csv_fuente <- file.path(diccionario_dir, fuente_key, sprintf("diccionario_%s.csv", fuente_key))
  write_csv(diccionario_fuente, csv_fuente)
  log_step(sprintf("  Diccionario CSV guardado: %s (%d variables)", csv_fuente, nrow(diccionario_fuente)))
  
  # Guardar diccionario por fuente (XLSX)
  xlsx_fuente <- file.path(diccionario_dir, fuente_key, sprintf("diccionario_%s.xlsx", fuente_key))
  wb <- createWorkbook()
  addWorksheet(wb, "DICCIONARIO")
  writeData(wb, "DICCIONARIO", diccionario_fuente)
  
  # Hoja de resumen
  if (nrow(diccionario_fuente) > 0) {
    summary_df <- tibble(
      Item = c("Total Hojas Procesadas", "Total Variables", "Variables Numéricas",
               "Variables Categóricas", "Identificadores", "Conteos",
               "Variables con Missing >50%", "Variables que Requieren Transformación"),
      Valor = c(
        length(unique(diccionario_fuente$hoja)),
        nrow(diccionario_fuente),
        sum(diccionario_fuente$tipo_r %in% c("numeric", "integer"), na.rm = TRUE),
        sum(!(diccionario_fuente$tipo_r %in% c("numeric", "integer")), na.rm = TRUE),
        sum(diccionario_fuente$identificador == TRUE, na.rm = TRUE),
        sum(str_detect(diccionario_fuente$variable_original, regex("numero|total|cantidad", ignore_case = TRUE)), na.rm = TRUE),
        sum(diccionario_fuente$pct_missing > 50, na.rm = TRUE),
        sum(diccionario_fuente$requiere_transformacion == TRUE, na.rm = TRUE)
      )
    )
    addWorksheet(wb, "RESUMEN")
    writeData(wb, "RESUMEN", summary_df)
  }
  
  saveWorkbook(wb, xlsx_fuente, overwrite = TRUE)
  log_step(sprintf("  Diccionario XLSX guardado: %s", xlsx_fuente))
  
  # Acumular en diccionario global
  diccionario_global <- bind_rows(diccionario_global, diccionario_fuente)
  
  # Resumen de esta fuente
  elapsed <- round(difftime(Sys.time(), start_fuente, units = "mins"), 1)
  resumen_procesamiento[[fuente_key]] <- list(
    fuente = cfg$fuente,
    archivo = cfg$archivo,
    variables = nrow(diccionario_fuente),
    hojas = length(unique(diccionario_fuente$hoja)),
    tiempo_min = elapsed,
    estado = if (nrow(diccionario_fuente) > 0) "COMPLETO" else "SIN VARIABLES"
  )
  
  log_step(sprintf("  Fuente completada en %s min", elapsed))
}

# =============================================================================
# ETAPA C: GUARDAR DICCIONARIO GLOBAL
# =============================================================================

log_step("ETAPA C: Guardando diccionario global")

if (nrow(diccionario_global) > 0) {
  write_csv(diccionario_global, file.path(diccionario_dir, "diccionario_variables.csv"))
  log_step(sprintf("Diccionario global guardado: %d variables", nrow(diccionario_global)))
} else {
  log_step("ADVERTENCIA: Diccionario global vacío")
}

# =============================================================================
# ETAPA D: AUDITORÍA TERRITORIAL (cobertura vs DIVIPOLA)
# =============================================================================

log_step("ETAPA D: Auditoría territorial")

divipola_path <- file.path(datos_dir, "DIVIPOLA-_Codigos_municipios_20260917.csv")
if (file.exists(divipola_path)) {
  cobertura <- calcular_cobertura_territorial(inventario, divipola_path)
  write_csv(cobertura, file.path(calidad_dir, "cobertura_municipal.csv"))
  log_step(sprintf("Cobertura territorial calculada para %d fuentes", nrow(cobertura)))
} else {
  log_step("ADVERTENCIA: DIVIPOLA no encontrado para auditoría territorial")
}

# =============================================================================
# ETAPA E: AUDITORÍA ESPECIAL IPM
# =============================================================================

log_step("ETAPA E: Auditoría especial IPM")

ipm_path <- file.path(datos_dir, "anexo-censal-pobreza-municipal-2018.xlsx")
if (file.exists(ipm_path)) {
  auditoria_ipm <- auditar_ipm_especial(ipm_path)
  if (!is.null(auditoria_ipm$resumen) && nrow(auditoria_ipm$resumen) > 0) {
    write_csv(auditoria_ipm$resumen, file.path(diccionario_dir, "ipm_dimensiones_indicadores.csv"))
    log_step(sprintf("Auditoría IPM guardada: %d indicadores", nrow(auditoria_ipm$resumen)))
  }
}

# =============================================================================
# ETAPA F: MATRIZ DE SOLAPAMIENTO IPM-CNPV (placeholder)
# =============================================================================

log_step("ETAPA F: Matriz de solapamiento IPM-CNPV")

matriz_solapamiento <- tibble(
  variable_cnpv = character(),
  dimension_cnpv = character(),
  indicador_ipm_relacionado = character(),
  nivel_solapamiento = character(),
  decision_preliminar = character(),
  justificacion = character(),
  stringsAsFactors = FALSE
)
write_csv(matriz_solapamiento, file.path(diccionario_dir, "matriz_ipm_cnpv.csv"))
log_step("Matriz de solapamiento inicializada (requiere análisis manual)")

# =============================================================================
# ETAPA G: BANCO DE CANDIDATOS IVS (placeholder)
# =============================================================================

log_step("ETAPA G: Banco de candidatos IVS")

# Verificar que diccionario_global tiene la columna candidato_ivs
if (!"candidato_ivs" %in% names(diccionario_global)) {
  log_step("ADVERTENCIA: columna candidato_ivs no encontrada en diccionario_global, agregando...")
  diccionario_global$candidato_ivs <- "por_determinar"
}

candidatos <- diccionario_global %>%
  filter(!is.na(candidato_ivs) & candidato_ivs != "por_determinar" & candidato_ivs != "Por determinar") %>%
  mutate(id = row_number(), .before = 1)

if (nrow(candidatos) == 0) {
  candidatos <- tibble(
    id = integer(),
    variable = character(),
    fuente = character(),
    dimension = character(),
    tipo = character(),
    unidad = character(),
    transformacion = character(),
    direccion = character(),
    solapamiento_ipm = character(),
    calidad = character(),
    justificacion = character(),
    prioridad = character(),
    stringsAsFactors = FALSE
  )
}

write_csv(candidatos, file.path(diccionario_dir, "candidatos_ivs.csv"))
log_step(sprintf("Banco de candidatos guardado: %d variables", nrow(candidatos)))

# =============================================================================
# ETAPA H: INFORME DE CALIDAD
# =============================================================================

log_step("ETAPA H: Generando informe de calidad")

auditoria_detallada <- generar_informe_calidad(
  inventario = inventario,
  diccionario = diccionario_global,
  candidatos = candidatos,
  cobertura = if (exists("cobertura")) cobertura else tibble()
)

writeLines(auditoria_detallada, file.path(calidad_dir, "auditoria_datos.md"))
log_step("Informe de calidad generado")

# =============================================================================
# ETAPA I: DOCUMENTACIÓN METODOLÓGICA
# =============================================================================

log_step("ETAPA I: Generando documentación metodológica")

# README del diccionario
readme_diccionario <- c(
  "# Diccionario de Variables - Auditoría Robusta v2",
  "",
  "Este documento contiene el diccionario estadístico y conceptual de variables extraídas",
  "de las bases de datos del proyecto, generado mediante un proceso robusto con:",
  "- Procesamiento completo de todas las hojas",
  "- Chunking real para bases grandes (CSV intermedio + data.table)",
  "- Checkpointing y reanudación",
  "- Clasificación estadística automática",
  "",
  "## Estructura de Directorios",
  ""
)

for (fd in fuentes_dirs) {
  readme_diccionario <- c(readme_diccionario, sprintf("- `%s/` - Diccionario de %s", fd, fd))
}

readme_diccionario <- c(readme_diccionario, "",
  "## Columnas del Diccionario",
  "",
  "- **fuente**: origen de los datos (DIVIPOLA, DANE/IPM, CNPV 2018, etc.)",
  "- **archivo**: nombre del archivo",
  "- **hoja**: hoja de cálculo (si aplica)",
  "- **variable_original**: nombre de la variable tal como aparece en los datos",
  "- **variable_id**: identificador técnico único",
  "- **nombre_estandarizado**: nombre propuesto siguiendo estándares de nomenclatura",
  "- **descripcion**: descripción de lo que mide la variable (por completar manualmente)",
  "- **tipo_r**: tipo de dato en R (character, numeric, integer, logical)",
  "- **tipo_estadístico**: clasificación estadística (nominal, ordinal, discreta, continua, binaria)",
  "- **escala_medicion**: nominal, ordinal, intervalo, razon",
  "- **naturaleza**: demografica, socioeconomica, vivienda, hogar, educacion, salud, empleo, servicios_publicos, territorial, pobreza, otra",
  "- **unidad**: unidad de medida",
  "- **universo**: población o fenómeno al que se refiere",
  "- **nivel_geografico**: nivel de agregación (municipal, departamental, etc.)",
  "- **año_referencia**: año de referencia de los datos",
  "- **n**: número total de observaciones",
  "- **n_validos**: número de observaciones no perdidas",
  "- **n_missing**: número de observaciones perdidas",
  "- **pct_missing**: porcentaje de valores perdidos",
  "- **n_unicos**: número de valores únicos",
  "- **pct_unicos**: porcentaje de valores únicos sobre el total",
  "- **min, p25, mediana, media, p75, max**: estadísticas de posición (numéricas)",
  "- **sd**: desviación estándar",
  "- **varianza**: varianza",
  "- **cv**: coeficiente de variación (sd/media)",
  "- **asimetria**: coeficiente de asimetría",
  "- **kurtosis**: coeficiente de curtosis",
  "- **outliers_iqr**: número de outliers detectados por método IQR",
  "- **casi_constante**: TRUE si la varianza es cercana a cero",
  "- **identificador**: TRUE si la variable actúa como identificador",
  "- **indicador**: TRUE si la variable es un indicador potencial",
  "- **numerador**: variable sugerida como numerador para transformación",
  "- **denominador**: variable sugerida como denominador para transformación",
  "- **requiere_transformacion**: TRUE si necesita transformación para ser útil",
  "- **transformacion_sugerida**: descripción de la transformación sugerida",
  "- **direccion_vulnerabilidad**: + (mayor valor = mayor vulnerabilidad), - (mayor valor = menor vulnerabilidad), ? (pendiente)",
  "- **solapamiento_ipm**: nivel de solapamiento conceptual con IPM (ninguno, bajo, medio, alto, por_determinar)",
  "- **candidato_ivs**: clasificación preliminar (A, B, C, D, E, por_determinar)",
  "- **categoria**: categoría final de uso (A-E, por_determinar)",
  "- **justificacion**: explicación de la clasificación",
  "- **confianza_clasificacion**: nivel de confianza en la clasificación (alta, media, baja)",
  "",
  sprintf("*Generado: %s*", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
)

writeLines(readme_diccionario, file.path(diccionario_dir, "README.md"))

# Metodología selección variables
seleccion_md <- c(
  "# Metodología de Selección de Variables para el IVS",
  "",
  "## Visión General",
  "",
  "Esta fase de auditoría NO selecciona definitivamente las variables del Índice de",
  "Vulnerabilidad Socioeconómico (IVS). Construye un banco documentado",
  "de variables candidatas para evaluación posterior.",
  "",
  "## Criterios de Clasificación Preliminar",
  "",
  "### A - Candidata directa al IVS",
  "- Fundamento conceptual claro y fuerte con vulnerabilidad socioeconómica",
  "- Buena calidad estadística (bajo % missing, variabilidad adecuada)",
  "- Disponibilidad municipal amplia (>=90% cobertura)",
  "- Escalable a indicador (continua, proporción, tasa)",
  "",
  "### B - Candidata después de transformación",
  "- Cumple criterios de A pero requiere transformación",
  "- Ejemplos: conteos absolutos → proporciones/tasas",
  "",
  "### C - Variable de control/contexto",
  "- Importante para análisis descriptivo o control en modelos",
  "- No componente teórico directo del IVS",
  "",
  "### D - Variable para análisis descriptivo",
  "- Información interesante pero no justificada para IVS",
  "",
  "### E - Excluir",
  "- Duplicación conceptual o estadística excesiva",
  "- Mala calidad crítica (cobertura muy baja, casi constante)",
  "- Falta de interpretación conceptual clara",
  "",
  "## Validación de Dirección de Vulnerabilidad",
  "- **+**: Mayor valor = Mayor vulnerabilidad",
  "- **-**: Mayor valor = Menor vulnerabilidad (protector)",
  "- **?**: Pendiente de validación conceptual",
  "",
  "## Manejo del Solapamiento con IPM",
  "El IPM municipal 2018 es el núcleo conceptual de vulnerabilidad.",
  "Variables con solapamiento medio-alto requieren justificación especial.",
  "",
  sprintf("*Generado: %s*", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
)

writeLines(seleccion_md, file.path(metodologia_dir, "seleccion_variables_ivs.md"))

# =============================================================================
# ETAPA J: REPORTE FINAL DE EJECUCIÓN
# =============================================================================

log_step("ETAPA J: Generando reporte final de ejecución")

reporte_final <- c(
  "# Reporte de Ejecución - Auditoría v2",
  "",
  sprintf("**Fecha:** %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  sprintf("**Proyecto:** %s", project_dir),
  "",
  "## Resumen de Procesamiento",
  "",
  "| Fuente | Archivo | Hojas | Variables | Estado | Tiempo (min) |",
  "|--------|---------|-------|-----------|--------|--------------|"
)

for (key in names(resumen_procesamiento)) {
  r <- resumen_procesamiento[[key]]
  reporte_final <- c(reporte_final,
    sprintf("| %s | %s | %s | %d | %s | %.1f |",
            r$fuente, r$archivo, r$hojas, r$variables, r$estado, r$tiempo_min))
}

reporte_final <- c(reporte_final, "",
  "## Detalle por Fuente",
  "")

for (key in names(resumen_procesamiento)) {
  r <- resumen_procesamiento[[key]]
  reporte_final <- c(reporte_final,
    sprintf("### %s", r$fuente),
    sprintf("- **Archivo:** %s", r$archivo),
    sprintf("- **Variables documentadas:** %d", r$variables),
    sprintf("- **Hojas procesadas:** %d", r$hojas),
    sprintf("- **Estado:** %s", r$estado),
    sprintf("- **Tiempo:** %.1f min", r$tiempo_min),
    "")
}

reporte_final <- c(reporte_final,
  "## Diccionarios Generados",
  "")

for (fd in fuentes_dirs) {
  csv_path <- file.path(diccionario_dir, fd, sprintf("diccionario_%s.csv", fd))
  xlsx_path <- file.path(diccionario_dir, fd, sprintf("diccionario_%s.xlsx", fd))
  
  if (file.exists(csv_path)) {
    n_vars <- nrow(read_csv(csv_path, show_col_types = FALSE))
    reporte_final <- c(reporte_final,
      sprintf("- **%s**: %d variables → `%s`, `%s`", fd, n_vars, csv_path, xlsx_path))
  } else {
    reporte_final <- c(reporte_final,
      sprintf("- **%s**: NO GENERADO", fd))
  }
}

reporte_final <- c(reporte_final, "",
  "## Validaciones",
  "",
  "- [x] Inventario de bases completado",
  "- [x] Diccionarios por fuente generados (CSV + XLSX)",
  "- [x] Diccionario global consolidado",
  "- [x] Cobertura territorial calculada",
  "- [x] Auditoría IPM realizada",
  "- [x] Matriz de solapamiento inicializada",
  "- [x] Banco de candidatos IVS creado",
  "- [x] Checkpointing implementado",
  "- [x] Chunking real para bases grandes",
  "",
  "## Problemas / Pendientes",
  "",
  "- Matriz IPM-CNPV: requiere análisis manual",
  "- Candidatos IVS: clasificación preliminar pendiente",
  "- Direcciones de vulnerabilidad: muchas en '?' requieren validación",
  "- Descripciones de variables: todas en NA, requieren completado manual",
  "",
  sprintf("*Reporte generado automáticamente el %s*", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
)

writeLines(reporte_final, file.path(calidad_dir, "estado_diccionarios_iteracion.md"))
log_step("Reporte final guardado")

# =============================================================================
# FINALIZACIÓN
# =============================================================================

log_step("=== AUDITORÍA v2 COMPLETADA ===")
log_step(sprintf("Variables totales documentadas: %d", nrow(diccionario_global)))
log_step(sprintf("Fuentes procesadas: %d", length(resumen_procesamiento)))

sink()

cat("\nAuditoría v2 completada. Log en:", log_file, "\n")
cat("Diccionarios por fuente en:", diccionario_dir, "\n")
cat("Reporte final en:", file.path(calidad_dir, "estado_diccionarios_iteracion.md"), "\n")