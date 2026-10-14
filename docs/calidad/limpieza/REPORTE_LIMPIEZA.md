# Fase 1 — Análisis estático de scripts R

> Alcance ejecutado en `limpieza/scripts-obsoletos`, después del commit de reglas `8ab5305`. No se ejecutó código del proyecto, no se abrieron libros Excel ni se modificó `datos/`. Los parámetros recibidos estaban sin completar: entrypoint vigente indeterminado; versión de R desconocida. Cada hallazgo cita el comando y la ubicación de la salida o del archivo que lo respalda.

## 1. Resumen ejecutivo

- Inventariados **17 archivos `.R` versionados** bajo `R/`; todos tienen fecha del último commit `2026-10-02` según el `git log` por archivo. Evidencia: E1, E2 y E3.
- Clasificación conservadora del CSV: **KEEP 8, SUPERSEDED 8, INCIERTO 1, DEAD 0, GENERATED 0**. No se propone borrar ningún `.R`: el entrypoint vigente sigue indeterminado y los scripts catalogados como históricos todavía pueden invocarse manualmente. Evidencia: E4, E5, E6.
- Los dos entrypoints candidatos cargan módulos de funciones. La ruta de auditoría comparte módulos, pero **no equivale al pipeline vivo de indicadores/PCA**, el cual no aparece implementado en esos entrypoints. Evidencia: E4 y E5.
- El intento de parse estático no pudo ejecutarse porque `Rscript` no está disponible en PATH; por tanto, sintaxis de los 17 scripts queda sin verificar. Evidencia: E7.

## 2. Versionado frente a archivos locales

`git ls-files -- R` lista los 17 scripts de la tabla siguiente y `git ls-files --others --exclude-standard -- R` no devolvió rutas: los `.R` de `R/` que entran al alcance están versionados. Evidencia: E1, líneas de salida 1–17 y 18–vacío.

También existen artefactos locales ignorados: `R/.Rhistory`, CSV/XLSX bajo `docs/diccionario/`, `docs/calidad/cobertura_municipal.csv`, checkpoints `.rds` e intermedios `.csv` bajo `temp/`. Sus nombres aparecen en `git ls-files --others --ignored --exclude-standard -- R docs temp`; por eso no son recuperables desde Git en su estado local. Los CSV/XLSX de diccionarios/cobertura son salidas producidas por scripts de auditoría; checkpoints e intermedios son producidos por las funciones v2. No se propone borrarlos. Evidencia: E6, E8.

Los scripts de diagnóstico en `temp/` (`.R` y `.py`) sí aparecen versionados según `git ls-files -- temp docs/diccionario docs/calidad resultados`; quedan fuera del alcance de borrado y se conservan como `INCIERTO`. `datos/` aparece como archivos ignorados en el listado de ignorados; no se accedió a su contenido. Evidencia: E8.

## 3. Inventario y clasificación de `.R`

`tamano_bytes` viene de `Get-ChildItem R -Recurse -File -Filter *.R`; `ultima_modificacion` es la fecha del último commit obtenida con `git log -1 --format=%cs -- <archivo>`, no la fecha local del archivo. Índices E2 corresponden al orden de salida del listado de tamaños; E3, al orden de `git ls-files -- R`.

