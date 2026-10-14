# Verificación de consolidados CNPV e IPM

> Enlaces de la bóveda: [[Inicio_Proyecto]] · [[Estructura_Bases]] · [[Correccion_Estructura_Bases]]

Ejecución: 2026-10-08

## Resumen ejecutivo

Conclusión: los libros sirven como base común para continuar con decisiones territoriales pendientes. Los 1122 códigos de CNPV/IPM coinciden entre los bloques CNPV e IPM; la comparación con DIVIPOLA presenta 2 discrepancias de código documentadas abajo. No se derivaron indicadores ni se imputaron valores.

## Hojas y bloques

| archivo | hoja | filas_excel | columnas | filas_encabezado |
| --- | --- | --- | --- | --- |
| CUADROS_MUNICIPALES_UNIDOS.xlsx | HOGARES_MUNICIPAL | 1126 | 29 | 3 |
| CUADROS_MUNICIPALES_UNIDOS.xlsx | PERSONA_DEMO | 12842 | 21 | 2 |
| CUADROS_MUNICIPALES_UNIDOS.xlsx | PERSONA_SOCIAL | 12842 | 16 | 2 |
| CUADROS_MUNICIPALES_UNIDOS.xlsx | VIVIENDAS | 6662 | 83 | 3 |
| CUADROS_MUNICIPALES_UNIDOS.xlsx | VIVIENDAS | 6662 | 83 | 2 |
| CUADROS_MUNICIPALES_UNIDOS.xlsx | IPM | 0 | 0 | 1 |
| CUADROS_MUNICIPALES_UNIDOS.xlsx | CONTEXTO | 80987 | 20 | 2 |
| IPM_2018_organizado_region.xlsx | IPM_municipios_region | 1123 | 23 | 1 |
| IPM_2018_organizado_region.xlsx | Indicadores_municipales | 17953 | 6 | 1 |
| IPM_2018_organizado_region.xlsx | Indicadores_por_dominio | 50491 | 7 | 1 |
| IPM_2018_organizado_region.xlsx | Diccionario_variables | 20 | 6 | 1 |
| IPM_2018_organizado_region.xlsx | Diccionario_dominio | 65 | 6 | 1 |
| IPM_2018_organizado_region.xlsx | Resumen_region | 7 | 21 | 1 |
| IPM_2018_organizado_region.xlsx | Resumen_departamento | 34 | 7 | 1 |
| IPM_2018_organizado_region.xlsx | Control_calidad | 7 | 2 | 1 |

## Resultados de verificación

Chequeos registrados: 734; con contador n_violaciones positivo: 24. Los chequeos de combinaciones ausentes reportan conteos estructurales, no errores de datos. Ver detalle en `resultados/verificacion_consolidados/chequeos_consistencia.csv`.

| hoja | chequeos | con_violaciones | violaciones |
| --- | --- | --- | --- |
| CNPV/IPM | 4 | 0 | 0 |
| CONTEXTO | 9 | 0 | 0 |
| CONTEXTO cols A:J | 1 | 0 | 0 |
| CONTEXTO cols K:T | 1 | 0 | 0 |
| CONTEXTO_1PM | 30 | 18 | 335 |
| CONTEXTO_1V | 13 | 0 | 0 |
| Control_calidad | 2 | 0 | 0 |
| DIVIPOLA | 3 | 1 | 2 |
| DIVIPOLA/IPM | 1 | 0 | 0 |
| Diccionario_dominio | 2 | 0 | 0 |
| Diccionario_variables | 2 | 0 | 0 |
| HOGARES | 2 | 0 | 0 |
| HOGARES_MUNICIPAL | 42 | 0 | 0 |
| IPM | 1 | 0 | 0 |
| IPM/DIVIPOLA | 1 | 0 | 0 |
| IPM_municipios_region | 63 | 0 | 0 |
| Indicadores_municipales | 3 | 0 | 0 |
| Indicadores_por_dominio | 4 | 0 | 0 |
| PERSONAS_DEMOGRAFICO | 2 | 0 | 0 |
| PERSONAS_SOCIAL | 1 | 0 | 0 |
| PERSONA_DEMO | 102 | 0 | 0 |
| PERSONA_SOCIAL | 72 | 0 | 0 |
| Resumen_departamento | 2 | 0 | 0 |
| Resumen_region | 2 | 0 | 0 |
| VIVIENDAS | 169 | 0 | 0 |
| VIVIENDAS cols A:AR | 1 | 0 | 0 |
| VIVIENDAS cols AS:BQ | 1 | 0 | 0 |
| VIVIENDAS cols BR:CE | 1 | 0 | 0 |
| VIVIENDAS_10V | 25 | 0 | 0 |
| VIVIENDAS_6V | 107 | 5 | 1202 |
| VIVIENDAS_8V | 55 | 0 | 0 |
| contexto_1PM | 1 | 0 | 0 |
| contexto_1V | 1 | 0 | 0 |
| hogares | 1 | 0 | 0 |
| ipm | 1 | 0 | 0 |
| originales | 1 | 0 | 0 |
| persona_demo | 1 | 0 | 0 |
| persona_social | 1 | 0 | 0 |
| viviendas_10V | 1 | 0 | 0 |
| viviendas_6V | 1 | 0 | 0 |
| viviendas_8V | 1 | 0 | 0 |

