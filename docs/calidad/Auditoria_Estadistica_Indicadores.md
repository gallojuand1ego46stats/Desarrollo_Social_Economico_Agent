> Enlaces Obsidian: [[Inicio_Proyecto]] · [[Resumen_General]] · [[Final_Base]] · [[Refactorizacion_Pipeline_Indicadores]]

# Auditoría estadística de indicadores municipales

Fecha: 2026-10-13. Universo objetivo: 1122 códigos CNPV/IPM 2018.

## 1. Resumen ejecutivo

Los indicadores candidatos están dentro de [0,1] y el pipeline los reproduce, pero su validez conceptual no es uniforme. La evidencia permite continuar con depuración conceptual y análisis exploratorio adicional; **no alcanza para autorizar un PCA definitivo ni un IVS**. La mayor reserva está en MSA 0.414 para estrato 1–2, la definición heterogénea del indicador de actividad, el significado demográfico de hogares con menores y la sensibilidad de variables con NR.

## 2. Universo analizado

Se revisaron 1122 municipios/códigos, 17 indicadores especificados y 7 candidatos propuestos. Los archivos obligatorios ausentes fueron: ninguno.

## 3. Indicadores evaluados

| id_indicador | familia | numerador | denominador | direccion | incluir_pca_propuesto | clasificacion |
| --- | --- | --- | --- | --- | --- | --- |
| educacion_ninguno_pre | Educacion | ninguno + preescolar | total personas 5+ en 17PM | 1 | FALSE | EXCLUIR_PREVIO_PCA |
| educacion_primaria_o_menos | Educacion | ninguno + preescolar + primaria completa/incompleta | total personas 5+ en 17PM | 1 | FALSE | EXCLUIR_PREVIO_PCA |
| educacion_sin_media_completa | Educacion | categorias hasta media incompleta | total personas 5+ en 17PM | 1 | FALSE | EXCLUIR_PREVIO_PCA |
| actividad_desocupacion_incapacidad_hogar | Actividad | busco_trabajo + oficios_hogar + incapacidad + otra situacion | personas 10+ actividad | 1 | TRUE | REVISAR_CONCEPTUALMENTE |
| paredes_inadecuadas | Vivienda | guadua + tapia + madera burda + cana + desecho + sin paredes | viviendas tipo Total | 1 | FALSE | EXCLUIR_PREVIO_PCA |
| sin_acueducto | Servicios | acueducto_no | viviendas ocupadas presentes | 1 | FALSE | EXCLUIR_PREVIO_PCA |
| sin_alcantarillado | Servicios | alcantarillado_no | viviendas ocupadas presentes | 1 | FALSE | EXCLUIR_PREVIO_PCA |
| sin_energia_electrica | Servicios | energia_no | viviendas ocupadas presentes | 1 | TRUE | MANTENER_CON_OBSERVACION |
| sin_gas_red_publica | Servicios | gas_no | total de respuesta del item | 1 | TRUE | MANTENER_CON_OBSERVACION |
| sin_recoleccion_basuras | Servicios | basuras_no | viviendas ocupadas presentes | 1 | TRUE | MANTENER_CON_OBSERVACION |
| sin_internet | Servicios | internet_no | total de respuesta del item | 1 | TRUE | MANTENER_CON_OBSERVACION |
| hogares_con_menores15 | Hogar/demografia | hogares_menores15 | hogares_total | 1 | TRUE | REVISAR_CONCEPTUALMENTE |
| hogares_con_adultos_mayores | Hogar/demografia | hogares_adultos_mayores | hogares_total_2HM | -1 | FALSE | REVISAR_CONCEPTUALMENTE |
| estrato_1_2 | Hogar/demografia | estrato_1 + estrato_2 | personas hogares particulares | 1 | TRUE | REVISAR_CONCEPTUALMENTE |
| sin_servicio_energia_10v | Hogar/demografia | sin_servicio_energia | personas hogares particulares | 1 | FALSE | EXCLUIR_PREVIO_PCA |
| dependencia_demografica | Hogar/demografia | grupos de edad 0-14 y 60+ | poblacion 15-59 | 1 | FALSE | EXCLUIR_PREVIO_PCA |
| pct_rural_disperso | Covariable | pob_rural_disperso | poblacion total | 1 | FALSE | EXCLUIR_PREVIO_PCA |

## 4. Calidad conceptual

