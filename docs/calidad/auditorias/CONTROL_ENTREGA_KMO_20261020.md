# Control de entrega de KMO y Bartlett — 20 de octubre de 2026

## Alcance de esta actualización

Se publica el Informe 1 metodológico versión 2.2, sus fuentes LaTeX, el cálculo principal `R/07_kmo_bartlett_candidatas.R`, el verificador modular en R, los auxiliares de cotejo y las salidas técnicas que permiten auditar las cifras. Los materiales de exposición, sus controles de formato y sincronización, y las carpetas temporales se mantienen locales y se excluyen mediante `.gitignore`.

## Evidencia numérica disponible

La ejecución registrada del verificador en R, del 20 de octubre de 2026, tiene estado `aprobado`: cinco conciliaciones globales y ocho MSA dentro de tolerancia. Sus archivos son:

- `verificacion_independiente_R.csv`: KMO, máximo error de MSA, chi-cuadrado, log-p y log-determinante.
- `verificacion_MSA_R.csv`: conciliación de las ocho candidatas.
- `estado_verificacion_R.csv`: resultado y fecha de la ejecución.
- `integridad_verificacion_R.csv`: huellas SHA-256 de los insumos antes y después.
- `manifest_sha256.csv`: matriz, tablas de referencia y código utilizado.
- `sessionInfo_verificacion_R.txt`: entorno de R.

Los archivos anteriores están en `resultados/kmo_bartlett_20261020/`. El script principal conserva además `controles.csv`, `integridad_insumos.csv` y `sessionInfo.txt`. Estas evidencias corresponden a las ejecuciones ya registradas; la preparación para publicar no constituye una nueva corrida estadística ni una nueva revisión documental.

## Cifras principales y alcance

Para 1.102 unidades y ocho candidatas: KMO = 0,6724059000; Bartlett chi-cuadrado = 4.305,6886379, gl = 28; log10(p nominal) = −901,4308951. Los ocho MSA principales superan 0,50. El diagnóstico muestra adecuación moderada para continuar la exploración; no demuestra una dimensión única, un IVS validado ni asociación con SECOP II.

La calibración inferencial de Bartlett es nominal: normalidad multivariada e independencia espacial no están acreditadas. No se ejecutó PCA ni se construyó un IVS. Las fórmulas, sensibilidades y referencias se explican en [KMO_BARTLETT_20261020.md](KMO_BARTLETT_20261020.md).

## Informe publicado y trazabilidad histórica

El PDF versión 2.2 tiene 48 páginas. Su SHA-256 es `f8881213717734ecb377bd511ecc6ae24cd490d8c02f3070cf253cdf218683b7`. Ese PDF documenta el cotejo original con Python/NumPy; sus dos archivos de resultados se preservan, claramente rotulados, en `historico_python/`. El código numérico vigente se sustituyó por R y sus resultados coinciden dentro de tolerancia.

Las fuentes LaTeX y las guías de reproducción reflejan la sustitución por R. El PDF no se recompiló durante esta preparación para GitHub; por ello conserva la descripción histórica del cotejo en Python. Se distingue expresamente el documento compilado de la implementación vigente.

## Auxiliares de control documental

```sh
python -m pip install -r requirements-analysis.txt
python R/auxiliares/cotejar_extremos_descriptivos.py
python R/auxiliares/verificar_entrega_descriptiva.py
python R/auxiliares/verificar_entrega_kmo.py
```

El primer auxiliar requiere el Excel consolidado y las salidas de R/06; los otros comparan los CSV y las tablas con el PDF. El control de KMO lee las conciliaciones producidas en R y no recalcula los estadísticos. Su ejecución por defecto publica únicamente controles del informe, en `control_entrega_informe.csv` e `informe_sha256.csv`; esos archivos se generan al ejecutar el auxiliar y no se presentan como evidencia de una ejecución nueva en esta actualización.

Los logs de compilación son locales: cuando no existe `main.log`, los auxiliares informan que ese control no se realizó. Para revisar también los materiales de exposición locales, el auxiliar de KMO admite `--materiales-exposicion` y requiere adicionalmente `python-docx==1.2.0`. Esa opción exige los PPTX, DOCX y JSON excluidos de GitHub. Las salidas de exposición quedan ignoradas por Git.
