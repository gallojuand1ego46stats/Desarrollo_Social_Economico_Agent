# Handoff consolidado — Desarrollo Social Económico

> Consolidación actualizada al 2026-10-01 con el avance informado por el autor y la documentación/archivos locales. Los libros Excel no se reabrieron ni se recalcularon sus estadísticas en esta actualización.

## 1. Resumen Ejecutivo

El repositorio contiene un proyecto universitario de análisis territorial y estadístico. La pregunta documentada es si la distribución de la contratación pública se corresponde con la vulnerabilidad socioeconómica municipal en Colombia. El bloque de vulnerabilidad usa insumos DANE/IPM, CNPV 2018 y DIVIPOLA; el análisis de SECOP II, la construcción del índice sintético y la asociación son objetivos metodológicos, no productos verificables en el código actual.

El autor informa que revisó manualmente las seis bases del proyecto, seleccionó hojas municipales con variables candidatas y reunió los datos seleccionados en `datos/CUADROS_MUNICIPALES_UNIDOS.xlsx`. También organizó el IPM en `datos/IPM_2018_organizado_region.xlsx` y documentó las decisiones en `docs/diccionario/decisiones_variables_IVS_CNPV2018.csv`. Los tres archivos existen. La siguiente fase es derivar indicadores comparables y validar una matriz para PCA; no consta que el IVS ya se haya construido o validado. **Estado recomendado:** avanzar desde selección/auditoría hacia la preparación reproducible de indicadores, manteniendo trazabilidad.

> Fuente: Mixto

## 2. Objetivos

**Objetivo documentado:** estudiar la correspondencia entre contratación pública y vulnerabilidad socioeconómica a escala municipal y caracterizar posibles brechas territoriales. El alcance es descriptivo/asociativo; los resúmenes excluyen inferencia causal.

**Objetivos de trabajo que aparecen en los documentos de transferencia:** auditar y armonizar insumos territoriales y socioeconómicos; documentar y tipificar variables; evaluar un IVS basado en PCA; construir indicadores SECOP II por municipio/año; analizar asociación y correspondencia; considerar análisis espacial solo tras diagnóstico. Son objetivos del proyecto, no etapas cuya implementación esté acreditada por el repositorio.

La selección manual de hojas/variables candidatas ya está documentada, pero aún falta cerrar qué variables derivadas integrarán la matriz analítica final del IVS. No se halló en el código inspeccionado una implementación de indicadores, PCA, bootstrap, muestreo SECOP II, permutaciones, clustering o dashboard.

> Fuente: Mixto

## 3. Estado Actual

| Componente | Evidencia local | Estado consolidado |
|---|---|---|
| Revisión y selección manual de las seis bases | Reporte del autor; consolidado y tabla de decisiones presentes | Completado según el autor; no repetí la inspección de las seis fuentes originales |
| Hojas CNPV candidatas | `datos/CUADROS_MUNICIPALES_UNIDOS.xlsx` | Archivo presente; hojas y dimensiones no revalidadas en esta actualización |
| IPM organizado | `datos/IPM_2018_organizado_region.xlsx` | Archivo presente; estructura y conteos no revalidados en esta actualización |
| Decisiones de selección | `docs/diccionario/decisiones_variables_IVS_CNPV2018.csv` | Presente; registra decisiones, motivos y notas de verificación |
| Auditoría de fuentes | Scripts en `R/`, diccionarios y documentación de calidad | Hay artefactos; ejecución/completitud actual no recalculada |
| Lectura de Excel grande por chunks | Función `procesar_excel_chunks()` en `R/funciones/auditoria_archivos.R` | No hace chunks: lee la hoja completa con `read_excel()` |
| Variante v2 | Conversión XLSX→CSV y procesamiento incremental del CSV en `R/funciones/auditoria_archivos_v2.R` | El CSV se genera después de cargar completa la hoja Excel; no resuelve la lectura XLSX con memoria acotada |
| Diccionarios | Hay CSV globales y directorios/archivos por fuente bajo `docs/diccionario/` | Existen; completitud y actualidad de cada contenido deben revisarse antes de usarlos como fuente analítica |
| SECOP II | No se encontraron archivos SECOP en `datos/` ni un pipeline SECOP en los archivos listados | No verificable como implementado; auditoría, ventana y panel pendientes |
| Indicadores y PCA/IVS | No se encontraron scripts de implementación en los archivos revisados | Siguiente etapa; construcción, adecuación, PCA y validación pendientes |
| Pruebas automatizadas | No se encontraron `tests/`, `testthat/` ni configuración equivalente | No constatadas |

