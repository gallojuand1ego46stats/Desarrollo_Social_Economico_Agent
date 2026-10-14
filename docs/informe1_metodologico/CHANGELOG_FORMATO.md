# CHANGELOG_FORMATO — Informe 1 Metodológico

## Fecha: 13 de octubre de 2026
## Versión: 2.0 (Corrección editorial, tipográfica y de maquetación)

---

## 1. Resumen de cambios

Este documento registra las correcciones editoriales, tipográficas y de maquetación aplicadas al **Informe 1 Metodológico** del proyecto *Desarrollo Social Económico*, sin alterar el contenido metodológico ni las decisiones estadísticas.

El objetivo fue adaptar el documento a estándares académicos formales (APA 7.ª edición), con tipografía Times New Roman equivalente, tamaño 11 pt, márgenes de 2.54 cm, interlineado doble, y tablas correctamente ajustadas dentro de los márgenes.

---

## 2. Cambios estructurales y de clase de documento

| Aspecto | Antes | Después |
|---------|-------|---------|
| Clase de documento | `book` (12pt) | `article` (11pt) |
| Tipografía | `lmodern` (Latin Modern) | `newtxtext` / `newtxmath` (Times New Roman equivalente) |
| Márgenes | Asimétricos (left=3cm, right=2.5cm, top=2.5cm, bottom=2.5cm) | Simétricos 2.54 cm (APA 7) |
| Interlineado | `\onehalfspacing` (1.5) | `\doublespacing` (2.0, APA 7) |
| Sangría primera línea | Default | 1.27 cm (APA 7) |
| Encabezados de sección | `\chapter`, `\section`, `\subsection` | `\section`, `\subsection`, `\subsubsection` |
| Portada | Entorno `titlepage` con `\include` | Entorno `titlepage` con `\input` |
| Bibliografía | `apalike` (sin cambios) | `apalike` (sin cambios) |
| Anexos | `\appendix` + `\include{anexos/anexo_a}` | `\appendix` + `\section*{Anexos}` + `\input{anexos/anexo_a}` |

---

## 3. Correcciones de comandos LaTeX problemáticos

### 3.1 Eliminación de `\\` espurios antes de `\section`
Se detectaron y corrigieron líneas con `\\section{...}` (doble barra invertida) en los siguientes archivos:
- `secciones/metodologia.tex` (línea 1)
- `secciones/marco_conceptual.tex` (línea 1)
- `secciones/preparacion_pca.tex` (línea 1)
- `secciones/limitaciones.tex` (línea 1)
- `secciones/estado_proyecto.tex` (línea 1 — ya correcto, se verificó)

Estos causaban errores `! LaTeX Error: There's no line here to end.`

### 3.2 Cambio de `\chapter` a `\section`
Todos los archivos en `secciones/` y `anexos/` usaban `\chapter{...}` (propio de clase `book`). Se cambiaron a `\section{...}` compatible con clase `article`.
- Archivos afectados: 15 archivos en `secciones/` + 2 en `anexos/`
- Las etiquetas `\label{ch:...}` se mantuvieron para compatibilidad de referencias cruzadas.

### 3.3 Front matter (`\frontmatter`/`\mainmatter`/`\appendix`)
- Se eliminaron `\frontmatter`, `\mainmatter`, `\appendix` (propios de `book`).
- La numeración de páginas romanas/arábigas se gestiona manualmente con `\pagenumbering{roman}` y `\pagenumbering{arabic}`.
- Los anexos ahora usan `\appendix` + `\section*{Anexos}` + `\input{...}`.

---

## 4. Tablas — Correcciones de desbordamiento (Overfull \hbox)

Todas las tablas que excedían el ancho de texto (`\textwidth`) se envolvieron en `\begin{adjustbox}{max width=\textwidth}...\end{adjustbox}` para garantizar que no sobresalgan de los márgenes.

### Tablas corregidas:

