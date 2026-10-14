# TRASH_OUT.md — Reglas del repositorio

## Contexto
Proyecto de grado (Estadística, USTA): correspondencia entre contratación pública (SECOP II) y vulnerabilidad socioeconómica municipal en Colombia. Alcance descriptivo/asociativo; no se afirma causalidad. Lenguaje principal: R (versión: desconocida). Documentación en MkDocs sobre docs/.

## Pipeline vivo
datos/CUADROS_MUNICIPALES_UNIDOS.xlsx + datos/IPM_2018_organizado_region.xlsx + docs/diccionario/decisiones_variables_IVS_CNPV2018.csv → derivar indicadores → matriz municipal → PCA/IVS. SECOP II se integra después del IVS.
Entrypoint vigente: no hay un script R activo; los candidatos históricos `OLVIDADOS/R/01_auditoria_bases.R` y `OLVIDADOS/R/01_auditoria_bases_v2.R` fueron archivados por decisión del usuario.

## Reglas inviolables
- Nunca modificar ni borrar nada en `datos/` (no está en git y no es recuperable).
- No tocar `.git/`, `.github/`, `mkdocs.yml`, `README.md`, `SECURITY.md`, `requirements.txt` sin petición explícita.
- Conservar siempre `docs/diccionario/decisiones_variables_IVS_CNPV2018.csv` y `docs/metodologia/seleccion_variables_ivs.md`.
- No ejecutar scripts que lean los libros Excel grandes sin confirmación.
- Ante la duda sobre si un archivo se usa, conservarlo y preguntar.

## Protocolo de borrado
- Rama nueva y etiqueta de respaldo antes de borrar.
- Solo se retiran de su ubicación activa los archivos marcados BORRAR por el usuario en docs/calidad/limpieza_candidatos.csv.
- Los scripts `.R` retirados se archivan con `git mv` bajo `OLVIDADOS/`, preservando su ruta relativa; no se eliminan irreversiblemente.
- Archivar en commits pequeños, uno por categoría, citando la evidencia en el mensaje.
- Tras cada commit, verificar por análisis estático que los .R restantes pasan `parse()` y que ninguna función llamada desde el entrypoint quedó sin definir.

## Convenciones de datos
- Códigos DIVIPOLA siempre como texto de longitud fija, nunca numéricos.
- El IPM/CNPV 2018 es un corte transversal: no replicarlo por año como si variara sin una decisión metodológica explícita.
- No alimentar el PCA con conteos absolutos cuando lo comparable son proporciones o tasas.
- Mantener trazabilidad: cada indicador con fórmula, numerador, denominador, orientación y regla de faltantes.

## Cambios a este archivo
Solo con aprobación del usuario.
