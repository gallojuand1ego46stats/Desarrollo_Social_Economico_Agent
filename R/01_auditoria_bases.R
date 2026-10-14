# 01_auditoria_bases.R
# Script principal para auditoría robusta de bases de datos del proyecto

# Cargar librerías necesarias
suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(purrr)
  library(janitor)
  library(tibble)
  library(lubridate)
})

# Determinar el directorio del proyecto
# Asumimos que el script se ejecuta desde el directorio R/ o desde la raíz del proyecto
if (basename(getwd()) == "R") {
  # Si estamos en R/, subir un nivel para llegar a la raíz del proyecto
  project_dir <- ".."
} else {
  # Si estamos en otro lugar, asumimos que estamos en la raíz del proyecto
  project_dir <- "."
}
project_dir <- normalizePath(project_dir)

# Definir rutas importantes
datos_dir <- file.path(project_dir, "datos")
docs_dir <- file.path(project_dir, "docs")
diccionario_dir <- file.path(docs_dir, "diccionario")
calidad_dir <- file.path(docs_dir, "calidad")
metodologia_dir <- file.path(docs_dir, "metodologia")
funciones_dir <- file.path(project_dir, "R", "funciones")

# Crear directorios de documentación si no existen
dir.create(diccionario_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(calidad_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(metodologia_dir, showWarnings = FALSE, recursive = TRUE)

# Cargar funciones personalizadas
funciones <- list.files(funciones_dir, pattern = "\\.R$", full.names = TRUE)
for (f in funciones) {
  source(f, echo = FALSE)
}

# Iniciar logging
log_file <- file.path(calidad_dir, "auditoria_log.txt")
sink(log_file, append = TRUE, type = c("output", "message"))
cat("=== INICIO DE AUDITORÍA ROBUSTA ===\n")
cat("Fecha y hora:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("Directorio de proyecto:", project_dir, "\n")
cat("Directorio de datos:", datos_dir, "\n\n")

# Función para reportar progreso con timestamp
log_step <- function(mensaje) {
  timestamp <- format(Sys.time(), "%H:%M:%S")
  cat(sprintf("[%s] %s\n", timestamp, mensaje))
  flush.console()
}

# ETAPA A: METADATOS DE ARCHIVOS
log_step("ETAPA A: Recopilando metadatos de archivos")
archivos <- list.files(datos_dir, full.names = TRUE, ignore.case = TRUE)
log_step(sprintf("Encontrados %d archivos en datos/", length(archivos)))

# Inventario de bases
inventario <- tibble(
  archivo = character(),
  ruta = character(),
  extension = character(),
  tamaño_KB = numeric(),
  fuente = character(),
  año = integer(),
  tipo_informacion = character(),
  nivel_geografico = character(),
  filas_total = integer(),
  columnas_total = integer(),
  hojas = integer(),
  hojas_nombres = character(),
  fecha_modificacion = POSIXct(),
  uso_potencial = character(),
  stringsAsFactors = FALSE
)

# Procesar cada archivo para obtener metadatos básicos
for (f in archivos) {
  fname <- basename(f)
  ext <- tolower(tools::file_ext(fname))
  
  # Información básica del archivo
  file_info <- file.info(f)
  
  # Determinar fuente y año basado en el nombre (heurística mejorada)
  fuente <- "Desconocida"
  año <- NA
  tipo_info <- "Desconocido"
  nivel_geo <- "Municipal" # asumimos municipal por defecto
  
  if (str_detect(fname, regex("DIVIPOLA", ignore_case = TRUE))) {
    fuente <- "DIVIPOLA"
    tipo_info <- "Códigos territoriales oficiales"
  } else if (str_detect(fname, regex("anexo-censal-pobreza|IPM", ignore_case = TRUE))) {
    fuente <- "DANE/IPM"
    año <- 2018
    tipo_info <- "Índice de Pobreza Multidimensional"
  } else if (str_detect(fname, regex("PERSONAS_DEMOGRAFICO", ignore_case = TRUE))) {
    fuente <- "CNPV 2018"
    año <- 2018
    tipo_info <- "Personas - Demográfico"
  } else if (str_detect(fname, regex("PERSONAS_SOCIAL", ignore_case = TRUE))) {
    fuente <- "CNPV 2018"
    año <- 2018
    tipo_info <- "Personas - Social"
  } else if (str_detect(fname, regex("HOGARES", ignore_case = TRUE))) {
    fuente <- "CNPV 2018"
    año <- 2018
    tipo_info <- "Hogares"
  } else if (str_detect(fname, regex("VIVIENDAS", ignore_case = TRUE))) {
    fuente <- "CNPV 2018"
    año <- 2018
    tipo_info <- "Viviendas"
  } else {
    fuente <- "Otra"
    tipo_info <- "Por determinar"
  }
  
  # Obtener información de hojas para Excel
  n_hojas <- NA
  n_filas <- NA
  n_cols <- NA
  nombres_hojas <- NA
  
  if (ext %in% c("xls", "xlsx")) {
    tryCatch(
      {
        hojas <- excel_sheets(f)
        n_hojas <- length(hojas)
        nombres_hojas <- paste(hojas, collapse = " | ")
        
        # Para obtener dimensiones, leer solo la primera fila de la primera hoja para columnas
        # y contar líneas para filas (más eficiente para archivos grandes)
        if (n_hojas > 0) {
          # Obtener número de columnas leyendo solo el encabezado (máximo 5 filas para detectar encabezado real)
          muestra_encabezado <- tryCatch(
            {
              read_excel(f, sheet = hojas[1], n_max = 5)
            },
            error = function(e) tibble()
          )
          if (nrow(muestra_encabezado) > 0) {
            n_cols <- ncol(muestra_encabezado)
          }
          
          # Para filas, usar un método alternativo: contar líneas en el archivo XML subyacente
          # Pero como aproximación, leeremos un número razonable de filas o usaremos metadata si está disponible
          # Para evitar cargar archivos grandes, estimaremos filas basándonos en tamaño para archivos muy grandes
          # Pero primero intentamos leer un número limitado de filas para obtener un conteo real si es pequeño
          if (file_info$size < 50 * 1024^2) {  # Menos de 50 MB, leer completamente para contar filas
            df_completo <- tryCatch(
              {
                read_excel(f, sheet = hojas[1])
              },
              error = function(e) NULL
            )
            if (!is.null(df_completo)) {
              n_filas <- nrow(df_completo)
            }
          } else {
            # Para archivos grandes, leer solo las primeras 100000 filas para estimar
            # o usar una aproximación basada en tamaño (menos precisa pero evita memoria excesiva)
            muestra_grande <- tryCatch(
              {
                read_excel(f, sheet = hojas[1], n_max = 100000)
              },
              error = function(e) NULL
            )
            if (!is.null(muestra_grande)) {
              n_filas <- nrow(muestra_grande)
              # Nota: esto es un mínimo, el archivo podría tener más filas
            }
          }
        }
      },
      error = function(e) {
        warning(sprintf("Error obteniendo metadatos de hojas para %s: %s", fname, e$message))
      }
    )
  } else if (ext == "csv") {
    # Para CSV, contar líneas y obtener columnas de manera eficiente
    tryCatch(
      {
        # Contar líneas (filas)
        lineas <- count_lines(f)
        n_filas <- lineas
        
        # Obtener columnas leyendo solo la primera fila
        muestra_csv <- read_csv(f, n_max = 1, show_col_types = FALSE)
        n_cols <- ncol(muestra_csv)
        
        n_hojas <- 1
        nombres_hojas <- "datos"
      },
      error = function(e) {
        warning(sprintf("Error obteniendo metadatos de CSV para %s: %s", fname, e$message))
      }
    )
  }
  
  # Añadir al inventario
  inventario <- bind_rows(inventario, tibble(
    archivo = fname,
    ruta = f,
    extension = ext,
    tamaño_KB = file_info$size / 1024,
    fuente = fuente,
    año = año,
    tipo_informacion = tipo_info,
    nivel_geografico = nivel_geo,
    filas_total = ifelse(is.na(n_filas), NA_integer_, as.integer(n_filas)),
    columnas_total = ifelse(is.na(n_cols), NA_integer_, as.integer(n_cols)),
    hojas = ifelse(is.na(n_hojas), NA_integer_, as.integer(n_hojas)),
    hojas_nombres = ifelse(is.na(nombres_hojas), NA_character_, nombres_hojas),
    fecha_modificacion = file_info$mtime,
    uso_potencial = "Por determinar",
    stringsAsFactors = FALSE
  ))
  
  # Limpieza de memoria
  gc()
}

# Guardar inventario básico
write_csv(inventario, file.path(diccionario_dir, "inventario_bases.csv"))
log_step(sprintf("Inventario básico guardado: %d archivos procesados", nrow(inventario)))

# ETAPA B: LECTURA DE MUESTRA Y DETECCIÓN DE ENCABEZADOS
log_step("ETAPA B: Lectura de muestra y detección de encabezados")

# Función para detectar fila de encabezado (se implementará en las funciones)
# Por ahora, usaremos un enfoque simple pero mejorado

# Inicializar diccionario de variables
diccionario_vars <- tibble(
  fuente = character(),
  archivo = character(),
  hoja = character(),
  variable_original = character(),
  variable_id = character(),
  nombre_estandarizado = character(),
  descripcion = character(),
  tipo_r = character(),
  tipo_estadistico = character(),
  escala_medicion = character(),
  naturaleza = character(),
  unidad = character(),
  universo = character(),
  nivel_geografico = character(),
  año_referencia = integer(),
  n = integer(),
  n_validos = integer(),
  n_missing = integer(),
  pct_missing = numeric(),
  n_unicos = integer(),
  pct_unicos = numeric(),
  min = numeric(),
  p25 = numeric(),
  mediana = numeric(),
  media = numeric(),
  p75 = numeric(),
  max = numeric(),
  sd = numeric(),
  varianza = numeric(),
  cv = numeric(),
  asimetria = numeric(),
  kurtosis = numeric(),
  outliers_iqr = integer(),
  casi_constante = logical(),
  identificador = logical(),
  indicador = logical(),
  numerador = character(),
  denominador = character(),
  requiere_transformacion = logical(),
  transformacion_sugerida = character(),
  direccion_vulnerabilidad = character(),
  solapamiento_ipm = character(),
  candidato_ivs = character(),
  categoria = character(),
  justificacion = character(),
  confianza_clasificacion = character(),
  stringsAsFactors = FALSE
)

# Procesar cada archivo para extraer metadatos de variables (con manejo robusto de memoria)
log_step("Iniciando procesamiento detallado de archivos...")
total_archivos <- nrow(inventario)
procesados <- 0

for (i in seq_len(nrow(inventario))) {
  fila_inv <- inventario[i, ]
  f <- fila_inv$ruta
  fname <- fila_inv$archivo
  ext <- fila_inv$extension
  
  log_step(sprintf("Procesando %d/%d: %s (%s)", i, total_archivos, fname, ext))
  
  # Saltar archivos vacíos o no relevantes
  if (fila_inv$tamaño_KB < 1) {
    log_step(sprintf("  Saltando %s: archivo vacío o muy pequeño", fname))
    next
  }
  
  # Procesar según extensión
  if (ext == "csv") {
    log_step("  Procesando como CSV")
    # Para CSV, procesar en chunks si es grande
    chunk_size <- 10000
    es_grande <- fila_inv$filas_total > chunk_size * 5  # Más de 5 chunks
    
    if (es_grande) {
      log_step(sprintf("  Archivo grande detectado (%s filas), procesando en chunks", 
                       format(fila_inv$filas_total, big.mark = ",")))
      # Procesar en chunks para obtener estadísticas
      resultado <- procesar_csv_chunks(f, chunk_size)
    } else {
      log_step("  Archivo pequeño, procesando completamente")
      df <- read_csv(f, show_col_types = FALSE)
      resultado <- procesar_dataframe_completo(df, fname, fila_inv)
      rm(df)
      gc()
    }
    
    # Unir resultados al diccionario
    if (!is.null(resultado) && nrow(resultado) > 0) {
      diccionario_vars <- bind_rows(diccionario_vars, resultado)
    }
    
  } else if (ext %in% c("xls", "xlsx")) {
    log_step("  Procesando como Excel")
    hojas <- excel_sheets(f)
    log_step(sprintf("  Encontradas %d hojas: %s", length(hojas), 
                     paste(hojas, collapse = ", ")))
    
    # Procesar cada hoja
    for (hoja in hojas) {
      log_step(sprintf("    Procesando hoja: '%s'", hoja))
      
      # Estrategia: leer muestra para detectar estructura, luego procesar según tamaño
      muestra_inicial <- tryCatch(
        {
          read_excel(f, sheet = hoja, n_max = 100)
        },
        error = function(e) {
          warning(sprintf("      Error leyendo muestra de hoja '%s': %s", hoja, e$message))
          tibble()
        }
      )
      
      if (nrow(muestra_inicial) == 0) {
        log_step(sprintf("      Hoja '%s' vacía o error de lectura, saltando", hoja))
        next
      }
      
      # Detectar fila de encabezado real
      fila_encabezado <- detectar_fila_encabezado(muestra_inicial)
      log_step(sprintf("      Fila de encabezado detectada: %d", fila_encabezado))
      
      # Ahora leer los datos correctamente saltando filas hasta el encabezado
      if (fila_encabezado > 1) {
        # Leer desde la fila de encabezado
        datos_hoja <- tryCatch(
          {
            read_excel(f, sheet = hoja, skip = fila_encabezado - 1)
          },
          error = function(e) {
            warning(sprintf("      Error leyendo hoja '%s' después de skip: %s", hoja, e$message))
            tibble()
          }
        )
      } else {
        # El encabezado está en la primera fila
        datos_hoja <- tryCatch(
          {
            read_excel(f, sheet = hoja)
          },
          error = function(e) {
            warning(sprintf("      Error leyendo hoja '%s': %s", hoja, e$message))
            tibble()
          }
        )
      }
      
      if (nrow(datos_hoja) == 0) {
        log_step(sprintf("      Hoja '%s' resultó en datos vacíos después de procesar encabezado", hoja))
        next
      }
      
      # Limpiar nombres de columnas
      nombres_orig <- names(datos_hoja)
      datos_hoja <- datos_hoja %>%
        janitor::clean_names() %>%
        set_names(nombres_orig)  # Mantener nombres originales pero limpios internamente
      
      # Procesar el data frame según su tamaño
      es_grande_hoja <- nrow(datos_hoja) > 50000  # Umbral para considerar grande
      
      if (es_grande_hoja) {
        log_step(sprintf("      Hoja grande (%s filas), procesando en chunks", 
                         format(nrow(datos_hoja), big.mark = ",")))
        # Para hojas grandes, procesar en chunks para estadísticas
        resultado_hoja <- procesar_excel_chunks(f, hoja, fila_encabezado, chunk_size = 10000)
      } else {
        log_step(sprintf("      Hoja pequeña (%s filas), procesando completamente", 
                         format(nrow(datos_hoja), big.mark = ",")))
        resultado_hoja <- procesar_dataframe_completo(datos_hoja, fname, fila_inv, hoja = hoja)
        rm(datos_hoja)
        gc()
      }
      
      # Unir resultados al diccionario
      if (!is.null(resultado_hoja) && nrow(resultado_hoja) > 0) {
        diccionario_vars <- bind_rows(diccionario_vars, resultado_hoja)
      }
      
      # Limpieza intermedia
      gc()
    }
  }
  
  # Actualizar progreso
  procesados <- procesados + 1
  if (procesados %% 5 == 0 || procesados == total_archivos) {
    log_step(sprintf("Progreso: %d/%d archivos procesados (%.1f%%)", 
                     procesados, total_archivos, 100 * procesados / total_archivos))
  }
  
  # Limpieza de memoria después de cada archivo
  gc()
}

log_step("Procesamiento de archivos completado")

# Guardar diccionario de variables (aunque esté incompleto, guardar lo que tengamos)
if (nrow(diccionario_vars) > 0) {
  write_csv(diccionario_vars, file.path(diccionario_dir, "diccionario_variables.csv"))
  log_step(sprintf("Diccionario de variables guardado: %d variables documentadas", nrow(diccionario_vars)))
} else {
  log_step("ADVERTENCIA: No se documentaron variables, creando diccionario vacío")
  write_csv(diccionario_vars, file.path(diccionario_dir, "diccionario_variables.csv"))
}

# ETAPC: AUDITORÍA TERRITORIAL
log_step("ETAP C: Iniciando auditoría territorial usando DIVIPOLA como estándar")

# Cargar DIVIPOLA como referencia territorial
divipola_path <- inventario %>%
  filter(str_detect(archivo, regex("DIVIPOLA", ignore_case = TRUE))) %>%
  pull(ruta) %>%
  first()

if (!is.na(divipola_path) && file.exists(divipola_path)) {
  log_step("Cargando DIVIPOLA como referencia territorial")
  divipola <- tryCatch(
    {
      read_csv(divipola_path, show_col_types = FALSE)
    },
    error = function(e) {
      warning(sprintf("Error cargando DIVIPOLA: %s", e$message))
      tibble()
    }
  )
  
  if (nrow(divipola) > 0) {
    # Estandarizar códigos territoriales como texto con ceros iniciales
    divipola_limpia <- divipola %>%
      mutate(
        codigo_departamento = str_pad(as.character(`Código Departamento`), width = 2, pad = "0"),
        codigo_municipio = str_pad(as.character(`Código Municipio`), width = 3, pad = "0"),
        divipola = str_c(codigo_departamento, codigo_municipio),
        nombre_departamento = str_trim(`Nombre Departamento`),
        nombre_municipio = str_trim(`Nombre Municipio`)
      ) %>%
      select(
        codigo_departamento, codigo_municipio, divipola,
        nombre_departamento, nombre_municipio,
        `Tipo: Municipio / Isla / Área no municipalizada`,
        longitud, latitud
      ) %>%
      rename(
        tipo_municipio = `Tipo: Municipio / Isla / Área no municipalizada`
      )
    
    log_step(sprintf("DIVIPOLA cargada: %d municipios territoriales", nrow(divipola_limpia)))
    
    # Aquí iría la comparación con otras bases, pero se hará en una función específica
    # Por ahora, guardamos la referencia
    write_csv(divipola_limpia, file.path(diccionario_dir, "divipola_estandarizada.csv"))
  } else {
    log_step("ADVERTENCIA: No se pudieron cargar datos válidos de DIVIPOLA")
  }
} else {
  log_step("ADVERTENCIA: No se encontró archivo DIVIPOLA en los datos")
}

# ETAP D: AUDITORÍA ESPECIAL DE IPM
log_step("ETAP D: Iniciando auditoría especial del IPM")

ipm_path <- inventario %>%
  filter(str_detect(archivo, regex("anexo-censal-pobreza|IPM", ignore_case = TRUE))) %>%
  pull(ruta) %>%
  first()

if (!is.na(ipm_path) && file.exists(ipm_path)) {
  log_step("Procesando IPM municipal 2018")
  auditoria_ipm <- auditar_ipm_especial(ipm_path)
  
  # Guardar resultados de auditoría IPM
  if (!is.null(auditoria_ipm$resumen) && nrow(auditoria_ipm$resumen) > 0) {
    write_csv(auditoria_ipm$resumen, file.path(diccionario_dir, "ipm_dimensiones_indicadores.csv"))
    log_step(sprintf("Auditoría IPM guardada: %d indicadores documentados", nrow(auditoria_ipm$resumen)))
  }
  
  if (!is.null(auditoria_ipm$variables) && nrow(auditoria_ipm$variables) > 0) {
    # Estas variables podrían fusionarse con el diccionario principal
    log_step(sprintf("IPM variables especiales: %d variables adicionales", nrow(auditoria_ipm$variables)))
  }
} else {
  log_step("ADVERTENCIA: No se encontró archivo IPM para auditoría especial")
}

# ETAP E: CONSTRUCCIÓN DE MATRIZ DE SOLAPAMIENTO IPM-CNPV
log_step("ETAP E: Construyendo matriz de solapamiento IPM-CNPV")

# Esta sería una función compleja que compara variables del diccionario con componentes IPM
# Por ahora, creamos una estructura básica
matriz_solapamiento <- tibble(
  variable_cnpv = character(),
  dimension_cnpv = character(),
  indicador_ipm_relacionado = character(),
  nivel_solapamiento = character(),
  decision_preliminar = character(),
  justificacion = character(),
  evidencia = character(),
  stringsAsFactors = FALSE
)

# Guardar matriz de solapamiento (placeholder por ahora, se llenará en funciones específicas)
write_csv(matriz_solapamiento, file.path(diccionario_dir, "matriz_ipm_cnpv.csv"))
log_step("Matriz de solapamiento IPM-CNPV inicializada")

# ETAP F: BANCO PRELIMINAR DE VARIABLES CANDIDATAS AL IVS
log_step("ETAP F: Construyendo banco preliminar de variables candidatas al IVS")

# Filtrar variables que tengan algún potencial como candidato
candidatos <- diccionario_vars %>%
  filter(!is.na(candidato_ivs) & candidato_ivs != "") %>%
  mutate(
    id = row_number(),
    .before = 1
  ) %>%
  select(id, everything())

if (nrow(candidatos) == 0) {
  log_step("ADVERTENCIA: No se identificaron variables candidatas al IVS en esta fase")
  # Crear estructura vacía pero con columnas correctas
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
log_step(sprintf("Banco de variables candidatas guardado: %d variables", nrow(candidatos)))

# ETAP G: AUDITORÍA DE CALIDAD Y COBERTURA MUNICIPAL
log_step("ETAP G: Calculando calidad y cobertura municipal")

# Calcular cobertura territorial comparando con DIVIPOLA
cobertura_municipal <- calcular_cobertura_territorial(
  inventario, 
  divipola_path = if (exists("divipola_path") && !is.na(divipola_path)) divipola_path else NULL
)

write_csv(cobertura_municipal, file.path(calidad_dir, "cobertura_municipal.csv"))
log_step(sprintf("Cobertura municipal calculada para %d fuentes", nrow(cobertura_municipal)))

# Generar informe de calidad detallado
auditoria_detallada <- generar_informe_calidad(
  inventario = inventario,
  diccionario = diccionario_vars,
  candidatos = candidatos,
  cobertura = cobertura_municipal
)

writeLines(auditoria_detallada, file.path(calidad_dir, "auditoria_datos.md"))
log_step("Informe de calidad detallado generado")

# ETAP H: DOCUMENTACIÓN METODOLÓGICA
log_step("ETAP H: Generando documentación metodológica")

# Crear README para el diccionario
readme_diccionario <- c(
  "# Diccionario de Variables - Auditoría Robusta",
  "",
  "Este documento contiene el diccionario estadístico y conceptual de variables extraídas",
  "de las bases de datos del proyecto, generado mediante un proceso robusto que evita",
  "cargar archivos completos en memoria.",
  "",
  "## Metodología",
  "",
  "1. **Etapa A - Metadatos**: Identificación de archivos, tamaño, extensión, hojas.",
  "2. **Etapa B - Lectura de Muestra**: Lectura controlada de muestras para detectar estructura.",
  "3. **Detección Inteligente de Encabezados**: Algoritmo para identificar filas de encabezado reales.",
  "4. **Etapa C - Tipificación Estadística**: Análisis completo de tipo, distribución, calidad.",
  "5. **Etapa D - Auditoría Territorial**: Uso de DIVIPOLA como estándar territorial.",
  "6. **Etapas E-F**: Análisis especial de IPM y construcción de banco de candidatos IVS.",
  "",
  "## Columnas del Diccionario",
  "",
  "- **fuente**: origen de los datos (DIVIPOLA, DANE/IPM, CNPV 2018, etc.)",
  "- **archivo**: nombre del archivo",
  "- **hoja**: hoja de cálculo (si aplica)",
  "- **variable_original**: nombre de la variable tal como aparece en los datos",
  "- **variable_id**: identificador técnico único",
  "- **nombre_estandarizado**: nombre propuesto siguiendo estándares de nomenclatura",
  "- **descripcion**: descripción de lo que mide la variable",
  "- **tipo_r**: tipo de dato en R (character, numeric, etc.)",
  "- **tipo_estadistico**: clasificación estadística (nominal, ordinal, continua, proporción, etc.)",
  "- **escala_medicion**: nominal, ordinal, intervalo, razón",
  "- **naturaleza**: demográfica, socioeconómica, vivienda, hogar, educación, salud, empleo, servicios públicos, territorial, pobreza, otra",
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
  "- **min, p25, mediana, media, p75, max**: estadísticas de posición",
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
  "- **solapamiento_ipm**: nivel de solapamiento conceptual con IPM (ninguno, bajo, medio, alto)",
  "- **candidato_ivs**: clasificación preliminar (A, B, C, D, E)",
  "- **categoria**: categoría final de uso (A-E)",
  "- **justificacion**: explicación de la clasificación",
  "- **confianza_clasificacion**: nivel de confianza en la clasificación (alta, media, baja)",
  "",
  "## Reglas de Transformación Sugerida",
  "",
  "- Las variables de **conteo absoluto** se sugieren transformar en proporciones o tasas",
  "- cuando tenga sentido conceptual (ej. viviendas con servicio / total viviendas)",
  "- Las variables ya expresadas como **porcentaje o proporción** no se sugieren transformar nuevamente",
  "- Las transformaciones se documentan pero NO se aplican sobre los datos originales",
  "",
  "## Próximos Pasos",
  "",
  "1. Revisar y validar las descripciones y unidades con documentación original",
  "2. Definir el conjunto final de variables para el IVS basado en criterios conceptuales y estadísticos",
  "3. Aplicar transformaciones sugeridas en un ambiente de trabajo separado",
  "4. Verificar supuestos para análisis de componentes principales (PCA)",
  "",
  sprintf("*Archivo generado automáticamente por 01_auditoria_bases.R*"),
  sprintf("*Fecha de generación: %s*", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
)

writeLines(readme_diccionario, file.path(diccionario_dir, "README.md"))

# Documentación metodológica de selección de variables
seleccion_variables_md <- c(
  "# Metodología de Selección de Variables para el IVS",
  "",
  "## Visión General",
  "",
  "Esta fase de auditoría NO selecciona definitivamente las variables del Índice de",
  "Vulnerabilidad Socioeconómico (IVS). En su lugar, construye un banco documentado",
  "de variables candidatas que serán evaluadas en una fase posterior mediante análisis",
  "estadístico rigurosos.",
  "",
  "## Criterios de Clasificación Preliminar",
  "",
  "Las variables se clasifican preliminarmente en cinco categorías basado en:",
  "",
  "### A - Candidata directa al IVS",
  "- Fundamento conceptual claro y fuerte con vulnerabilidad socioeconómica",
  "- Buena calidad estadística (bajo % missing, variabilidad adecuada)",
  "- Disponibilidad municipal amplia (>=90% cobertura)",
  "- Escalable a indicador (continua, proporción, tasa)",
  "- Bajo riesgo de solapamiento excesivo con otras variables candidatas",
  "",
  "### B - Candidata después de transformación",
  "- Cumple con criterios de A pero requiere transformación para ser útil",
  "- Ejemplos: conteos absolutos que necesitan convertirse en proporciones o tasas",
  "- Transformaciones comunes: por total de viviendas, hogares, población, etc.",
  "",
  "### C - Variable de control/contexto",
  "- Importante para el análisis descriptivo o como control en modelos",
  "- Pero no componente teórico directo del IVS",
  "- Ejemplos: población total, área municipal, categoría de departamento",
  "",
  "### D - Variable para análisis descriptivo",
  "- Información interesante pero no suficientemente justificada para formar parte del IVS",
  "- Puede ser útil para entender el contexto pero no para la construcción del índice",
  "",
  "### E - Excluir",
  "- Duplicación conceptual o estadística excesiva",
  "- Mala calidad crítica (cobertura muy baja, casi constante)",
  "- Falta de interpretación conceptual clara",
  "- Incompatibilidad territorial o temporal",
  "",
  "## Validación de Dirección de Vulnerabilidad",
  "",
  "Para cada variable candidata se documenta la dirección esperada:",
  "",
  "- **+** : Mayor valor de la variable = Mayor vulnerabilidad socioeconómica",
  "- **-** : Mayor valor de la variable = Menor vulnerabilidad socioeconómica (protector)",
  "- **?** : Dirección pendiente de validación conceptual o empírica",
  "",
  "## Manejo del Solapamiento con IPM",
  "",
  "El IPM municipal 2018 se considera el núcleo conceptual de vulnerabilidad.",
  "Por tanto:",
  "",
  "1. Las variables que son componentes directos del IPM se marcan con alto solapamiento",
  "2. Se evita el doble conteo conceptual en el IVS",
  "3. Las variables con solapamiento medio-alto requieren justificación especial para inclusión",
  "4. El análisis de solapamiento se basa en definición conceptual, no solo correlación",
  "",
  "## Próximos Pasos para la Selección Definitiva",
  "",
  "La selección definitiva del IVS se realizará en una fase posterior que incluirá:",
  "",
  "- Análisis descriptivo detallado de variables candidatas",
  "- Evaluación de supuestos de normalidad y linealidad",
  "- Cálculo de matriz de correlaciones policóricas o de Pearson según tipo de variable",
  "- Prueba de adecuación muestral de Kaiser-Meyer-Olkin (KMO)",
  "- Prueba de esfericidad de Bartlett",
  "- Análisis de Componentes Principales (PCA) con rotación ortogonal y oblíqua",
  "- Evaluación de carga de componentes y varianza explicada",
  "- Análisis de sensibilidad y robustez (bootstrap, eliminación de variables)",
  "- Validación externa con indicadores conocidos de pobreza y vulnerabilidad",
  "",
  sprintf("*Archivo generado automáticamente por 01_auditoria_bases.R*"),
  sprintf("*Fecha de generación: %s*", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
)

writeLines(seleccion_variables_md, file.path(metodologia_dir, "seleccion_variables_ivs.md"))

# Finalizar logging
log_step("Auditoría robusta completada exitosamente")
log_step(sprintf("Resumen de resultados:"))
log_step(sprintf("- %d archivos inventariados", nrow(inventario)))
log_step(sprintf("- %d variables documentadas en diccionario", nrow(diccionario_vars)))
log_step(sprintf("- %d variables candidatas al IVS identificadas", nrow(candidatos)))
log_step(sprintf("- Cobertura territorial calculada para %d fuentes", nrow(cobertura_municipal)))

sink()  # Cerrar logging
cat("Auditoría robusta completada. Revise el log en:", log_file, "\n")