| Archivo | Cat. | Git | Bytes | Último commit | Confianza | Acción | Evidencia / criterio |
|---|---|---:|---:|---|---|---|---|
| `R/01_auditoria_bases.R` | KEEP | sí | 30.799 | 2026-10-02 | media | CONSERVAR | E1.1, E2.2, E3.1; carga de funciones y llamadas E4.1, E5.1 |
| `R/01_auditoria_bases_v2.R` | KEEP | sí | 30.102 | 2026-10-02 | media | CONSERVAR | E1.2, E2.1, E3.2; carga y llamadas E4.2, E5.2 |
| `R/auditoria_simple.R` | SUPERSEDED | sí | 13.338 | 2026-10-02 | media | CONSERVAR | Documentado como versión simple predecesora; sucesor candidato `R/01_auditoria_bases.R`. Diferencias de comportamiento no comparadas línea por línea. E1.3, E2.4, E3.3, E6.1 |
| `R/auditoria_simple_fixed.R` | SUPERSEDED | sí | 13.589 | 2026-10-02 | media | CONSERVAR | Documentado como versión simple con rutas corregidas; sucesor candidato `R/01_auditoria_bases.R`. E1.4, E2.3, E3.4, E6.1 |
| `R/final_auditoria.R` | SUPERSEDED | sí | 13.626 | 2026-10-02 | media | CONSERVAR | Variante de auditoría histórica; el diagnóstico le atribuye ruta absoluta. Sucesor candidato `R/01_auditoria_bases.R`. E1.5, E2.9, E3.5, E6.1 |
| `R/final_auditoria_corrected.R` | SUPERSEDED | sí | 13.647 | 2026-10-02 | media | CONSERVAR | Variante “corrected”; ruta absoluta visible en línea 5; sucesor candidato `R/01_auditoria_bases.R`. Diferencia precisa no validada. E1.6, E2.5, E3.6, E6.1, E6.2 |
| `R/final_auditoria_fixed.R` | SUPERSEDED | sí | 13.625 | 2026-10-02 | media | CONSERVAR | Variante “fixed”; ruta absoluta visible en línea 5; sucesor candidato `R/01_auditoria_bases.R`. Diferencia precisa no validada. E1.7, E2.6, E3.7, E6.1, E6.2 |
| `R/final_auditoria_fixed2.R` | SUPERSEDED | sí | 13.687 | 2026-10-02 | media | CONSERVAR | Variante “fixed2”; ruta absoluta visible en línea 5; sucesor candidato `R/01_auditoria_bases.R`. Diferencia precisa no validada. E1.8, E2.7, E3.8, E6.1, E6.2 |
| `R/final_auditoria_working.R` | SUPERSEDED | sí | 13.647 | 2026-10-02 | media | CONSERVAR | Variante “working”; ruta absoluta visible en línea 5; sucesor candidato `R/01_auditoria_bases.R`. Diferencia precisa no validada. E1.9, E2.8, E3.9, E6.1, E6.2 |
| `R/funciones/auditoria_archivos.R` | KEEP | sí | 16.452 | 2026-10-02 | alta | CONSERVAR | Carga dinámica del candidato A; funciones usadas por éste. E1.10, E2.13, E3.10, E4.1, E5.1 |
| `R/funciones/auditoria_archivos_v2.R` | KEEP | sí | 25.744 | 2026-10-02 | alta | CONSERVAR | Cargado por ambos candidatos; checkpoint y procesamiento CSV. E1.11, E2.12, E3.11, E4.1–E4.2, E5.2 |
| `R/funciones/auditoria_ipm.R` | KEEP | sí | 6.871 | 2026-10-02 | alta | CONSERVAR | Carga dinámica y llamadas `auditar_ipm_especial()`. E1.12, E2.14, E3.12, E4.1–E4.2, E5.1–E5.2 |
| `R/funciones/auditoria_territorial.R` | KEEP | sí | 7.726 | 2026-10-02 | alta | CONSERVAR | Carga dinámica y llamada `calcular_cobertura_territorial()`. E1.13, E2.15, E3.13, E4.1–E4.2, E5.1–E5.2 |
| `R/funciones/generar_informe_calidad.R` | KEEP | sí | 14.478 | 2026-10-02 | alta | CONSERVAR | Carga dinámica y llamada `generar_informe_calidad()`. E1.14, E2.16, E3.14, E4.1–E4.2, E5.1–E5.2 |
| `R/funciones/utils.R` | KEEP | sí | 13.022 | 2026-10-02 | alta | CONSERVAR | Carga explícita/dinámica; utilidades estadísticas. E1.15, E2.17, E3.15, E4.1–E4.2 |
| `R/separate_dictionaries.R` | SUPERSEDED | sí | 30.198 | 2026-10-02 | media | CONSERVAR | Documentado como original de la pareja; sucesor `separate_dictionaries_final.R` (versión final/openxlsx según diagnóstico). Puede producir diccionarios XLSX. E1.16, E2.11, E3.16, E6.1, E6.3 |
| `R/separate_dictionaries_final.R` | INCIERTO | sí | 30.132 | 2026-10-02 | media | CONSERVAR | Puede producir diccionarios separados y README; no se determinó si sigue siendo generador mantenido o si sus resultados locales tienen consumidor vigente. E1.17, E2.10, E3.17, E6.3 |