| severidad | indicador | hallazgo | evidencia | accion_sugerida |
| --- | --- | --- | --- | --- |
| IMPORTANTE | educacion_ninguno_pre | Población 5+; categorías anidadas de educación y próximas a bajo logro educativo IPM. La edad 5+ incluye población escolar y no representa educación adulta. | Consistente en aritmética según salidas del pipeline; interpretación conceptual se valora en este informe. | EXCLUIR_PREVIO_PCA |
| IMPORTANTE | educacion_primaria_o_menos | Proxy próximo a bajo logro educativo IPM; fuerte solapamiento conceptual y anidamiento con los otros dos indicadores educativos. | Consistente en aritmética según salidas del pipeline; interpretación conceptual se valora en este informe. | EXCLUIR_PREVIO_PCA |
| IMPORTANTE | educacion_sin_media_completa | Proxy cercano a bajo logro educativo IPM; categorías educativas acumulativas y denominador de 5+. | Consistente en aritmética según salidas del pipeline; interpretación conceptual se valora en este informe. | EXCLUIR_PREVIO_PCA |
| IMPORTANTE | actividad_desocupacion_incapacidad_hogar | Combina búsqueda de empleo, oficios del hogar, incapacidad permanente y otra situación; estados heterogéneos con distinta interpretación de vulnerabilidad. | Parcial: numerador agrupa situaciones laborales, domésticas, incapacidad y otra situación. | REVISAR_CONCEPTUALMENTE |
| IMPORTANTE | sin_gas_red_publica | Mide acceso a gas por red, dependiente de oferta territorial; base total incluye sin información, base válida la excluye. | Revisar: base total usa gas_total, que incluye Sin información; la etiqueta 'total de respuesta' describe más bien la base válida. | MANTENER_CON_OBSERVACION |
| IMPORTANTE | sin_recoleccion_basuras | Mide servicio territorial; correlación moderada-fuerte con internet y gas exige inspección de bloque de servicios. | Consistente en aritmética según salidas del pipeline; interpretación conceptual se valora en este informe. | MANTENER_CON_OBSERVACION |
| IMPORTANTE | sin_internet | Acceso/uso de infraestructura con saturación cerca del techo y sensibilidad a sin información. | Revisar: base total usa internet_total, que incluye Sin información; la etiqueta 'total de respuesta' describe más bien la base válida. | MANTENER_CON_OBSERVACION |
| IMPORTANTE | hogares_con_menores15 | Composición/presión demográfica del hogar; proporción no equivale por sí sola a privación y su dirección como vulnerabilidad requiere marco conceptual. | Consistente en aritmética según salidas del pipeline; interpretación conceptual se valora en este informe. | REVISAR_CONCEPTUALMENTE |
| IMPORTANTE | hogares_con_adultos_mayores | Composición del hogar; dirección de vulnerabilidad no está definida y puede reflejar envejecimiento/contexto. | Consistente en aritmética según salidas del pipeline; interpretación conceptual se valora en este informe. | REVISAR_CONCEPTUALMENTE |
| IMPORTANTE | estrato_1_2 | Proporción sobre toda la población en hogares particulares, incluidos no tiene estrato y sin respuesta; estratificación no cubre uniformemente lo rural. MSA bajo. | Parcial: base válida excluye no_sabe_no_responde; no_tiene_estrato permanece en denominador por ser categoría distinta. | REVISAR_CONCEPTUALMENTE |
| IMPORTANTE | sin_servicio_energia_10v | Indicador de energía basado en personas; posible duplicación del indicador de viviendas 8V. | Consistente en aritmética según salidas del pipeline; interpretación conceptual se valora en este informe. | EXCLUIR_PREVIO_PCA |
| IMPORTANTE | dependencia_demografica | Razón demográfica, no proporción [0,1]; concepto de tasa de dependencia presente directamente en IPM. | Coherente como razón demográfica; valor puede superar 1 y no es proporción. | EXCLUIR_PREVIO_PCA |
| IMPORTANTE | pct_rural_disperso | Covariable territorial de contexto; no tiene una dirección universal de vulnerabilidad. | Consistente en aritmética según salidas del pipeline; interpretación conceptual se valora en este informe. | EXCLUIR_PREVIO_PCA |

## 5. Distribución

Los 17 indicadores se recalcularon descriptivamente desde `indicadores_municipales_base_total.csv`. Los valores de indicadores proporcionales quedaron dentro de [0,1]. Una proporción cercana a 1 no se considera imposible; puede reflejar universalidad del fenómeno o concentración territorial. La razón de dependencia no es proporción y puede superar 1. `pct_ceros` se expresa en porcentaje.

