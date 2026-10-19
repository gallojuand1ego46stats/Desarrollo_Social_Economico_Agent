# Justificación bibliográfica y estado de verificación

“Respaldo parcial” significa que la fuente explica un principio general, pero no prueba que el indicador elegido sea válido para este proyecto. Las fuentes nuevas verificadas están en `referencias_nuevas.bib`.

| Decisión | Qué debe justificarse | Fuentes verificadas y contenido pertinente | Fuerza del respaldo | Estado y límite |
|---|---|---|---|---|
| A. Selección de cuadros y descarte | Correspondencia entre concepto, unidad, definición y variables | CNPV DANE documenta universos y variables; metadatos DANE definen P_TRABAJO como actividad de semana anterior en personas de 10+; DNP ICVU es antecedente colombiano sobre cuidado/dependencia en hogares urbanos. | Parcial/contextual | No hay evidencia que determine que estos cuadros concretos sean combinación óptima de un IVS municipal. |
| B. Evitar circularidad/solapamiento con IPM | Distinguir predictor de criterio externo | DANE describe 15 privaciones, cinco dimensiones, unidad hogar y umbrales. OECD/JRC y Greco et al. recomiendan transparencia y robustez en selección, ponderación, agregación y sensibilidad. | Fuerte para el principio; parcial para la lista | Excluir IPM agregado evita inclusión directa; no elimina solapamiento conceptual. La asociación futura será convergencia parcial, no independiente. |
| C. Ponderaciones | Distinguir normativas, iguales y empíricas | Decancq y Lugo clasifican pesos normativos, basados en datos e híbridos; OECD/JRC y Greco recomiendan sensibilidad. | Fuerte para describir métodos; no valida el 2:1 | El peso de 5PM es normativo, aprobado por el equipo. 702/1.122 municipios cambian ≥2 pp frente a 1:1; eso obliga a reportar sensibilidad, no elige el peso por sí solo. |
| D. Composición 17PM | Evitar PCA cruda de partes que suman uno | Aitchison (1983) formaliza PCA composicional en contrastes log-ratio. | Fuerte para cautela composicional | El agregado reduce dimensión, no controla composición de edad de población 5+. 17PM queda reservada. |
| E. Estrato y “No tiene estrato” | Precisar unidad y propósito social | DANE define estratificación como clasificación de inmuebles residenciales para régimen de servicios; seis estratos reflejan aproximación jerárquica socioeconómica. | Parcial | No es ingreso del hogar; ley no declara “No tiene estrato” como vulnerabilidad. Inclusión es decisión del equipo. |
| F. Antecedentes colombianos | Situar constructo y límites de transferencia | CEPAL ofrece marco de activos/oportunidades y vulnerabilidad; DANE IPM censal; DNP ICVU urbano; artículo Novum Jus aplica análisis espacial de IPM en Cundinamarca. | Contextual | Estas fuentes no validan una PCA municipal de ocho indicadores ni la comparación 2018–2026. |
| G. Diagnósticos PCA | Explicar KMO/MSA y esfericidad de Bartlett | Kaiser (1974) define el índice de simplicidad factorial; Bartlett (1950) presenta la prueba de esfericidad. | Fuerte para definir estadísticos; nulo para validar el IVS | Se aplican a la matriz que se defina; los valores existentes son de una matriz histórica de siete variables. La significancia no demuestra validez conceptual ni dimensionalidad útil. |

## Matriz candidata × privación IPM

La proximidad temática no implica equivalencia. Los indicadores IPM se definen a nivel de hogar; las candidatas IVS son proporciones municipales de hogares, viviendas o personas.

| Candidata | Privación IPM cercana | Tipo | Implicación |
|---|---|---|---|
| 1HM | Barreras cuidado primera infancia; tasa dependencia | Parcial: <15 frente a 0–5; composición frente a personas por ocupado | No es mismo concepto/corte. |
| 2HM | Tasa dependencia | Parcial: estructura de edad no equivale a razón por ocupado | No inferir dependencia económica/funcional. |
| 5PM | Dependencia, informalidad, trabajo infantil | Indirecta/parcial, definiciones de población distintas | Validar convergencia con cautela; no llamar desempleo oficial. |
| 6V | Paredes exteriores inadecuadas | Alta, pero parcial; agrega tapia/bahareque/adobe y no usa cortes urbano/rurales | Hacer sensibilidad con componentes y área. |
| Energía 8V | Sin indicador exacto entre las 15 privaciones listadas | Baja directa, dominio servicios | Puede complementar; condiciones de oferta importan. |
| Gas 8V | Agua/saneamiento | Baja directa | No equivale a esos servicios; conservar sensibilidad NR. |
| Internet 8V | Educación/acceso | Indirecta | Proxy de acceso digital, no privación IPM equivalente. |
| 10V | Vivienda/servicios; sin indicador de estrato | Contextual | Proxy administrativo; “sin estrato” requiere interpretación propia. |
| 17PM reservada | Analfabetismo, bajo logro, inasistencia y rezago | Cercana en educación, distinta edad/medida | Mantener exploratoria; 5+ no ajustada por edad. |

## Verificadas y no verificadas

- Incluidas como definitivas únicamente referencias con URL/DOI cotejados en fuente editorial o institucional; véase `referencias_nuevas.bib`.
- La entrada activa de Kaiser tenía DOI erróneo. La nueva edición usa 10.1007/BF02291575.
- La clave dane2019ipm aparece en un módulo legado no incluido por el main activo y no tiene entrada homónima en el .bib activo; no se trasladó.
- La afirmación local de SECOP 2015–2025 (7.827.129 filas/59 variables) no se verificó en datos originales; se trata como fuente narrativa histórica, no como cifra reproducida.
- Monsalvo y Jiménez se verificó en la página editorial Novum Jus y se incluye como antecedente contextual, no como método de IVS.
- El DANE muestra P_TRABAJO como actividad de semana anterior y varias categorías en población 10+; no respalda nombrar el score 5PM como desempleo oficial.