## Llaves, universo y cobertura

Códigos en unión de fuentes: 1123; códigos CNPV/IPM: 1122; DIVIPOLA: 1122. Diferencias de conjunto: DIVIPOLA solo: 27493; IPM solo: 94663.

### Discrepancias territoriales

| codigo | fuente | detalle |
| --- | --- | --- |
| 27493 | Solo DIVIPOLA | Código Departamento=27; Nombre Departamento=CHOCÓ; Código Municipio=27493; Nombre Municipio=NUEVO BELÉN DE BAJIRÁ; Tipo: Municipio / Isla / Área no municipalizada=Municipio; longitud=-76,71727; Latitud=7,3719; codigo_municipio=27493; codigo_departamento=27 |

| codigo | fuente | detalle |
| --- | --- | --- |
| 94663 | Solo CNPV/IPM | region_geografica=Amazonía; departamento=GUAINÍA; id=94663; municipio=MAPIRIPANA; ipm_municipal=95.5; ipm=95.5; cabeceras=NA; ipm_centros_poblados_y_rural_disperso=95.5; analfabetismo=39.6; bajo_logro_educativo=89.6; barreras_a_servicios_para_cuidado_de_la_primera_infancia=18.7; barreras_de_acceso_a_servicios_de_salud=0.7; tasa_de_dependencia=92.5; hacinamiento_critico=32.8; inadecuada_eliminacion_de_excretas=57.5; inasistencia_escolar=18.7; material_inadecuado_de_paredes_exteriores=18.7; material_inadecuado_de_pisos=22.4; rezago_escolar=59; sin_acceso_a_fuente_de_agua_mejorada=78.4; sin_aseguramiento_en_salud=30.6; trabajo_infantil=0; trabajo_informal=98.5; codigo_municipio=94663; codigo_departamento=94; nombre_municipio=MAPIRIPANA; nombre_departamento=GUAINÍA |

La unión tiene 1123 códigos; no se resolvió cuál universo adoptar.

### Tipo DIVIPOLA y áreas no municipalizadas

| tipo_divipola | n |
| --- | --- |
| Isla | 1 |
| Municipio | 1103 |
| Área no municipalizada | 18 |
|  | 1 |

Áreas no municipalizadas dentro de IPM/CNPV: 18; el mismo conteo alimenta chequeos_consistencia.csv.

### Cobertura por área

| area | municipios_con_fila |
| --- | --- |
| Total | 1122 |
| Cabecera | 1102 |
| Centro poblado | 930 |
| Rural disperso | 1122 |

Cabecera: TRUE 1102, FALSE 20, NA 1. Centro poblado: TRUE 930, FALSE 192, NA 1.

Sin Cabecera en CNPV/IPM: 20; `--` en Cabeceras IPM: 20; diferencia simétrica: 0.

| codigo_municipio | nombre_municipio_ipm |
| --- | --- |
| 94343 | BARRANCOMINAS |
| 94663 | MAPIRIPANA |