La categoría `SUPERSEDED` refleja la clasificación del diagnóstico fechado del proyecto y las familias/variantes que describe; no es prueba suficiente para borrar. No hubo comparación textual de diffs entre todas las variantes; por ello la acción sigue siendo `CONSERVAR`. El CSV deja `decision_usuario` vacío para las 17 filas. Evidencia: E6.1–E6.3.

## 4. Alcanzabilidad desde entrypoints candidatos

`ENTRYPOINT_VIGENTE` fue enviado como parámetro sin rellenar. Se analizan los dos candidatos lado a lado, no se elige uno.

| Candidato | Dependencias `.R` alcanzables por carga estática/dinámica | Observación |
|---|---|---|
| A — `R/01_auditoria_bases.R` | Los seis `.R` de `R/funciones/`: `utils.R`, `auditoria_archivos.R`, `auditoria_archivos_v2.R`, `auditoria_ipm.R`, `auditoria_territorial.R`, `generar_informe_calidad.R` | `list.files(funciones_dir, pattern="\\.R$")` y `source()` recorren los módulos; además llama funciones de auditoría, territorial y reporte. E4.1, E5.1. |
| B — `R/01_auditoria_bases_v2.R` | Los mismos seis módulos: carga explícita de `utils.R`, `auditoria_archivos.R`, `auditoria_archivos_v2.R`, seguida de carga de los módulos restantes | Llama procesamiento CSV directo, procesamiento por hoja, checkpoints, cobertura, IPM y reporte. E4.2, E5.2. |

Ninguno de los candidatos referencia `CUADROS_MUNICIPALES_UNIDOS.xlsx` o `IPM_2018_organizado_region.xlsx` por nombre ni contiene los pasos para derivar indicadores/PCA según las búsquedas de rutas/llamadas ejecutadas. Por tanto, son entrypoints de auditoría de datos, no evidencia de que sean entrypoint del pipeline vivo del IVS. Preguntar cuál debe mantenerse para esa función. Evidencia: E4.1–E4.2 y E5.1–E5.2.

### Grafo estático

```mermaid
flowchart TD
  A[01_auditoria_bases.R candidato A] -->|list.files + source| F1[funciones/utils.R]
  A --> F2[funciones/auditoria_archivos.R]
  A --> F3[funciones/auditoria_archivos_v2.R]
  A --> F4[funciones/auditoria_ipm.R]
  A --> F5[funciones/auditoria_territorial.R]
  A --> F6[funciones/generar_informe_calidad.R]
  B[01_auditoria_bases_v2.R candidato B] --> F1
  B --> F2
  B --> F3
  B --> F4
  B --> F5
  B --> F6
  A -. no carga . .-> L[Scripts autónomos históricos]
  B -. no carga . .-> L
  A -. sin referencia . .-> P[Pipeline indicadores / PCA]
  B -. sin referencia . .-> P
```

## 5. Funciones y llamadas

Las definiciones se localizaron con `rg -n '^[[:space:]]*[A-Za-z.][A-Za-z0-9._]*[[:space:]]*(<-|=)[[:space:]]*function' R --glob '*.R'`; los sitios de llamada, con búsquedas `rg -n '<nombre>\(' R --glob '*.R'`, omitiendo la propia línea de definición. Resultado por archivo:

