# Desarrollo Social y Económico

## Introducción

Este proyecto estudia cómo se distribuyen territorialmente distintas condiciones socioeconómicas en Colombia usando información municipal agregada del Censo Nacional de Población y Vivienda (CNPV) de 2018. A partir de esa información se preparan indicadores candidatos que, después de su evaluación metodológica, podrían resumirse en un índice de vulnerabilidad socioeconómica (IVS).

En una etapa posterior, el proyecto busca examinar la relación entre esas condiciones territoriales y la contratación pública registrada en SECOP II, con prioridad en los contratos de 2026. El análisis conecta fuentes y periodos distintos; por eso documenta la cobertura, las equivalencias territoriales y las limitaciones de cada fuente antes de interpretar los resultados.

## Objetivos

### Objetivo general

Describir las condiciones socioeconómicas a escala municipal con información del CNPV 2018 y evaluar si un conjunto transparente y metodológicamente defendible de indicadores permite caracterizar patrones territoriales de vulnerabilidad, para estudiar posteriormente su asociación con la contratación pública de SECOP II.

### Objetivos específicos

1. Organizar y auditar las fuentes censales y sus identificadores territoriales, dejando trazabilidad de cobertura, consistencia y transformaciones.
2. Definir indicadores candidatos con sus fuentes, fórmulas, denominadores, dirección e interpretación documentados.
3. Calcular los indicadores municipales y describir sus distribuciones, calidad y sensibilidad a decisiones de fórmula, denominador y universo territorial.
4. Evaluar, cuando se hayan resuelto las decisiones metodológicas pendientes, la pertinencia y estabilidad de un análisis de componentes principales (PCA); construir un IVS solo si sus resultados son interpretables y robustos.
5. En la etapa posterior, integrar la información territorial con SECOP II y estudiar asociaciones entre los indicadores o el IVS y la contratación pública, documentando las diferencias de cobertura y periodo.
6. Usar el Índice de Pobreza Multidimensional (IPM) como referencia externa para contrastar resultados, no como insumo para calcular el PCA.

## Alcance e interpretación

El proyecto desarrolla una base empírica y metodológica para analizar patrones territoriales de vulnerabilidad socioeconómica. La selección de indicadores se apoya en fuentes identificables, definiciones y denominadores explícitos, auditorías de calidad, análisis de sensibilidad y evaluación de su coherencia estadística. La síntesis mediante PCA y la eventual propuesta de un IVS están condicionadas a que las decisiones de universo y comparabilidad territorial estén resueltas y a que los resultados sean estables e interpretables.

La unidad de análisis es el municipio y los indicadores representan condiciones agregadas de cada territorio. La vulnerabilidad se aborda como un fenómeno multidimensional, distinto de la pobreza monetaria; el IPM se utiliza como referencia externa para contrastar los resultados. Las conclusiones se refieren a patrones y asociaciones territoriales: no describen necesariamente la situación de cada persona ni, por sí solas, demuestran relaciones causales.

La etapa prevista con SECOP II permitirá examinar cómo se relacionan las condiciones territoriales con la contratación pública. Como el CNPV corresponde a 2018 y la contratación priorizada a 2026, la integración documentará cobertura, equivalencias geográficas y diferencias de periodo, y sus hallazgos se interpretarán como asociaciones entre fuentes y momentos distintos.

## Estado metodológico

Al 20 de octubre de 2026 se han auditado los consolidados CNPV/IPM y se han calculado ocho indicadores candidatos, junto con análisis descriptivos y de sensibilidad. El diagnóstico actual de las ocho candidatas obtuvo KMO 0,6724 y Bartlett nominal χ²(28) = 4.305,69 (p < 0,001), con adecuación moderada y los ocho MSA > 0,50. Su sensibilidad y límites están documentados en el informe. Siguen pendientes decisiones sobre el universo territorial y la correspondencia entre códigos territoriales; también están pendientes el PCA exploratorio, la eventual construcción de un IVS y la integración con SECOP II. Por ello, los resultados disponibles son insumos de trabajo y no constituyen un índice final ni validado.