Composición verificada: 18 códigos tipo área no municipalizada y 2 casos adicionales mostrados arriba. Hipótesis no comprobada: los casos adicionales podrían corresponder a territorios que eran ANM en 2018.

### Nombres distintos IPM-DIVIPOLA

| codigo_municipio | nombre_ipm | nombre_div |
| --- | --- | --- |
| 13468 | MOMPÓS | SANTA CRUZ DE MOMPOX |
| 19760 | SOTARÁ PAISPAMBA | SOTARÁ - PAISPAMBA |
| 68235 | EL CARMEN DE CHUCURI | EL CARMEN DE CHUCURÍ |
| 76001 | CALI | SANTIAGO DE CALI |

### Combinaciones estructuralmente ausentes

Tipos observados en 6V: 7; universo de combinaciones: 7854; filas presentes: 6652; ausencias: 1202.

| tipo_vivienda | combinaciones_ausentes |
| --- | --- |
| Apartamento | 15 |
| Otro tipo de vivienda (1) | 141 |
| Tipo cuarto | 6 |
| Vivienda tradicional indígena | 446 |
| Vivienda tradicional étnica | 594 |

Grupos de edad observados: 19; bloques municipio-área: 4276; universo de combinaciones: 81244; filas presentes: 80909; ausencias: 335.

| grupo_edad | combinaciones_ausentes |
| --- | --- |
| 0 a 4 | 13 |
| 10 a 14 | 7 |
| 15 a 19 | 7 |
| 20 a 24 | 9 |
| 25 a 29 | 6 |
| 30 a 34 | 8 |
| 35 a 39 | 8 |
| 40 a 44 | 8 |
| 45 a 49 | 5 |
| 5 a 9 | 8 |
| 50 a 54 | 12 |
| 55 a 59 | 8 |
| 60 a 64 | 11 |
| 65 a 69 | 12 |
| 70 a 74 | 29 |
| 75 a 79 | 33 |
| 80 a 84 | 62 |
| 85 y más | 89 |

Son combinaciones no observadas estructuralmente, no datos faltantes de una fila; no se imputaron.

## Duda de 17PM

El encabezado de la columna E está bajo Nivel educativo y F:T son categorías de nivel educativo. La suma E = suma(F:T) se verifica en el CSV de chequeos. La evidencia indica nivel educativo alcanzado, aunque el CSV de decisiones lo describa como asistencia escolar.

## Reconciliación IPM

| chequeo | hoja | n_evaluado | n_violaciones | tolerancia | evidencia |
| --- | --- | --- | --- | --- | --- |
| IPM rango [0,100] ipm_municipal | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] ipm | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] cabeceras | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] ipm_centros_poblados_y_rural_disperso | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] analfabetismo | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] bajo_logro_educativo | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] barreras_a_servicios_para_cuidado_de_la_primera_infancia | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] barreras_de_acceso_a_servicios_de_salud | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] tasa_de_dependencia | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] hacinamiento_critico | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] inadecuada_eliminacion_de_excretas | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] inasistencia_escolar | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] material_inadecuado_de_paredes_exteriores | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] material_inadecuado_de_pisos | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] rezago_escolar | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] sin_acceso_a_fuente_de_agua_mejorada | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] sin_aseguramiento_en_salud | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] trabajo_infantil | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| IPM rango [0,100] trabajo_informal | IPM_municipios_region | 1122 | 0 | 0-100 |  |
| Resumen_region recalculado | Resumen_region | 120 | 0 | 1e-6 |  |
| Resumen_departamento recalculado | Resumen_departamento | 165 | 0 | 1e-6 |  |
| Control_calidad recalculado | Control_calidad | 6 | 0 | exacto | Municipios únicos en IPM:1122:1122; Municipios con departamento:1122:1122; Municipios con región:1122:1122; IPM municipal no nulo:1122:1122; Indicadores de privación:15:15; Registros dominio por municipio:50490:50490 |

Las hojas ancha y largas, diccionarios, resúmenes y controles se compararon según los chequeos. Material inadecuado de paredes exteriores está presente aunque no esté incluida en el grupo indicado por las decisiones.

## Discrepancias

