# Solución de pendientes metodológicos y estadísticos del IVS

> **Nota de vigencia:** esta nota conserva el estado y los análisis de la corrida del 15 de octubre de 2026. La actualización metodológica del 18 de octubre y `docs/calidad/auditorias/ACTUALIZACION_DESCRIPTIVA_20261018.md` son posteriores y prevalecen para describir el avance actual: 17PM queda reservada y el primer PCA se plantea con ocho candidatas, aún sin ejecutar. La matriz de nueve columnas documentada más abajo es un producto histórico de preparación, no la especificación vigente del PCA.

> Registro de decisiones y análisis con corte al 15 de octubre. Mantiene separadas las decisiones del autor, las recomendaciones metodológicas, los resultados observados y las tareas que dependen de nueva información. Los libros originales no se modifican.

## Estado y alcance

**Actualizado:** 2026-10-15  
**Repositorio:** raíz del proyecto  
**Fase en el corte 2026-10-15:** fórmulas operacionales aprobadas aplicadas y matriz municipal candidata generada; PCA e IVS no ejecutados.  
**Objetivo:** construir un IVS municipal que describa vulnerabilidad socioeconómica en 2018 con variables DANE/CNPV; analizar después su asociación, correspondencia y brechas con contratación SECOP II 2026. SECOP no forma parte de los componentes del IVS.

Este documento no equivale a aprobación final de variables ni a un PCA ejecutado. La recomendación de componentes y faltantes queda condicionada a los resultados reproducibles y a decisiones posteriores del autor.

## Decisiones acordadas con el autor

1. La base censal de referencia es 2018. El IVS usa únicamente indicadores derivados del DANE/CNPV; SECOP II se analiza después.
2. El universo de referencia conserva las unidades censales 2018; los municipios constituidos se analizan como universo principal y las áreas no municipalizadas por separado.
3. Para el enlace posterior a SECOP se registran los casos históricos `27493 -> 27615` y `94663 -> 94343`. La correspondencia se debe verificar con la codificación oficial y queda restringida al enlace: no altera los códigos ni valores CNPV/IPM originales.
4. `1PM` queda como contexto y denominador. `1V_MPIO` queda como contexto para denominadores de vivienda.
5. `1HM` y `2HM` son candidatos como proporción de hogares con menores de 15 y hogares con personas de 60+, con dirección positiva acordada como **carga potencial de cuidado**. Esta interpretación no prueba dependencia funcional, enfermedad o dependencia económica.
6. `17PM` se documenta como **nivel educativo alcanzado** en población de 5 años y más. Se aprobó una candidata agregada: proporción sin educación media completa, usando Ninguno, Preescolar, primaria completa/incompleta, secundaria completa/incompleta y media incompleta. “Normal incompleta” se prueba como sensibilidad; “Normal completa” queda excluida. Las 15 proporciones individuales siguen descriptivas, fuera de la PCA.
7. `5PM` es la única tabla de actividad considerada. `6PM` se excluye por redundancia. Se aprobó una medida experimental ponderada de personas 10+ (incapacidad permanente peso 2, búsqueda y trabajo no remunerado peso 1), con advertencia de que no mide actividad del hogar ni desempleo oficial.
8. `6V_MPIO` agrupa en un indicador las seis categorías de pared aprobadas: guadua, tapia/bahareque/adobe, madera burda, caña/vegetales, desecho y sin paredes.
9. De `8V_MPIO` se evalúan por separado energía, gas e internet. Acueducto y alcantarillado permanecen descriptivos/comparativos por cercanía con privaciones IPM.
10. Para `10V_MPIO`, por decisión del autor, “no tiene estrato” es una categoría candidata de vulnerabilidad, distinta de “sin servicio de energía” y de “no sabe/no responde”. Esta decisión operacional se somete a sensibilidad y no se presenta como una consecuencia automática de la Ley 142.
11. Las privaciones IPM no son componentes del IVS DANE. Se conservan como validadores externos por dominio. `IPM Municipal` es el criterio agregado principal; `IPM` es un duplicado que sirve como control, no como un segundo validador independiente.
12. Los valores extremos se cotejan con fuentes y se conservan salvo decisión fundada distinta; no se eliminan por superar un umbral estadístico.
13. Si el enlace SECOP no cubre el 100% del universo acordado, se reporta cobertura y se presenta sensibilidad en la intersección observada; no se imputan contratos ni asignaciones.

