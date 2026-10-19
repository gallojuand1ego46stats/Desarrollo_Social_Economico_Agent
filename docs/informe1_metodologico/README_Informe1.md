# Informe 1 metodológico

Versión vigente: **2.1**, actualización al **18 de octubre de 2026**. El documento describe la extracción y auditoría de los consolidados DANE/IPM, las decisiones sobre variables, los indicadores candidatos, sus sensibilidades, el diccionario operativo y el estado anterior al primer PCA.

## Productos

- `main.tex`: punto de entrada LaTeX.
- `Informe1_Metodologico.pdf`: informe compilado.
- `referencias.bib`: fuentes teóricas, estadísticas y técnicas.
- `secciones/portada.tex`, `secciones/resumen.tex` y `secciones/actualizacion/`: módulos del informe.
- `secciones/actualizacion/diccionario_operativo_variables.tex`: diccionario de cuadros, variables, categorías, denominadores y uso analítico.
- `secciones/actualizacion/formulas_pruebas_auditoria.tex`: fórmulas de indicadores, controles y pruebas organizadas por etapa; distingue diagnósticos históricos de los pendientes para el PCA actual.
- `anexos/`: catálogo de procedencia y reproducibilidad.

## Compilar

Desde esta carpeta, con MiKTeX/TeX Live y BibTeX instalados:

```powershell
pdflatex -interaction=nonstopmode main.tex
bibtex main
pdflatex -interaction=nonstopmode main.tex
pdflatex -interaction=nonstopmode main.tex
Copy-Item main.pdf Informe1_Metodologico.pdf -Force
```

`main.pdf` es una salida local de compilación e idéntica a la copia canónica `Informe1_Metodologico.pdf`; no se versiona por separado. La última compilación verificable del documento queda publicada bajo el nombre canónico.

## Reproducir la actualización vigente

La actualización del 18 de octubre se recalcula desde la raíz del repositorio con R 4.6.0:

```powershell
python -m pip install -r requirements-analysis.txt
Rscript R/06_descriptivos_sensibilidades_ivs.R
python R/auxiliares/cotejar_extremos_descriptivos.py
```

`R/06` usa R base y lee las tablas intermedias versionadas en `datos/intermedio/`; no reconstruye los consolidados desde los libros Excel, no ejecuta PCA y no calcula un IVS. El auxiliar de Python coteja extremos contra el libro consolidado y requiere Python 3.12 con `openpyxl==3.1.5`.

`R/05_conformar_indicadores_finales.R` reproduce la matriz candidata histórica del 15 de octubre, que contiene nueve columnas, incluida 17PM como variable educativa reservada. No equivale a la especificación vigente de ocho candidatas del primer PCA. Las etapas históricas `R/01`–`R/05` tienen dependencias adicionales y no están fijadas en un entorno `renv.lock`; esta documentación no afirma que el flujo completo desde Excel sea reproducible en cualquier dispositivo.

## Bóveda Obsidian

La nota de navegación es [`Informe_Metodologico_Obsidian.md`](../../Informe_Metodologico_Obsidian.md); el resumen general del repositorio enlaza esa nota. El informe fuente y su PDF permanecen en esta carpeta.
