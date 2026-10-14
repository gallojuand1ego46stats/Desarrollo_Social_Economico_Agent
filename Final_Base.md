> Enlaces de la bóveda: [[Inicio_Proyecto]] · [[Estructura_Bases]] · [[VERIFICACION_CONSOLIDADOS]] · [[Correccion_Estructura_Bases]]

# Base final, indicadores y matriz lista para PCA

Fecha de ejecución: 2026-10-13. Script: R/02_base_final_indicadores.R.

## Alcance

La ejecución construye los denominadores, especifica indicadores, calcula proporciones en versiones base total y base válida para variables sensibles a no respuesta, y genera matrices y diagnósticos de aptitud. No ejecuta PCA ni bootstrap.

## Decisiones metodológicas fijadas por el autor

- Universo: 1.122 códigos con datos CNPV/IPM 2018. Se conservan sin fusiones o exclusiones; los cambios se reservan para el enlace posterior con SECOP.
- Los CSV en datos/intermedio son de solo lectura. Sus MD5 antes y después están en resultados/base_trabajo/.
- No hay imputación estadística. Las combinaciones demográficas ausentes dentro de áreas existentes se completan como ceros estructurales y se marcan. Las áreas inexistentes se documentan y no se crean filas.
- Los índices 0/0 quedan NA y se señalan con flag_indice_indefinido. Los 20 NA de Cabeceras en IPM se conservan como NA estructural y se cotejan con municipios sin cabecera.
- No respuesta de ítem se trata como calidad: base total incluye la categoría en el denominador y base válida la resta. no_tiene_estrato se mantiene distinto de no_sabe_no_responde.
- El IPM se reserva para validación externa. Se excluyen del PCA propuesto indicadores que replican directamente sus privaciones.
- El total de 17PM coincide con la población de 5+ de 1PM en los 1.122 municipios. Por ello pob_10mas se calculó desde 1PM; el total de 17PM se conserva como pob_17PM_educacion. Las categorías de nivel educativo no se pueden filtrar a 10+ con los archivos disponibles.

## Especificación de indicadores

Verificación estructural de edad: el total de 17PM (Nivel educativo) coincide con población 5+ de 1PM, no con población 10+. El libro no permite cortar las categorías de nivel educativo por edad; se calculan usando el total del 17PM y se documenta esta discrepancia. pob_10mas se calcula desde los grupos 1PM de 10 años o más; la cobertura de 5PM se coteja contra ese valor.
Los indicadores de educación, paredes inadecuadas, acueducto, alcantarillado y dependencia se calculan para descripción, pero quedan fuera de la matriz PCA propuesta por solapamiento con IPM. Hogares con adultos mayores queda fuera hasta definir su dirección. Como candidatos analíticos provisionales quedan actividad no ocupada, falta de electricidad, gas, recolección, internet, hogares con menores y estratos 1-2. La decisión final de inclusión corresponde al autor; consultar especificacion_indicadores.csv.

## Resultados esperado vs obtenido

