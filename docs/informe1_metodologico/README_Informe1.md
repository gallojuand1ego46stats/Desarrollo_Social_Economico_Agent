# Informe 1 Metodológico — Proyecto Desarrollo Social Económico

## Propósito del documento

Este informe documenta de manera rigurosa, reproducible y trazable **todo el proceso metodológico realizado hasta el estado actual del proyecto** (corte: 13 de octubre de 2026), desde la selección y auditoría inicial de las fuentes de información hasta la construcción de los indicadores socioeconómicos municipales y los diagnósticos estadísticos preliminares.

Es el **primer informe metodológico formal del proyecto** y está diseñado para ser **modular, ampliable y científicamente trazable**, permitiendo incorporar posteriormente:

```
AUDITORÍA ESTADÍSTICA INTEGRAL
        ↓
PCA (exploratorio → definitivo)
        ↓
ÍNDICE SINTÉTICO / IVS (construcción + estabilidad)
        ↓
VALIDACIÓN EXTERNA CON IPM MUNICIPAL
        ↓
INTEGRACIÓN SECOP II (panel municipal-año)
        ↓
ANÁLISIS DE ASOCIACIÓN / CORRESPONDENCIA
        ↓
ANÁLISIS ESPACIAL (condicionado a resultados previos)
```

sin reescribir las secciones metodológicas ya consolidadas.

## Fecha de generación

**13 de octubre de 2026** (versión 1.0)

## Fuentes utilizadas

### Fuentes de datos primarias
- **CNPV 2018** (4 tomos: HOGARES, PERSONAS_DEMOGRAFICO, PERSONAS_SOCIAL, VIVIENDAS) — 8 cuadros municipales seleccionados.
- **IPM 2018 organizado por región** — Hoja `IPM_municipios_region` (1.122 municipios × 15 privaciones + agregado).
- **DIVIPOLA** — Códigos municipales 20260917 (referencia territorial).

### Fuentes documentales del proyecto
- `Resumen_General.md` — Handoff consolidado con estado vigente al 2026-10-13.
- `Final_Base.md` — Documentación metodológica de la base final de indicadores.
- `decisiones_variables_IVS_CNPV2018.csv` — 115 filas con decisiones de inclusión/exclusión de variables.
- `Correccion_Estructura_Bases.md`, `Estructura_Bases.md`, `Inicio_Proyecto.md`.
- Scripts R activos: `R/00_config.R`, `R/01_verificar_consolidados.R`, `R/02_base_final_indicadores.R`, `R/03_auditoria_indicadores.R`.
- Productos reproducibles en `datos/trabajo/`, `resultados/base_trabajo/`, `resultados/auditoria_estadistica/`, `datos/intermedio/`.

## Cómo compilar el documento

### Requisitos
- Distribución LaTeX (TeX Live, MiKTeX, o similar) con paquetes: `babel-spanish`, `booktabs`, `longtable`, `hyperref`, `natbib`, `geometry`, `setspace`, `caption`, `subcaption`, `enumitem`, `csquotes`, `xcolor`, `indentfirst`, `pdflscape`, `rotating`, `titlesec`.
- `bibtex` o `biber` para bibliografía (estilo `apalike`).

### Comandos (ejecutar en `docs/informe1_metodologico/`)

```bash
# Primera pasada
pdflatex -interaction=nonstopmode main.tex

# Bibliografía
bibtex main

# Segunda pasada (resolver referencias)
pdflatex -interaction=nonstopmode main.tex

# Tercera pasada (índice, listas, referencias cruzadas)
pdflatex -interaction=nonstopmode main.tex
```

### Producto esperado
`Informe1_Metodologico.pdf` en el mismo directorio.

## Estructura del documento

```
docs/informe1_metodologico/
├── main.tex                 # Archivo principal
├── referencias.bib          # Bibliografía BibTeX
├── README_Informe1.md       # Este archivo
├── secciones/
│   ├── portada.tex
│   ├── resumen.tex
│   ├── palabras_clave.tex
│   ├── introduccion.tex
│   ├── metodologia.tex
│   ├── marco_conceptual.tex
│   ├── fuentes.tex
│   ├── unidad_analisis.tex
│   ├── seleccion_bases.tex
│   ├── tratamiento_faltantes.tex
│   ├── indicadores.tex
│   ├── control_calidad.tex
│   ├── diagnostico.tex
│   ├── preparacion_pca.tex
│   ├── reproducibilidad.tex
│   ├── limitaciones.tex
│   ├── estado_proyecto.tex
│   └── conclusiones.tex
├── tablas/                  # Tablas metodológicas (se referencian desde secciones)
├── figuras/                 # Figuras (diagramas de flujo, arquitectura)
├── anexos/
│   ├── anexo_a.tex         # Especificación completa de indicadores
│   └── anexo_b.tex         # Inventario de productos reproducibles (CSV)
```

