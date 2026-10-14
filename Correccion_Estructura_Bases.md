> Enlaces de la bóveda: [[Inicio_Proyecto]] · [[Estructura_Bases]] · [[VERIFICACION_CONSOLIDADOS]] · [[Final_Base]]

# Corrección del script de verificación de consolidados

Fecha de ejecución: 2026-10-08 · Script: [R/01_verificar_consolidados.R](R/01_verificar_consolidados.R)

## Resumen

Se corrigieron los conteos de unicidad y combinaciones ausentes, se unificó el conteo de áreas no municipalizadas, se ajustaron los flags de cobertura para códigos sin registro CNPV y se corrigió el manejo de UTF-8. También se separó el encabezado de dos filas del bloque 10V en el inventario.

Los diez CSV tidy coinciden byte a byte con la línea base regenerada que el usuario autorizó. Los libros fuente también conservaron sus hashes. La nota de auditoría se genera con tablas Markdown construidas por el script y contiene un enlace de retorno a esta nota.

## Cambios y causas raíz

| ID | Síntoma | Causa raíz comprobada y evidencia | Archivo o función | Antes → después | Estado |
| --- | --- | --- | --- | --- | --- |
| 1 | HOGARES informaba duplicados por municipio. | `hogares_1HM_2HM.csv` tiene 4.488 filas, 1.122 códigos y 4.488 pares código-área únicos. El verificador llamaba `check_keys()` una segunda vez usando solo `codigo_municipio`. | `R/01_verificar_consolidados.R`, validación de HOGARES | 1.122 duplicados por código → 0 duplicados por `codigo_municipio + area`, sobre 4.488 filas. | corregido |
| 2 | Las dos clases de vivienda tradicional aparecían ausentes en todos los municipios; los chequeos de ausencias reportaban cero violaciones. | Los valores fuente observados tienen siete etiquetas distintas. La comparación literal fallaba para etiquetas acentuadas bajo la lectura/codificación previa. El código además fijaba cero en `n_violaciones` aunque calculaba `n ausentes`. Se normalizan etiquetas observadas con NFC, espacios y minúsculas; los conteos pasan a `n_violaciones`. | `norm_label`, `type_grid`, `age_grid` | Vivienda: 1.202 ausencias reales (15 apartamento, 6 tipo cuarto, 446 tradicional indígena, 594 tradicional étnica, 141 otro tipo; 0 total y casa). Edad: 335 ausencias. | corregido |
| 3 | El CSV registraba 18 áreas no municipalizadas y el reporte decía 0 en otra sección. | El chequeo ya calculaba 18; el reporte repetía una comparación literal de texto acentuado que, con la codificación anterior, no coincidía. | Conteo único `anm_count`, reutilizado en reporte y chequeo | Conteos separados 18 y 0 → 18 en ambos. | corregido |
| 4 | `27493` quedaba marcado sin Cabecera ni Centro poblado como si la fuente lo hubiera confirmado. | El código hacía `%in%` contra códigos de CNPV para todo el universo unido: un código fuera del CNPV se convertía en `FALSE`. | Construcción de `tiene_cabecera` y `tiene_centro_poblado` | Cabecera: TRUE/FALSE/NA = 1.102/20/1. Centro poblado: 930/192/1. `n_evaluado` para cobertura queda en 1.122. | corregido |
| 5 | CSV y reporte mostraban mojibake y volcados de tibbles. | El archivo `.R` era UTF-8 sin BOM, mientras el script cambiaba `LC_CTYPE` a `Spanish_Colombia.1252`; además, el reporte usaba `print()`/`capture.output()` de tibbles. | Inicialización, lectura CSV, helper `markdown_table` y escritura del reporte | Se establece locale UTF-8 disponible, se especifica UTF-8 al leer CSV, los literales Unicode se expresan con escapes y se escanean los artefactos por `Ã`, `â€` y `�`. El escaneo final encontró 0 coincidencias. | corregido |
| Opcional | BR incluía “Total Nacional” dentro del nombre de encabezado. | El inventario aplicaba tres filas de encabezado a todas las columnas de VIVIENDAS, aunque el bloque 10V empieza en la fila 3. | `sheet_inventory()` | BR:CE inventariadas con 2 filas de encabezado; no cambia la extracción tidy ni el chequeo numérico que incluye la fila nacional. | corregido |