## Análisis conceptual y estadístico

### Actividad de población: 5PM; 6PM no se incorpora

`5PM` describe categorías de actividad para población de 10 años y más, pero no enlaza actividad con hogares. No permite medir dependencia económica **del hogar**. `6PM` se excluye. La fórmula aprobada para la candidata experimental es:

`(trabajo_no_remunerado + busco_trabajo + 2 * incapacidad_permanente) / (2 * (poblacion_10mas - no_informa))`.

Se conserva sensibilidad usando población 10+ total y una cota superior para la no respuesta. No es una tasa oficial de desempleo ni se llama “actividad laboral del hogar”. El peso doble es decisión del autor y requiere validación sustantiva.

### Matriz candidata aplicada el 2026-10-15

El script [`R/05_conformar_indicadores_finales.R`](R/05_conformar_indicadores_finales.R) genera una matriz sin faltantes para los 1.122 municipios, orientada para que mayor valor represente mayor vulnerabilidad y estandarizada en z como insumo previo. Incluye nueve variables: 1HM, 2HM, paredes agrupadas 6V, energía/gas/internet 8V, estrato 1–2 + no tiene estrato 10V, actividad ponderada 5PM y la candidata educativa agregada 17PM. El script no imputa ni ejecuta PCA.

Gas e internet usan como denominador el total válido (total menos sin información); la sensibilidad municipal frente al total alcanza 58 municipios con delta ≥2 pp para gas y 85 para internet. En 10V se aplica la proporción de estratos 1–2 más no tiene estrato sobre personas en estratos 1–6 más no tiene estrato. Al comparar con el total BU, 711 municipios cambian ≥2 pp y la diferencia máxima es 0,988; por esto la variable debe interpretarse estrictamente entre categorías clasificables. La clasificación DANE por estrato se refiere a inmuebles residenciales para servicios públicos, no es medida directa de ingreso.

Las 15 proporciones 17PM tienen como denominador población total de 5+ y suman uno; se conservan descriptivamente fuera de PCA. La candidata agregada usa ese mismo denominador e incluye únicamente las categorías bajo el umbral aprobado. Añadir `Normal incompleta` afecta al menos 2 pp a 12 municipios (máximo 4,79 pp); usar denominador sin “Sin información” afecta al menos 2 pp a 105 municipios (máximo 21,41 pp). El cuadro municipal 17PM no incluye edad. En los cuadros estáticos consultados, el cuadro 19PD ofrece nivel educativo por edad a nivel departamental. DANE tiene una interfaz Redatam para tabulación personalizada por nivel educativo, edad y geografía; queda pendiente verificar que permita el nivel municipal y que respete el universo requerido. Hasta entonces, no se asume que exista un cruce municipal reproducible.

Detalle de fórmulas, fuentes, resultados y archivos: [`docs/metodologia/Formulas_indicadores_IVS_candidatos_2026-10-15.md`](docs/metodologia/Formulas_indicadores_IVS_candidatos_2026-10-15.md).

Con `5PM` se puede describir la composición municipal de esas categorías. Un cociente como “personas que buscaron trabajo / personas de 10+” sería un porcentaje de búsqueda de trabajo en el universo 10+, no una tasa oficial de desempleo. Tampoco se debe denominar tasa GEIH: la PET de la GEIH vigente parte de los 15 años y la clasificación de desocupación exige condiciones de búsqueda y disponibilidad que no aparecen completas en la pregunta censal. No se recomienda construir con 5PM un indicador único sumando búsqueda de empleo, oficios del hogar, incapacidad y otras situaciones: son estados distintos y su suma no representa una dimensión laboral interpretable.

La categoría 5PM puede permanecer como contexto descriptivo. Para una tasa de desempleo comparable se necesitaría otra fuente que mida población de 15+ y cumpla los criterios de ocupación/desocupación, o autorización explícita para definir y denominar un proxy censal limitado. No se necesita 6PM para el plan vigente.

### Nivel educativo 17PM

Se corrige el catálogo para describir 17PM como nivel educativo alcanzado de población 5+. Sus categorías no se deben describir como asistencia escolar ni limitar a población 10+ sin desagregación que lo permita. Educación alcanzada e inasistencia escolar son conceptos distintos, aunque pertenecen al mismo ámbito y pueden estar correlacionados. La relación con IPM se reportará como convergencia con solapamiento de dominio, no como validación totalmente independiente.