| Archivo | Tabla (caption) | Ajuste aplicado |
|---------|-----------------|-----------------|
| `fuentes.tex` | `tab:fuentes_cnpv` | `adjustbox` |
| `fuentes.tex` | `tab:justificacion_fuentes` | `adjustbox` |
| `unidad_analisis.tex` | `tab:decisiones_territoriales` | `adjustbox` |
| `seleccion_bases.tex` | `tab:cuadros_seleccionados` | `adjustbox` |
| `indicadores.tex` | `tab:denominadores` | `adjustbox` |
| `indicadores.tex` | `tab:direccion_vulnerabilidad` | `adjustbox` |
| `control_calidad.tex` | `tab:validaciones_estructurales` | `adjustbox` |
| `control_calidad.tex` | `tab:cobertura_calidad` | `adjustbox` |
| `diagnostico.tex` | `tab:estadisticos_descriptivos` | `adjustbox` |
| `diagnostico.tex` | `tab:diagnosticos_aptitud` | `adjustbox` |
| `tratamiento_faltantes.tex` | `tab:decisiones_faltantes` | `adjustbox` |
| `reproducibilidad.tex` | `tab:scripts_principales` | `adjustbox` |
| `reproducibilidad.tex` | `tab:trazabilidad` | `adjustbox` |
| `estado_proyecto.tex` | `tab:estado_proyecto` | `adjustbox` |
| `conclusiones.tex` | `tab:problemas_detectados` | `adjustbox` |
| `anexos/anexo_a.tex` | `tab:especificacion_indicadores` | `adjustbox` (ya tenía, se verificó) |

**Nota:** Las tablas que ya cabían dentro de los márgenes (ej. `tab:universo_municipal`, `tab:diagnosticos_aptitud` simple) no se modificaron.

---

## 5. Páginas en blanco y saltos de página

### 5.1 Uso de `\clearpage` vs `\include`
- Se cambió `\include{secciones/...}` por `\input{secciones/...}` en todo el documento principal para evitar saltos de página forzados por `\include` (que siempre empieza en página impar en clase `book`).
- Se añadieron `\clearpage` estratégicos entre secciones mayores para control de flujo.

### 5.2 Páginas preliminares
- Portada: `\input{secciones/portada}` + `\clearpage`
- Resumen y palabras clave: `\input{...}` + `\clearpage`
- TOC, LOT, LOF: cada uno seguido de `\clearpage`

### 5.3 Resultado
- Se eliminaron páginas completamente en blanco no justificadas.
- Solo quedan páginas en blanco intencionales: reverso de portada, y separadores entre partes mayores (TOC, LOT, LOF, Bibliografía, Anexos).

---

## 6. Duplicaciones de texto detectadas y eliminadas

### 6.1 Resumen y Palabras clave
- Se cambió `\chapter*{Resumen}` / `\chapter*{Palabras clave}` a `\section*{...}` con `\addcontentsline{toc}{section}{...}` para que aparezcan en el TOC sin numerar.

### 6.2 Verificación de contenido duplicado
- Se revisaron todas las secciones: no se encontraron párrafos idénticos repetidos.
- Las referencias cruzadas (ej. "ver Sección X") se mantuvieron y ahora apuntan correctamente tras la recompilación.

---

## 7. Adaptación a APA 7.ª edición

| Elemento | Implementación |
|----------|----------------|
| Márgenes | 2.54 cm (geometry `margin=2.54cm`) |
| Fuente | Times New Roman equivalente (`newtxtext`/`newtxmath`) |
| Tamaño fuente | 11 pt (`\documentclass[11pt]{article}`) |
| Interlineado | Doble (`\doublespacing` via `setspace`) |
| Sangría primera línea | 1.27 cm (`\setlength{\parindent}{1.27cm}`) |
| Espaciado entre párrafos | 0 pt (`\setlength{\parskip}{0pt}`) |
| Alineación | Justificada (default), con `\RaggedRight` en captions |
| Encabezados | Jerarquía: Section > Subsection > Subsubsection |
| Numeración páginas | Árabe continua (romana solo en front matter) |
| Citas y referencias | `natbib` + `apalike` (estilo APA-like) |
| Captions de tablas/figuras | `\captionsetup{labelfont=bf, textfont=it, justification=raggedright, singlelinecheck=false}` |

---

## 8. Referencias cruzadas y bibliografía

- Se ejecutó `pdflatex` → `bibtex` → `pdflatex` × 2 para resolver todas las referencias.
- Advertencias de referencias indefinidas resueltas (labels `ch:...` ahora resuelven como `section.X.Y`).
- Bibliografía `apalike` procesada correctamente (15 entradas).
- Citaciones en texto (`\citep`, `\citet`) funcionan correctamente.

---

## 9. Problemas no resueltos / Limitaciones conocidas

