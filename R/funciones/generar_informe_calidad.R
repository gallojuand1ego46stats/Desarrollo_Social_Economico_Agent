#' Generar informe de calidad detallado
#'
#' @param inventario Tibble con inventario de bases
#' @param diccionario Tibble con diccionario de variables
#' @param candidatos Tibble con variables candidatas al IVS
#' @param cobertura Tibble con cobertura municipal por fuente
#' @return Cadena con el informe en formato markdown
generar_informe_calidad <- function(inventario, diccionario, candidatos, cobertura) {
  lines <- c()
  
  lines <- append(lines, "# Informe de Calidad y Auditoría de Datos")
  lines <- append(lines, "")
  lines <- append(lines, sprintf("**Fecha de generación:** %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
  lines <- append(lines, "")
  
  lines <- append(lines, "## Resumen Ejecutivo")
  lines <- append(lines, "")
  lines <- append(lines, sprintf("- **Archivos analizados:** %d", nrow(inventario)))
  lines <- append(lines, sprintf("- **Variables documentadas:** %d", nrow(diccionario)))
  lines <- append(lines, sprintf("- **Variables candidatas al IVS:** %d", nrow(candidatos)))
  lines <- append(lines, sprintf("- **Fuentes con cobertura territorial evaluada:** %d", nrow(cobertura)))
  lines <- append(lines, "")
  
  lines <- append(lines, "## 1. Inventario de Bases")
  lines <- append(lines, "")
  if (nrow(inventario) > 0) {
    lines <- append(lines, "| Archivo | Fuente | Año | Filas | Columnas | Hojas | Tamaño (KB) |")
    lines <- append(lines, "|---------|--------|-----|-------|----------|-------|-------------|")
    for (i in seq_len(min(nrow(inventario), 20))) {  # Limitar a 20 para no hacer el informe demasiado largo
      fila <- inventario[i, ]
      lines <- append(lines, sprintf("| %s | %s | %s | %s | %s | %s | %s |", 
                                     fila$archivo,
                                     fila$fuente,
                                     ifelse(is.na(fila$año), "NA", as.character(fila$año)),
                                     ifelse(is.na(fila$filas_total), "NA", format(fila$filas_total, big.mark=",")),
                                     ifelse(is.na(fila$columnas_total), "NA", as.integer(fila$columnas_total)),
                                     ifelse(is.na(fila$hojas), "NA", as.integer(fila$hojas)),
                                     format(round(fila$tamaño_KB, 1), big.mark=",")))
    }
    if (nrow(inventario) > 20) {
      lines <- append(lines, sprintf("| ... y %d archivos más | | | | | | |", nrow(inventario) - 20))
    }
  } else {
    lines <- append(lines, "*No se encontraron archivos en el inventario.*")
  }
  lines <- append(lines, "")
  
  lines <- append(lines, "## 2. Estadísticas del Diccionario de Variables")
  lines <- append(lines, "")
  if (nrow(diccionario) > 0) {
    lines <- append(lines, sprintf("- **Total de variables:** %d", nrow(diccionario)))
    
    # Distribución por fuente
    dist_fuente <- diccionario %>% 
      count(fuente, sort = TRUE)
    lines <- append(lines, "")
    lines <- append(lines, "### Distribución por Fuente")
    lines <- append(lines, "| Fuente | Cantidad | Porcentaje |")
    lines <- append(lines, "|--------|----------|------------|")
    for (i in seq_len(nrow(dist_fuente))) {
      fila <- dist_fuente[i, ]
      pct <- round(100 * fila$n / nrow(diccionario), 1)
      lines <- append(lines, sprintf("| %s | %d | %.1f%% |", fila$fuente, fila$n, pct))
    }
    
    # Distribución por tipo estadístico
    dist_tipo <- diccionario %>% 
      count(tipo_estadistico, sort = TRUE)
    lines <- append(lines, "")
    lines <- append(lines, "### Distribución por Tipo Estadístico")
    lines <- append(lines, "| Tipo Estadístico | Cantidad | Porcentaje |")
    lines <- append(lines, "|------------------|----------|------------|")
    for (i in seq_len(min(nrow(dist_tipo), 10))) {
      fila <- dist_tipo[i, ]
      pct <- round(100 * fila$n / nrow(diccionario), 1)
      lines <- append(lines, sprintf("| %s | %d | %.1f%% |", 
                                     ifelse(is.na(fila$tipo_estadistico), "NA", fila$tipo_estadistico),
                                     fila$n, pct))
    }
    if (nrow(dist_tipo) > 10) {
      lines <- append(lines, sprintf("| ... y %d tipos más | | |", nrow(dist_tipo) - 10))
    }
    
    # Calidad de datos: missing
    lines <- append(lines, "")
    lines <- append(lines, "### Análisis de Valores Perdidos")
    missing_stats <- diccionario %>%
      summarise(
        media_missing = mean(pct_missing, na.rm = TRUE),
        mediana_missing = median(pct_missing, na.rm = TRUE),
        max_missing = max(pct_missing, na.rm = TRUE),
        vars_alto_missing = sum(pct_missing > 50, na.rm = TRUE),
        vars_bajo_missing = sum(pct_missing <= 5, na.rm = TRUE)
      )
    lines <- append(lines, sprintf("- **Porcentaje medio de missing:** %.2f%%", missing_stats$media_missing))
    lines <- append(lines, sprintf("- **Porcentaje mediano de missing:** %.2f%%", missing_stats$mediana_missing))
    lines <- append(lines, sprintf("- **Máximo porcentaje de missing:** %.2f%%", missing_stats$max_missing))
    lines <- append(lines, sprintf("- **Variables con >50%% missing:** %d", missing_stats$vars_alto_missing))
    lines <- append(lines, sprintf("- **Variables con <=5%% missing:** %d", missing_stats$vars_bajo_missing))
    
    # Variabilidad
    lines <- append(lines, "")
    lines <- append(lines, "### Análisis de Variabilidad")
    variabilidad <- diccionario %>%
      filter(!is.na(varianza)) %>%
      summarise(
        vars_casi_constante = sum(casi_constante, na.rm = TRUE),
        media_cv = mean(cv, na.rm = TRUE),
        mediana_cv = median(cv, na.rm = TRUE)
      )
    lines <- append(lines, sprintf("- **Variables casi constantes (varianza ≈ 0):** %d", variabilidad$vars_casi_constante))
    if (!is.na(variabilidad$media_cv)) {
      lines <- append(lines, sprintf("- **Coeficiente de variación medio:** %.2f%%", variabilidad$media_cv))
      lines <- append(lines, sprintf("- **Coeficiente de variación mediano:** %.2f%%", variabilidad$mediana_cv))
    }
    
    # Identificadores e indicadores
    lines <- append(lines, "")
    lines <- append(lines, "### Identificadores y Indicadores Potenciales")
    ids <- diccionario %>% 
      summarise(
        identificadores = sum(identificador, na.rm = TRUE),
        indicadores = sum(indicador, na.rm = TRUE),
        ambos = sum(identificador & indicador, na.rm = TRUE)
      )
    lines <- append(lines, sprintf("- **Variables clasificadas como identificadores:** %d", ids$identificadores))
    lines <- append(lines, sprintf("- **Variables clasificadas como indicadores potenciales:** %d", ids$indicadores))
    lines <- append(lines, sprintf("- **Variables marcadas como ambos (revisar):** %d", ids$ambos))
    
    # Necesitan transformación
    lines <- append(lines, "")
    lines <- append(lines, "### Variables que Requieren Transformación")
    trans <- diccionario %>%
      summarise(
        requieren_trans = sum(requiere_transformacion, na.rm = TRUE),
        no_requieren = sum(!requiere_transformacion, na.rm = TRUE)
      )
    lines <- append(lines, sprintf("- **Variables que requieren transformación:** %d", trans$requieren_trans))
    lines <- append(lines, sprintf("- **Variables que no requieren transformación:** %d", trans$no_requieren))
    
    if (trans$requieren_trans > 0) {
      # Mostrar algunos ejemplos
      ej_trans <- diccionario %>%
        filter(requiere_transformacion == TRUE) %>%
        select(variable_original, transformacion_sugerida) %>%
        head(5)
      lines <- append(lines, "")
      lines <- append(lines, "**Ejemplos de transformación sugerida:**")
      lines <- append(lines, "| Variable Original | Transformación Sugerida |")
      lines <- append(lines, "|-------------------|-------------------------|")
      for (j in seq_len(nrow(ej_trans))) {
        fila <- ej_trans[j, ]
        lines <- append(lines, sprintf("| %s | %s |", 
                                       fila$variable_original,
                                       ifelse(is.na(fila$transformacion_sugerida), "NA", fila$transformacion_sugerida)))
      }
    }
    
  } else {
    lines <- append(lines, "*El diccionario de variables está vacío.*")
  }
  
  lines <- append(lines, "")
  lines <- append(lines, "## 3. Variables Candidatas al IVS")
  lines <- append(lines, "")
  if (nrow(candidatos) > 0) {
    lines <- append(lines, sprintf("- **Total de candidatas:** %d", nrow(candidatos)))
    
    # Distribución por categoría
    dist_cat <- candidatos %>%
      count(categoria, sort = TRUE)
    lines <- append(lines, "")
    lines <- append(lines, "### Distribución por Categoría Preliminar")
    lines <- append(lines, "| Categoría | Cantidad | Porcentaje |")
    lines <- append(lines, "|-----------|----------|------------|")
    for (i in seq_len(nrow(dist_cat))) {
      fila <- dist_cat[i, ]
      pct <- round(100 * fila$n / nrow(candidatos), 1)
      lines <- append(lines, sprintf("| %s | %d | %.1f%% |", fila$categoria, fila$n, pct))
    }
    
    # Distribución por fuente
    dist_fuente_cand <- candidatos %>%
      count(fuente, sort = TRUE)
    lines <- append(lines, "")
    lines <- append(lines, "### Distribución por Fuente")
    lines <- append(lines, "| Fuente | Cantidad | Porcentaje |")
    lines <- append(lines, "|--------|----------|------------|")
    for (i in seq_len(nrow(dist_fuente_cand))) {
      fila <- dist_fuente_cand[i, ]
      pct <- round(100 * fila$n / nrow(candidatos), 1)
      lines <- append(lines, sprintf("| %s | %d | %.1f%% |", fila$fuente, fila$n, pct))
    }
    
    # Dirección de vulnerabilidad
    dir_vuln <- candidatos %>%
      count(direccion_vulnerabilidad, sort = TRUE)
    lines <- append(lines, "")
    lines <- append(lines, "### Dirección de Vulnerabilidad")
    lines <- append(lines, "| Dirección | Cantidad | Porcentaje |")
    lines <- append(lines, "|-----------|----------|------------|")
    for (i in seq_len(nrow(dir_vuln))) {
      fila <- dir_vuln[i, ]
      pct <- round(100 * fila$n / nrow(candidatos), 1)
      lines <- append(lines, sprintf("| %s | %d | %.1f%% |", 
                                     ifelse(is.na(fila$direccion_vulnerabilidad), "NA", fila$direccion_vulnerabilidad),
                                     fila$n, pct))
    }
    
    # Solapamiento con IPM
    solap <- candidatos %>%
      count(solapamiento_ipm, sort = TRUE)
    lines <- append(lines, "")
    lines <- append(lines, "### Solapamiento con IPM")
    lines <- append(lines, "| Nivel de Solapamiento | Cantidad | Porcentaje |")
    lines <- append(lines, "|-----------------------|----------|------------|")
    for (i in seq_len(nrow(solap))) {
      fila <- solap[i, ]
      pct <- round(100 * fila$n / nrow(candidatos), 1)
      lines <- append(lines, sprintf("| %s | %d | %.1f%% |", 
                                     ifelse(is.na(fila$solapamiento_ipm), "NA", fila$solapamiento_ipm),
                                     fila$n, pct))
    }
    
  } else {
    lines <- append(lines, "*No se identificaron variables candidatas al IVS en esta fase.*")
  }
  
  lines <- append(lines, "")
  lines <- append(lines, "## 4. Cobertura Territorial")
  lines <- append(lines, "")
  if (nrow(cobertura) > 0) {
    lines <- append(lines, "| Fuente | Municipios en Fuente | Coinciden con DIVIPOLA | No Coinciden | Duplicados | Cobertura % |")
    lines <- append(lines, "|--------|----------------------|------------------------|--------------|------------|-------------|")
    for (i in seq_len(nrow(cobertura))) {
      fila <- cobertura[i, ]
      lines <- append(lines, sprintf("| %s | %d | %d | %d | %d | %.2f%% |", 
                                     fila$fuente,
                                     fila$municipios,
                                     fila$coinciden_divipola,
                                     fila$no_coinciden,
                                     fila$duplicados,
                                     fila$cobertura_pct))
    }
    
    # Resumen de cobertura
    lines <- append(lines, "")
    lines <- append(lines, "### Resumen de Cobertura Territorial")
    cobertura_resumen <- cobertura %>%
      summarise(
        media_cobertura = mean(cobertura_pct, na.rm = TRUE),
        mediana_cobertura = median(cobertura_pct, na.rm = TRUE),
        min_cobertura = min(cobertura_pct, na.rm = TRUE),
        max_cobertura = max(cobertura_pct, na.rm = TRUE),
        fuentes_baja_cobertura = sum(cobertura_pct < 80, na.rm = TRUE),
        fuentes_alta_cobertura = sum(cobertura_pct >= 95, na.rm = TRUE)
      )
    lines <- append(lines, sprintf("- **Cobertura media:** %.2f%%", cobertura_resumen$media_cobertura))
    lines <- append(lines, sprintf("- **Cobertura mediana:** %.2f%%", cobertura_resumen$mediana_cobertura))
    lines <- append(lines, sprintf("- **Rango de cobertura:** %.2f%% - %.2f%%", 
                                   cobertura_resumen$min_cobertura, cobertura_resumen$max_cobertura))
    lines <- append(lines, sprintf("- **Fuentes con cobertura <80%%:** %d", cobertura_resumen$fuentes_baja_cobertura))
    lines <- append(lines, sprintf("- **Fuentes con cobertura ≥95%%:** %d", cobertura_resumen$fuentes_alta_cobertura))
    
  } else {
    lines <- append(lines, "*No se pudo calcular la cobertura territorial.*")
  }
  
  lines <- append(lines, "")
  lines <- append(lines, "## 5. Próximos Pasos Recomendados")
  lines <- append(lines, "")
  lines <- append(lines, "1. **Revisión de diccionario:** Completar descripciones y unidades consultando documentación original.")
  lines <- append(lines, "2. **Validación de transformaciones:** Confirmar que las transformaciones sugeridas son estadística y conceptualmente adecuadas.")
  lines <- append(lines, "3. **Análisis de solapamiento IPM-CNPV:** Desarrollar la matriz de solapamiento con información detallada.")
  lines <- append(lines, "4. **Selección preliminar de IVS:** Aplicar los criterios de clasificación para definir el conjunto final de candidatas.")
  lines <- append(lines, "5. **Preparación para análisis estadístico:** Crear base analítica con las transformaciones necesarias y manejo de missing.")
  lines <- append(lines, "")
  
  lines <- append(lines, "--")
  lines <- append(lines, sprintf("*Informe generado automáticamente por la función `generar_informe_calidad()`*"))
  lines <- append(lines, sprintf("*Timestamp: %s*", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
  
  return(paste(lines, collapse = "\n"))
}