| indicador | tipo_escala | minimo | p01 | mediana | media | p99 | maximo | desviacion_estandar | varianza | asimetria | curtosis_exceso | pct_ceros | n_fuera_0_1 | alertas |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| educacion_ninguno_pre | proporcion | 0.0280968438156111 | 0.0375674722916302 | 0.0899072825498065 | 0.0948012393102854 | 0.210817142443648 | 0.386901424245823 | 0.0377994753957138 | 0.00142880034019117 | 1.44832500200863 | 5.1376264430375 | 0 | 0 | sin alerta automatica |
| educacion_primaria_o_menos | proporcion | 0.179659319923495 | 0.260338089224932 | 0.52531093900871 | 0.509518603541027 | 0.694344279232581 | 0.8203125 | 0.0965863269702576 | 0.0093289185576055 | -0.595557271346959 | 0.250195176699887 | 0 | 0 | sin alerta automatica |
| educacion_sin_media_completa | proporcion | 0.317330526423886 | 0.438390064107561 | 0.73076052385968 | 0.711073381080918 | 0.865738993975295 | 0.957300275482094 | 0.0932468397470333 | 0.00869497312280892 | -1.05444048174043 | 1.22107894090613 | 0 | 0 | sin alerta automatica |
| actividad_desocupacion_incapacidad_hogar | proporcion | 0.136340338288057 | 0.203006902690285 | 0.366287430387402 | 0.376705901434362 | 0.651416546103963 | 0.853862212943633 | 0.0833365872505391 | 0.00694498677456671 | 1.14777353218735 | 3.46339591587588 | 0 | 0 | sin alerta automatica |
| paredes_inadecuadas | proporcion | 0.00109177755032412 | 0.00906371217427159 | 0.279495375059557 | 0.321610309805009 | 0.967972700357441 | 0.990291262135922 | 0.234019428191704 | 0.0547650927711723 | 0.803604592805759 | 0.0430059904048625 | 0 | 0 | sin alerta automatica |
| sin_acueducto | proporcion | 0 | 0.010310970115318 | 0.256049971501922 | 0.312557852926902 | 0.975736874918446 | 0.994565217391304 | 0.236324523375157 | 0.055849280348495 | 0.945053993800585 | 0.215752686025672 | 0.089126559714795 | 0 | sin alerta automatica |
| sin_alcantarillado | proporcion | 0.00423063800750597 | 0.0305506614755555 | 0.560378152890516 | 0.544477459231973 | 0.992618192026951 | 1 | 0.253556723673887 | 0.0642910121202357 | -0.143807227015461 | -0.811547491516693 | 0 | 0 | sin alerta automatica |
| sin_energia_electrica | proporcion | 0.000881765605954511 | 0.00225714249589758 | 0.0328953582443215 | 0.0885011018579919 | 0.858929026563461 | 0.966442953020134 | 0.154583383204115 | 0.0238960223628303 | 3.36764287739215 | 12.3428204774939 | 0 | 0 | asimetria alta |
| sin_gas_red_publica | proporcion | 0.0300837677325657 | 0.083300041474617 | 0.712705335630165 | 0.671423181187179 | 1 | 1 | 0.272527880681335 | 0.07427144574866 | -0.486230046618949 | -0.899147365095764 | 0 | 0 | sin alerta automatica |
| sin_recoleccion_basuras | proporcion | 0.00208120095530536 | 0.0150743253966882 | 0.505641213711612 | 0.489696444778176 | 0.988013757697828 | 0.997533908754624 | 0.255070277722137 | 0.0650608465772481 | -0.102312025241152 | -0.904952706354623 | 0 | 0 | sin alerta automatica |
| sin_internet | proporcion | 0.118014329580348 | 0.327692285737585 | 0.920057672567135 | 0.868900853243975 | 0.989041013181498 | 0.99296806328743 | 0.141408323880019 | 0.0199963140625563 | -2.30512195866121 | 5.63424024920954 | 0 | 0 | asimetria alta |
| hogares_con_menores15 | proporcion | 0.224903474903475 | 0.275635778998263 | 0.451239454434362 | 0.459969719607356 | 0.69917115522443 | 0.795454545454545 | 0.0941385061083038 | 0.00886205833230316 | 0.382124968630763 | -0.121044009723364 | 0 | 0 | sin alerta automatica |
| hogares_con_adultos_mayores | proporcion | 0.125 | 0.16349342197085 | 0.322850133686155 | 0.324782641985925 | 0.513879207052749 | 0.585913312693498 | 0.0824114933660157 | 0.00679165423881684 | 0.206985784037404 | -0.357106474024855 | 0 | 0 | sin alerta automatica |
| estrato_1_2 | proporcion | 0.00802792321116928 | 0.048365674991062 | 0.900969648631657 | 0.837039263598951 | 0.987753798843586 | 0.991444388525415 | 0.183823472165796 | 0.033791068919089 | -2.37428703523958 | 6.03154183319412 | 0 | 0 | asimetria alta |
| sin_servicio_energia_10v | proporcion | 0.000558659217877095 | 0.00163648955696571 | 0.0283742756482468 | 0.0855685050504875 | 0.899064784469189 | 0.98848167539267 | 0.158952372876391 | 0.0252658568430352 | 3.45523885492656 | 12.8977425490963 | 0 | 0 | asimetria alta |
| dependencia_demografica | razon | 0.34082825203252 | 0.464144106203944 | 0.651486651486652 | 0.664384958759218 | 1.01025606051601 | 1.36990595611285 | 0.110067403061546 | 0.0121148332167127 | 1.29967257807813 | 4.39065154230451 | 0 | NA | sin alerta automatica |
| pct_rural_disperso | proporcion | 0.000657082429026616 | 0.0129878185411008 | 0.443988673556844 | 0.434818859854113 | 0.899107435991763 | 1 | 0.249946649848079 | 0.0624733277702782 | -0.0469085304222415 | -1.09221704761033 | 0 | 0 | sin alerta automatica |

