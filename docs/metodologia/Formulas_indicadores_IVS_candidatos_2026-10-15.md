# Fórmulas de indicadores candidatos y matriz previa al PCA

**Fecha:** 2026-10-15  
**Universo:** municipios del CNPV 2018 incluidos en IPM (1.122 códigos).  
**Script:** [`R/05_conformar_indicadores_finales.R`](../../R/05_conformar_indicadores_finales.R)  
**Salidas:** [`resultados/indicadores_finales_ivs_20261015/`](../../resultados/indicadores_finales_ivs_20261015/)

## Decisiones aplicadas

- `6PM` excluido; no produce indicadores ni columnas de la matriz.
- `1HM` y `2HM`: proporción de hogares con menores de 15 y de hogares con personas de 60+, respectivamente; dirección positiva como carga potencial de cuidado, no como prueba individual de dependencia.
- `6V_MPIO`: se agrupan en una proporción las seis categorías aprobadas por el autor: guadua, tapia/bahareque/adobe, madera burda, caña/vegetales, materiales de desecho y sin paredes.
- `8V_MPIO`: energía, gas e internet como tres variables separadas. Gas e internet usan base válida que excluye “sin información”; los cocientes sobre el total se conservan para sensibilidad. Acueducto y alcantarillado quedan descriptivos/comparativos por posible cercanía con IPM.
- `10V_MPIO`: “no tiene estrato” se trata como categoría de vulnerabilidad por decisión operacional del autor. Numerador: estratos 1–2 más no tiene estrato. Denominador: estratos 1–6 más no tiene estrato. “Sin servicio de energía” y “no sabe/no responde” se excluyen de ese denominador y se dejan como categorías separadas.
- `5PM`: peso 2 para incapacidad permanente, frente a peso 1 para trabajo no remunerado y búsqueda de trabajo, según decisión del autor. Se presenta como indicador experimental municipal de personas de 10 años y más; la tabla no permite llamarlo indicador “del hogar”, medir dependencia económica del hogar ni calcular la tasa oficial de desempleo.
- `17PM`: sus 15 categorías se expresan sobre población total de 5 años y más y se guardan en un banco descriptivo separado. Además se acordó una sola candidata acumulada de población sin educación media completa; no entran juntas las 15 proporciones en la matriz estándar porque suman uno. La candidata mantiene la cautela por mezcla de edades.
- IPM se conserva como validador externo; no integra estas ocho columnas.

## Fórmulas aplicadas

| Variable | Numerador | Denominador | Dirección |
|---|---|---|---|
| `hogares_menores15` | Hogares con menores de 15 (`1HM`) | Hogares totales (`1HM`) | Positiva |
| `hogares_adultos_mayores` | Hogares con personas de 60+ (`2HM`) | Hogares totales (`2HM`) | Positiva |
| `paredes_precarias_6V` | Suma de las seis categorías de pared acordadas | Total de viviendas, tipo `Total` (`6V`) | Positiva |
| `sin_energia_8V` | Viviendas ocupadas presentes sin energía | Total de viviendas ocupadas presentes (`8V`) | Positiva |
| `sin_gas_8V` | Viviendas sin gas por red | Total gas menos “sin información” (`8V`) | Positiva |
| `sin_internet_8V` | Viviendas sin internet | Total internet menos “sin información” (`8V`) | Positiva |
| `estratos_1_2_o_sin_estrato_10V` | Personas en estratos 1–2 más “no tiene estrato” | Personas en estratos 1–6 más “no tiene estrato” (`10V`) | Positiva |
| `actividad_vulnerabilidad_10mas_5PM` | No remunerado + buscó trabajo + 2 × incapacidad permanente | 2 × (población 10+ menos “no informa”) | Positiva; experimental |
| `sin_media_completa_17PM` | Ninguno + preescolar + primaria completa/incompleta + secundaria completa/incompleta + media incompleta | Población total de 5+ | Positiva; exploratoria |

El último cociente normaliza el puntaje ponderado en [0,1], usando el peso máximo posible (2) por persona con respuesta válida. Es una puntuación operacional definida para este estudio, no una clasificación oficial de vulnerabilidad laboral. Las alternativas guardadas comparan el mismo numerador con población 10+ total y una cota superior que asigna puntaje máximo a la no respuesta.

Para `sin_media_completa_17PM`, `Normal completa` y `Normal incompleta` se excluyen del numerador principal, y `Normal incompleta` se incorpora solo en una variante de sensibilidad. La proporción principal usa el denominador acordado de población total 5+; otra variante usa 5+ menos “sin información”. “Sin información” también se conserva como proporción separada. La denominación del indicador no elimina el límite de que el cuadro incluye niños de 5 a 14 años.

## Sustento y límites interpretativos

