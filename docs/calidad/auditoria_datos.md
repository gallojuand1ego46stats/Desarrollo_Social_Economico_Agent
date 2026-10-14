# Informe de Calidad y Auditoría de Datos

**Fecha de generación:** 2026-09-22 19:37:30

## Resumen Ejecutivo

- **Archivos analizados:** 6
- **Variables documentadas:** 1857
- **Variables candidatas al IVS:** 0
- **Fuentes con cobertura territorial evaluada:** 0

## 1. Inventario de Bases

| Archivo | Fuente | Año | Filas | Columnas | Hojas | Tamaño (KB) |
|---------|--------|-----|-------|----------|-------|-------------|

## 2. Estadísticas del Diccionario de Variables

- **Total de variables:** 1857

### Distribución por Fuente
| Fuente | Cantidad | Porcentaje |
|--------|----------|------------|
| CNPV 2018 | 1765 | 95.0% |
| DANE/IPM | 85 | 4.6% |
| DIVIPOLA | 7 | 0.4% |

### Distribución por Tipo Estadístico
| Tipo Estadístico | Cantidad | Porcentaje |
|------------------|----------|------------|
| nominal | 1525 | 82.1% |
| continua | 327 | 17.6% |
| discreta | 5 | 0.3% |

### Análisis de Valores Perdidos
- **Porcentaje medio de missing:** 11.32%
- **Porcentaje mediano de missing:** 0.15%
- **Máximo porcentaje de missing:** 100.00%
- **Variables con >50% missing:** 220
- **Variables con <=5% missing:** 1573

### Análisis de Variabilidad
- **Variables casi constantes (varianza ≈ 0):** 17
- **Coeficiente de variación medio:** 1170.51%
- **Coeficiente de variación mediano:** 672.99%

### Identificadores y Indicadores Potenciales
- **Variables clasificadas como identificadores:** 352
- **Variables clasificadas como indicadores potenciales:** 362
- **Variables marcadas como ambos (revisar):** 0

### Variables que Requieren Transformación
- **Variables que requieren transformación:** 52
- **Variables que no requieren transformación:** 1805

**Ejemplos de transformación sugerida:**
| Variable Original | Transformación Sugerida |
|-------------------|-------------------------|
| Total | transformacion_por_determinar |
| Total | transformacion_por_determinar |
| Total | transformacion_por_determinar |
| Total | transformacion_por_determinar |
| Total | transformacion_por_determinar |

## 3. Variables Candidatas al IVS

*No se identificaron variables candidatas al IVS en esta fase.*

## 4. Cobertura Territorial

*No se pudo calcular la cobertura territorial.*

## 5. Próximos Pasos Recomendados

1. **Revisión de diccionario:** Completar descripciones y unidades consultando documentación original.
2. **Validación de transformaciones:** Confirmar que las transformaciones sugeridas son estadística y conceptualmente adecuadas.
3. **Análisis de solapamiento IPM-CNPV:** Desarrollar la matriz de solapamiento con información detallada.
4. **Selección preliminar de IVS:** Aplicar los criterios de clasificación para definir el conjunto final de candidatas.
5. **Preparación para análisis estadístico:** Crear base analítica con las transformaciones necesarias y manejo de missing.

--
*Informe generado automáticamente por la función `generar_informe_calidad()`*
*Timestamp: 2026-09-22 19:37:30*