El diagnóstico `docs/calidad/DIAGNOSTICO_ESTADO_ACTUAL.md` es del 2026-09-22 y reporta procesamiento parcial de las fuentes originales; es anterior a la selección manual y consolidación aquí informadas. La tabla de decisiones registra como incluidas 2 hojas de HOGARES, 1 de PERSONAS_DEMOGRAFICO, 1 de PERSONAS_SOCIAL y 3 de VIVIENDAS; 1PM y 1V_MPIO figuran como contexto. También marca 14 variables IPM como incluidas y 2 para validación. Son estados consignados en el CSV, no una auditoría independiente de valores.

> Fuente: Verificado en repo

## 4. Arquitectura

### Inventario de carpetas

```text
.
├── .github/                  # workflows/configuración GitHub
├── datos/                    # insumos locales (README: ignorados al publicar)
├── docs/
│   ├── calidad/
│   ├── diccionario/
│   │   ├── divipola/ hogares/ ipm/
│   │   ├── personas_demografico/ personas_social/ viviendas/
│   └── metodologia/
├── R/
│   └── funciones/
├── resultados/               # placeholder local
├── src/                      # solo .gitkeep observado
└── temp/                     # checkpoints y csv_intermediate presentes
```

Se excluyeron `.git`, `.venv` y las carpetas excluidas por la tarea (`node_modules`, `__pycache__`, `dist`, `build`). No se detectaron estas últimas en la estructura listada. Entre los archivos de raíz están `README.md`, `SECURITY.md`, `mkdocs.yml` y `requirements.txt`.

### Lenguajes, configuración y entrypoints

- **R:** lenguaje del pipeline de auditoría; scripts bajo `R/` y `R/funciones/`.
- **Python:** utilidades auxiliares en `temp/`; no se encontró configuración Python de proyecto (`pyproject.toml`/`requirements.txt` de Python) ni evidencia de que sea el pipeline principal.
- **Documentación:** MkDocs Material (`mkdocs.yml`; `requirements.txt` declara `mkdocs-material>=9.5`).
- **Entrypoint candidato:** `R/01_auditoria_bases.R` se identifica a sí mismo como script principal y carga las funciones de `R/funciones/`. Existe también `R/01_auditoria_bases_v2.R`; no se encontró configuración que establezca cuál reemplaza al otro.
- No se encontraron `package.json`, `pyproject.toml`, `DESCRIPTION`, `renv.lock`, `Makefile` o directorio `tests/`.

### Flujo respaldado

El código de auditoría inventaría archivos de `datos/`, procesa metadatos y hojas, y genera diccionarios/salidas de calidad. El flujo actualizado es: fuentes revisadas → hojas candidatas en `CUADROS_MUNICIPALES_UNIDOS.xlsx` + IPM organizado → decisiones documentadas → pendiente derivar indicadores → validar matriz → PCA/IVS. SECOP II y análisis posteriores siguen siendo fases no verificadas como implementadas.

> Fuente: Verificado en repo

## 5. Decisiones Técnicas (ADRs)