## 6. Variabilidad

Ninguno de los siete candidatos tiene varianza casi nula. Eso no demuestra que cada variable sea útil: el MSA y la interpretación conceptual señalan reservas para estrato 1–2 y electricidad.

## 7. Outliers

Se identificaron 32 municipios con al menos un |z| > 4; 17 tienen menos de 5.000 habitantes y el máximo es 3 indicadores extremos en un municipio. Los valores z son un diagnóstico estadístico; no justifican eliminar observaciones. La tabla lista códigos, variables implicadas y población cuando está disponible. La base actual no prueba por sí sola si un valor extremo es error o realidad; se requiere inspección de fuente para cada caso.

| indicador | n_municipios_abs_z_mayor_4 |
| --- | --- |
| actividad_desocupacion_incapacidad_hogar | 5 |
| sin_energia_electrica | 19 |
| sin_gas_red_publica | 0 |
| sin_recoleccion_basuras | 0 |
| sin_internet | 8 |
| hogares_con_menores15 | 0 |
| estrato_1_2 | 18 |

Municipios (máximo 40 mostrados):

| codigo_municipio | n_indicadores_abs_z_mayor_4 | indicadores | nombre_municipio | nombre_departamento | pob_total | flag_pob_lt5000 | tipo_divipola |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 05266 | 1 | sin_internet | ENVIGADO | ANTIOQUIA | 212437 | FALSE | Municipio |
| 05360 | 1 | sin_internet | ITAGÜÍ | ANTIOQUIA | 263332 | FALSE | Municipio |
| 05631 | 1 | sin_internet | SABANETA | ANTIOQUIA | 81797 | FALSE | Municipio |
| 11001 | 1 | sin_internet | BOGOTÁ, D.C. | BOGOTÁ, D.C. | 7181469 | FALSE | Municipio |
| 19785 | 1 | actividad_desocupacion_incapacidad_hogar | SUCRE | CAUCA | 6201 | FALSE | Municipio |
| 25175 | 1 | sin_internet | CHÍA | CUNDINAMARCA | 129613 | FALSE | Municipio |
| 25372 | 1 | actividad_desocupacion_incapacidad_hogar | JUNÍN | CUNDINAMARCA | 5234 | FALSE | Municipio |
| 27250 | 1 | sin_energia_electrica | EL LITORAL DEL SAN JUAN | CHOCÓ | 11579 | FALSE | Municipio |
| 27425 | 2 | sin_energia_electrica;estrato_1_2 | MEDIO ATRATO | CHOCÓ | 10140 | FALSE | Municipio |
| 27745 | 2 | sin_energia_electrica;estrato_1_2 | SIPÍ | CHOCÓ | 2768 | TRUE | Municipio |
| 44560 | 1 | sin_energia_electrica | MANAURE | LA GUAJIRA | 74528 | FALSE | Municipio |
| 44847 | 2 | sin_energia_electrica;estrato_1_2 | URIBIA | LA GUAJIRA | 160711 | FALSE | Municipio |
| 68001 | 1 | sin_internet | BUCARAMANGA | SANTANDER | 528855 | FALSE | Municipio |
| 68276 | 1 | sin_internet | FLORIDABLANCA | SANTANDER | 275109 | FALSE | Municipio |
| 76001 | 1 | sin_internet | SANTIAGO DE CALI | VALLE DEL CAUCA | 1822869 | FALSE | Municipio |
| 91263 | 1 | estrato_1_2 | EL ENCANTO | AMAZONAS | 1885 | TRUE | Área no municipalizada |
| 91407 | 1 | sin_energia_electrica | LA PEDRERA | AMAZONAS | 3781 | TRUE | Área no municipalizada |
| 91430 | 2 | sin_energia_electrica;estrato_1_2 | LA VICTORIA | AMAZONAS | 166 | TRUE | Área no municipalizada |
| 91460 | 1 | sin_energia_electrica | MIRITÍ - PARANÁ | AMAZONAS | 1023 | TRUE | Área no municipalizada |
| 91530 | 1 | estrato_1_2 | PUERTO ALEGRÍA | AMAZONAS | 681 | TRUE | Área no municipalizada |
| 91669 | 2 | sin_energia_electrica;estrato_1_2 | PUERTO SANTANDER | AMAZONAS | 1450 | TRUE | Área no municipalizada |
| 91798 | 2 | sin_energia_electrica;estrato_1_2 | TARAPACÁ | AMAZONAS | 3179 | TRUE | Área no municipalizada |
| 94663 | 2 | sin_energia_electrica;estrato_1_2 | MAPIRIPANA | GUAINÍA | 1011 | TRUE | NA |
| 94883 | 2 | sin_energia_electrica;estrato_1_2 | SAN FELIPE | GUAINÍA | 1411 | TRUE | Área no municipalizada |
| 94884 | 2 | sin_energia_electrica;estrato_1_2 | PUERTO COLOMBIA | GUAINÍA | 1643 | TRUE | Área no municipalizada |
| 94885 | 2 | sin_energia_electrica;estrato_1_2 | LA GUADALUPE | GUAINÍA | 222 | TRUE | Área no municipalizada |
| 94886 | 2 | sin_energia_electrica;estrato_1_2 | CACAHUAL | GUAINÍA | 839 | TRUE | Área no municipalizada |
| 94887 | 2 | actividad_desocupacion_incapacidad_hogar;estrato_1_2 | PANA PANA | GUAINÍA | 1182 | TRUE | Área no municipalizada |
| 94888 | 3 | actividad_desocupacion_incapacidad_hogar;sin_energia_electrica;estrato_1_2 | MORICHAL | GUAINÍA | 812 | TRUE | Área no municipalizada |
| 97511 | 3 | actividad_desocupacion_incapacidad_hogar;sin_energia_electrica;estrato_1_2 | PACOA | VAUPÉS | 3956 | TRUE | Área no municipalizada |
| 97889 | 2 | sin_energia_electrica;estrato_1_2 | YAVARATÉ | VAUPÉS | 756 | TRUE | Área no municipalizada |
| 99773 | 2 | sin_energia_electrica;estrato_1_2 | CUMARIBO | VICHADA | 43138 | FALSE | Municipio |

