---
tags: [metodologia, IVS, auditoria, sensibilidad]
---

# Actualización descriptiva del informe — 18 de octubre de 2026

## Alcance autorizado y decisiones

Entregable principal: [[docs/informe1_metodologico/Informe1_Metodologico.pdf|Informe 1 Metodológico]]. El usuario autorizó actualizar fuentes, cálculos descriptivos, sensibilidades y PDF; **ordenó no ejecutar PCA**. Esta entrega no calcula PCA, componentes, puntajes, KMO, Bartlett ni IVS. Los resultados preliminares de conversación no se incorporan como resultados reproducibles del informe.

- Ocho candidatas: 1HM, 2HM, seis materiales agregados 6V, energía, gas e internet 8V, 10V y actividad ponderada 5PM.
- Basuras: fuera de las ocho; únicamente sensibilidad exploratoria, confirmado por el equipo.
- 17PM: reservada, no entra al primer PCA. 1PM y 1V: contexto. 6PM: excluida.
- IPM: contraste convergente externo parcial; sus quince privaciones están fuera de las ocho. Se conserva la lista aprobada pese a proximidades temáticas y se preparan escenarios de retiro para análisis futuro.
- 5PM mantiene peso 2:1 normativo; 10V mantiene estratos 1–2 más sin estrato, sobre estratos 1–6 más sin estrato. No se convierten esas convenciones en hechos demostrados por la bibliografía.
- Tabla solicitada: 1HM, 6V agregada, energía y 10V. Estadísticas territoriales descriptivas, sin inferencia muestral de municipios. Razones de sumas aparte.

## Trabajo reproducible realizado

- [x] Leer fórmulas, decisiones, módulos y salidas existentes; preservar los cambios previos.
- [x] Guardar respaldo previo de fuentes/PDF en `tmp/actualizacion_informe_20261018/respaldo/` y sus SHA-256.
- [x] Crear `R/06_descriptivos_sensibilidades_ivs.R`, en R base, sin dependencias nuevas.
- [x] Recalcular las ocho fórmulas desde `datos/intermedio/` y compararlas con la corrida del 15 de octubre: diferencia cero en las ocho, tolerancia 1e-12.
- [x] Verificar la lista histórica ANM en la capa DANE 2018; no inferir el tipo administrativo por ausencia de cabecera.
- [x] Generar descriptivos, escenarios de fórmula, cotas de no respuesta, correlaciones, contribuciones materiales y matriz conceptual candidata × 15 privaciones.
- [x] Cotejar extremos directamente contra Excel mediante auxiliar independiente.
- [x] Actualizar informe modular, bibliografía, figuras y tablas generadas por R.
- [x] Compilar y verificar PDF; registro final en `CONTROL_ENTREGA_DESCRIPTIVA_20261018.md`.

### Comandos

Desde la raíz del repositorio:

```text
Rscript R/06_descriptivos_sensibilidades_ivs.R
python -m pip install -r requirements-analysis.txt
python R/auxiliares/cotejar_extremos_descriptivos.py
```

El flujo se ejecutó con R 4.6.0 y Python 3.12.14; `R/06` funciona con R base. El auxiliar de cotejo requiere `openpyxl==3.1.5`, fijado en `requirements-analysis.txt`. Los paquetes requeridos por scripts históricos no están disponibles en la biblioteca de este R, por lo que esta entrega no acredita una corrida histórica completa desde Excel a través de R/01–R/05.

Para compilar, ejecutar desde `docs/informe1_metodologico`: `pdflatex main.tex`, `bibtex main`, y repetir `pdflatex main.tex` hasta resolver referencias. Las tablas y figuras de la actualización se incluyen directamente desde `resultados/descriptivos_sensibilidades_20261018/`; ejecutar R/06 antes de compilar.

## Geografía y fuentes