| Decisión / criterio | Evidencia y estado |
|---|---|
| Usar R para el análisis estadístico y mantener R como implementación principal | Los scripts de auditoría están en R; consistente con ambos resúmenes. R/RStudio instalado y versión exacta: no verificados. |
| Mantener la estructura actual (`datos/`, `R/`, `docs/`, `resultados/`) | Estructura real y README respaldan estas rutas. Los datos y resultados se describen como no publicables en README/SECURITY. |
| Auditar y tipificar antes de cerrar selección de variables/PCA | Está en los resúmenes y en `docs/metodologia/seleccion_variables_ivs.md`; decisión metodológica, no resultado analítico ejecutado. |
| DIVIPOLA como referencia de claves territoriales | Hay archivo CSV DIVIPOLA, código y documentación de auditoría territorial. Su cobertura efectiva no se recalculó aquí. |
| Selección manual de hojas candidatas antes de derivar indicadores | Informado por el autor y reflejado en el consolidado y `decisiones_variables_IVS_CNPV2018.csv`; la selección no significa que los campos ya sean indicadores finales. |
| No llamar “chunking de Excel” a una lectura completa | Verificado directamente en las funciones R. La variante v2 lee toda la hoja para crear CSV y luego sí procesa ese CSV por chunks. |
| Diseño del eje SECOP II | Muestreo estratificado, período exploratorio 2015–2025 y métodos posteriores aparecen en el resumen Claude, pero no hay implementación local que los confirme. Se conservan como propuesta metodológica, no ADR de software aceptada/verificada. |

No se revisó historial de commits ni decisiones formales tipo ADR. Por tanto, autoría, fecha y aprobación de decisiones metodológicas no se pueden determinar desde la evidencia examinada.

> Fuente: Mixto

## 6. Fragmentos Clave de Código

Los siguientes son fragmentos **copiados del código real** (se omiten bloques largos); no se ejecutaron.

### Punto de entrada y carga de funciones — `R/01_auditoria_bases.R`

```r
funciones <- list.files(funciones_dir, pattern = "\\.R$", full.names = TRUE)
for (f in funciones) {
  source(f, echo = FALSE)
}
```

El script recorre todos los `.R` de `R/funciones/`, así que la disponibilidad y coexistencia de variantes de funciones en esa carpeta importa.

### Lectura denominada chunks — `R/funciones/auditoria_archivos.R`

```r
procesar_excel_chunks <- function(file_path, hoja, fila_encabezado, chunk_size = 10000) {
  # ...
  df <- tryCatch(
    read_excel(file_path, sheet = hoja, skip = fila_encabezado - 1),
    error = function(e) {
      warning(sprintf("Error leyendo hoja '%s': %s", hoja, e$message))
      return(NULL)
    }
  )
```

La implementación carga la hoja completa. En `auditoria_archivos_v2.R`, `excel_sheet_to_csv()` también hace `read_excel()` completo y `fwrite()`; después `procesar_csv_chunks_real()` lee el CSV en bloques. Por ello, el procesamiento incremental del CSV no significa lectura XLSX incremental.

### Limitación de inventario del entrypoint

En `R/01_auditoria_bases.R`, el conteo de filas para Excel grande está limitado a una muestra de hasta 100.000 filas (comentada como mínimo/estimación); no debe citarse como conteo total. El script escribe inventario, diccionario, matriz de solapamiento, candidatos y cobertura; esto acredita capacidad prevista de salida, no que todas esas salidas estén completas.

> Fuente: Verificado en repo

## 7. Stack y Dependencias

| Elemento | Verificación |
|---|---|
| R | Código fuente principal. Versión no fijada en archivos de configuración encontrados. |
| Paquetes R | Scripts usan, entre otros, `readxl`, `readr`, `dplyr`, `tidyr`, `stringr`, `purrr`, `janitor`, `tibble`, `lubridate` y en v2 `data.table`. No hay manifiesto R con versiones fijadas. |
| Python | Scripts auxiliares de inspección/debug en `temp/`; versiones y dependencias no declaradas. |
| MkDocs Material | `requirements.txt`: `mkdocs-material>=9.5`; MkDocs configurado en `mkdocs.yml`. |
| Instalación / ejecución / pruebas | No se encontró comando canónico declarado en `Makefile`, scripts de paquetes o README. El entrypoint R candidato es `R/01_auditoria_bases.R`; ejecución no probada. |