| severidad | hoja | columna_fila | descripcion | evidencia | accion_sugerida |
| --- | --- | --- | --- | --- | --- |
| MEDIA | DIVIPOLA/IPM/CNPV | 27493 | Código presente solo en DIVIPOLA; fuera de CNPV/IPM | Código Departamento=27; Nombre Departamento=CHOCÓ; Código Municipio=27493; Nombre Municipio=NUEVO BELÉN DE BAJIRÁ; Tipo: Municipio / Isla / Área no municipalizada=Municipio; longitud=-76,71727; Latitud=7,3719; codigo_municipio=27493; codigo_departamento=27 | Decidir si conservar fuera del universo maestro; no eliminar ni reasignar |
| MEDIA | DIVIPOLA/IPM/CNPV | 94663 | Código presente en IPM/CNPV pero ausente de DIVIPOLA; sin fila ni coordenadas en catálogo | region_geografica=Amazonía; departamento=GUAINÍA; id=94663; municipio=MAPIRIPANA; ipm_municipal=95.5; ipm=95.5; cabeceras=NA; ipm_centros_poblados_y_rural_disperso=95.5; analfabetismo=39.6; bajo_logro_educativo=89.6; barreras_a_servicios_para_cuidado_de_la_primera_infancia=18.7; barreras_de_acceso_a_servicios_de_salud=0.7; tasa_de_dependencia=92.5; hacinamiento_critico=32.8; inadecuada_eliminacion_de_excretas=57.5; inasistencia_escolar=18.7; material_inadecuado_de_paredes_exteriores=18.7; material_inadecuado_de_pisos=22.4; rezago_escolar=59; sin_acceso_a_fuente_de_agua_mejorada=78.4; sin_aseguramiento_en_salud=30.6; trabajo_infantil=0; trabajo_informal=98.5; codigo_municipio=94663; codigo_departamento=94; nombre_municipio=MAPIRIPANA; nombre_departamento=GUAINÍA | Decidir si conservar en universo maestro sin coordenadas; no imputar |
| BAJA | VIVIENDAS | BR(70) | Ajuste del encabezado de inventario para el bloque 10V: dos filas de encabezado; sin incorporar Total Nacional a BR | BR:CE inventariadas con filas 1:2; el bloque 10V conserva sus datos desde la fila 3 | Solo presentación del inventario; sin cambio en las tablas tidy |
| BAJA | PERSONA_SOCIAL | fila 1722; bloque municipal; columna departamento | Etiqueta departamental de origen anomala: typo D0C0 en nombre de Bogota; sin efecto: la llave se toma del codigo municipal | etiqueta=11_Bogotá, D0C0; municipio=11001_Bogotá, D0C0; codigo_municipio=11001; etiqueta departamental DIVIPOLA por codigo=11_BOGOTÁ, D.C. | Sin efecto: la llave se toma del codigo municipal |
| BAJA | PERSONA_SOCIAL | fila 4833; bloque municipal; columna departamento | Etiqueta departamental de origen anomala: falta nombre departamental; sin efecto: la llave se toma del codigo municipal | etiqueta=23_; municipio=23001_Montería; codigo_municipio=23001; etiqueta departamental DIVIPOLA por codigo=23_CÓRDOBA | Sin efecto: la llave se toma del codigo municipal |
| BAJA | VIVIENDAS | fila 577; bloque 8V; columna departamento | Etiqueta departamental de origen anomala: typo D0C0 en nombre de Bogota; sin efecto: la llave se toma del codigo municipal | etiqueta=11_Bogotá, D0C0; municipio=001_Bogotá, D0C0; codigo_municipio=11001; etiqueta departamental DIVIPOLA por codigo=11_BOGOTÁ, D.C. | Sin efecto: la llave se toma del codigo municipal |
| BAJA | CONTEXTO | fila 10868; bloque 1PM; columna departamento | Etiqueta departamental de origen anomala: falta formato codigo_nombre; sin efecto: la llave se toma del codigo municipal | etiqueta=11Bogotá, D.C.; municipio=11001_Bogotá, D.C.; codigo_municipio=11001; etiqueta departamental DIVIPOLA por codigo=11_BOGOTÁ, D.C. | Sin efecto: la llave se toma del codigo municipal |
| BAJA | CONTEXTO | fila 46032; bloque 1PM; columna departamento | Etiqueta departamental de origen anomala: codigo departamental no coincide con codigo municipal; sin efecto: la llave se toma del codigo municipal | etiqueta=47_La Guajira; municipio=44001_Riohacha; codigo_municipio=44001; etiqueta departamental DIVIPOLA por codigo=44_LA GUAJIRA | Sin efecto: la llave se toma del codigo municipal |
| BAJA | CNPV/IPM | Cabecera | Hallazgo informativo: composición verificada de los municipios sin Cabecera | 18 áreas no municipalizadas; casos adicionales: 94343 BARRANCOMINAS; 94663 MAPIRIPANA | Documentar como ausencia de área; no imputar |
| BAJA | VIVIENDAS_6V | tipo_vivienda | Combinación de tipo ausente en municipios; no tratar como NA de una fila existente | Apartamento: 15 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | VIVIENDAS_6V | tipo_vivienda | Combinación de tipo ausente en municipios; no tratar como NA de una fila existente | Tipo cuarto: 6 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | VIVIENDAS_6V | tipo_vivienda | Combinación de tipo ausente en municipios; no tratar como NA de una fila existente | Vivienda tradicional indígena: 446 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | VIVIENDAS_6V | tipo_vivienda | Combinación de tipo ausente en municipios; no tratar como NA de una fila existente | Vivienda tradicional étnica: 594 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | VIVIENDAS_6V | tipo_vivienda | Combinación de tipo ausente en municipios; no tratar como NA de una fila existente | Otro tipo de vivienda (1): 141 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 0 a 4: 13 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 5 a 9: 8 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 10 a 14: 7 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 15 a 19: 7 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 20 a 24: 9 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 25 a 29: 6 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 30 a 34: 8 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 35 a 39: 8 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 40 a 44: 8 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 45 a 49: 5 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 50 a 54: 12 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 55 a 59: 8 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 60 a 64: 11 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 65 a 69: 12 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 70 a 74: 29 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 75 a 79: 33 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 80 a 84: 62 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | CONTEXTO_1PM | grupo_edad | Grupo de edad ausente en bloques; no tratar como NA de una fila existente | 85 y más: 89 combinaciones | Conservar como ausencia estructural; no imputar |
| BAJA | IPM/DIVIPOLA | 13468 | Nombre difiere entre fuentes; llave por código preserva la correspondencia | IPM=MOMPÓS; DIVIPOLA=SANTA CRUZ DE MOMPOX | No unir ni corregir por nombre; mantener código |
| BAJA | IPM/DIVIPOLA | 19760 | Nombre difiere entre fuentes; llave por código preserva la correspondencia | IPM=SOTARÁ PAISPAMBA; DIVIPOLA=SOTARÁ - PAISPAMBA | No unir ni corregir por nombre; mantener código |
| BAJA | IPM/DIVIPOLA | 68235 | Nombre difiere entre fuentes; llave por código preserva la correspondencia | IPM=EL CARMEN DE CHUCURI; DIVIPOLA=EL CARMEN DE CHUCURÍ | No unir ni corregir por nombre; mantener código |
| BAJA | IPM/DIVIPOLA | 76001 | Nombre difiere entre fuentes; llave por código preserva la correspondencia | IPM=CALI; DIVIPOLA=SANTIAGO DE CALI | No unir ni corregir por nombre; mantener código |

## Decisiones pendientes del usuario

- Elegir universo maestro y tratamiento de 27493/94663.
- Definir tratamiento analítico de las áreas no municipalizadas.
- Mantener las filas ausentes como combinaciones no observadas, sin imputación.
- Decidir qué columnas de 8V se conservan para la fase siguiente.

## Integridad de archivos fuente

MD5 antes/después: CUADROS = 7ff8bd0f6d4590ce85988d9c63893fb9 = 7ff8bd0f6d4590ce85988d9c63893fb9; IPM = 63093138c0ae645546f1409bb4118f12 = 63093138c0ae645546f1409bb4118f12; DIVIPOLA = bc963c8595abcb569039681281320732 = bc963c8595abcb569039681281320732

## Siguiente paso

Resolver las decisiones territoriales y de variables antes de preparar indicadores derivados o realizar análisis multivariado.