## Qué etapas están documentadas (COMPLETADAS)

| Etapa | Estado | Detalle |
|-------|--------|---------|
| Selección y auditoría de fuentes (CNPV, IPM, DIVIPOLA) | ✅ Completado | 8 cuadros censales + IPM municipal + DIVIPOLA; validaciones estructurales PASS |
| Definición de unidad de análisis y universo municipal | ✅ Completado | 1.122 municipios, llave `codigo_municipio` (5 chars), homologación verificada |
| Tratamiento territorial (casos especiales) | ✅ Documentado | 20 sin cabecera, 192 sin centro poblado, códigos 94663/27493, ANM, ausencias estructurales |
| Selección de variables e indicadores | ✅ Documentado (provisional) | 14 indicadores especificados; 7 candidatos PCA + 7 descripción/solapamiento IPM |
| Construcción de indicadores (fórmulas, NR, dirección) | ✅ Completado | Base total y base válida; `especificacion_indicadores.csv` como fuente única |
| Control de calidad estructural y estadístico | ✅ Completado | Cero violaciones en validaciones; consistencia conteos, rangos, MD5, duplicados |
| Diagnósticos estadísticos preliminares | ✅ Disponibles | Descriptivos, correlaciones, KMO≈0.642, Bartlett sig., MSA estrato 1-2≈0.414, outliers 32 municipios, sensibilidad NR |
| Reproducibilidad y arquitectura computacional | ✅ Documentado | Pipeline R modular, trazabilidad, prueba integridad byte-a-byte |

## Qué etapas quedan PENDIENTES (explícitamente NO realizadas)

| Etapa | Estado | Comentario |
|-------|--------|------------|
| Auditoría estadística integral | ⏳ Pendiente | Comparar base total vs. válida, transformaciones, parallel analysis, estabilidad, decisión variables problemáticas |
| PCA (ejecución e interpretación) | ⏳ Pendiente | No se ha estimado ningún componente; diagnósticos actuales no deciden si PCA es apropiado |
| Construcción del IVS | ⏳ Pendiente | No existe índice sintético validado |
| Validación externa con IPM | ⏳ Pendiente | IPM reservado como criterio; requiere IVS construido |
| Integración SECOP II | ⏳ Pendiente | Datos no obtenidos; pipeline no implementado; crosswalk territorial pendiente |
| Análisis de asociación | ⏳ Pendiente | Condicionado a IVS + SECOP II |
| Análisis espacial | ⏳ Pendiente | Condicionado a resultados de asociación |

## Decisiones metodológicas clave (resumen)

1. **Universo:** 1.122 municipios CNPV/IPM 2018, sin fusiones ni exclusiones en datos 2018.
2. **Llave:** `codigo_municipio` (texto 5 chars); nunca nombre municipal.
3. **Faltantes:** Sin imputación; ceros estructurales + flags; NA para denominador 0 y 0/0.
4. **No respuesta (NR):** Dos escenarios — base total (incluye NR) y base válida (excluye NR) — como sensibilidad; `no_tiene_estrato` separado.
5. **IPM:** Solo validación externa; indicadores que replican privaciones IPM excluidos de matriz PCA.
6. **17PM:** Total = población 5+ de 1PM; no permite filtrar 10+; `pob_10mas` desde 1PM.
7. **Conflictos territoriales:** No resueltos en 2018; documentados en `crosswalk_enlace.csv` para enlace SECOP futuro.
8. **Indicadores PCA:** 7 provisionales (desocupación, sin energía, sin gas, sin recolección, sin internet, hogares con menores, estrato 1-2) — **requieren aprobación final del autor**.

## Reproducibilidad del pipeline de indicadores

Desde la raíz del repositorio:

```bash
# 1. Verificación consolidados
Rscript R/01_verificar_consolidados.R

# 2. Construcción indicadores y diagnósticos base
Rscript R/02_base_final_indicadores.R

# 3. Auditoría estadística preliminar
Rscript R/03_auditoria_indicadores.R

# 4. Prueba de integridad (opcional)
Rscript R/tests/test_pipeline_indicadores.R
```

Requiere R ≥ 4.0 y paquetes: `readxl`, `readr`, `dplyr`, `tidyr`, `stringr`, `purrr`, `janitor`, `tibble`, `lubridate`, `data.table`.

## Contacto / Responsable

**Juan Diego Gallo** — Investigador en Estadística Aplicada  
Proyecto: Desarrollo Social Económico  
Repositorio: `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent`  
Bóveda Obsidian: raíz del repositorio (`.obsidian/`)