Se consultó la capa oficial [Áreas no municipalizadas de 2018](https://geoportal.dane.gov.co/mparcgis/rest/services/Divipola/Serv_DeptosMpiosANM_2018/MapServer/2), mediante la operación `query` con `where=1=1`, `outFields=*`, `returnGeometry=false`, `f=pjson`. Devuelve veinte atributos territoriales, entre ellos 94343 y 94663. La transcripción de los campos de código/nombre se conserva en `docs/metodologia/anm_divipola_2018_verificadas_20261018.csv`; solo se quitó el espacio final del nombre YAVARATÉ. Consulta: 18 de octubre de 2026.

La sección 2.2.6 del [documento metodológico CNPV](https://www.dane.gov.co/files/censo2018/informacion-tecnica/DSO-CNPV-MET-001-V2.pdf) distingue municipios, ANM y ámbito insular. La clasificación de esta entrega separa 1.101 municipios/distritos, San Andrés (88001) y veinte ANM. La tabla principal usa **ámbito municipal e insular**, 1.102 unidades; también se produce escenario municipal estricto de 1.101, ANM y universo censal completo. **La inclusión de San Andrés en el PCA definitivo no queda resuelta por esta tabla**.

El [DANE, NBI](https://www.dane.gov.co/index.php/estadisticas-por-tema/pobreza-y-condiciones-de-vida/necesidades-basicas-insatisfechas-nbi) documenta la integración de Barrancominas y Mapiripana bajo la Ordenanza 248 de 2019. El [boletín ELIC de febrero de 2024](https://www.dane.gov.co/files/operaciones/ELIC/bol-ELIC-feb2024.pdf) documenta la incorporación de Nuevo Belén de Bajirá al marco estadístico. Este último dato **no acredita una fecha legal de creación ni prueba el enlace 27493→27615**. Se retiró del informe la afirmación no sustentada de creación en 2019. La homologación sigue pendiente de acto y cartografía; se preservaron los códigos censales.

## Resultados y cómo leerlos

Fuente computable: `resultados/descriptivos_sensibilidades_20261018/`.

- `verificacion_formulas.csv`: reproducción independiente desde seis tablas intermedias, ocho fórmulas, todas coincidentes.
- `clasificacion_territorial_2018.csv`: clasificación temporal por código y ámbito descriptivo.
- `numeradores_denominadores.csv`: conteos y cocientes de las ocho candidatas; permite auditar cada razón.
- `indicadores_ocho_todas_unidades.csv`, `matriz_ocho_municipal_e_insular_0_1.csv`, `indicadores_anm.csv`: preservan respectivamente todas las unidades, el ámbito principal descriptivo y ANM. No son resultados de PCA.
- `descriptivos_ocho_por_ambito.csv`: cuatro ámbitos. DE poblacional divide por N; se conserva también DE convencional con N−1. Cuartiles tipo 7 de R. No son intervalos de confianza.
- `descriptivos_cuatro_informe.csv`: tabla principal y razones de sumas; la media simple da igual peso a cada unidad, la razón de sumas pondera por el denominador.
- `sensibilidades_formulas_por_ambito.csv`, `sensibilidades_por_codigo.csv`: delta, Spearman y cambios ≥2 pp. Cambiar el universo cambia los conteos; los valores históricos 702/46 de 5PM corresponden a 1.122 códigos, frente a 698/44 en 1.102 unidades.
- `cotas_no_respuesta_servicios.csv`: asignación extrema de NR; no intervalos probabilísticos ni imputación aplicada.
- `candidatas_sensibilidad_reservadas.csv`, `descriptivos_sensibilidades_reservadas.csv`: materiales separados, basuras, educación y elegibilidad 10V.
- `correlaciones_escenarios.csv`, `sensibilidad_correlaciones.csv`: Pearson/Spearman y diferencias sobre pares comunes. Retirar/agregar columnas no cambia sus correlaciones comunes; delta cero no demuestra estabilidad dimensional.
- `sensibilidad_correlaciones_territorial.csv`: efecto descriptivo de ámbitos alternativos.
- `solapamiento_conceptual_ipm.csv`: evaluación cualitativa completa, nueve candidatas (17PM reservada) × quince privaciones; no es una prueba ni puntuación de similitud.
- `extremos_z_mayor_4_para_cotejo.csv`, `cotejo_extremos_excel.csv`: 43 códigos y 47 celdas actuales, todas coincidentes con valores del libro a tolerancia 1e-12. No se eliminó ninguna. La lista histórica de 32 pertenece a otra especificación y no se da por validada retrospectivamente.
- `integridad_insumos.csv`, `integridad_excel_cotejo.csv`: MD5 antes/después de insumos y resultados históricos; SHA-256 del Excel en el cotejo. Todos iguales.
- `tablas_tex/`, `figuras/`: tablas y gráficos generados desde los mismos datos; incorporados directamente al informe.
- `resumen_ejecucion.csv`, `sessionInfo.txt`: alcance y entorno. PCA y KMO/Bartlett en FALSE.

## Bibliografía: qué respalda y qué no

- [OECD/JRC 2008](https://doi.org/10.1787/9789264043466-en): guía de construcción y sensibilidad; no prescribe nuestras ocho candidatas.
- [Decancq y Lugo 2013](https://www.tandfonline.com/doi/full/10.1080/07474938.2012.690641): distingue pesos normativos, empíricos e híbridos; no demuestra que incapacidad deba tener peso dos.
- [DNP ICVU 2023](https://www.dnp.gov.co/publicaciones/Planeacion/Paginas/indicador-de-condiciones-de-vulnerabilidad-urbana.aspx): antecedente de cuidado, vivienda y bienes; unidad hogar y método diferente, respaldo contextual.
- [DANE, IPM censal 2020](https://www.dane.gov.co/files/investigaciones/condiciones_vida/pobreza/2018/informacion-censal/nota-metodologia-censal-pobreza-municipal-2018.pdf): define privaciones y unidad; permite comparar conceptos. No prueba validez independiente del IVS.
- [DANE, estratificación](https://www.dane.gov.co/index.php/servicios-al-ciudadano/servicios-informacion/estratificacion-socioeconomica): justifica naturaleza administrativa del inmueble; no prueba que sin estrato sea vulnerabilidad ni selecciona el corte 1–2.
- CNPV y P_TRABAJO: definiciones y universos censales; no convierten 5PM en desempleo ni dependencia del hogar.
- [Kaiser 1974](https://doi.org/10.1007/BF02291575): DOI corregido. Se conserva para la fórmula de diagnóstico futuro, no se ejecutó en esta corrida.
- [Monsalvo Herrera y Jiménez 2025](https://novumjus.ucatolica.edu.co/article/view/6178): la página editorial identifica **Ana Elena Monsalvo Herrera y Wilson G. Jiménez**. Se corrigieron los nombres erróneos del .bib activo, incluso el antecedente de auditoría que atribuía otro nombre. Solo antecedente espacial de IPM.
- [Alkire et al., libro OUP](https://academic.oup.com/book/11882): fecha bibliográfica corregida de 2011 a 2015 y DOI añadido; se conserva la clave antigua por compatibilidad. Su discusión de unidad y decisiones normativas no valida automáticamente estos indicadores.

Las fuentes verificadas no acreditan como hechos el peso 2:1, el agrupamiento de seis paredes, la vulnerabilidad automática de personas mayores o de quienes no tienen estrato. Esas reglas se mantienen como acuerdos y se califican como aproximaciones o decisiones normativas.

## Pendientes y consistencia histórica

- Cerrar inclusión insular para PCA; estandarizar en ese universo y autorizar después los diagnósticos y PCA.
- Verificar enlaces con SECOP por geografía común; no reasignar automáticamente 27493 ni 94663.
- Explorar estabilidad de componentes/cargas/puntajes con las sensibilidades preparadas; esta entrega solo estudia valores y correlaciones.
- Formalizar IVS después de evaluar coherencia e interpretación; SECOP y validación externa siguen posteriores.
- El CSV de decisiones conserva una instrucción residual en `verificar` de 6PM sobre tasa de desocupación, incompatible con su estado DESCARTAR. No se ejecuta ni se considera decisión vigente. No se alteró el CSV histórico; esta nota y el informe registran el acuerdo actual.
- Los módulos y notas del 15 de octubre permanecen como historia. La nota Obsidian añade enlace a esta actualización, sin borrar el estado anterior.

## Respaldo y control de cambios

Se preservó el estado previo en el respaldo local mencionado. No se editaron datos originales, scripts R/00–R/05, el CSV de decisiones ni resultados históricos. Las fuentes LaTeX se actualizaron en su estructura existente, conservando extracción, diccionarios, fórmulas, controles históricos y alcance SECOP. Las nuevas cifras provienen de los CSV de esta corrida. La compresión de tablas se limitó al ancho de texto y se revisó la salida renderizada.

Navegación: [[Informe_Metodologico_Obsidian]] · [[Solucion_pendientes]] · [[Resumen_General]].