## 8. Correlaciones

La matriz tiene estructura informativa, con relaciones moderadas y fuertes, pero no pares con |r| ≥ 0,90. Relaciones notables: electricidad con estrato 1–2 negativa (r≈−0,776); internet con recolección (r≈0,702); recolección con gas (r≈0,697). La relación negativa con estrato puede reflejar composición urbana/rural y definición del denominador. Correlación no establece redundancia conceptual por sí sola.

| indicador_1 | indicador_2 | correlacion | clasificacion |
| --- | --- | --- | --- |
| estrato_1_2 | sin_energia_electrica | -0.776241162398416 | fuerte negativa |
| sin_internet | sin_recoleccion_basuras | 0.70228645891589 | fuerte positiva |
| sin_gas_red_publica | sin_recoleccion_basuras | 0.696814720764968 | moderada positiva |
| sin_gas_red_publica | sin_internet | 0.594409836733666 | moderada positiva |
| actividad_desocupacion_incapacidad_hogar | sin_recoleccion_basuras | 0.53042290583608 | moderada positiva |
| actividad_desocupacion_incapacidad_hogar | sin_internet | 0.513383433740356 | moderada positiva |
| hogares_con_menores15 | sin_energia_electrica | 0.494466062284533 | moderada positiva |
| sin_energia_electrica | sin_recoleccion_basuras | 0.402546116547774 | moderada positiva |
| actividad_desocupacion_incapacidad_hogar | sin_gas_red_publica | 0.369276721973895 | debil positiva |
| estrato_1_2 | hogares_con_menores15 | -0.346433270206373 | debil negativa |
| sin_energia_electrica | sin_gas_red_publica | 0.342761819157454 | debil positiva |
| actividad_desocupacion_incapacidad_hogar | sin_energia_electrica | 0.336267398394551 | debil positiva |
| estrato_1_2 | sin_internet | 0.305646548680245 | debil positiva |
| sin_energia_electrica | sin_internet | 0.209692238464919 | debil positiva |
| hogares_con_menores15 | sin_internet | 0.14769247284663 | debil positiva |
| hogares_con_menores15 | sin_recoleccion_basuras | 0.135235693787363 | debil positiva |
| actividad_desocupacion_incapacidad_hogar | hogares_con_menores15 | 0.128870161276706 | debil positiva |
| actividad_desocupacion_incapacidad_hogar | estrato_1_2 | -0.0446908819590632 | debil negativa |
| estrato_1_2 | sin_gas_red_publica | -0.044400614917713 | debil negativa |
| estrato_1_2 | sin_recoleccion_basuras | -0.0419383836065024 | debil negativa |
| hogares_con_menores15 | sin_gas_red_publica | 0.035365078660437 | debil positiva |

## 9. KMO individual

| indicador | MSA | clasificacion | hallazgo |
| --- | --- | --- | --- |
| actividad_desocupacion_incapacidad_hogar | 0.88237330419164 | adecuado | Adecuación individual favorable, no prueba suficiente por sí sola. |
| sin_energia_electrica | 0.554371036453898 | aceptable/marginal | Adecuación marginal; revisar comunalidades y concepto. |
| sin_gas_red_publica | 0.799257466359547 | adecuado | Adecuación individual favorable, no prueba suficiente por sí sola. |
| sin_recoleccion_basuras | 0.798025541311982 | adecuado | Adecuación individual favorable, no prueba suficiente por sí sola. |
| sin_internet | 0.587697852316609 | aceptable/marginal | Adecuación marginal; revisar comunalidades y concepto. |
| hogares_con_menores15 | 0.744336164051589 | adecuado | Adecuación individual favorable, no prueba suficiente por sí sola. |
| estrato_1_2 | 0.414310611748725 | problemático | La variable comparte poca varianza común; puede debilitar una solución factorial. |