| Archivo | Funciones nombradas encontradas | Llamador estático identificado |
|---|---|---|
| `R/01_auditoria_bases.R` | `log_step` | El propio script; se usa durante etapas. E5.1 |
| `R/01_auditoria_bases_v2.R` | `detectar_raiz_proyecto`, `log_step` | El propio script. E5.2 |
| `R/auditoria_simple*.R`, `R/final_auditoria*.R` | No se detectaron asignaciones nombradas `nombre <- function`; sí bloques anónimos `function(e)` | Son scripts autónomos ejecutables; no se cargan desde los entrypoints candidatos. E4.3, E6.1 |
| `R/funciones/auditoria_archivos.R` | `count_lines`, `detectar_fila_encabezado`, `procesar_dataframe_completo`, `procesar_csv_chunks`, `procesar_excel_chunks` | Llamadas desde candidato A y entre funciones del módulo. E5.1 |
| `R/funciones/auditoria_archivos_v2.R` | `get_checkpoint_dir`, `checkpoint_key`, `save_checkpoint`, `load_checkpoint`, `is_sheet_complete`, `get_checkpoint_progress`, `detectar_fila_encabezado`, `excel_sheet_to_csv`, `procesar_csv_chunks_real`, `leer_hoja_excel_con_encabezado`, `procesar_hoja_excel`, `procesar_csv_directo` | Las funciones listadas se usan dentro del módulo o desde candidato B, **excepto `get_checkpoint_progress`**, para la cual no se halló llamada nominal. E5.2, E5.3, E5.4 |
| `R/funciones/auditoria_ipm.R` | `auditar_ipm_especial`, `analizar_hoja_ipm`, `inferir_dimension_ipm`, `inferir_definicion_ipm`, `extraer_variables_ipm_detalladas` | Candidato A/B y llamadas internas del módulo. E5.1–E5.2 |
| `R/funciones/auditoria_territorial.R` | `calcular_cobertura_territorial`, `extraer_codigos_municipales` | Candidato A/B y llamada interna. E5.1–E5.2 |
| `R/funciones/generar_informe_calidad.R` | `generar_informe_calidad` | Candidato A/B. E5.1–E5.2 |
| `R/funciones/utils.R` | `clasificar_tipo_estadistico`, `clasificar_escala_medicion`, `inferir_naturaleza`, `inferir_unidad`, `inferir_universo`, `es_identificador`, `es_indicador`, `necesita_transformacion`, `sugerir_transformacion`, `inferir_direccion_vulnerabilidad`, `asimetria`, `curtosis` | Funciones del módulo de auditoría de archivos y clasificaciones internas. E5.1, E5.2 |
| `R/separate_dictionaries*.R` | `create_base_dir`, `get_file_info`, `detect_header_row`, `process_base` en cada variante | Llamadas desde el propio script; no se cargan desde los dos entrypoints candidatos. E5.5, E6.3 |

`get_checkpoint_progress()` es la única función sin llamada estática nominal identificada: `rg -n 'get_checkpoint_progress' R` devolvió solo su definición en `auditoria_archivos_v2.R:77`; las búsquedas de cargas dinámicas no mostraron despacho por nombre. Se señala como **posible código muerto dentro de archivo KEEP**, pero queda conservada porque una llamada manual/reflexiva no se descarta. E5.3–E5.4.

## 6. Sombreado de funciones

`R/funciones/auditoria_archivos.R:25` y `R/funciones/auditoria_archivos_v2.R:89` definen ambas `detectar_fila_encabezado()`. A carga los módulos con `list.files()` y luego `source()` (`R/01_auditoria_bases.R:42-44`); con el orden alfabético del listado, `auditoria_archivos_v2.R` viene después de `auditoria_archivos.R`, por lo que la definición v2 prevalece. B también carga primero `auditoria_archivos.R` y después `auditoria_archivos_v2.R` (`R/01_auditoria_bases_v2.R:64,67`); prevalece v2 allí también. La función original queda sombreada, no el archivo completo: otras funciones de `auditoria_archivos.R` siguen llamadas. Evidencia: E4.1–E4.2, E5.6.

