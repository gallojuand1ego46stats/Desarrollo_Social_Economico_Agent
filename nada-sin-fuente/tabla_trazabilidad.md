# Tabla de trazabilidad

**Cómo leer la columna "Tipo de verificación":**
- **Directa**: se contrastó contra el texto/abstract original o la página oficial del editor, sin usar la herramienta evaluada.
- **Solo NotebookLM**: se contrastó únicamente con la respuesta de NotebookLM. **No es independiente** (es la misma herramienta que luego evaluamos), por eso no se cuenta como verificación fuerte.
- **Pendiente**: no se pudo verificar.

| # | Afirmación (cita textual del Informe 1) | Fuente | Ubicación | Tipo de verificación | Verificado por | Fecha |
|---|---|---|---|---|---|---|
| 1 | "encontrando una alta persistencia en la distribución del ingreso y efectos del gasto público —especialmente de la inversión— sobre la posición relativa de algunos departamentos" | Ardila-Rueda (2004) | Resumen, Revista ESPE 22(45); solo resumen, no texto completo | Solo NotebookLM | Juan David | 2026-10-02 |
| 2 | "mostró diferencias importantes en ingresos fiscales per cápita y en las condiciones de provisión de servicios entre entidades territoriales" | Bonet-Morón (2006) | Doc. de Trabajo N.º 77, Resumen | Solo NotebookLM | Juan David | 2026-10-02 |
| 3 | "advirtió que la descentralización y las transferencias no garantizan por sí mismas equidad territorial" | Bonet-Morón (2006) | Doc. de Trabajo N.º 77, Resumen | Solo NotebookLM | Juan David | 2026-10-02 |
| 4 | "analizaron el IPM en municipios de Cundinamarca mediante indicadores locales de asociación espacial (LISA). El estudio encontró agrupamientos espaciales de pobreza" | Monsalvo Herrera y Jiménez (2025) | Novum Jus 19(2), Metodología, pp. 213–251 (999 permutaciones, GeoDa, Queen orden 1) | **Directa** (texto completo en SciELO) | Juan David | 2026-10-02 |
| 5 | "analizaron más de 90.000 contratos de autoridades locales del Reino Unido y encontraron diferencias regionales en la selección de proveedores" | Ferry et al. (2023) → **corregir a Eckersley, Flynn, Lakoma y Ferry (2023), Regional Studies 57(10)** | Resumen | Contenido: solo NotebookLM. Metadatos: **directa** vía Crossref | Juan David (contenido); Claude (metadatos) | 2026-10-02 / 2026-10-06 |
| 6 | "a partir de más de 50.000 contratos de obras públicas municipales en Italia, estudiaron la cooperación intermunicipal mediante modelos de efectos fijos y estimadores de matching" | Arachia et al. (2024) → **corregir a Arachi et al. (2024)** | Regional Studies 58(11), Resumen (50.905 contratos) | Contenido: solo NotebookLM. Metadatos: **directa** vía Crossref | Juan David (contenido); Claude (metadatos) | 2026-10-02 / 2026-10-06 |
| 7 | "plantea una relación multidimensional entre contratación pública y desigualdad laboral" | Sarter (2024) | J. of Industrial Relations 66(1), Resumen | Solo NotebookLM | Juan David | 2026-10-02 |
| 8 | "muestran, desde la contratación pública sostenible a nivel local, que las compras gubernamentales pueden utilizarse estratégicamente para abordar objetivos sociales, económicos y ambientales" | Rodriguez-Plesa et al. (2022) | J. of Cleaner Production 338, Resumen (264 gobiernos, Poisson, índice verde y de equidad social) | **Directa** (palabra por palabra contra el abstract oficial) | Juan David | 2026-10-02 |
| 9 | "utilizaron datos abiertos de SECOP II para desarrollar modelos de clasificación destinados a identificar procesos de contratación de interés" | Figueroa-Gómez y Galpin (2024) | SN Computer Science 5, 87, Resumen | Solo NotebookLM | Juan David | 2026-10-02 |
| 10 | "desarrollaron VigIA, una herramienta basada en datos abiertos de SECOP II para detectar ineficiencias y construir índices de riesgo" | Salazar, Pérez y Gallego (2024) | Data & Policy 6, e75, Resumen | **Directa** (página del editor en Cambridge Core, 2026-10-06). No está en el corpus de NotebookLM | Claude (búsqueda web); el equipo debe confirmar | 2026-10-06 |
| 11 | "utilizó Isolation Forest sobre datos abiertos de SECOP II para identificar banderas rojas" | Gutiérrez Vanegas (2024) | Trabajo de grado, Univ. Los Libertadores | **Pendiente: NO verificada.** No se ubicó el documento | — | — |
| 12 | "analiza el carácter transaccional de SECOP II y su relación con los principios de publicidad y transparencia" | Díaz Díez (2023) | Rev. Eurolatinoamericana de Derecho Administrativo 10(2) | **Parcial**: el artículo existe en Redalyc y el tema coincide; la frase "transaccional" no se confirmó | Claude (búsqueda web) | 2026-10-06 |
| 13 | "el histórico reporta 7.827.129 registros y 59 variables, con última fecha de publicación 2025-10-05" | `Historico_de_Datos.ipynb`, repo público ustadistica/desarrollo_social_y_economico | README del repo | **Directa** (consulta al repo) | Juan David | 2026-09 |
| 14 | Estructura de 5 dimensiones y 15 indicadores del IPM censal municipal | DANE (2020), Nota metodológica COM-030-PD-001-r-004 V8, 31-01-2020 | Tabla 1 | **Directa** (documento oficial y CONPES) | Juan David | 2026-10-02 |

## Resumen honesto

- Verificación directa del contenido: filas 4, 8, 10, 13 y 14.
- Solo contra NotebookLM (no independiente): filas 1, 2, 3, 5 (contenido), 6 (contenido), 7 y 9.
- Pendiente o parcial: filas 11 y 12.
- Correcciones al Informe 1 encontradas al construir esta tabla: "Arachia" → "Arachi"; "Ferry et al. 57(11)" → "Eckersley, Flynn, Lakoma y Ferry, 57(10)"; Gutiérrez Vanegas y Díaz Díez sin verificar.