> Fuente: Verificado en repo

## 8. Datos y Pipelines

### Archivos presentes localmente en `datos/`

Se listaron estos insumos: `anexo-censal-pobreza-municipal-2018.xlsx`, `CUADROS_MUNICIPALES_UNIDOS.xlsx`, `DIVIPOLA-_Códigos_municipios_20260917.csv`, `HOGARES_Cuadros_CNPV_2018.XLSX`, `PERSONAS_DEMOGRAFICO_Cuadros_CNPV_2018.xlsx`, `PERSONAS_SOCIAL_Cuadros_CNPV_2018.XLSX`, `VIVIENDAS_Cuadros_CNPV_2018.XLSX`, `IPM_2018_organizado_region.xlsx` e `Indices de bases y filas.xlsx`. README indica que `datos/` no se sube a GitHub. Los dos libros consolidados están presentes por nombre; sus hojas, dimensiones y llaves no se revalidaron leyendo su contenido.

El diagnóstico local del 2026-09-22 reporta las seis bases fuente y dimensiones/estado de procesamiento; esas magnitudes son **reportadas por el diagnóstico**, no recalculadas. El archivo `IPM_2018_organizado_region.xlsx` sí está presente. El CSV de decisiones registra la hoja principal `IPM_municipios_region`, 14 indicadores seleccionados, y `IPM Municipal` como criterio de validación (no como insumo para evitar circularidad). Las cifras y los contenidos del libro no se revalidaron aquí.

### Productos documentales y SECOP

Hay CSV globales y por fuente en `docs/diccionario/`, además de `docs/calidad/cobertura_municipal.csv` y reportes/logs. SECOP II, Parquet trimestrales, fuente de población per cápita y datos TerriData no se encontraron en los archivos listados. Cifras como 7,827,129 contratos/59 campos y el rango 2015–2025 son afirmaciones del resumen Claude que quedan **sin verificación local**.

### Flujo

**Avance actual:** inspección manual de seis bases, selección de hojas/variables candidatas, consolidación CNPV y organización del IPM, con decisiones documentadas. **Pendiente:** verificar claves/cobertura de los consolidados → derivar tasas/proporciones comparables → validar variables/dirección/missing/colinealidad → matriz analítica → adecuación y PCA → validación del IVS. Después: SECOP II, integración municipio-año y análisis de asociación/correspondencia; análisis espacial solo si el diagnóstico lo justifica.

> Fuente: Mixto

## 9. Testing

No se localizaron archivos o configuración de pruebas automatizadas ni comando de test. Los casos sugeridos en ambos resúmenes (hojas grandes, encabezados irregulares, cobertura DIVIPOLA, estadísticas de muestreo, bootstrap y permutaciones) son propuestas, no pruebas existentes. No se ejecutó ningún script ni test en esta consolidación; cobertura y reproducibilidad de ejecución quedan sin verificar.

> Fuente: Verificado en repo

## 10. Deuda Técnica y TODOs