### Materiales de pared 6V_MPIO

Se producirán proporciones municipales por cada uno de los nueve materiales sobre viviendas ocupadas con personas presentes. El patrón IPM de pared es distinto por área urbana/rural: la definición oficial incluye categorías que no coinciden exactamente con la agrupación inicial de materiales y separa reglas urbanas y rurales. En particular, no se dará por hecho que tapia/bahareque/adobe sea privación en todo contexto.

Las nueve participaciones son composicionales: suman uno (100%). No se deben introducir simultáneamente todas como predictores de un PCA estándar, pues existe dependencia lineal. Se examinarán distribución, ceros, variabilidad y asociaciones; la agrupación de categorías o una codificación de referencia requerirá justificación explícita. El IPM de paredes puede utilizarse como comparación específica, con advertencia de solapamiento y de diferencia entre viviendas contadas y privación IPM a nivel de hogar/persona.

### Estrato 10V_MPIO y “sin información”

La fuente 10V tiene personas de hogares particulares en “sin servicio de energía”, “no tiene estrato”, estratos 1–6 y “no sabe/no responde”; el chequeo establece que estas categorías suman el total de personas. No se debe tratar “sin servicio” como sinónimo de “no tiene estrato”. Se contrastan estas definiciones:

1. Estratos 1–2 / personas con estrato asignado (1–6).
2. (Estratos 1–2 + no tiene estrato) / personas censadas: definición operativa principal según decisión del autor, considerando “no tiene estrato” vulnerable.
3. El mismo numerador / personas con estrato 1–6 o “no tiene estrato”, excluyendo tanto “sin servicio” como “no sabe/no responde”.
4. Cota superior si los casos “no sabe/no responde” también pudieran pertenecer a la categoría vulnerable.

La categoría “sin servicio de energía” se conserva separada y se mide desde 8V; incluirla en el denominador de una proporción sobre categorías de estrato cambia el significado de la tasa. El análisis de sensibilidad confirma que esta decisión de denominador puede cambiar mucho la distribución municipal; el catálogo deja la selección final pendiente y recomienda publicar el perfil de cinco categorías (sin servicio, no tiene estrato, estratos 1–2, estratos 3–6 y no sabe/no responde) antes de reducirlo a un indicador único.

La Ley 142 regula la estratificación de inmuebles residenciales para los servicios públicos, con categorías 1–6 y mecanismos de subsidios/contribuciones. La norma por sí sola no establece que un registro censal “no tiene estrato” sea equivalente a pobreza; se conservará como hipótesis conceptual del proyecto. La metodología DANE es distinta para zonas urbanas y rurales, así que se reportará la sensibilidad por área cuando las tablas lo permitan.

**Resultado reproducible del 2026-10-15:** control de 10V con 1.122 municipios, cero códigos duplicados y cero violaciones de `BU = suma(BV:CD)`. Al comparar `(estratos 1–2 + no tiene estrato) / total` con el mismo numerador sobre `total - no sabe/no responde`, 26 municipios difieren al menos 0,02, 8 difieren al menos 10% en términos relativos, el máximo cambio absoluto es 0,225 y Spearman es 0,9961. La no respuesta ponderada es 0,199%, pero el máximo municipal de la tasa “no sabe/no responde” alcanza 0,520.

Una tercera variante, con denominador `estratos 1–6 + no tiene estrato` (excluye “sin servicio” y “no sabe/no responde”), difiere en al menos 0,02 en 711 municipios; el cambio máximo es 0,988 y Spearman frente a la tasa sobre el total es 0,4045. Esto verifica que el denominador no es una elección inocua. No se ha seleccionado aún una tasa única: se recomienda mantener “sin servicio” aparte y presentar primero todas las categorías, antes de cerrar el indicador. El resultado está en `resultados/solucion_pendientes/estructura_10V_6V_20261015_v05/`.

La media municipal no ponderada de la tasa con numerador acordado es 0,851 sobre el total, frente a 0,854 al excluir no respuesta y 0,939 al restringir a estrato/sin estrato. No son tasas nacionales: son promedios simples de las proporciones municipales.

### Servicios públicos 8V_MPIO: energía, gas e internet