La clasificación colombiana por estratos corresponde a inmuebles residenciales para la prestación de servicios públicos. Por eso, incluir “no tiene estrato” como vulnerabilidad es una decisión operacional del proyecto y no una consecuencia estadística directa de la Ley 142 ni una medición individual de ingreso. El denominador de `10V` compara las categorías observadas de estrato y “no tiene estrato”; dejar aparte ausencia de servicio y no respuesta evita asignarles silenciosamente la misma condición. La definición institucional del DANE describe el objeto como clasificación de inmuebles residenciales y explica sus usos en servicios públicos ([DANE, estratificación](https://www.dane.gov.co/index.php/servicios-al-ciudadano/servicios-informacion/estratificacion-socioeconomica)).

La pregunta de actividad de `5PM` se refiere a lo realizado durante la semana anterior al censo. DANE distingue trabajo, búsqueda de trabajo e incapacidad permanente entre sus categorías ([metadatos CNPV 2018, P_TRABAJO](https://microdatos.dane.gov.co/index.php/catalog/643/variable/F11/V589?name=P_TRABAJO)). La tasa oficial de desempleo requiere una población de referencia y criterios laborales específicos; este agregado de 10+ y su ponderación propia no los sustituyen.

En los cuadros estáticos consultados, `17PM` cruza nivel educativo con municipio, áreas y sexo, no con edad. El cuadro de nivel educativo por grupos de edad identificado en la documentación es `19PD`, de alcance departamental. DANE también ofrece una interfaz Redatam para tabulaciones personalizadas que solicita nivel educativo, edad y nivel geográfico; queda pendiente confirmar si permite salida municipal con las restricciones de reserva y si replica el universo 17PM ([Redatam CNPV, tabulación de educación](https://systema59.dane.gov.co/bincol/RpWebStats.exe/CrossTab?BASE=CNPVBASE4V2&ITEM=EDUC_2&lang=esp), [documento metodológico CNPV 2018](https://www.dane.gov.co/files/censo2018/informacion-tecnica/DSO-CNPV-MET-001-V2.pdf)). Hasta verificarlo, no se presume que el cruce municipal esté disponible.

Las proporciones de educación `17PM` son composicionales porque las categorías exhaustivas suman uno. La PCA usual sobre todas ellas sin transformación puede producir dependencias impuestas por la suma constante; el análisis composicional de Aitchison formula transformaciones log-ratio para ese problema ([Aitchison, 1983](https://doi.org/10.2307/2335943)). No se aplicó una transformación en esta entrega para respetar la decisión de mantener las proporciones descriptivas y candidatas mientras se define su uso.

## Resultado de la corrida

El script encontró los mismos 1.122 códigos únicos en las seis fuentes usadas. Los controles de suma de categorías de `17PM`, `5PM`, nueve materiales `6V`, categorías `BU:CD` de `10V`, y totales de energía/gas/internet `8V` registraron 0 violaciones (tolerancia de redondeo: 0,5 unidad). Las nueve columnas candidatas están en [0,1], con 1.122 municipios completos y 0 celdas faltantes. La matriz z estandariza cada columna por media y desviación estándar; no ejecuta PCA ni selecciona componentes.

La sensibilidad municipal se entrega en `sensibilidad_no_respuesta_municipal.csv` y se resume en `resumen_sensibilidad.csv`. Frente a dividir por total, el denominador válido cambia al menos 2 puntos porcentuales en 58 municipios para gas y 85 para internet; máximas diferencias absolutas: 0,1246 y 0,1676. Para `10V`, sustituir el denominador aprobado por el total de personas cambia al menos 2 puntos en 711 municipios y hasta 0,988; se conserva la fórmula aprobada, interpretada entre categorías clasificables. Para `5PM`, excluir “no informa” frente al total cambia hasta 0,0084 y no supera 2 puntos porcentuales en ningún municipio; la cota superior de no respuesta modifica 235 municipios en al menos 2 puntos, hasta 0,1826. La sensibilidad del peso de incapacidad es material: cambiar de 2:1 a 1:1 altera al menos 2 puntos en 702 municipios (diferencia máxima 0,2143; Spearman 0,9496); usar 3:1 lo hace en 46 (máximo 0,0714; Spearman 0,9761). Para `17PM`, incluir `Normal incompleta` suma esa proporción al indicador: la diferencia alcanza ≥2 puntos en 12 municipios (máxima 0,0479; Spearman 0,9979). Cambiar a denominador válido de educación alcanza ≥2 puntos en 105 municipios (máxima 0,2141; Spearman 0,9678). Por eso queda documentado el principal y ambas sensibilidades.

## Archivos generados

- `formulas_indicadores.csv`: fórmulas, dirección y estatus de cada variable.
- `indicadores_municipales_y_denominadores.csv`: numeradores, denominadores, indicadores y proporciones 17PM municipales.
- `matriz_pca_candidata.csv`: ocho indicadores en escala 0–1 con llave y nombres municipales.
- `matriz_pca_candidata_z.csv`: mismas ocho variables estandarizadas (z).
- `parametros_z_pca.csv`: medias y desviaciones estándar aplicadas.
- `candidatas_17PM_descriptivas.csv`: 15 proporciones educativas, incluida “sin información”.
- `chequeos_matriz.csv`, `cobertura_indicadores_pca.csv`, `sensibilidad_no_respuesta_municipal.csv`, `resumen_sensibilidad.csv` y `resumen_ejecucion.csv`: controles y trazabilidad.

## Pendientes antes de calcular el IVS

1. Confirmar si la tabulación personalizada Redatam permite el cruce municipal nivel educativo × edad. Mientras no se compruebe, interpretar `sin_media_completa_17PM` como candidata exploratoria en población 5+ y revisar sensibilidad.
2. Validar sustantivamente la ponderación 2:1 de `5PM`; comparar resultados y documentar por qué ese peso es adecuado.
3. Auditar redundancia/correlación de las ocho candidatas y cercanía con privaciones IPM; el IPM es validación externa.
4. Ejecutar diagnósticos de PCA, selección de componentes e incertidumbre solo después de aprobar la matriz analítica definitiva. Esta corrida no calculó KMO, Bartlett, PCA ni IVS.