- Confirmar que el consolidado CNPV y el IPM organizado contienen las hojas previstas, llaves municipales consistentes, datos completos y sin duplicados inesperados.
- Derivar indicadores a nivel municipal a partir de numeradores/denominadores explícitos; evitar alimentar el PCA con conteos absolutos cuando sean proporciones o tasas las magnitudes comparables.
- Validar dirección de vulnerabilidad, datos faltantes, cobertura, outliers, transformaciones y redundancia con IPM antes de congelar la matriz.
- Reemplazar o documentar con claridad la falsa lectura por chunks de XLSX; es una deuda para volver a procesar fuentes originales grandes, no un bloqueo para trabajar sobre el consolidado ya preparado.
- Confirmar cuál entrypoint/variante se mantiene y retirar duplicados solo tras revisar su lógica.
- Actualizar el diagnóstico de calidad anterior a la revisión manual para que no presente como actual el procesamiento parcial previo.
- Establecer entorno R reproducible y versiones; no hay `renv.lock`/`DESCRIPTION` encontrado.
- Añadir pruebas automatizadas y comandos de ejecución documentados.
- Confirmar universo municipal y criterios de cobertura en ambos archivos consolidados.
- Incorporar/ubicar y auditar SECOP II; fijar ventana temporal a partir de evidencia.
- Definir origen/año del denominador per cápita y decidir compatibilidad de variables complementarias.
- Documentar decisiones metodológicas de muestreo, bootstrap, permutación, correspondencia y dependencia espacial; actualmente constan en el resumen Claude, sin respaldo de implementación local.

> Fuente: Mixto

## 11. Próximos Pasos

### Cerebro documental con Obsidian

Recomiendo iniciar un vault en `docs/obsidian/` y usar Markdown como fuente principal, enlazando los documentos existentes en lugar de duplicarlos. Mantener `Resumen_General.md`, decisiones, metodología y reportes como notas canónicas; no copiar bases Excel ni datos sensibles al vault. Crear una portada (`Inicio.md`) con enlaces a objetivos, inventario de datos, decisiones IVS, diccionario, pipeline, resultados y pendientes. Usar notas por fuente/hoja, una nota por decisión metodológica y una bitácora fechada de cambios/ejecuciones. Antes de sincronizar el vault, revisar qué archivos se publican por GitHub y qué carpetas locales ignora `.gitignore`.

### Indicadores y PCA

1. **Fijar esquema y llave:** listar hojas y columnas de `CUADROS_MUNICIPALES_UNIDOS.xlsx` e `IPM_2018_organizado_region.xlsx`; identificar código municipal, nombre, universo y año. Normalizar código DIVIPOLA como texto de longitud fija y comprobar unicidad/cobertura en ambos.
2. **Congelar catálogo candidato:** convertir `decisiones_variables_IVS_CNPV2018.csv` en una tabla de especificación con concepto, hoja/variable fuente, numerador, denominador, unidad, dirección esperada, regla de faltantes, solapamiento IPM y decisión. Resolver filas `CONTEXTO`, `VALIDACIÓN` y `verificar` antes de incluirlas en PCA.
3. **Derivar indicadores:** calcular por municipio proporciones/tasas desde conteos municipales y denominadores válidos. Guardar código reproducible, valores fuente, fórmula, denominador cero y criterio de faltantes. No promediar porcentajes de subgrupos sin ponderación apropiada. Evaluar solapamiento (p. ej., 8V con agua/alcantarillado IPM) según la nota de decisiones.
4. **Validar la matriz:** una fila por municipio y una columna por indicador; comprobar dimensiones, unicidad, cobertura, rangos, faltantes, variabilidad y correlaciones. Revisar transformaciones para distribuciones muy asimétricas y estandarizar el sentido para que valores mayores representen mayor vulnerabilidad; justificar excepciones como envejecimiento/contexto.
5. **Evaluar adecuación:** documentar tratamiento de faltantes y escala; revisar matriz de correlación, KMO/Bartlett si corresponde y colinealidad. Decidir y registrar criterio de retención (scree/parallel analysis y varianza explicada como evidencia complementaria); no aceptar PCA solo porque el cálculo corre.
6. **Estimar e interpretar PCA:** centrar/escalar según la definición de indicadores; guardar cargas, eigenvalues, varianza explicada, scores municipales y versión de datos/código. Orientar el signo para que score alto signifique más vulnerabilidad. Revisar si PC1 representa un constructo interpretable; si no, reconsiderar conjunto o estructura en vez de forzar un índice unidimensional.
7. **Validar y publicar:** contrastar IVS con IPM agregado como validación externa (sin incluir el agregado IPM como predictor si eso crea circularidad), evaluar sensibilidad a variables/missing y estabilidad del ranking, mapear limitaciones. Registrar la versión aprobada en Obsidian y mantener los resultados reproducibles en archivos de salida.
8. **Después del IVS:** recién entonces integrar SECOP II por municipio-año; el IPM/CNPV 2018 es corte transversal y no debe replicarse como si variara anualmente sin una decisión metodológica explícita.