La corrida del 2026-10-15 evaluó 1.122 municipios. Las categorías suman el total en gas e internet en todos los municipios. Para gas, la no respuesta ponderada es 0,861%; para internet, 0,911%. Al comparar `Sí / total` con `Sí / (total - sin información)`, hay 3 municipios con diferencia absoluta de al menos 0,02 para gas y 1 para internet; los máximos son 0,0322 y 0,0206, respectivamente. Las correlaciones de rangos son 0,99996 y 0,99987. La sensibilidad global es baja, pero no nula a nivel municipal; conservar tasas y no respuesta por separado. Energía, gas e internet quedan como análisis diferenciados; agua y alcantarillado permanecen descriptivos por ahora.

### Materiales de pared 6V_MPIO

El control reprodujo 1.122 municipios sin violaciones entre total y suma de los nueve materiales. La salida entrega una participación por material y municipio, sin agrupar. Medias simples municipales observadas: bloque/ladrillo/piedra/madera pulida 64,51%; tapia/bahareque/adobe 16,27%; madera burda 13,02%; caña/vegetales 1,24%; material prefabricado 1,11%; desecho 1,00%; concreto vaciado 2,22%; guadua 0,49%; sin paredes 0,14%. Las participaciones son composicionales y no deben entrar todas juntas en un PCA estándar. La similitud temática con “Material inadecuado de paredes exteriores” del IPM se examina como validación externa específica, no como independencia conceptual.

### No respuesta y faltantes

Se distinguen cuatro estados antes del PCA: cero observado; combinación estructural inexistente; no respuesta/desconocido; denominador cero o no aplicable. Una combinación estructural se codifica como cero solo si la lógica de la tabla confirma ausencia de casos y no ausencia de observación. “No informa” no se convierte automáticamente a cero.

Para cada indicador afectado se comparan la base total, la base válida y el porcentaje de no respuesta municipal. Si la matriz aprobada queda completa no se imputa. Si quedan faltantes: primero se informa cobertura y patrón; luego se compara análisis de casos completos si la pérdida es baja y, si la falta afecta sustancialmente unidades, se evalúa imputación múltiple compatible con proporciones y con su estructura territorial, con sensibilidad y alineación de componentes. No se usará sustitución por cero como regla general.

### PCA propuesto

El PCA se mantiene desactivado hasta cerrar la especificación. Para la decisión se usarán análisis paralelo, gráfico scree e interpretación sustantiva de cargas; el criterio de Kaiser no decidirá por sí solo. Las variables deben orientarse a mayor vulnerabilidad, escalarse de forma coherente y revisarse por redundancia, composición, valores extremos y estructura de dominios. KMO/Bartlett son diagnósticos, no autorización automática. Si PC1 no representa una dimensión común interpretable, no se forzará un IVS unidimensional; se considerarán dimensiones/subíndices.

## Arquitectura reproducible implementada/iniciada

- `R/00_config.R`: configuración ya existente; `ejecutar_pca = FALSE` y `ejecutar_bootstrap = FALSE` se conservan.
- `R/funciones/solucion_pendientes.R`: helpers de lectura, extracción de llave, agregación laboral, sensibilidad 10V y análisis de materiales 6V.
- `R/04_analizar_pendientes.R`: entrypoint modular, ejecutable desde la raíz, lanza las auditorías de 10V, 8V y 6V.
- `R/04_auditoria_estrato_paredes.R`: ejecutado correctamente; audita 10V, la sensibilidad de gas/internet en 8V y categorías de paredes 6V, con hashes de intermedios.
- Las corridas exploratorias de lectura 6PM no produjeron indicadores aceptados y quedaron marcadas como no continuadas tras la decisión de excluir ese bloque por redundancia.
- El proceso no debe reemplazar `resultados/base_trabajo/`, `resultados/auditoria_estadistica/`, `datos/intermedio/` ni libros fuente. Los artefactos nuevos son independientes y deben incluir chequeos de cobertura, conciliación 5PM/6PM, sumas de 10V y hashes de insumos.
- La ejecución inicial de `R/04_analizar_pendientes.R` está en curso; la hoja 6PM es grande (216 mil filas en un libro de 222 MB). No se aceptarán salidas hasta que la corrida termine y supere sus controles.

## Decisiones y tareas pendientes