Las funciones `create_base_dir`, `get_file_info`, `detect_header_row` y `process_base` se repiten entre `separate_dictionaries.R` y `separate_dictionaries_final.R`, pero son scripts autónomos y no se sourcean entre sí ni desde candidatos; no se produce sombreado en las rutas alcanzables examinadas. Evidencia: E5.5, E6.3.

## 7. Archivos generados y fuera del alcance de borrado

- Los entrypoints de auditoría escriben inventarios, diccionarios, matriz IPM-CNPV, candidatos IVS, cobertura e informes bajo `docs/`; esos outputs no son `.R` y no se proponen para borrado. Evidencia: E6.4 (líneas indicadas de los dos entrypoints).
- El flujo v2 escribe checkpoints `.rds` y CSV intermedios en `temp/`; están ignorados por Git, y el generador declarado está en `R/funciones/auditoria_archivos_v2.R`. Se clasifican `GENERATED`, riesgo alto por posible continuidad/reanudación, acción `CONSERVAR`. Evidencia: E6.5, E8.
- Los CSV/XLSX de `docs/diccionario/` y `docs/calidad/cobertura_municipal.csv` son artefactos generados por entrypoints/script de diccionarios; se clasifican `GENERATED`, acción `CONSERVAR`. `decisiones_variables_IVS_CNPV2018.csv` y `docs/metodologia/seleccion_variables_ivs.md` son explícitamente protegidos por `TRASH_OUT.md`, línea 13; no son candidatos a borrado. Evidencia: E6.4–E6.6.
- Scripts de depuración en `temp/` se clasifican `INCIERTO`: su presencia versionada acredita que existen, pero no se estableció si tienen valor reproducible actual. No se proponen para borrado. Evidencia: E8.
- `datos/` se deja intacto; aparecen como archivos ignorados/no versionados en `git ls-files --others --ignored --exclude-standard -- datos`. Evidencia: E9.

## 8. Preguntas exactas para resolver los inciertos

1. **¿Cuál entrypoint debe mantenerse como principal para la auditoría actual: `R/01_auditoria_bases.R`, `R/01_auditoria_bases_v2.R`, ambos, o ninguno porque el pipeline vivo de indicadores/PCA tendrá otro?**
2. **¿`R/separate_dictionaries_final.R` se sigue usando manualmente para generar los XLSX separados de diccionarios, o sus resultados actuales ya tienen otro generador mantenido?**
3. **¿`get_checkpoint_progress()` se invoca desde fuera de `R/` o mediante reflexión, o autorizas tratarla como código muerto dentro del módulo v2?**
4. **¿Los scripts versionados de depuración en `temp/` se conservan como herramientas reproducibles del proyecto o se consideran experimentos históricos?**
5. **¿Puedes confirmar/instalar en PATH la versión de R que debe usar el repositorio para que el control `parse()` sea verificable?**

## 9. Problemas detectados (sin proponer arreglos)

- **Nombre engañoso:** `procesar_excel_chunks()` declara `chunk_size`, pero lee la hoja Excel completa con `read_excel()`; la ruta v2 también materializa la hoja antes de crear CSV por chunks. Evidencia: `auditoria_archivos.R:380-397`, `auditoria_archivos_v2.R:166-221,496-552,572-644`; búsquedas E4.4.
- **Sombreado:** la segunda definición de `detectar_fila_encabezado()` prevalece al cargar ambos módulos; la definición previa queda inalcanzable por nombre en ese entorno. Evidencia: E5.6.
- **Ruta absoluta:** cinco scripts `final_auditoria*.R` y las dos variantes `separate_dictionaries*.R` contienen raíz `C:/Users/juand/...` en la línea 5. Evidencia: E6.2.
- **Código posiblemente no llamado:** `get_checkpoint_progress()` no tiene llamadas estáticas encontradas, dentro de un módulo usado. Evidencia: E5.3–E5.4.
- **Entry point ambiguo:** existen dos candidatos distintos; no hay valor de configuración del usuario que resuelva cuál se mantiene. Evidencia: E4.1–E4.2.
- **Parse no verificado:** `Rscript` no se reconoce como comando en este entorno; no se puede afirmar que los `.R` pasan sintaxis. Evidencia: E7.
- **Historiales/experimentos locales:** hay `.Rhistory`, archivos ignorados de diccionario y temporales generados; no se consideran recuperables por Git. Evidencia: E6, E8.

