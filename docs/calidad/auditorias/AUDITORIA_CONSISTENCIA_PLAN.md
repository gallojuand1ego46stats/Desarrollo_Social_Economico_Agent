# Plan de auditoría de consistencia metodológica

**Corte de revisión:** 18 de octubre de 2026. **Alcance:** auditoría del estado del proyecto y propuesta de una edición metodológica nueva. Los documentos existentes se conservan intactos; los productos de esta revisión se guardan en esta carpeta.

## Fases y criterios

- [x] **0. Trazabilidad.** Registrar alcance, fuentes revisadas, regla de no modificación y corte temporal.
- [x] **1. Consistencia interna.** Contrastar el informe activo, CSV de decisiones, fórmulas, matrices, auditoría de consolidados y reportes históricos. Cada hallazgo identifica evidencia y tipo.
- [x] **2. Bibliografía.** Verificar referencias en páginas editoriales, fuentes oficiales o repositorios institucionales. `referencias_nuevas.bib` contiene solo entradas contrastadas; los elementos no confirmados quedan registrados en `REFERENCIAS_NO_INCLUIDAS.md`.
- [x] **3. Propuestas.** Separar errores verificables de decisiones pendientes; no alterar decisiones del equipo ni aplicar las correcciones dentro de los archivos originales.
- [x] **4. Reproducción.** Ejecutar `verificar_cifras_auditoria.R` para cotejar cifras principales desde los CSV existentes; el último cotejo registra 31 PASS y 0 por revisar en `cotejo_cifras_auditoria.csv`.
- [x] **5. Nueva edición metodológica.** Crear INFORME_METODOLOGICO_REVISION_FINAL.tex, con bibliografía propia, compilarlo como PDF separado y revisar sus citas, referencias y páginas.
- [x] **6. Cierre.** Resumir resultados, límites y asuntos que requieren decisión del equipo en RESUMEN_EJECUTIVO_AUDITORIA.md.

## Fuentes revisadas

1. docs/informe1_metodologico/main.tex, portada, resumen, anexos y módulos activos en docs/informe1_metodologico/secciones/actualizacion/.
2. docs/informe1_metodologico/referencias.bib y el PDF/log de la compilación existente.
3. docs/diccionario/decisiones_variables_IVS_CNPV2018.csv.
4. docs/metodologia/Formulas_indicadores_IVS_candidatos_2026-10-15.md y resultados/indicadores_finales_ivs_20261015/.
5. resultados/verificacion_consolidados/, docs/calidad/auditorias/VERIFICACION_CONSOLIDADOS.md, docs/calidad/DIAGNOSTICO_ESTADO_ACTUAL.md.
6. Solucion_pendientes.md, Resumen_General.md y docs/Informe1_Estado_Arte_Muestreo_Division_Trabajo.tex.
7. R/00_config.R, R/01_verificar_consolidados.R y scripts de preparación/auditoría de indicadores.
8. Fuentes bibliográficas: DANE, DNP, CEPAL, OECD/JRC, Springer, Wiley, Oxford Academic y metadatos bibliográficos identificados en la justificación.

## Criterio de evidencia

Se usan las etiquetas **VERIFICADO EN ARCHIVO**, **FUENTE EXTERNA VERIFICADA**, **DECISIÓN DEL EQUIPO** e **INFERENCIA/PROPUESTA**. Los resultados 2026-10-15 describen la corrida almacenada; la auditoría documental tiene corte 2026-10-18. No se ejecutó PCA ni se construyó o validó un IVS.