| Tema | Estado | Regla de cierre |
|---|---|---|
| 17PM | Candidata agregada calculada; proporciones completas se conservan como descriptivas | Verificar cruce educativo×edad municipal en Redatam; valorar sesgo por población 5+ y sensibilidad de denominador/categoría normal incompleta. |
| Actividad 5PM | Indicador experimental ponderado aplicado; 6PM excluido | Validar sustantivamente el peso doble de incapacidad; no llamarlo indicador del hogar ni tasa oficial de desempleo. |
| 10V denominador | Fórmula aprobada y aplicada | La sensibilidad frente al total es grande; interpretar solo entre personas clasificadas por estrato o “no tiene estrato”. |
| Paredes 6V | Las seis categorías indicadas se agrupan y sumas verificadas | Revisar distribución/ceros y cercanía a la privación IPM de materiales de pared. |
| 8V servicios | Sensibilidad de gas e internet completada; suma validada | Mantener energía, gas e internet separados y registrar el pequeño efecto municipal de no respuesta. |
| Municipios 27493/94663 | Correspondencia excepcional acordada para SECOP | Verificar evidencia histórica DIVIPOLA y guardar crosswalk separado del universo 2018. |
| Áreas no municipalizadas | Análisis separado acordado | Clasificar exactamente las unidades; no mezclarlas silenciosamente con municipios constituidos. |
| Valores extremos | Cotejo autorizado | Registrar valor derivado, numerador/denominador, celda/fila fuente y resultado del cotejo, sin borrado automático. |
| SECOP II 2026 | Esperando archivo del compañero | Al recibirlo, inventariar esquema/cobertura, aplicar crosswalk documentado y medir cobertura; no imputar. |
| PCA/IVS | No ejecutado | Aprobar catálogo final, faltantes y estrategia; luego análisis paralelo/scree/interpretación/sensibilidad. |
| Comparación hash previa del código | No acreditada | No inventar una línea base anterior; conservar hashes de cada nueva ejecución a partir de ahora. |

## Fuentes metodológicas consultadas

- DANE, CNPV 2018, metadatos de la pregunta de actividad: https://microdatos.dane.gov.co/index.php/catalog/643/variable/F11/V589?name=P_TRABAJO
- DANE, estudio poscensal con operacionalización de categorías laborales 1–3 ocupación, 4 desempleo y 5–9 inactividad: https://www.dane.gov.co/files/censo2018/estudios-poscensales/14-Integracion-poblacion-venezolana-Colombia.pdf
- DANE, GEIH, definición PET 15+ y condiciones de clasificación laboral: https://www.dane.gov.co/files/operaciones/GEIH/DSO-GEIH-MET-001-V11.pdf
- DANE, estratificación socioeconómica: definición y metodologías urbana/rural: https://www.dane.gov.co/index.php/component/content/article/2419-estratificacion-socioeconomica-metodologia?Itemid=5039&catid=116
- DANE, estratificación socioeconómica: finalidad y alcance como clasificación de inmuebles residenciales: https://www.dane.gov.co/index.php/component/content/article/2421-estratificacion-socioeconomica-preguntas-frecuentes?Itemid=109
- DANE, criterio IPM de paredes exteriores: https://sitios.dane.gov.co/Pobreza_y_condiciones_de_vida/
- CNPV 2018, fuente de categorías de pared: https://microdatos.dane.gov.co/index.php/catalog/643/variable/F8/V529?name=V_MAT_PARED

## Bitácora

- 2026-10-15: se revisaron el índice de bases, las decisiones del proyecto, la tabla 10V municipal existente y los libros fuente. Se corrigió la decisión de 17PM y se trasladaron las privaciones IPM de inclusión a validación externa. Se identificó 6PM como fuente de actividad por edad, separada de 5PM. Se inició una auditoría R nueva con salidas versionadas para no sobrescribir resultados históricos.
- 2026-10-15: terminó la auditoría versionada 10V/8V/6V. El autor aprobó el denominador válido de 10V, gas e internet, agrupó seis categorías 6V y confirmó la exclusión de 6PM. No se ejecutaron KMO, Bartlett, PCA ni cálculo del IVS.
- 2026-10-15: se aplicaron ocho indicadores candidatos sobre 1.122 municipios con cero faltantes y cero violaciones en los controles. Se generaron matrices 0–1 y z, banco descriptivo de 15 proporciones 17PM y sensibilidad de no respuesta. La matriz queda previa al PCA; 17PM sigue fuera hasta definir una selección o transformación composicional. Detalle en `docs/metodologia/Formulas_indicadores_IVS_candidatos_2026-10-15.md`.