## 10. Registro de evidencia y comandos

Los índices de salida son ordinales dentro de la salida del comando, contando desde 1. Para `rg`, se cita `ruta:línea` tal como aparece en su salida.

- **E0** — `git status --short; git branch --show-current; git rev-parse HEAD`: salida `git status` vacía; rama `limpieza/scripts-obsoletos`; HEAD del commit de reglas `8ab5305de327e942b93cdf7ce6547d04170154ae`. Verificación posterior al commit antes de fase 1.
- **E1** — `git ls-files -- R`: stdout, líneas 1–17, enumera los 17 archivos R en el mismo orden de la tabla de inventario. `git ls-files --others --exclude-standard -- R`: stdout vacío.
- **E2** — `Get-ChildItem R -Recurse -File -Filter *.R | Select-Object FullName,Length,LastWriteTime`: stdout, registros 1–17, contiene tamaño por archivo. Mapa registro→archivo: 1 `01_auditoria_bases_v2.R`; 2 `01_auditoria_bases.R`; 3 `auditoria_simple_fixed.R`; 4 `auditoria_simple.R`; 5 `final_auditoria_corrected.R`; 6 `final_auditoria_fixed.R`; 7 `final_auditoria_fixed2.R`; 8 `final_auditoria_working.R`; 9 `final_auditoria.R`; 10 `separate_dictionaries_final.R`; 11 `separate_dictionaries.R`; 12 `funciones/auditoria_archivos_v2.R`; 13 `funciones/auditoria_archivos.R`; 14 `funciones/auditoria_ipm.R`; 15 `funciones/auditoria_territorial.R`; 16 `funciones/generar_informe_calidad.R`; 17 `funciones/utils.R`.
- **E3** — Secuencia de 17 comandos `git log -1 --format=%cs -- <archivo>` siguiendo el orden E1: stdout líneas 1–17, cada una `2026-10-02`.
- **E4.1** — `rg -n 'source\(|sys\.source\(|library\(|require\(|...|list\.files\(|...' R --glob '*.R'`: stdout `R/01_auditoria_bases.R:42,44` y llamadas 324–415, 515, 590, 599; `R/01_auditoria_bases_v2.R:61,64,67,74` y llamadas 274, 310–326, 464, 479, 547. Estos path:line son las líneas literales de la salida `rg`.
- **E4.2** — `rg -n '01_auditoria_bases|auditoria_simple|final_auditoria|separate_dictionaries|...' .github mkdocs.yml README.md docs ...`: stdout `docs/calidad/auditorias/DIAGNOSTICO_ESTADO_ACTUAL.md:90,96-114,264-277,340-348` (ruta actual del archivo movido; la evidencia original se levantó antes del movimiento); resumen y reporte mencionan algunos nombres pero no son invocaciones ejecutables. No se encontró mención de scripts en el workflow/docs MkDocs como entrypoints.
- **E4.3** — `rg -n '^[[:space:]]*[A-Za-z.][A-Za-z0-9._]*[[:space:]]*(<-|=)[[:space:]]*function\b' R --glob '*.R'`: stdout lista definiciones nombradas en entrypoints, funciones y dos scripts de diccionario; no muestra funciones nombradas en variantes `auditoria_simple*`/`final_auditoria*` (solo funciones anónimas no matcheadas por esa expresión).
- **E4.4** — Búsquedas de `read_excel`, `procesar_excel_chunks`, `procesar_hoja_excel`, `excel_sheet_to_csv`, `procesar_csv_chunks_real`: stdout incluye `auditoria_archivos.R:380-397`, `auditoria_archivos_v2.R:166-221,248,496-552,572-644`; sustenta la ruta de materialización previa.
- **E5.1** — `rg -n 'procesar_csv_chunks\(|...|generar_informe_calidad\(' R --glob '*.R'`: stdout `R/01_auditoria_bases.R:194,324,328,365,411,415,515,590,599`; llamadas internas `auditoria_archivos.R:397`, `auditoria_ipm.R:44,58,107,110`, `auditoria_territorial.R:83`.
- **E5.2** — misma búsqueda de llamadas: stdout `R/01_auditoria_bases_v2.R:274,310,314,323,326,464,479,547`; referencias internas en `auditoria_archivos_v2.R:37-78,259-269,353,473-480,593-697`.
- **E5.3** — `rg -n 'get_checkpoint_progress' R`: stdout tiene una sola coincidencia, definición `R/funciones/auditoria_archivos_v2.R:77`.
- **E5.4** — `rg -n 'list\.files\(|source\(|sys\.source\(|do\.call\(|match\.fun\(|get\(|eval\(parse\(' R --glob '*.R'`: stdout enumera cargas dinámicas; no aparece `get_checkpoint_progress` ni despacho reflexivo por su nombre.
- **E5.5** — búsqueda de las cuatro definiciones de diccionarios: stdout `separate_dictionaries.R:61,66,75,114` y `separate_dictionaries_final.R:66,71,80,119`.
- **E5.6** — búsqueda de duplicados: stdout define `detectar_fila_encabezado` en `auditoria_archivos.R:25` y `auditoria_archivos_v2.R:89`; cargas en E4.1 establecen orden base→v2 en ambos candidatos.
- **E6.1** — `rg -n '01_auditoria_bases|auditoria_simple|final_auditoria|separate_dictionaries...' docs`: stdout `DIAGNOSTICO_ESTADO_ACTUAL.md:90-114,264-277,340-348` (referencia relativa histórica al momento de la búsqueda; archivo ahora en `docs/calidad/auditorias/`), etiquetas CORE/LEGACY/TEST y sucesión histórica.
- **E6.2** — `rg -n 'C:/Users|C:\\Users|/Users/|/home/' R --glob '*.R'`: stdout líneas 5 de cinco `final_auditoria*.R` y ambas `separate_dictionaries*.R`.
- **E6.3** — E5.5 y `rg -n 'write.csv\(|writeLines\(' R/separate_dictionaries*.R`: stdout `separate_dictionaries*.R:439,442,669,672` registra salidas de diccionarios/README.
- **E6.4** — `rg -n 'write_csv\(|write\.csv\(|writeLines\(' R/01_auditoria_bases*.R`: stdout ubica salidas: candidato A líneas 234,445-449,497,519,548,583,595,606,691,771; candidato B líneas 231,393,450,465,481,501,538,554,630,678,762.
- **E6.5** — `rg -n 'file.path\(.*temp|saveRDS\(|fwrite\(' R/funciones/auditoria_archivos_v2.R`: stdout líneas 21,39,54,62,166-221,248-... y 478-480,630-639, indicando rutas temporales, checkpoints y CSV.
- **E6.6** — `rg -n` sobre reglas de `TRASH_OUT.md`: la regla de conservar `decisiones_variables_IVS_CNPV2018.csv` y `seleccion_variables_ivs.md` está en `TRASH_OUT.md:13`.
- **E7** — `Rscript -e "for (f in list.files('R', ...)) parse(file=f)"`: salida literal `Rscript: The term 'Rscript' is not recognized...`; parse no ejecutado.
- **E8** — `git ls-files -- temp docs/diccionario docs/calidad resultados`; stdout enumera docs/calidad principales, README diccionario, `.gitkeep` y scripts `.R`/`.py` de `temp/`. `git ls-files --others --ignored --exclude-standard -- R docs temp`; stdout enumera `.Rhistory`, CSV/XLSX de diccionario/cobertura y archivos temporales en `temp/`.
- **E9** — `git ls-files --others --ignored --exclude-standard -- datos`: stdout lista nombres de los libros/CSV ignorados. Ningún libro fue abierto.