### Recomendación del estado actual

El proyecto avanzó de una auditoría exploratoria a una fase metodológica más concreta: ya existe una selección manual documentada y los datos candidatos están consolidados. La prioridad inmediata no es volver a inspeccionar indiscriminadamente las seis bases ni ejecutar PCA de inmediato; es convertir la selección en un catálogo reproducible de fórmulas, verificar los dos libros consolidados y producir una matriz municipal validada. Obsidian puede ayudar a mantener decisiones, procedencia y bitácora, pero debe enlazar artefactos reproducibles y no convertirse en una copia paralela de los datos. El PCA será defendible cuando cada indicador tenga definición, escala, orientación, cobertura y tratamiento de faltantes explícitos.

El orden y las prioridades metodológicas proceden de los resúmenes y documentos del proyecto; no se verificó planificación con el equipo.

> Fuente: Mixto

## 12. Referencias

**Archivos locales verificados:**

- `README.md`, `SECURITY.md`, `requirements.txt`, `mkdocs.yml`.
- `R/01_auditoria_bases.R`, `R/01_auditoria_bases_v2.R` y funciones de `R/funciones/`.
- `docs/metodologia/seleccion_variables_ivs.md`.
- `docs/calidad/DIAGNOSTICO_ESTADO_ACTUAL.md`, `docs/calidad/auditoria_datos.md` y registros de auditoría.
- `docs/diccionario/` y subdirectorios por fuente.
- Fuentes de transferencia: `docs/Resumen_GPT.md` y `docs/Resumen_Claude.md`.

README configura el sitio del proyecto en GitHub Pages y apunta al repositorio `gallojuand1ego46stats/Desarrollo_Social_Economico_Agent`. El resumen Claude cita como referencia académica `ustadistica/desarrollo_social_y_economico` y bibliografía extensa; su relación con este repo y las citas bibliográficas no se verificaron en esta auditoría local.

> Fuente: Mixto

## 13. Auditoría de esta consolidación

| Sección | Fuente original | ¿Verificado? | Cambios realizados |
|---|---|---|---|
| 1. Resumen Ejecutivo | Ambos; README y repo | Parcial | Se separó propósito documentado de implementación comprobada. |
| 2. Objetivos | Ambos; metodología local | Parcial | PCA/SECOP/análisis se etiquetaron como objetivos, no como productos. |
| 3. Estado Actual | Autor; tabla de decisiones; archivos y diagnóstico | Sí, con salvedad | Se añadió la revisión manual, el consolidado, el IPM organizado y se preservó la fecha del diagnóstico anterior. |
| 4. Arquitectura | Ambos; inventario actual | Sí | Se sustituyó árbol conceptual por estructura real; se anotó `src/` vacío y ausencia de `tests/`. |
| 5. Decisiones Técnicas | Ambos; código y configuración | Parcial | Se separaron decisiones respaldadas de metodología que solo aparece en Claude. |
| 6. Fragmentos de Código | GPT y código R | Sí | Se reemplazaron snippets conceptuales por ejemplos reales y se explicó el límite XLSX/CSV. |
| 7. Stack y Dependencias | Ambos; scripts/configuración | Sí | Se conservaron solo paquetes vistos en código y la dependencia de MkDocs; versiones R pendientes. |
| 8. Datos y Pipelines | Autor; CSV de decisiones; archivos y docs | Parcial | Se registraron los nuevos archivos y el flujo actualizado; su contenido tabular no se releyó. |
| 9. Testing | Ambos; inventario/configuración | Sí | Se distinguieron pruebas propuestas de pruebas existentes; ninguna ejecutada. |
| 10. Deuda Técnica | Ambos; repo | Parcial | Se priorizaron bloqueos confirmables y pendientes que requieren revisión/equipo. |
| 11. Próximos Pasos | Autor; archivos y metodología | Parcial | Se añadieron propuesta de vault Obsidian, ruta a indicadores/PCA y recomendación de estado. |
| 12. Referencias | Ambos; archivos raíz y docs | Parcial | Se listaron referencias comprobadas; bibliografía externa queda sin validar. |
| 13. Auditoría | Instrucción del usuario y comparación | Sí | Se añadió trazabilidad, discrepancias y lista de pendientes. |