## Hallazgos verificados que no son errores del script

- **Verificado:** `27493` (Nuevo Belén de Bajirá) aparece solo en DIVIPOLA. **Verificado:** `94663` (Mapiripana) aparece en CNPV/IPM y no tiene fila ni coordenadas en el DIVIPOLA usado. La intersección CNPV/IPM-DIVIPOLA es de 1.121 códigos y la unión de 1.123. No se resolvió el universo maestro.
- **Verificado:** los 20 códigos sin Cabecera se componen de 18 áreas no municipalizadas en el catálogo DIVIPOLA y dos registros adicionales: `94343` Barrancominas y `94663` Mapiripana. Las 18 áreas se distribuyen en Amazonas (9), Guainía (6) y Vaupés (3). Coinciden con los 20 `--` de Cabeceras IPM.
- **Hipótesis, no comprobada:** Barrancominas y Mapiripana pudieron ser áreas no municipalizadas en 2018.
- **Verificado en las etiquetas fuente:** PERSONA_SOCIAL fila 4833 contiene `23_` (referencia por código DIVIPOLA: `23_CÓRDOBA`); CONTEXTO fila 10868 contiene `11Bogotá, D.C.` (referencia: `11_BOGOTÁ, D.C.`); CONTEXTO fila 46032 contiene `47_La Guajira` para el municipio 44001 (referencia: `44_LA GUAJIRA`); PERSONA_SOCIAL fila 1722 contiene `11_Bogotá, D0C0` (cero en vez de O). Se registran como BAJA con número de fila y sin efecto sobre la llave municipal.
- **Verificado:** 6V tiene 1.202 combinaciones de tipo ausentes; 1PM tiene 335 combinaciones de grupo de edad ausentes. Son ausencias estructurales, no filas imputables.
- **Verificado:** hay cuatro diferencias literales de nombre entre IPM y DIVIPOLA (códigos `13468`, `19760`, `68235` y `76001`). La unión continúa siendo por código.

## Decisiones pendientes del usuario

- Elegir el universo territorial y el tratamiento de `27493` y `94663`.
- Definir el tratamiento analítico de las áreas no municipalizadas.
- Mantener o no las combinaciones estructuralmente ausentes como no observadas; no se imputaron.
- Elegir qué columnas de 8V pasan a la siguiente fase.

## Verificación posterior

- `parse(file = "R/01_verificar_consolidados.R", encoding = "UTF-8")` y la corrida integral finalizaron sin error. Se realizó una segunda corrida para verificar reproducibilidad; el reporte mantuvo el wikilink a esta nota.
- Unicidad HOGARES: 4.488 filas evaluadas, 0 duplicados por código-área. IPM y DIVIPOLA mantienen unicidad municipal.
- Combinaciones ausentes: 1.202 tipos de vivienda y 335 grupos de edad. En `chequeos_consistencia.csv`, `n_violaciones` refleja estos conteos estructurales por instrucción; no son inconsistencias de valores observados. La única diferencia territorial es la fila con 2 códigos entre DIVIPOLA e IPM.
- Flags: Cabecera TRUE/FALSE/NA = 1.102/20/1; Centro poblado = 930/192/1. Áreas no municipalizadas = 18 en chequeo y reporte.
- El escaneo automático de los CSV de auditoría y el reporte encontró 0 marcadores de codificación dañada.
- Los hashes MD5 de los tres archivos fuente se mantuvieron iguales antes y después. Los hashes MD5 de los diez CSV tidy se compararon contra la línea base regenerada autorizada y permanecieron iguales.

## Archivos regenerados

En `resultados/verificacion_consolidados/`: `inventario_hojas_columnas.csv`, `mapa_llaves.csv`, `cobertura_municipal_por_hoja.csv`, `discrepancias.csv`, `chequeos_consistencia.csv` y `universo_municipal_maestro.csv`. En `datos/intermedio/` se volvieron a escribir las diez tablas tidy, sin cambio de bytes frente a su línea base aceptada. También se regeneró `docs/calidad/auditorias/VERIFICACION_CONSOLIDADOS.md`.

Reproducción desde la raíz: `Rscript R/01_verificar_consolidados.R`.