> **Limitación del registro:** las búsquedas `rg` son léxicas; no prueban ejecución ni resuelven llamadas construidas indirectamente. Por esa limitación y por el entrypoint indeterminado, no se declara ningún script `DEAD` ni se recomienda borrar.

## Actualización posterior — decisión de fase 2 (2026-10-04)

El usuario completó `decision_usuario` como `BORRAR` para los 17 scripts listados en `docs/calidad/limpieza_candidatos.csv` y ordenó archivarlos bajo `OLVIDADOS/` porque considera que no aportan al proyecto en lo metodológico ni funcional. Se completó el movimiento con `git mv`, preservando las rutas relativas bajo `OLVIDADOS/R/`, en tres commits: `568a55e` (8 antes `KEEP`), `160c05a` (8 antes `SUPERSEDED`) y `2e74075` (1 antes `INCIERTO`). No se eliminó ni modificó el contenido de los scripts. La tabla y las evidencias de fase 1 que siguen usan las rutas originales al momento de la auditoría; cada `.R` está ahora en la ruta correspondiente bajo `OLVIDADOS/R/`.

Antes del archivado, `Rscript 4.6.0` ejecutó `parse(file=..., encoding="latin1")` y encontró los siguientes errores. El usuario confirmó archivar de todos modos porque los scripts no aportan al proyecto; los errores se conservan como limitación de esos artefactos históricos, no como un bloqueo para retirarlos del árbol activo:

