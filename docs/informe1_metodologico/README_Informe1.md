# Informe 1 metodológico

Versión vigente: **2.2**, actualización al **20 de octubre de 2026**. KMO/MSA y Bartlett ya están calculados para las ocho candidatas; PCA e IVS siguen pendientes. El documento describe la extracción y auditoría de los consolidados DANE/IPM, las decisiones sobre variables, los indicadores candidatos, sus sensibilidades, el diccionario operativo y el estado anterior al primer PCA.

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

## Diagnóstico vigente de adecuación del 20 de octubre

```powershell
Rscript R/07_kmo_bartlett_candidatas.R
Rscript --vanilla R/auxiliares/verificar_kmo_bartlett.R
```

R/07 y el cotejo vigente usan R base, con R 4.6.0 comprobado. El verificador modular reconstruye Pearson con productos cruzados y utiliza inversión general, determinante LU y cola chi-cuadrado finita en logaritmos. No importa el código de R/07. Para 1.102 unidades y ocho candidatas: KMO 0,6724059; Bartlett chi-cuadrado 4.305,6886, gl 28 y p nominal <0,001; todos los MSA principales >0,50. Los supuestos y sensibilidades se describen en el informe y `resultados/kmo_bartlett_20261020/`. No se ejecutó PCA.

La organización y las salidas del verificador se explican en [`R/funciones/verificacion_kmo/README.md`](../../R/funciones/verificacion_kmo/README.md). El PDF versión 2.2 documenta el cotejo original en Python/NumPy, preservado ahora en `historico_python/`; la sustitución del código por R no modifica ese PDF ni los resultados principales. El estado del cotejo vigente está en `estado_verificacion_R.csv` y sus diferencias en `verificacion_independiente_R.csv` y `verificacion_MSA_R.csv`.

## Cotejo de tablas y control del PDF

Después de generar las salidas y disponer del informe compilado:

```sh
python -m pip install -r requirements-analysis.txt
python R/auxiliares/verificar_entrega_descriptiva.py
python R/auxiliares/verificar_entrega_kmo.py
```

Estos auxiliares cotejan cifras y archivos; no recalculan el diagnóstico estadístico. `requirements-analysis.txt` fija `openpyxl` para el cotejo con Excel y `pypdf` para leer el PDF. Si no hay un log local de LaTeX, el control de compilación se informa como no realizado. El auxiliar KMO funciona sin presentaciones ni guiones: la revisión opcional de esos materiales locales requiere `--materiales-exposicion` y `python-docx==1.2.0`. La actualización pública excluye los materiales de exposición, sus controles y las carpetas temporales.

## Bóveda Obsidian

La nota de navegación es [`Informe_Metodologico_Obsidian.md`](../../Informe_Metodologico_Obsidian.md); el resumen general del repositorio enlaza esa nota. El informe fuente y su PDF permanecen en esta carpeta.
