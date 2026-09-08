# Registro de fuentes de datos

## 1. DIVIPOLA

- Fuente: DANE / Datos Abiertos Colombia.
- Dataset: `DIVIPOLA- Códigos municipios`.
- ID Socrata: `gdxc-w37w`.
- Variables clave: `cod_dpto`, `dpto`, `cod_mpio`, `nom_mpio`, `tipo_municipio`, `longitud`, `latitud`.
- Uso en el proyecto: llave territorial maestra para homologar SECOP II y DANE/IPM.
- Estado de referencia consultado: corte 30 de diciembre de 2024.

Fuente oficial: https://www.datos.gov.co/Mapas-Nacionales/DIVIPOLA-C-digos-municipios/gdxc-w37w

## 2. SECOP II - Contratos Electrónicos

- Fuente: Agencia Nacional de Contratación Pública - Colombia Compra Eficiente / Datos Abiertos Colombia.
- Dataset: `SECOP II - Contratos Electrónicos`.
- ID Socrata actual: `jbjy-vk9h`.
- Uso en el proyecto: construcción de medidas municipales de contratación (número de contratos, valor contratado, valor per cápita, modalidades, sectores, tipos y duración, sujeto a disponibilidad y auditoría).
- Recomendación: no descargar de entrada toda la base a Git; trabajar primero con consultas filtradas/descargas por periodos y almacenar los archivos localmente en `data/raw/secop_ii/`.

Fuente oficial: https://www.datos.gov.co/Gastos-Gubernamentales/SECOP-II-Contratos-Electr-nicos/jbjy-vk9h

El repositorio base `ustadistica/desarrollo_social_y_economico` documenta además un proceso de descarga trimestral y consolidación histórica usando la API de SECOP, lo que se tomará como referencia de ingeniería de datos, no como sustituto de la fuente oficial.

## 3. DANE - IPM municipal censal 2018

- Fuente: Departamento Administrativo Nacional de Estadística (DANE).
- Producto: Medida de pobreza multidimensional municipal de fuente censal 2018.
- Base principal para el análisis municipal: anexo censal de pobreza municipal 2018.
- Uso en el proyecto: variable IPM y, previa revisión del anexo/diccionario, indicadores compatibles para la construcción del IVS mediante PCA.

Fuente oficial: https://www.dane.gov.co/files/investigaciones/condiciones_vida/pobreza/2018/informacion-censal/anexo-censal-pobreza-municipal-2018.xlsx

Complemento oficial: el Geoportal DANE dispone de un servicio municipal de IPM 2018 con código municipal, nombre, departamento e IPM, útil para validación territorial.

Servicio: https://geoportal.dane.gov.co/mparcgis/rest/services/INDICADORES_COND_DE_VIDA/Serv_Mpios_IndPobrezaMultidimensional_2018/MapServer/4

## 4. Microdatos IPM 2018

El catálogo de microdatos del DANE documenta bases nacionales/departamentales de hogares, personas, viviendas y factores de expansión. Estas bases se conservarán como fuente de respaldo metodológico y no se incorporarán automáticamente al Gold municipal hasta verificar la unidad de análisis y la posibilidad de agregación reproducible.

Catálogo: https://microdatos.dane.gov.co/catalog/606/data_dictionary

## Regla de almacenamiento

Las bases originales y derivadas no se publican en GitHub. El `.gitignore` protege CSV, Excel, Parquet, RDS y otros formatos. GitHub almacena código, documentación, diccionarios y metadatos de procedencia.