Expresión usada antes del archivo (solo análisis sintáctico; no ejecuta scripts del proyecto):

```powershell
& 'C:\Program Files\R\R-4.6.0\bin\Rscript.exe' -e "files <- list.files('R', pattern='\\.R$', recursive=TRUE, full.names=TRUE); for (f in files) { parse(file=f, encoding='latin1') }"
```

| Archivo | Error reportado por `parse()` |
|---|---|
| `R/01_auditoria_bases.R` | Token inválido en línea 72 (`tama�...`) |
| `R/01_auditoria_bases_v2.R` | Token inválido en línea 104 (`a�...`) |
| `R/auditoria_simple_fixed.R` | Error de sintaxis en línea 304, cadena/comillas |
| `R/final_auditoria.R` | Error de sintaxis en línea 317, cadena/comillas |
| `R/final_auditoria_fixed.R` | Error de sintaxis en línea 317, cadena/comillas |
| `R/funciones/auditoria_archivos.R` | Token inválido en línea 124 (`a�...`) |
| `R/funciones/auditoria_archivos_v2.R` | Token inválido en línea 409 (`a�...`) |
| `R/funciones/generar_informe_calidad.R` | Token inválido en línea 34 (`a�...`) |
| `R/separate_dictionaries.R` | Error de sintaxis en línea 582 (`foreach(...) {`) |
| `R/separate_dictionaries_final.R` | Error de sintaxis en línea 585 (`foreach(...) {`) |

`auditoria_simple.R`, `final_auditoria_corrected.R`, `final_auditoria_fixed2.R`, `final_auditoria_working.R`, `funciones/auditoria_ipm.R`, `funciones/auditoria_territorial.R` y `funciones/utils.R` sí pasaron ese parse estático previo. No se reparó ningún script. Por instrucción explícita del usuario se priorizó archivarlos fuera del árbol activo pese a que la condición `parse()` no se cumplió; los commits de archivo no se revirtieron. Los 17 archivos quedaron preservados en `OLVIDADOS/R/`; no hay scripts `.R` activos bajo `R/`.

Verificación posterior: `git ls-files OLVIDADOS/R` enumeró 17 archivos; se repitió la lectura con `list.files('OLVIDADOS/R', pattern='\\.R$', recursive=TRUE)` y `parse(file=f, encoding='latin1')`, que reportó los mismos 10 errores y 7 archivos parseables. `list.files('R', pattern='\\.R$', recursive=TRUE)` devolvió 0. La estructura activa ya no contiene un entrypoint ni funciones R; la fase de indicadores/PCA debe iniciar con código nuevo.