| metrica | esperado | obtenido | estado | nota |
| --- | --- | --- | --- | --- |
| Universo CNPV/IPM | 1122 | 1122 | PASS |  |
| Combinaciones edad ausentes | 335 | 335 | PASS |  |
| Municipios afectados | 119 | 119 | PASS |  |
| Area Centro poblado | 299 | 299 | PASS |  |
| Area Rural disperso | 25 | 25 | PASS |  |
| Area Cabecera | 6 | 6 | PASS |  |
| Area Total | 5 | 5 | PASS |  |
| Edad 85 y mas | 89 | 89 | PASS |  |
| Edad 80 a 84 | 62 | 62 | PASS |  |
| Edad 75 a 79 | 33 | 33 | PASS |  |
| Municipios sin Cabecera | 20 | 20 | PASS |  |
| Municipios sin Centro poblado | 192 | 192 | PASS |  |
| Poblacion <1000 | 10 | 10 | PASS |  |
| Poblacion <5000 | 225 | 225 | PASS |  |
| CNPV sin cabecera | 20 | 20 | PASS |  |
| CNPV sin cabecera y etiqueta ANM DIVIPOLA | 18 | 18 | PASS |  |
| Cobertura baja población 10+ 5PM | 28 | 28 | PASS | pob_base_actividad / pob_10mas < 0.9 |
| Cobertura baja menores15 HOGARES | 26 | 26 | PASS | personas_menores15 / pob_0_14 < 0.9 |
| Cobertura baja personas 60+ HOGARES | 20 | 20 | PASS | personas_60mas / pob_60_mas < 0.95 |
| Poblacion de los 18 ANM DIVIPOLA sin cabecera | 26569 | 26569 | PASS | Los otros dos sin cabecera se detallan aparte |
| Poblacion en 20 municipios sin cabecera | 34787 | 34787 | PASS | Incluye 18 ANM y los códigos 94343/94663 |
| Poblacion de 94343 y 94663 sin cabecera | 8218 | 8218 | PASS | 94343=7207; 94663=1011 |
| Diferencias total 17PM vs poblacion 5+ 1PM | 0 | 0 | PASS | Evidencia de universo etario 5+; 17PM no permite denominar solo a 10+ |
| Municipios con item NR >5% | 83 | 83 | PASS | No_tiene_estrato queda aparte |
| Municipios con item NR >10% | 37 | 37 | PASS |  |
| Municipios con item NR >20% | 7 | 7 | PASS |  |
| NA estructurales IPM cabeceras | 20 | 20 | PASS |  |

## Resultados de validación

| validacion | n_evaluado | n_violaciones | estado | tolerancia | evidencia |
| --- | --- | --- | --- | --- | --- |
| Llave/prefijo contexto_1PM | 80909 | 0 | PASS | 0 |  |
| Llave/prefijo contexto_1V | 4276 | 0 | PASS | 0 |  |
| Llave/prefijo hogares_1HM_2HM | 4488 | 0 | PASS | 0 |  |
| Llave/prefijo persona_demo_17PM | 12828 | 0 | PASS | 0 |  |
| Llave/prefijo persona_social_5PM | 12828 | 0 | PASS | 0 |  |
| Llave/prefijo viviendas_6V | 6652 | 0 | PASS | 0 |  |
| Llave/prefijo viviendas_8V | 4276 | 0 | PASS | 0 |  |
| Llave/prefijo viviendas_10V | 4276 | 0 | PASS | 0 |  |
| Llave/prefijo ipm_municipal_ancho | 1122 | 0 | PASS | 0 |  |
| Suma grupos edad = total | 4276 | 0 | PASS | exacta |  |
| Hombre + mujer = total 1PM | 81244 | 0 | PASS | exacta |  |
| Suma población total municipios = control_nacional 1PM E | 1 | 0 | PASS | exacta | suma municipal 44164417 control 44164417 |
| Matriz propuesta base total sin NA | 7854 | 0 | PASS | 0 | Si >0 no se genera z-score ni diagnosticos |
| Proporcion 0-1 actividad_desocupacion_incapacidad_hogar | 1122 | 0 | PASS | [0,1] |  |
| Proporcion 0-1 sin_energia_electrica | 1122 | 0 | PASS | [0,1] |  |
| Proporcion 0-1 sin_gas_red_publica | 1122 | 0 | PASS | [0,1] |  |
| Proporcion 0-1 sin_recoleccion_basuras | 1122 | 0 | PASS | [0,1] |  |
| Proporcion 0-1 sin_internet | 1122 | 0 | PASS | [0,1] |  |
| Proporcion 0-1 hogares_con_menores15 | 1122 | 0 | PASS | [0,1] |  |
| Proporcion 0-1 estrato_1_2 | 1122 | 0 | PASS | [0,1] |  |
| Viviendas presentes 1V = 8V | 1122 | 0 | PASS | exacta | Reportar diferencia sin ajustar |
| Viviendas 1V ocupadas presentes vs total tipo Total 6V | 1122 | 0 | PASS | exacta | Conceptos pueden diferir; solo reportar |
| 17PM total = suma de categorias | 12828 | 0 | PASS | abs <= 1e-8 |  |
| 5PM total = suma de categorias | 12828 | 0 | PASS | abs <= 1e-8 |  |
| 17PM Total=Hombre+Mujer | 4276 | 0 | PASS | abs <= 1e-8 |  |
| 5PM Total=Hombre+Mujer | 4276 | 0 | PASS | abs <= 1e-8 |  |
| 8V servicio energia = categorias | 4276 | 0 | PASS | abs <= 1e-8 |  |
| 8V servicio acueducto = categorias | 4276 | 0 | PASS | abs <= 1e-8 |  |
| 8V servicio alcantarillado = categorias | 4276 | 0 | PASS | abs <= 1e-8 |  |
| 8V servicio gas = categorias | 4276 | 0 | PASS | abs <= 1e-8 |  |
| 8V servicio basuras = categorias | 4276 | 0 | PASS | abs <= 1e-8 |  |
| 8V servicio internet = categorias | 4276 | 0 | PASS | abs <= 1e-8 |  |
| 10V BU = suma BV:CD | 4276 | 0 | PASS | abs <= 1e-8 |  |
| 20 NA IPM cabeceras = municipios sin cabecera | 20 | 0 | PASS | 0 |  |
| IPM Municipal = IPM | 1122 | 0 | PASS | 1e-10 |  |
| IPM fuera de rango 0-100 | 21318 | 0 | PASS | [0,100] |  |
| IPM NA fuera de Cabeceras | 1122 | 0 | PASS | 0 |  |
| Valores negativos en conteos | 1037032 | 0 | PASS | 0 |  |
| Valores no enteros en conteos | 1037032 | 0 | PASS | 0 |  |
| Llaves universo 2018 únicas | 1122 | 0 | PASS | 0 |  |
| MD5 insumos sin cambios | 11 | 0 | PASS | 0 |  |