### Discrepancias y resolución

- **Ruta/nombre de resúmenes:** ambos están bajo `docs/`; el nombre observado es `Resumen_Claude.md` (mayúscula inicial), no `Resumen_claude.md`. La estructura indicada por el Paso 6 solicita `Resumen_General.md` en la raíz; se usó ese nombre, aunque el Paso 4 menciona `HANDOFF.md`.
- **Chunking:** GPT afirma que `procesar_excel_chunks()` lee la hoja completa; verificado en `auditoria_archivos.R`. Claude no describe esa implementación. La variante v2 convierte tras leer XLSX completo y hace chunks del CSV, así que se precisó el límite de ambos flujos.
- **Estado de scripts/diccionarios:** Claude dice que scripts y pipeline propio no están confirmados; el inventario actual sí muestra muchos scripts R, diccionarios y reportes. Se resolvió con el estado real, manteniendo la incertidumbre sobre ejecución/completitud.
- **IPM actualizado:** ahora está presente `IPM_2018_organizado_region.xlsx`; la selección documentada incluye 14 indicadores y deja el agregado IPM para validación. Los datos no se recalcularon.
- **Avance de selección:** el autor reporta revisión manual de seis bases, hojas candidatas reunidas en `CUADROS_MUNICIPALES_UNIDOS.xlsx` y criterios documentados. Los nombres y la tabla de decisiones se confirmaron localmente; la inspección manual no se repitió.
- **SECOP II:** metodología y estadísticas de contratos en Claude no tienen archivos de datos ni implementación local identificados; quedan como no verificadas, no como hechos del pipeline.
- **Tests:** no existe evidencia local de suite de pruebas; todos los casos listados en los resúmenes se clasifican como propuestas.
- **Estados detallados de hojas y errores:** se conservan solo como reporte fechado del diagnóstico local, no como estado actual revalidado.

### Pendientes que requieren input humano o evidencia adicional

- Confirmar versión/tag y remoto/branch vigentes, responsables y relación con el repositorio académico citado.
- Confirmar si `R/01_auditoria_bases.R` o la variante v2 es el entrypoint mantenido, y qué scripts legacy siguen en uso.
- Validar dimensiones, llaves y cobertura de los dos libros consolidados y actualizar el diagnóstico de 2026-09-22.
- Definir fórmulas, denominadores, orientación y faltantes de cada indicador; después cerrar matriz y selección final del IVS.
- Decidir implementación y alcance del vault Obsidian, incluido qué se sincroniza/versiona.
- Definir fuentes complementarias y acuerdos metodológicos (muestreo, correspondencia y permutación espacial).
- Proveer o localizar los datos SECOP II, documentar período/diccionario, fuente de población y URLs exactas de datos.
- Fijar versiones del entorno R y estrategia de pruebas.
- Aclarar redacción formal de objetivos y prioridades acordadas por el equipo.

> Fuente: Verificado en repo
