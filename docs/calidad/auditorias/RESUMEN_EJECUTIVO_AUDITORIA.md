# Resumen ejecutivo de auditoría metodológica

**Corte de la auditoría:** 18 de octubre de 2026. **Estado de los resultados auditados:** línea base del 15 de octubre. Esta revisión es independiente y complementaria; no reemplaza el informe activo ni incorpora la actualización descriptiva del 18 de octubre. Las referencias a nueve columnas corresponden a la matriz histórica: ocho candidatas para el primer PCA más 17PM reservada. Para el estado vigente, consultar `docs/calidad/auditorias/ACTUALIZACION_DESCRIPTIVA_20261018.md` y el Informe 1 metodológico v2.1.

**Conclusión de la línea base auditada:** los cálculos del 15 de octubre preparan nueve indicadores candidatos; no existe PCA ejecutado ni IVS final. La matriz de nueve columnas no debe leerse como la especificación vigente del PCA.

## Hallazgos de mayor impacto

1. La matriz guardada tiene nueve candidatas y 1.122 códigos; el PCA planeado usa ocho y reserva sin_media_completa_17PM. El resumen de corrida llama “n_indicadores_pca” a nueve: inconsistencia objetiva de estado.
2. La sensibilidad 10V es alta: usando denominador total frente a categorías clasificables, Spearman=0,4045, delta máximo=0,988 y 711 municipios tienen cambios ≥2 pp. La fórmula acordada queda provisional como proporción entre elegibles.
3. Se mantiene cercanía conceptual parcial con IPM en paredes (6V), educación (17PM), estructura por edad/hogar (1HM/2HM) y actividad (5PM). La comparación será convergente parcial, no independiente.
4. La matriz de la línea base auditada difiere de la especificación histórica de siete: incorpora 2HM y 6V; excluye basuras sin decisión explícita; cambia fórmulas de 5PM y 10V. KMO/Bartlett anteriores no son diagnósticos de las ocho variables planeadas.
5. CNPV 2018 reporta 1.101 municipios, 20 ANM y archipiélago. Los 18 códigos ANM de DIVIPOLA 2026 no clasifican la geografía de 2018; 27493 y 94663 requieren crosswalk validado.
6. DOI de Kaiser incorrecto en la bibliografía activa; la referencia verificada usa 10.1007/BF02291575.

Las Tablas 3, 4 y 6 del informe de la línea base auditada son rastreables a sus CSV. La Tabla 6 usa siete variables históricas: KMO=0,6425; Bartlett χ²=4.664,8728, gl=21, p<0,001. El valor cero en CSV es subdesbordamiento, no probabilidad nula.

## Decisiones pendientes del equipo

- Fijar la geografía 2018 para municipios, ANM e isla.
- Confirmar tratamiento de basuras 8V y regla de solapamiento IPM.
- Resolver interpretación de denominador 10V luego de sensibilidad multivariada.
- Mantener 5PM 2:1 como experimental y decidir escenarios.
- Definir criterios PCA, componentes y estabilidad.

## Evidencia y límites

El script `verificar_cifras_auditoria.R` se ejecutó con R 4.6.0: **31 verificaciones PASS, 0 por revisar**, con salida en `cotejo_cifras_auditoria.csv`. R mostró advertencias de locale UTF-8 no disponible en este Windows; no afectaron las lecturas ni los cotejos. La nueva bibliografía incluye únicamente referencias con DOI o URL verificados; los elementos no incorporados y su motivo están en `REFERENCIAS_NO_INCLUIDAS.md`.

El informe metodológico nuevo compiló a PDF de 15 páginas con MiKTeX/BibTeX; la revisión final del log no encontró citas, referencias cruzadas ni ecuaciones sin resolver. Se inspeccionó visualmente la maquetación de tablas y fórmulas. Los documentos, scripts y resultados previos del proyecto permanecen intactos; los productos de esta auditoría están separados en esta carpeta.

El histórico SECOP 2015–2025 se observó solo en narrativa local; no se cotejó con fuente de datos. No se ejecutó PCA, no se construyó IVS y no se modificaron datos ni documentos previos.