Descriptivos, correlaciones y diagnósticos previos se generan por R/03_auditoria_indicadores.R. No se ejecuta PCA ni bootstrap.

## Tratamiento de territorio y calidad

- 94663 Mapiripana → 94343 Barrancominas: documentado para la capa SECOP; en 2018 permanecen ambos códigos.
- 27493 Nuevo Belén de Bajirá: se propone 27615 Riosucio como padre, pendiente de verificación DANE/IGAC. Existe conflicto histórico con 05480 Mutatá; Riosucio suma 48.257 personas y un centro poblado de 13.504, mientras Mutatá suma 12.607. Es evidencia compatible, no prueba del límite; no se dividen datos CNPV.
- En los veinte municipios sin cabecera hay 26.569 personas en las 18 áreas no municipalizadas DIVIPOLA. Los otros dos códigos suman 8.218: 94343 Barrancominas (7.207) y 94663 Mapiripana (1.011). La proporción rural dispersa de esos veinte va de 47.27% a 100%; consultar municipios_sin_cabecera.csv.
- Umbrales operativos de cobertura: 5PM sobre pob_10mas, menores15 de HOGARES sobre 1PM y personas 60+ usan los parámetros de R/00_config.R. El prompt no daba esos tres umbrales; quedan editables y requieren aprobación metodológica.
- La población agregada de los 20 municipios sin cabecera se informa con pct_rural_disperso por municipio en municipios_sin_cabecera.csv. Los códigos fuera del conjunto de ANM 2026 se mantienen separados.
- La hipótesis para 27493 tiene conflicto histórico con Mutatá (05480); los totales municipales de 2018 y el centro poblado de Riosucio son coherentes con que incluya parte de Bajirá, pero no prueban el padre. No se fraccionan ni reasignan los conteos.
- Comparar el PCA posterior con y sin los 20 municipios sin cabecera como análisis de sensibilidad; esta etapa solo crea la bandera y covariables.

## Entregables

Tablas de denominadores e indicadores: datos/trabajo/. Especificación, controles, sensibilidad, crosswalk y diagnósticos: resultados/base_trabajo/.

## Próximo paso

Aprobar indicadores y direcciones, confirmar el umbral de cobertura y el padre de 27493; después ejecutar PCA, selección de componentes, bootstrap y validación externa con IPM.

Reproducción: Rscript R/02_base_final_indicadores.R (incluye auditoría R/03_auditoria_indicadores.R).
