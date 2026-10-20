# Verificación numérica independiente en R

Este módulo sustituye el cotejo numérico que antes se ejecutaba en Python. Usa **R base** y `tools::sha256sum`; la versión comprobada es **R 4.6.0**. No instala paquetes ni depende de NumPy, `psych`, `digest` o `jsonlite`.

## Ejecución

```sh
Rscript --vanilla R/auxiliares/verificar_kmo_bartlett.R
```

Primero debe existir la salida principal de `R/07_kmo_bartlett_candidatas.R`. El verificador puede iniciarse desde otra carpeta indicando la ruta del archivo R; deduce la raíz a partir de su ubicación. En RStudio puede cargarse con `source()` y ejecutarse mediante `verificar_kmo_bartlett("ruta/al/repositorio")`.

## Organización

- `configuracion.R`: columnas acordadas, rutas, dimensiones y tolerancias.
- `entrada.R`: CSV UTF-8, códigos con ceros iniciales, rangos, finitud, variación y huellas.
- `calculos.R`: Pearson por productos cruzados, KMO/MSA, inversa general, determinante LU y cola de Bartlett en logaritmos.
- `comparacion.R`: lectura de referencias después del cálculo, selección inequívoca del escenario y alineación de MSA por nombre.
- `salidas.R`: controles globales y por indicador, resumen CSV/RDS, entorno e integridad SHA-256.
- `flujo.R`: orden de ejecución, estado de la corrida, errores y resumen de consola.

## Independencia del cotejo

El cálculo principal utiliza `cor()`, Cholesky, `chol2inv()` y `pchisq()`. Este cotejo reconstruye Pearson mediante centrado, estandarización y `crossprod()`, usa `solve()` y `determinant()` con LU y calcula la supervivencia chi-cuadrado mediante una suma finita para grados de libertad pares evaluada con log-sum-exp. No importa código de R/07 ni utiliza sus resultados para calcular las cifras independientes.

La independencia es de **implementación**, no de lenguaje o plataforma: ambas ejecuciones usan R y pueden compartir LAPACK. Este control no sustituye una auditoría externa ni la validación conceptual del índice.

La cola finita requiere grados de libertad pares positivos; con ocho candidatas son 28. Otro caso provoca un error explícito. La correlación debe ser definida positiva; no se aplica imputación, eliminación de territorios, pseudoinversa o regularización. Los autovalores solo comprueban estabilidad numérica, sin estimar o interpretar componentes de PCA.

## Controles y resultados

Se concilian KMO, el máximo error de los MSA, chi-cuadrado, log-p y log-determinante, además de los ocho MSA por separado. Tolerancias absolutas: KMO/MSA y log-determinante `1e-12`; estadístico y log-p `1e-8`. La matriz y las dos tablas de referencia deben conservar sus huellas antes y después.

Las salidas en `resultados/kmo_bartlett_20261020/` son:

- `verificacion_independiente_R.csv`: cinco conciliaciones globales.
- `verificacion_MSA_R.csv`: cotejo de cada una de las ocho candidatas.
- `resumen_verificacion_R.csv` y `.rds`: resultados, dimensión y diagnósticos numéricos.
- `manifest_sha256.csv`: matriz, referencias, script principal y módulos utilizados.
- `integridad_verificacion_R.csv`: huellas de los insumos antes y después.
- `sessionInfo_verificacion_R.txt`: entorno empleado.
- `estado_verificacion_R.csv`: `en_curso`, `aprobado` o `fallido`. Una ejecución fallida no autoriza reutilizar salidas anteriores como si fueran de esa corrida.

Los resultados previos de Python se conservan identificados como históricos. El PDF metodológico existente documenta aquella ejecución; los comandos vigentes están en este README y en la guía del informe.

## Referencias de implementación

- [R: solve y las rutinas LAPACK](https://stat.ethz.ch/R-manual/R-devel/library/base/html/solve.html).
- [R: determinante mediante LU](https://stat.ethz.ch/R-manual/R-devel/library/base/html/det.html).
- [R: distribución chi-cuadrado](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/Chisquare.html).
- [R: SHA-256 de archivos](https://stat.ethz.ch/R-manual/R-devel/library/tools/html/sha256sum.html).