## 10. KMO global

KMO global recalculado desde el CSV: 0.642. Señala adecuación moderada en esta matriz; los KMO individuales bajos indican que algunas variables no comparten suficiente varianza común. No constituye aprobación automática del PCA.

## 11. Bartlett

χ² = 4664.873, gl = 21, p almacenado = 0. El valor 0 en el CSV es límite de representación numérica; el resultado debe expresarse como p < 0,001. Con 1.122 observaciones, significancia no implica que las asociaciones sean sustantivamente fuertes.

## 12. Determinante

Determinante = 0.0154. No sugiere singularidad numérica extrema en esta matriz, pero debe interpretarse junto con MSA, correlaciones y estabilidad.

## 13. No respuesta

| indicador | spearman | dif_abs_max | dif_abs_mediana | n_abs_ge_002 | n_rel_ge_10pct | n_sens_alta | n_base_valida_NA | severidad | hallazgo | distincion_nr |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| educacion_sin_media_completa | 0.967762432090028 | 0.214135694259258 | 0.0067266040778699 | 105 | 25 | 105 | 0 | IMPORTANTE | 105 municipios sensibles; diferencia absoluta máxima 0.214; Spearman 0.968 | la diferencia base total/base válida refleja inclusión/exclusión de la categoría NR |
| educacion_primaria_o_menos | 0.985066877894298 | 0.15336485324194 | 0.00475156810894256 | 88 | 25 | 88 | 0 | MENOR | 88 municipios sensibles; diferencia absoluta máxima 0.153; Spearman 0.985 | la diferencia base total/base válida refleja inclusión/exclusión de la categoría NR |
| sin_internet | 0.954424743767677 | 0.167574361122748 | 0.00391855249863143 | 85 | 11 | 85 | 0 | MENOR | 85 municipios sensibles; diferencia absoluta máxima 0.168; Spearman 0.954 | la diferencia base total/base válida refleja inclusión/exclusión de la categoría NR |
| sin_gas_red_publica | 0.993570673716847 | 0.124565609820491 | 0.00243157622858414 | 58 | 4 | 58 | 0 | MENOR | 58 municipios sensibles; diferencia absoluta máxima 0.125; Spearman 0.994 | la diferencia base total/base válida refleja inclusión/exclusión de la categoría NR |
| actividad_desocupacion_incapacidad_hogar | 0.994724533414725 | 0.104038520911012 | 0.00576694699707966 | 54 | 24 | 54 | 0 | MENOR | 54 municipios sensibles; diferencia absoluta máxima 0.104; Spearman 0.995 | la diferencia base total/base válida refleja inclusión/exclusión de la categoría NR |
| estrato_1_2 | 0.996570950011684 | 0.136552368962696 | 0.0007776569300606 | 26 | 8 | 26 | 0 | MENOR | 26 municipios sensibles; diferencia absoluta máxima 0.137; Spearman 0.997 | no_sabe_no_responde se trata como NR; no_tiene_estrato sigue siendo categoría sustantiva distinta |
| educacion_ninguno_pre | 0.99768389870453 | 0.0316114351287735 | 0.000842491043462443 | 13 | 25 | 26 | 0 | MENOR | 26 municipios sensibles; diferencia absoluta máxima 0.032; Spearman 0.998 | la diferencia base total/base válida refleja inclusión/exclusión de la categoría NR |
| 10V: no_sabe_no_responde | NA | NA | NA | NA | NA | NA | NA | IMPORTANTE | NR ponderada=0.2%; tasa municipal máxima=52.01% | No respuesta |
| 10V: no_tiene_estrato (categoria distinta) | NA | NA | NA | NA | NA | NA | NA | MENOR | NR ponderada=0.92%; tasa municipal máxima=53.6% | Categoría sustantiva; no confundir con no_sabe_no_responde |
| 17PM: sin_informacion | NA | NA | NA | NA | NA | NA | NA | IMPORTANTE | NR ponderada=1.7%; tasa municipal máxima=36.86% | No respuesta |
| 5PM: no_informa | NA | NA | NA | NA | NA | NA | NA | IMPORTANTE | NR ponderada=1.9%; tasa municipal máxima=19.1% | No respuesta |
| 8V_gas: sin_informacion | NA | NA | NA | NA | NA | NA | NA | IMPORTANTE | NR ponderada=0.86%; tasa municipal máxima=12.68% | No respuesta |
| 8V_internet: sin_informacion | NA | NA | NA | NA | NA | NA | NA | IMPORTANTE | NR ponderada=0.91%; tasa municipal máxima=17.2% | No respuesta |

