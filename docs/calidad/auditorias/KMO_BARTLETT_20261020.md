# Diagnóstico vigente de ocho candidatas al 20 de octubre de 2026

Se ejecutan KMO global, MSA individual y Bartlett por solicitud expresa del equipo. La matriz principal es `resultados/descriptivos_sensibilidades_20261018/matriz_ocho_municipal_e_insular_0_1.csv`: 1.102 unidades (1.101 municipios/distritos y San Andrés), ocho columnas, sin NA. Se mantienen indicadores y observaciones. No se ejecuta PCA ni se construye un IVS.

## Resultado principal

- KMO global: **0,6724059000**, adecuación moderada según la escala convencional.
- MSA: 1HM 0,577981; 2HM 0,555317; 6V 0,764925; energía 0,784206; gas 0,712314; internet 0,648935; 10V 0,678102; 5PM 0,630254. Todos >0,50.
- Bartlett: **chi-cuadrado 4.305,6886379; gl 28; p nominal <0,001**.
- Log10(p nominal) = −901,4308951; probabilidad aproximada 3,707703 × 10⁻⁹⁰². El p ordinario se deja vacío al subdesbordar y se activa `p_subdesbordamiento`. No se interpreta como cero matemático.
- Determinante 0,0197781257; rango completo; Cholesky válida; condición espectral 23,7513. No se usa pseudoinversa ni regularización.

## Sensibilidad y alcance

Sin San Andrés KMO = 0,673223; con los 1.122 códigos censales = 0,675780. La geografía futura no se decide por estos valores. Spearman produce KMO = 0,748906, como sensibilidad descriptiva de rangos, sin p Bartlett.

5PM peso 1:1: KMO = 0,667605, pero MSA de 5PM = 0,413704. 10V total: KMO = 0,546254, MSA de 10V = 0,392617 y dos MSA <0,50. No se cambian variables o fórmulas para optimizar KMO.

Hay evidencia para continuar explorando reducción de dimensión, sin demostrar un factor único, un IVS válido o asociación contractual. La calibración chi-cuadrado de Bartlett es nominal: estos agregados censales acotados no acreditan normalidad multivariada ni independencia espacial. No se extrapola a otros años ni se infiere causalidad.

## Reproducción y cotejo

```text
Rscript R/07_kmo_bartlett_candidatas.R
Rscript --vanilla R/auxiliares/verificar_kmo_bartlett.R
```

R/07 y el cotejo numérico vigente usan R base 4.6.0. El verificador se organiza en seis módulos comentados en `R/funciones/verificacion_kmo/`: configuración, entrada, cálculos, comparación, salidas y flujo. Reconstruye Pearson mediante productos cruzados, usa inversión general, determinante LU y la identidad finita de cola chi-cuadrado para gl pares evaluada en logaritmos. No reutiliza el código de cálculo de R/07. Aprueban cinco conciliaciones globales y ocho conciliaciones individuales de MSA: tolerancia 1e-12 para KMO/MSA y log-determinante; 1e-8 para estadístico y log-p. No se instaló ni ejecutó `psych`.

La independencia es de implementación, no de plataforma: ambos flujos usan R y pueden compartir bibliotecas numéricas. La matriz y las tablas de referencia conservan sus huellas SHA-256 antes y después del cotejo. La implementación rechaza una matriz no definida positiva o una cola con grados de libertad impares, sin introducir pseudoinversa, regularización o aproximaciones silenciosas.

Las salidas están en `resultados/kmo_bartlett_20261020/`. El cálculo principal conserva `integridad_insumos.csv`, `controles.csv` y `sessionInfo.txt`. El cotejo actual produce `verificacion_independiente_R.csv`, `verificacion_MSA_R.csv`, `resumen_verificacion_R.csv` y `.rds`, `integridad_verificacion_R.csv`, `sessionInfo_verificacion_R.txt` y `estado_verificacion_R.csv`. `manifest_sha256.csv` identifica la matriz, referencias y código de ambas implementaciones. La matriz z es exclusiva del diagnóstico, sin componentes ni puntajes.

El cotejo previo en Python/NumPy se conserva en `historico_python/`, identificado como registro anterior. El PDF versión 2.2 describe aquella corrida original; esta sustitución del verificador mantiene las cifras y no recompila el informe.

El Informe 1 versión 2.2 conserva los diagnósticos históricos identificados como históricos y añade resultados, fórmulas, interpretación y sensibilidades actuales. Presentación y guiones usan esas mismas cifras. La auditoría nada-sin-fuente mantiene sus resultados registrados y sus pendientes de confirmación.

## Referencias de implementación

- [Kaiser y Rice 1974](https://doi.org/10.1177/001316447403400115).
- [Bartlett 1951](https://doi.org/10.1093/biomet/38.3-4.337).
- [Documentación oficial psych KMO](https://personality-project.org/r/psych/help/KMO.html).
- [Documentación CRAN EFAtools Bartlett](https://search.r-project.org/CRAN/refmans/EFAtools/html/BARTLETT.html).

Consulta de documentación: 20 de octubre de 2026. Las cifras se calculan con la matriz local.