## Documentación vigente

- [Informe metodológico v2.2 (PDF)](docs/informe1_metodologico/Informe1_Metodologico.pdf)
- [Estado y navegación del informe](Informe_Metodologico_Obsidian.md)
- [KMO, MSA y Bartlett vigentes del 20 de octubre](docs/calidad/auditorias/KMO_BARTLETT_20261020.md)
- [Decisiones, fuentes y salidas de la actualización descriptiva del 18 de octubre](docs/calidad/auditorias/ACTUALIZACION_DESCRIPTIVA_20261018.md)
- [Control de entrega y verificaciones](docs/calidad/auditorias/CONTROL_ENTREGA_DESCRIPTIVA_20261018.md)
- [Auditoría complementaria de la línea base del 15 de octubre](docs/calidad/auditorias/RESUMEN_EJECUTIVO_AUDITORIA.md)
- [Informe completo de auditoría de la línea base](docs/calidad/auditorias/INFORME_METODOLOGICO_REVISION_FINAL.pdf)
- [Fórmulas de indicadores del 15 de octubre](docs/metodologia/Formulas_indicadores_IVS_candidatos_2026-10-15.md)
- [Diccionario de decisiones de variables](docs/diccionario/decisiones_variables_IVS_CNPV2018.csv)
- [Decisiones abiertas](Solucion_pendientes.md)
- [Mapa del repositorio](docs/estructura_repositorio.md)

## Estructura principal

- `R/`: configuración, extracción, auditorías y cálculo de indicadores.
- `data/`: estructura de ingesta inicial; `R/00_ingesta_fuentes.R` guarda allí descargas de DIVIPOLA, IPM y muestras SECOP II.
- `datos/`: libros fuente y tablas intermedias agregadas.
- `resultados/`: controles de calidad, matrices candidatas y sensibilidades.
- `docs/`: metodología, diccionarios, informes y auditorías.
- `nada-sin-fuente/`: entregable independiente del curso de Consultoría, con su propio [README](nada-sin-fuente/README.md).

## Reproducción de la actualización más reciente

La actualización del 18 de octubre se puede recalcular desde la raíz con R 4.6.0. `R/06` usa R base y parte de las tablas intermedias versionadas en `datos/intermedio/`; genera los resultados en `resultados/descriptivos_sensibilidades_20261018/`. El cotejo independiente contra el libro consolidado usa Python 3.12 y `openpyxl` 3.1.5:

```sh
python -m pip install -r requirements-analysis.txt
Rscript R/06_descriptivos_sensibilidades_ivs.R
python R/auxiliares/cotejar_extremos_descriptivos.py
```

La actualización recalcula las ocho fórmulas, descriptivos y sensibilidades. No ejecuta PCA ni calcula un IVS. Este procedimiento reproduce esa actualización desde las tablas intermedias; no representa una reconstrucción completa desde los libros originales ni ejecuta las etapas históricas `R/01`–`R/05`. El flujo activo de GitHub Actions construye el sitio de documentación y no ejecuta el análisis estadístico.

La auditoría independiente de consistencia revisa la línea base del 15 de octubre y se conserva como documento complementario, no como estado metodológico vigente. El informe versión 2.2 del 20 de octubre es la referencia actual.

El diagnóstico vigente y su cotejo numérico se ejecutan con R base:

```sh
Rscript --vanilla R/07_kmo_bartlett_candidatas.R
Rscript --vanilla R/auxiliares/verificar_kmo_bartlett.R
```

El verificador está organizado en [seis módulos comentados](R/funciones/verificacion_kmo/README.md). Reconstruye los cálculos mediante una implementación distinta del script principal y concilia cinco controles globales y los ocho MSA. La versión comprobada es R 4.6.0 y no requiere paquetes adicionales. Las salidas están en `resultados/kmo_bartlett_20261020/`; el cotejo previo en Python se conserva identificado como histórico en `historico_python/`.