| Problema | Descripción | Impacto |
|----------|-------------|---------|
| `Command \Bbbk already defined` | Conflicto entre `newtxmath` y `amssymb` | Solo warning en log; no afecta salida PDF |
| Overfull \hbox en verbatim/code | Rutas largas y código en `\verb`/`verbatim` exceden margen | Solo warnings; legibilidad mantenida |
| Overfull \hbox en párrafos normales | Palabras largas sin separación silábica (ej. rutas de archivos) | Solo warnings; no afecta legibilidad |
| `\Bbbk already defined` | Conflicto `newtxmath` + `amssymb` | Cosmético; no afecta salida |
| Font `t1xbtt`, `t1xttsl` no encontradas | Fuentes txfonts no instaladas en MiKTeX | Se generan PK automáticamente; PDF correcto |

**Nota:** Ninguno de estos problemas afecta la corrección visual o científica del PDF final.

---

## 10. Archivos modificados

### Archivos principales
- `main.tex` — Reescrito completamente (clase, paquetes, estructura, front matter)
- `secciones/portada.tex` — Ajustado para `\input` y `\clearpage`
- `secciones/resumen.tex` — `\section*` + `addcontentsline`
- `secciones/palabras_clave.tex` — `\section*` + `addcontentsline`

### Secciones (15 archivos)
- `secciones/introduccion.tex`
- `secciones/metodologia.tex` (corregido `\\section`)
- `secciones/marco_conceptual.tex` (corregido `\\section`, actualizada ref `sec:auditoria_pendiente_limitaciones`)
- `secciones/fuentes.tex` (tablas con `adjustbox`)
- `secciones/unidad_analisis.tex` (tablas con `adjustbox`)
- `secciones/seleccion_bases.tex` (tabla con `adjustbox`)
- `secciones/tratamiento_faltantes.tex` (tabla con `adjustbox`)
- `secciones/indicadores.tex` (tablas con `adjustbox`)
- `secciones/control_calidad.tex` (tablas con `adjustbox`)
- `secciones/diagnostico.tex` (tablas con `adjustbox`, actualizada ref `sec:auditoria_pendiente_limitaciones`)
- `secciones/preparacion_pca.tex` (corregido `\\section`)
- `secciones/reproducibilidad.tex` (tablas con `adjustbox`)
- `secciones/limitaciones.tex` (corregido `\\section`, label `sec:auditoria_pendiente_limitaciones`)
- `secciones/estado_proyecto.tex` (tabla con `adjustbox`)
- `secciones/conclusiones.tex` (tabla con `adjustbox`)

### Anexos (2 archivos)
- `anexos/anexo_a.tex` — Ya correcto (usaba `longtable`/`adjustbox`)
- `anexos/anexo_b.tex` — Ya correcto (estructura `section`/`subsection`)

### Archivos de soporte
- `referencias.bib` — Sin cambios (15 entradas APA-like)
- `README_Informe1.md` — Sin cambios (documentación del proyecto)

---

## 11. Resultado de compilación final

```
Output written on main.pdf (68 pages, 461393 bytes).
Transcript written on main.log.
```

- **Páginas:** 68
- **Tamaño:** 461 KB
- **Errores:** 0
- **Warnings:** Solo overfull/underfull hbox (cosméticos), `\Bbbk already defined` (conflicto de paquetes), fuentes PK generadas automáticamente
- **Referencias cruzadas:** Resueltas (2 pasadas + bibtex + 2 pasadas)
- **Bibliografía:** 15 entradas procesadas con `apalike`

---

## 12. Verificación visual del PDF final

| Elemento | Estado |
|----------|--------|
| Portada | ✅ Correcta |
| Resumen / Palabras clave | ✅ En TOC, formato correcto |
| Tabla de contenidos | ✅ Completa, numeración correcta |
| Lista de tablas | ✅ 21 tablas listadas |
| Lista de figuras | ✅ Vacía (no hay figuras) |
| Cuerpo principal (15 secciones) | ✅ Numeración 1–15, jerarquía correcta |
| Tablas (21) | ✅ Todas dentro de márgenes, captions APA |
| Bibliografía | ✅ 15 entradas, formato APA-like |
| Anexos (A, B) | ✅ En TOC, formato apéndice |
| Páginas en blanco accidentales | ✅ Eliminadas |
| Textos duplicados | ✅ No detectados |
| Tipografía | ✅ Times New Roman equivalente, 11 pt |
| Márgenes | ✅ 2.54 cm |
| Interlineado | ✅ Doble |

---

## 13. Archivo final entregado

**`docs/informe1_metodologico/Informe1_Metodologico.pdf`** (461 KB, 68 páginas)

Compilado con:
```bash
cd docs/informe1_metodologico
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

---

**Fin del CHANGELOG_FORMATO.md**