Las correlaciones/KMO se calcularon para la matriz base total. La sensibilidad NR actual compara cada proporción municipio por municipio, pero no recalcula las matrices de correlación/KMO con la matriz base válida; por tanto el efecto de NR sobre estructura multivariada todavía no está cuantificado. La categoría 10V `no_tiene_estrato` se mantuvo distinta de `no_sabe_no_responde`.

## 14. Decisiones sobre variables

| id_indicador | clasificacion | severidad_conceptual | MSA | evaluacion_conceptual |
| --- | --- | --- | --- | --- |
| educacion_ninguno_pre | EXCLUIR_PREVIO_PCA | IMPORTANTE | NA | Población 5+; categorías anidadas de educación y próximas a bajo logro educativo IPM. La edad 5+ incluye población escolar y no representa educación adulta. |
| educacion_primaria_o_menos | EXCLUIR_PREVIO_PCA | IMPORTANTE | NA | Proxy próximo a bajo logro educativo IPM; fuerte solapamiento conceptual y anidamiento con los otros dos indicadores educativos. |
| educacion_sin_media_completa | EXCLUIR_PREVIO_PCA | IMPORTANTE | NA | Proxy cercano a bajo logro educativo IPM; categorías educativas acumulativas y denominador de 5+. |
| actividad_desocupacion_incapacidad_hogar | REVISAR_CONCEPTUALMENTE | IMPORTANTE | 0.88237330419164 | Combina búsqueda de empleo, oficios del hogar, incapacidad permanente y otra situación; estados heterogéneos con distinta interpretación de vulnerabilidad. |
| paredes_inadecuadas | EXCLUIR_PREVIO_PCA | SIN PROBLEMA | NA | Correspondencia directa con privación IPM de material de paredes. |
| sin_acueducto | EXCLUIR_PREVIO_PCA | SIN PROBLEMA | NA | Correspondencia directa o muy cercana a acceso a fuente de agua mejorada IPM. |
| sin_alcantarillado | EXCLUIR_PREVIO_PCA | SIN PROBLEMA | NA | Correspondencia directa o muy cercana a eliminación de excretas IPM. |
| sin_energia_electrica | MANTENER_CON_OBSERVACION | SIN PROBLEMA | 0.554371036453898 | Concepto interpretable; MSA marginal y distribución muy asimétrica. No hay privación IPM idéntica. |
| sin_gas_red_publica | MANTENER_CON_OBSERVACION | IMPORTANTE | 0.799257466359547 | Mide acceso a gas por red, dependiente de oferta territorial; base total incluye sin información, base válida la excluye. |
| sin_recoleccion_basuras | MANTENER_CON_OBSERVACION | IMPORTANTE | 0.798025541311982 | Mide servicio territorial; correlación moderada-fuerte con internet y gas exige inspección de bloque de servicios. |
| sin_internet | MANTENER_CON_OBSERVACION | IMPORTANTE | 0.587697852316609 | Acceso/uso de infraestructura con saturación cerca del techo y sensibilidad a sin información. |
| hogares_con_menores15 | REVISAR_CONCEPTUALMENTE | IMPORTANTE | 0.744336164051589 | Composición/presión demográfica del hogar; proporción no equivale por sí sola a privación y su dirección como vulnerabilidad requiere marco conceptual. |
| hogares_con_adultos_mayores | REVISAR_CONCEPTUALMENTE | IMPORTANTE | NA | Composición del hogar; dirección de vulnerabilidad no está definida y puede reflejar envejecimiento/contexto. |
| estrato_1_2 | REVISAR_CONCEPTUALMENTE | IMPORTANTE | 0.414310611748725 | Proporción sobre toda la población en hogares particulares, incluidos no tiene estrato y sin respuesta; estratificación no cubre uniformemente lo rural. MSA bajo. |
| sin_servicio_energia_10v | EXCLUIR_PREVIO_PCA | IMPORTANTE | NA | Indicador de energía basado en personas; posible duplicación del indicador de viviendas 8V. |
| dependencia_demografica | EXCLUIR_PREVIO_PCA | IMPORTANTE | NA | Razón demográfica, no proporción [0,1]; concepto de tasa de dependencia presente directamente en IPM. |
| pct_rural_disperso | EXCLUIR_PREVIO_PCA | IMPORTANTE | NA | Covariable territorial de contexto; no tiene una dirección universal de vulnerabilidad. |

## 15. Variables recomendadas para PCA

Como candidatas para **revisión**, no aprobación: sin energía eléctrica, gas por red, recolección de basuras e internet. Actividad, hogares con menores y estrato 1–2 requieren revisión conceptual antes de conservarse. Ninguna debe pasar a PCA automáticamente.

## 16. Variables que deben excluirse antes del PCA

Por circularidad/solapamiento con privaciones IPM: educación, paredes inadecuadas, falta de acueducto, falta de alcantarillado y dependencia demográfica. `sin_servicio_energia_10v` es redundante como formulación alternativa a electricidad 8V; `pct_rural_disperso` es contexto y no candidato de vulnerabilidad sin definición adicional.

## 17. Variables que requieren revisión

Actividad (numerador heterogéneo); hogares con menores (composición no es privación); adultos mayores (dirección); estrato 1–2 (MSA 0.414 y universo de personas no estratificadas); y los cuatro servicios candidatos por correlación/territorialidad, sesgo y/o NR.

## 18. Limitaciones

Los archivos fuente son resúmenes municipales, no microdatos; outliers no se pueden validar caso a caso contra la fuente original en esta automatización. Los valores de p se almacenan como cero por subdesbordamiento. Los candidatos se evalúan en base total; falta recomputar la matriz válida. El número de archivos ausentes, si los hubiera, se reporta sin inventar sustitutos.

## Comparación reproducible de salidas

| control | valor | estado | interpretacion |
| --- | --- | --- | --- |
| descriptivos_min_p1_mediana_media_p99_max | 1.11022302462516e-16 | PASS | Comparación recalculada contra estadisticos_indicadores.csv; asimetria/curtosis dependen de la convención del paquete psych. |
| correlaciones_recalculadas_vs_archivo | 1.11022302462516e-16 | PASS | Correlaciones recalculadas desde la matriz municipal y cotejadas por par. |
| sensibilidad_NR_resumen_vs_municipio | 0 | PASS | Municipios sensibles y diferencia máxima coinciden entre los dos CSV. |
| outliers_recalculados_vs_archivo | 0 | PASS | Diferencia de conteo de municipios con algun \|z\|>4. |

## 19. Recomendaciones antes del PCA

1. Resolver denominadores de 8V gas/internet: la especificación dice 'total de respuesta', pero la base total usa el total que incluye Sin información; decidir base principal y reflejarlo en la etiqueta.
2. Definir el constructo e interpretación de actividad y composición de hogares.
3. Revisar el universo del estrato 1–2, su baja adecuación MSA y los casos rurales sin estrato.
4. Recalcular correlaciones/KMO en base válida y comparar matrices/rankings.
5. Inspeccionar municipios extremos con fuente y denominadores; no excluirlos por z-score.
6. Evaluar dimensiones/estructura (incluida posible estructura de servicios) antes de decidir si un índice unidimensional tiene sentido.
7. Congelar decisiones conceptuales y documentar regla de faltantes/cobertura.

## Conclusiones A–J

- **A. ¿Están correctamente construidos?** Aritméticamente, las comprobaciones del pipeline registran cero fallos y los candidatos están en [0,1]. Conceptualmente hay etiquetas/denominadores que deben corregirse o ratificarse, sobre todo gas e internet.
- **B. ¿Hay evidencia suficiente para PCA?** No para ejecutarlo como decisión final; sí para una etapa adicional de revisión y análisis exploratorio, con reservas de MSA y concepto.
- **C. ¿Mantener?** Cuatro servicios (energía 8V, gas, recolección, internet) como candidatos condicionados a revisión.
- **D. ¿Revisar?** Actividad, hogares con menores, estrato 1–2 y hogares con adultos mayores.
- **E. ¿Excluir antes?** Educación, paredes, acueducto, alcantarillado, dependencia, energía 10V duplicada y ruralidad como covariable contextual.
- **F. ¿Problema demográfico?** Sí: 17PM mide nivel educativo para población 5+ y el indicador de actividad cubre 10+; no deben confundirse poblaciones. La dependencia es razón y puede superar 1.
- **G. ¿NR afecta materialmente?** Hay decenas a más de cien municipios con diferencias absolutas ≥0,02 en varios indicadores; la correlación de ranking sigue alta (ρ≈0,95–0,997). El impacto sobre estructura PCA aún no fue probado.
- **H. ¿Outliers son errores?** No hay evidencia para llamarlos errores; son extremos estadísticos que requieren verificación por fuente.
- **I. ¿Correlación informativa?** Sí, con relaciones complementarias y bloques moderados/fuertes, sin pares ≥0,90; esto no resuelve la adecuación individual ni la conceptual.
- **J. ¿Qué falta?** Resolver denominadores/NR y conceptos, analizar base válida, revisar extremos, aprobar variables y parámetros, luego reconsiderar PCA.

## Reproducción

Desde la raíz: `Rscript R/03_auditoria_indicadores.R`. El script lee la base consolidada existente, los nueve CSV requeridos y salidas NR; no construye de nuevo los indicadores ni ejecuta PCA.

> Enlaces Obsidian: [[Inicio_Proyecto]] · [[Resumen_General]] · [[Final_Base]] · [[Refactorizacion_Pipeline_Indicadores]]
