# Resumen_GPT — Handoff del Proyecto Desarrollo Social Económico

> Documento de transferencia técnica para continuidad del desarrollo, auditoría y análisis estadístico del proyecto.  
> **Repositorio raíz obligatorio:** `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent`

---

# 1. Metadata del Proyecto

| Campo | Información |
|---|---|
| **Nombre** | Desarrollo Social Económico |
| **Versión** | `[PENDIENTE: confirmar versión/tag actual del repositorio]` |
| **Fecha del handoff** | 2026-10-01 |
| **Autor** | Juan Diego Gallo Quintero |
| **Área** | Estadística aplicada, ciencia de datos, análisis territorial |
| **Lenguaje principal** | R |
| **Entorno principal** | RStudio |
| **Herramientas auxiliares** | Git, GitHub, Cursor, OpenCode |
| **Repositorio local** | `C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent` |
| **Repositorio remoto** | `[PENDIENTE: confirmar URL/repositorio remoto actual]` |
| **Unidad de análisis** | Municipios colombianos |
| **Fuentes principales** | DANE, SECOP II, DIVIPOLA |
| **Estado de la fase** | Recuperación y auditoría del pipeline |

---

# 2. Objetivos y Alcance

## 2.1 Objetivo general

Determinar si existe una correspondencia entre la distribución territorial de la contratación pública y las condiciones de vulnerabilidad socioeconómica de los municipios colombianos.

El proyecto busca integrar información territorial, socioeconómica y de contratación pública para estudiar patrones de asociación y posibles brechas territoriales.

## 2.2 Objetivos específicos

1. Caracterizar la distribución territorial de la contratación pública en los municipios colombianos.
2. Construir una caracterización estadística de las condiciones de vulnerabilidad socioeconómica municipal.
3. Integrar las fuentes mediante identificadores territoriales consistentes.
4. Construir, después de validar las variables disponibles, una representación sintética de la vulnerabilidad socioeconómica mediante análisis de componentes principales (PCA), cuando metodológicamente corresponda.
5. Analizar la asociación entre características de la contratación pública y vulnerabilidad socioeconómica.
6. Identificar patrones de correspondencia territorial.
7. Identificar posibles brechas territoriales.
8. Evaluar la necesidad de incorporar análisis espacial según los diagnósticos estadísticos.
9. Mantener un pipeline reproducible, auditable y documentado.

## 2.3 Alcance

El análisis está orientado principalmente a:

- Municipios colombianos.
- Información socioeconómica del DANE.
- Información de contratación pública de SECOP II.
- DIVIPOLA como referencia territorial.
- Variables relacionadas con:
  - vulnerabilidad socioeconómica;
  - privaciones;
  - características demográficas;
  - hogares;
  - vivienda;
  - personas;
  - contratación pública;
  - territorio.

## 2.4 Fuera de alcance

Quedan fuera de alcance, salvo decisión metodológica posterior documentada:

- Inferencia causal sobre el efecto de la contratación pública sobre la pobreza.
- Interpretaciones causales a partir de asociaciones observacionales.
- Predicción individual de pobreza municipal.
- Construcción de modelos de machine learning como objetivo principal.
- Análisis espacial avanzado antes de verificar que los diagnósticos estadísticos lo justifiquen.
- PCA definitivo antes de completar la auditoría y tipificación de las variables.
- Uso de muestras como sustituto del procesamiento completo de las bases pesadas.

---

# 3. Estado Actual

## 3.1 Situación general

El proyecto se encuentra en una **fase de recuperación y auditoría del pipeline**.

La prioridad actual no es ejecutar todavía el PCA definitivo, sino recuperar y verificar físicamente el estado real de los datos, scripts y documentación.

El principio operativo actual es:

> **Primero garantizar que el pipeline procesa correctamente todas las bases y que las variables están correctamente documentadas y tipificadas; después realizar la construcción definitiva de indicadores y análisis multivariado.**

## 3.2 Estado por módulo

| Módulo | Estado | % Avance | Notas |
|---|---|---:|---|
| Inventario de bases | 🟢 Funcional | 100% | Las 6 bases principales están identificadas |
| Auditoría de archivos | 🟡 En corrección | 70% | Existen scripts funcionales, pero el procesamiento de Excel requiere corrección |
| Procesamiento por chunks | 🔴 Bloqueado | 30% | La función actual no implementa chunks reales sobre Excel |
| Diccionario general | 🟡 Incompleto | 40% | `inventario_bases.csv` avanzado; diccionario de variables incompleto |
| Diccionarios por base | 🔴 Pendiente | 20% | Deben generarse y validarse individualmente |
| Tipificación estadística | 🟡 En desarrollo | 40% | Debe asignarse tipo, escala, naturaleza, unidad y dirección |
| Auditoría IPM | 🟡 En desarrollo | 70% | Existen funciones específicas |
| Auditoría territorial | 🟡 En desarrollo | 70% | DIVIPOLA debe actuar como referencia territorial |
| CNPV hogares | 🟡 Parcial | 50% | No todas las hojas han sido procesadas |
| CNPV personas demográfico | 🔴 Pendiente | 30% | Base pesada; procesamiento completo pendiente |
| CNPV personas social | 🔴 Bloqueado | 25% | Se presentó error de lectura alrededor de `1PM` |
| CNPV viviendas | 🔴 Pendiente | 20% | Requiere procesamiento completo |
| Integración territorial | 🟡 En desarrollo | 40% | Requiere validación de cobertura y llaves |
| Selección de variables para PCA | 🔴 Pendiente | 25% | No debe cerrarse hasta terminar auditoría |
| PCA definitivo | ⏸️ No iniciado | 0% | Deliberadamente pospuesto |
| Asociación contratación-vulnerabilidad | ⏸️ Pendiente | 0% | Depende de la construcción de indicadores |
| Correspondencia | ⏸️ Pendiente | 0% | Depende de fases anteriores |
| Brechas territoriales | ⏸️ Pendiente | 0% | Depende de integración y diagnóstico |
| Análisis espacial | ⏸️ Condicional | 0% | Solo realizar si los diagnósticos lo justifican |
| Testing del pipeline | 🟡 En desarrollo | 40% | Debe fortalecerse con validaciones de cobertura y procesamiento |

## 3.3 Problemas conocidos

### Problema crítico 1 — Falso procesamiento por chunks

La función:

```r
procesar_excel_chunks()
```

se encuentra documentada como mecanismo de procesamiento por chunks, pero actualmente utiliza `read_excel()` sobre hojas completas.

Por tanto:

> **No debe considerarse un procesamiento chunked real.**

Esto es especialmente relevante para las bases:

- `PERSONAS_DEMOGRAFICO_Cuadros_CNPV_2018.xlsx`
- `PERSONAS_SOCIAL_Cuadros_CNPV_2018.XLSX`

No se debe utilizar muestreo como sustituto del procesamiento final.

Se permiten muestras pequeñas únicamente para tareas auxiliares como:

- detección de encabezados;
- inspección inicial;
- identificación de estructura;
- metadata.

## 3.4 Problema crítico 2 — Procesamiento incompleto de bases

Se identificaron:

- `PERSONAS_DEMOGRAFICO`: procesamiento incompleto.
- `PERSONAS_SOCIAL`: fallo durante procesamiento alrededor de `1PM`.
- `HOGARES`: hojas `2HD`, `2HM`, `3HD`, `3HM` pendientes.
- `VIVIENDAS`: procesamiento completo pendiente.

---

# 4. Arquitectura y Estructura

## 4.1 Raíz obligatoria

```text
C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent
```

El proyecto debe respetar la arquitectura existente.

**No crear una estructura paralela ni migrar arbitrariamente `datos/` hacia otra arquitectura sin una decisión documentada.**

## 4.2 Árbol conceptual

```text
Desarrollo_Social_Economico_Agent/
│
├── datos/
│   ├── anexo-censal-pobreza-municipal-2018.xlsx
│   ├── DIVIPOLA-_Códigos_municipios_20260917.csv
│   ├── HOGARES_Cuadros_CNPV_2018.XLSX
│   ├── PERSONAS_DEMOGRAFICO_Cuadros_CNPV_2018.xlsx
│   ├── PERSONAS_SOCIAL_Cuadros_CNPV_2018.XLSX
│   └── VIVIENDAS_Cuadros_CNPV_2018.XLSX
│
├── R/
│   ├── 01_auditoria_bases.R
│   └── funciones/
│       ├── auditoria_archivos.R
│       ├── auditoria_ipm.R
│       ├── auditoria_territorial.R
│       ├── generar_informe_calidad.R
│       └── utils.R
│
├── docs/
│   ├── diccionario/
│   │   ├── inventario_bases.csv
│   │   ├── diccionario_variables.csv
│   │   ├── candidatos_ivs.csv
│   │   ├── matriz_ipm_cnpv.csv
│   │   └── cobertura_municipal.csv
│   │
│   └── calidad/
│
├── tests/
│
├── outputs/
│   ├── tablas/
│   └── figuras/
│
├── [PENDIENTE: confirmar carpetas adicionales existentes]
│
└── docs/handoff/Resumen_GPT.md
```

## 4.3 Flujo conceptual de datos

```text
                 ┌─────────────────────┐
                 │      FUENTES        │
                 └──────────┬──────────┘
                            │
          ┌─────────────────┼──────────────────┐
          │                 │                  │
          ▼                 ▼                  ▼
     DANE / IPM          CNPV              DIVIPOLA
          │          Hogares/Personas/         │
          │             Viviendas              │
          │                 │                  │
          └─────────────────┼──────────────────┘
                            ▼
                  ┌──────────────────┐
                  │ AUDITORÍA DATOS  │
                  └────────┬─────────┘
                           │
                           ▼
                ┌─────────────────────┐
                │ DICCIONARIOS        │
                │ + TIPIFICACIÓN      │
                └──────────┬──────────┘
                           │
                           ▼
                ┌─────────────────────┐
                │ LIMPIEZA / HOMOG.   │
                │ TERRITORIAL         │
                └──────────┬──────────┘
                           │
                           ▼
                ┌─────────────────────┐
                │ INDICADORES SOCIO-  │
                │ ECONÓMICOS          │
                └──────────┬──────────┘
                           │
                           ▼
                ┌─────────────────────┐
                │ PCA / ÍNDICE DE     │
                │ VULNERABILIDAD      │
                └──────────┬──────────┘
                           │
                           ▼
             ┌───────────────────────────┐
             │ INTEGRACIÓN SECOP II      │
             └─────────────┬─────────────┘
                           │
                           ▼
             ┌───────────────────────────┐
             │ ASOCIACIÓN /              │
             │ CORRESPONDENCIA / BRECHAS │
             └─────────────┬─────────────┘
                           │
                           ▼
             ┌───────────────────────────┐
             │ ANÁLISIS ESPACIAL         │
             │ SI DIAGNÓSTICOS LO        │
             │ JUSTIFICAN                │
             └───────────────────────────┘
```

---

# 5. Decisiones Técnicas Tomadas (ADR resumido)

| Decisión | Alternativas consideradas | Justificación | Consecuencias |
|---|---|---|---|
| Utilizar R como lenguaje principal | Python, R, mixto | El procesamiento estadístico y análisis se desarrollan principalmente en R/RStudio | Se requiere mantener reproducibilidad en R |
| Mantener `datos/` como organización actual | Migrar inmediatamente a `data/` | El repositorio actual utiliza `datos/`; no se debe romper la arquitectura existente | Algunos diseños anteriores de carpetas `data/` quedan como referencia conceptual |
| Procesar bases pesadas completas | Muestreo como procesamiento final | El análisis requiere cobertura completa de municipios/hojas relevantes | Mayor costo computacional |
| Usar chunks reales cuando sean necesarios | Leer hojas Excel completas | Las bases de personas pueden ser demasiado grandes para memoria | Requiere estrategia técnica compatible con XLSX |
| Usar DIVIPOLA como referencia territorial | Matching textual directo | Permite estandarizar códigos municipales | Requiere validar cambios y cobertura |
| Auditar antes del PCA | Ejecutar PCA inmediatamente | El PCA depende de variables correctamente tipificadas y validadas | Retrasa temporalmente el PCA |
| PCA para sintetizar vulnerabilidad | Elegir arbitrariamente una variable objetivo | El objetivo analítico es representar una dimensión latente de vulnerabilidad | Requiere diagnóstico de adecuación y selección de variables |
| Análisis espacial condicional | Incorporarlo automáticamente | No toda asociación requiere modelamiento espacial | Puede quedar fuera si no se justifica |
| Separar diccionarios por base | Un único diccionario plano | Cada fuente tiene estructura y semántica propia | Mayor documentación, pero mejor trazabilidad |
| Mantener muestras solo para metadata | Procesar todo siempre | Las muestras son útiles para detectar estructura, pero no sustituyen el análisis | Se debe etiquetar explícitamente cualquier muestra |

## 5.1 Trade-offs críticos

### Completitud vs rendimiento

Procesar todas las hojas aumenta:

- tiempo;
- memoria;
- almacenamiento temporal;
- complejidad del pipeline.

Pero permite:

- cobertura completa;
- auditoría reproducible;
- menor riesgo de sesgo por selección;
- trazabilidad de resultados.

### Automatización vs control metodológico

La automatización del diccionario reduce trabajo manual, pero puede producir tipificaciones incorrectas.

Por eso la clasificación automática debe ser:

```text
detección automática
        ↓
regla estadística
        ↓
validación
        ↓
documentación
```

y no:

```text
nombre de columna → tipo asumido
```

### PCA temprano vs calidad de datos

Ejecutar el PCA demasiado pronto puede generar un índice técnicamente calculado pero metodológicamente débil.

La decisión actual es:

> **auditar → tipificar → seleccionar → diagnosticar → PCA.**

---

# 6. Fragmentos Clave de Código

> **Nota:** los fragmentos exactos del repositorio no fueron proporcionados en el contexto disponible. No se inventan implementaciones. Los siguientes bloques representan contratos conceptuales que deben verificarse contra el código real antes de copiarlos como implementación definitiva.

## 6.1 Punto de entrada de auditoría

> Referencia histórica: este entrypoint y sus módulos fueron archivados bajo `OLVIDADOS/R/` por decisión del usuario. El siguiente esquema muestra sus rutas actuales de archivo; no es un comando de ejecución del pipeline vigente.

Archivo:

```text
OLVIDADOS/R/01_auditoria_bases.R
```

El script funciona como orquestador principal de la auditoría.

```r
# Punto de entrada del pipeline de auditoría.
# El objetivo es centralizar la ejecución y evitar que cada auditoría
# tenga rutas o configuraciones independientes.

source("OLVIDADOS/R/funciones/auditoria_archivos.R")
source("OLVIDADOS/R/funciones/auditoria_ipm.R")
source("OLVIDADOS/R/funciones/auditoria_territorial.R")
source("OLVIDADOS/R/funciones/generar_informe_calidad.R")
source("OLVIDADOS/R/funciones/utils.R")
```

**Por qué importa:** las funciones deben mantenerse separadas de la orquestación para facilitar testing y reutilización.

---

## 6.2 Procesamiento de archivos Excel

Archivo:

```text
OLVIDADOS/R/funciones/auditoria_archivos.R
```

La función actualmente denominada:

```r
procesar_excel_chunks()
```

debe considerarse pendiente de corrección hasta verificar que realiza procesamiento realmente incremental.

**Problema conocido:**

```r
# NO asumir que esto constituye chunking:
readxl::read_excel(...)
```

Leer una hoja completa mediante `read_excel()` no constituye procesamiento por chunks.

La implementación definitiva debe documentar explícitamente:

- tamaño de chunk;
- mecanismo de lectura;
- manejo de encabezados;
- tipos;
- errores;
- hojas vacías;
- recuperación ante errores;
- salida incremental.

---

## 6.3 Tipificación estadística

Las utilidades del proyecto contemplan atributos como:

```text
tipo
escala
naturaleza
unidad
dirección de vulnerabilidad
```

Conceptualmente, una variable debe documentarse mediante metadatos como:

```r
list(
  nombre = "...",
  tipo = "...",
  escala = "...",
  naturaleza = "...",
  unidad = "...",
  direccion_vulnerabilidad = "..."
)
```

**Por qué importa:** el nombre de una variable no es suficiente para decidir cómo debe entrar al análisis estadístico.

---

## 6.4 Auditoría territorial

Archivo:

```text
OLVIDADOS/R/funciones/auditoria_territorial.R
```

El objetivo es comprobar que los identificadores territoriales puedan utilizarse para integrar las fuentes.

Conceptualmente:

```r
# La integración debe priorizar códigos territoriales estandarizados
# sobre coincidencias textuales de nombres municipales.

municipios <- municipios |>
  dplyr::mutate(codigo_municipio = ...)
```

La implementación exacta debe verificarse contra DIVIPOLA antes de modificarla.

---

## 6.5 Auditoría IPM

Archivo:

```text
OLVIDADOS/R/funciones/auditoria_ipm.R
```

Debe comprobar, como mínimo:

- hojas existentes;
- dimensiones;
- variables;
- cobertura territorial;
- valores faltantes;
- consistencia de identificadores;
- naturaleza de indicadores;
- correspondencia con dimensiones de vulnerabilidad.

---

## 6.6 Generación del informe de calidad

Archivo:

```text
OLVIDADOS/R/funciones/generar_informe_calidad.R
```

El informe debe actuar como evidencia de ejecución y no solamente como salida decorativa.

Debe permitir responder:

```text
¿Qué archivo se procesó?
¿Qué hoja se procesó?
¿Cuántas filas tenía?
¿Cuántas columnas?
¿Hubo errores?
¿Cuántos faltantes?
¿Qué variables fueron detectadas?
¿Se procesó completo o parcialmente?
```

---

## 6.7 Construcción del índice mediante PCA

El PCA definitivo todavía no debe ejecutarse como producto final.

La estructura metodológica esperada será aproximadamente:

```r
# 1. Seleccionar variables válidas
# 2. Revisar correlaciones y adecuación
# 3. Estandarizar cuando corresponda
# 4. Ejecutar PCA
# 5. Revisar cargas
# 6. Revisar varianza explicada
# 7. Determinar orientación del componente
# 8. Construir índice documentado
```

**Importante:** todavía no existe una única "variable objetivo" definida para PCA.

El PCA es una técnica de reducción/síntesis de variables, no un modelo supervisado que obligatoriamente requiera una variable objetivo `Y`.

---

## 6.8 Integración final con contratación pública

La integración conceptual será:

```text
Municipio
   │
   ├── Vulnerabilidad socioeconómica
   │       └── Índice / componentes
   │
   └── Contratación pública
           ├── modalidad
           ├── sector
           ├── tipo de contrato
           └── duración
```

La unidad territorial común debe ser validada antes de cualquier análisis de asociación.

---

# 7. Dependencias y Entorno

## 7.1 Lenguaje

```text
R
```

Versión exacta:

```text
[PENDIENTE: ejecutar R.version.string]
```

## 7.2 IDE

```text
RStudio
```

## 7.3 Librerías

El proyecto utiliza funciones asociadas, como mínimo, con:

```r
readxl
dplyr
```

Además, deben verificarse las dependencias reales mediante:

```text
[PENDIENTE: renv.lock / DESCRIPTION / scripts actuales]
```

No declarar versiones exactas sin obtenerlas del repositorio.

## 7.4 Git

Git es utilizado para control de versiones.

Verificar:

```bash
git status
git branch
git remote -v
git log --oneline -10
```

## 7.5 Instalación

```r
# [PENDIENTE: confirmar mecanismo definitivo de instalación]
```

Si el proyecto utiliza `renv`, el procedimiento esperado sería:

```r
renv::restore()
```

pero esto **debe verificarse antes de ejecutarlo**.

## 7.6 Ejecución

Punto de entrada:

```text
OLVIDADOS/R/01_auditoria_bases.R
```

Debe ejecutarse desde:

```text
C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent
```

Evitar rutas absolutas codificadas dentro de los scripts.

---

# 8. Datos

## 8.1 Inventario actual

### IPM

```text
anexo-censal-pobreza-municipal-2018.xlsx
```

Características conocidas:

- 6 hojas.
- Aproximadamente 6.748 filas.
- Aproximadamente 1,3 MB.

Hojas relevantes:

```text
2_IPM Mpio y Dpt
4_IPM Mpio dominios
6_Privaciones IPM Dpt-Mpio
8_Privaciones Mpio dominio
TB_REF
Visor
```

---

## 8.2 DIVIPOLA

```text
DIVIPOLA-_Códigos_municipios_20260917.csv
```

Características:

- Hoja/dataset: `datos`
- Aproximadamente 1.122 filas.
- 7 columnas.

Función:

> Referencia territorial para códigos y nombres municipales.

---

## 8.3 CNPV — Hogares

```text
HOGARES_Cuadros_CNPV_2018.XLSX
```

Características:

- 7 hojas.
- Aproximadamente 6.811 filas.

Hojas:

```text
Índice
1HD
1HM
2HD
2HM
3HD
3HM
```

Las hojas `2HD`, `2HM`, `3HD` y `3HM` requieren verificación/procesamiento completo.

---

## 8.4 CNPV — Personas Demográfico

```text
PERSONAS_DEMOGRAFICO_Cuadros_CNPV_2018.xlsx
```

Características:

- 37 hojas.
- Aproximadamente 140 MB.
- Aproximadamente 746.898 filas.

Hojas grandes conocidas:

```text
1PM     80.995 × 9
3PM    138.080 × 16
5.1PM   80.992 × 21
5.2PM  161.278 × 22
14PM    63.994 × 71
15PM    75.716 × 14
19PM    63.719 × 21
```

Debe procesarse de forma completa y auditable.

---

## 8.5 CNPV — Personas Social

```text
PERSONAS_SOCIAL_Cuadros_CNPV_2018.XLSX
```

Características:

- 27 hojas.
- Aproximadamente 222 MB.
- Aproximadamente 1.494.993 filas.

Hojas grandes conocidas:

```text
1PM      232.800 × 62
1.1PM    232.789 × 9
2PM      216.282 × 16
2.1PM    216.283 × 18
3PM       39.415 × 47
6PM      216.682 × 16
7PM      229.433 × 14
8PM       55.447 × 18
```

Problema conocido:

```text
Error de lectura alrededor de la hoja 1PM.
```

Debe investigarse si se trata de:

- problema del archivo;
- hoja corrupta;
- limitación de `readxl`;
- problema de memoria;
- encabezados;
- celdas especiales;
- error introducido por el pipeline.

No asumir la causa sin diagnóstico.

---

## 8.6 CNPV — Viviendas

```text
VIVIENDAS_Cuadros_CNPV_2018.XLSX
```

Características:

- 21 hojas.
- Aproximadamente 8,4 MB.
- Aproximadamente 54.987 filas.

Hojas municipales conocidas:

```text
1V_MPIO
7V_MPIO
6V_MPIO
2V_MPIO
4V_MPIO
```

Procesamiento completo pendiente.

---

## 8.7 Pipeline de datos

El pipeline objetivo es:

```text
Raw
 ↓
Auditoría estructural
 ↓
Validación territorial
 ↓
Tipificación estadística
 ↓
Diccionarios
 ↓
Limpieza
 ↓
Variables analíticas
 ↓
Indicadores
 ↓
PCA / índice
 ↓
Integración SECOP II
 ↓
Asociación
 ↓
Correspondencia
 ↓
Brechas territoriales
```

## 8.8 Principio de reproducibilidad

No deben conservarse resultados finales generados mediante:

- muestras no documentadas;
- ejecuciones parciales presentadas como completas;
- variables sin definición;
- identificadores territoriales no validados;
- transformaciones no registradas.

---

# 9. Testing y Validación

## 9.1 Validaciones mínimas

Cada base debe superar:

### Validación estructural

- archivo existe;
- archivo puede abrirse;
- hojas identificadas;
- dimensiones registradas;
- columnas identificadas.

### Validación territorial

- código municipal presente cuando corresponda;
- códigos válidos;
- duplicados revisados;
- municipios faltantes identificados;
- cobertura comparada contra DIVIPOLA.

### Validación estadística

- tipo de variable;
- escala de medición;
- naturaleza;
- unidad;
- dirección respecto a vulnerabilidad;
- valores faltantes;
- valores extremos cuando corresponda.

### Validación de procesamiento

Debe poder demostrarse:

```text
archivo → hoja → filas procesadas → resultado
```

y no únicamente:

```text
archivo → script ejecutado
```

## 9.2 Casos críticos

Se deben probar específicamente:

1. Archivos Excel grandes.
2. Hojas con más de 200.000 filas.
3. Hojas vacías.
4. Hojas con errores de lectura.
5. Encabezados irregulares.
6. Variables completamente faltantes.
7. Variables categóricas.
8. Códigos municipales con formatos diferentes.
9. Municipios duplicados.
10. Hojas procesadas parcialmente.

## 9.3 Cobertura

```text
[PENDIENTE: calcular cobertura de tests del repositorio actual]
```

La cobertura relevante no debe medirse solamente en líneas de código; también debe contemplar cobertura de:

- archivos;
- hojas;
- variables;
- municipios;
- reglas de validación.

---

# 10. Deuda Técnica y TODOs

## Prioridad P0 — Bloqueante

### P0.1 Implementar procesamiento real por chunks

**Impacto:** crítico.

La función actual no puede considerarse chunked si internamente carga hojas completas.

**Resultado esperado:**

- procesamiento incremental;
- memoria controlada;
- trazabilidad;
- posibilidad de procesar las bases grandes.

---

### P0.2 Procesar todas las bases pendientes

**Impacto:** crítico.

Pendientes:

```text
PERSONAS_DEMOGRAFICO
PERSONAS_SOCIAL
HOGARES
VIVIENDAS
```

---

### P0.3 Resolver el fallo de `PERSONAS_SOCIAL`

**Impacto:** crítico.

Debe identificarse la causa real del fallo alrededor de `1PM`.

---

### P0.4 Completar diccionarios por base

**Impacto:** crítico.

Cada base debe tener:

- variables;
- descripción;
- tipo;
- escala;
- naturaleza;
- unidad;
- rol analítico;
- candidato a indicador;
- justificación.

---

# Prioridad P1 — Alta

### P1.1 Validar cobertura municipal

Completar:

```text
docs/diccionario/cobertura_municipal.csv
```

---

### P1.2 Completar matriz IPM-CNPV

Completar:

```text
docs/diccionario/matriz_ipm_cnpv.csv
```

Debe documentar cómo se relacionan las variables/dimensiones.

---

### P1.3 Completar candidatos a índice

Completar:

```text
docs/diccionario/candidatos_ivs.csv
```

No seleccionar variables únicamente por disponibilidad.

---

### P1.4 Limpiar scripts duplicados

Revisar scripts experimentales/legacy:

```text
auditoria_simple*.R
final_auditoria*.R
separate_dictionaries*.R
```

Eliminar únicamente después de comprobar que no contienen lógica necesaria.

---

# Prioridad P2 — Media

### P2.1 Automatizar reportes de calidad

Generar reportes reproducibles con:

- resumen;
- errores;
- cobertura;
- variables;
- faltantes;
- procesamiento.

### P2.2 Mejorar logging

Registrar:

```text
timestamp
archivo
hoja
filas
columnas
estado
error
duración
```

### P2.3 Formalizar configuración

Centralizar:

- rutas;
- parámetros;
- tamaño de chunk;
- opciones de procesamiento.

---

# Prioridad P3 — Posterior

### P3.1 PCA definitivo

Solo después de completar la auditoría.

### P3.2 Integración SECOP II

### P3.3 Asociación

### P3.4 Correspondencia

### P3.5 Brechas territoriales

### P3.6 Análisis espacial condicional

---

# 11. Próximos Pasos Recomendados

## 11.1 Roadmap — Próximas 1-2 semanas

### Etapa 1 — Recuperación técnica

```text
1. Inspeccionar estado real del repositorio.
2. Ejecutar git status.
3. Identificar scripts activos vs legacy.
4. Confirmar dependencias.
5. Confirmar estructura física de carpetas.
```

### Etapa 2 — Auditoría del procesamiento

```text
6. Revisar procesar_excel_chunks().
7. Determinar estrategia real para XLSX grandes.
8. Resolver PERSONAS_SOCIAL / 1PM.
9. Procesar PERSONAS_DEMOGRAFICO.
10. Procesar HOGARES completo.
11. Procesar VIVIENDAS completo.
```

### Etapa 3 — Diccionarios

```text
12. Generar inventario por base.
13. Generar diccionario de variables.
14. Asignar tipo estadístico.
15. Asignar escala.
16. Asignar naturaleza.
17. Registrar unidad.
18. Registrar dirección de vulnerabilidad.
19. Validar candidatos para índice.
```

### Etapa 4 — Calidad

```text
20. Validar cobertura municipal.
21. Validar códigos DIVIPOLA.
22. Validar duplicados.
23. Validar faltantes.
24. Generar informe de calidad.
25. Ejecutar tests.
```

---

## 11.2 Medio plazo

Una vez estabilizado el pipeline:

```text
Auditoría completa
      ↓
Selección metodológica de variables
      ↓
Diagnóstico de correlaciones
      ↓
PCA
      ↓
Construcción del índice de vulnerabilidad
      ↓
Validación del índice
      ↓
Integración SECOP II
      ↓
Variables de contratación
      ↓
Análisis de asociación
      ↓
Correspondencia
      ↓
Brechas territoriales
      ↓
Diagnóstico espacial
      ↓
Análisis espacial si procede
      ↓
Resultados
      ↓
Informe / artículo / tesis
```

## 11.3 Criterio de avance

No avanzar al siguiente bloque únicamente porque el script termina sin error.

El criterio debe ser:

> **El resultado debe ser reproducible, verificable y metodológicamente justificable.**

---

# 12. Contactos / Referencias

## 12.1 Repositorio relacionado

Repositorio académico/proyecto previamente utilizado:

`https://github.com/ustadistica/desarrollo_social_y_economico`

Estado exacto de la relación con el repositorio actual:

```text
[PENDIENTE: confirmar si es upstream, referencia histórica o repositorio activo]
```

## 12.2 GitHub

Repositorio actual:

```text
[PENDIENTE: ejecutar git remote -v y registrar URL]
```

## 12.3 Issues / Pull Requests

```text
[PENDIENTE: registrar issues y PRs activos del repositorio]
```

## 12.4 Documentación

Documentos internos relevantes:

```text
docs/diccionario/
docs/calidad/
```

## 12.5 Fuentes de datos

### DANE

Fuentes utilizadas:

- Índice de Pobreza Multidimensional.
- Censo Nacional de Población y Vivienda 2018.
- Información territorial.

URL oficial:

```text
[PENDIENTE: registrar URLs exactas de descarga utilizadas]
```

### DIVIPOLA

Fuente utilizada para códigos y referencias territoriales:

```text
DIVIPOLA
```

URL/documentación:

```text
[PENDIENTE: registrar URL exacta]
```

### SECOP II

Fuente prevista para la información de contratación pública:

```text
SECOP II
```

URL/documentación:

```text
[PENDIENTE: registrar dataset/API exacto utilizado]
```

---

# Anexo A — Reglas de continuidad para el siguiente developer

## Regla 1 — No romper la arquitectura existente

Trabajar exclusivamente sobre:

```text
C:\Users\juand\Projects\Desarrollo_Social_Economico_Agent
```

No crear una estructura paralela sin justificación y aprobación.

## Regla 2 — No confundir sample con procesamiento completo

Una muestra sirve para:

```text
metadata
detección
diagnóstico inicial
```

No sirve como sustituto de:

```text
auditoría final
diccionario final
cobertura completa
resultado estadístico final
```

## Regla 3 — No ejecutar el PCA definitivo todavía

El PCA depende de que las variables hayan sido:

```text
identificadas
→ documentadas
→ tipificadas
→ validadas
→ seleccionadas
```

## Regla 4 — Toda variable necesita definición estadística

Como mínimo:

```text
nombre
descripción
tipo
escala
naturaleza
unidad
dirección
rol analítico
```

## Regla 5 — Los errores deben conservar evidencia

No ocultar errores mediante:

```r
try(...)
```

sin registrar:

- archivo;
- hoja;
- error;
- contexto;
- acción tomada.

## Regla 6 — No asumir que una función hace lo que dice su nombre

Especialmente:

```text
procesar_excel_chunks()
```

Debe verificarse la implementación real.

## Regla 7 — Todo resultado crítico debe ser auditable

El pipeline debe permitir responder:

> ¿De qué archivo, hoja, variable y transformación salió este resultado?

---

# Anexo B — Estado conceptual del índice de vulnerabilidad

El proyecto contempla la construcción de un indicador sintético de vulnerabilidad socioeconómica.

Sin embargo:

> **No existe todavía una variable objetivo única definida para el PCA, y esto no constituye necesariamente un problema metodológico.**

El PCA no requiere una variable dependiente `Y` en el sentido de una regresión.

La pregunta correcta antes del PCA es:

```text
¿Qué conjunto de variables representa de forma defendible
la dimensión de vulnerabilidad socioeconómica que se quiere sintetizar?
```

Por tanto, la secuencia correcta es:

```text
Marco teórico
      ↓
Dimensiones de vulnerabilidad
      ↓
Variables observables
      ↓
Tipificación
      ↓
Calidad y cobertura
      ↓
Correlaciones
      ↓
Adecuación para PCA
      ↓
PCA
      ↓
Componente(s)
      ↓
Índice de vulnerabilidad
```

La definición final debe documentarse y justificarse estadística y conceptualmente.

---

# Anexo C — Estado de recuperación

## Lo que se considera confirmado

- El proyecto trabaja a nivel municipal.
- La pregunta central relaciona contratación pública y vulnerabilidad socioeconómica.
- El repositorio local obligatorio es `Desarrollo_Social_Economico_Agent`.
- R/RStudio es el entorno principal.
- DANE/IPM, CNPV y DIVIPOLA forman parte del bloque socioeconómico/territorial.
- SECOP II constituye el bloque de contratación pública.
- La auditoría del pipeline precede al PCA definitivo.
- El procesamiento final de las bases pesadas debe ser completo.
- El uso de sampling como sustituto del procesamiento final está descartado.
- Los diccionarios deben incorporar tipificación estadística.
- La arquitectura existente debe respetarse.

## Lo que debe verificarse directamente en el repositorio

```text
[ ] URL exacta del remoto Git
[ ] Branch actual
[ ] Commit actual
[ ] Versiones exactas de R
[ ] Versiones exactas de paquetes
[ ] Existencia de renv.lock
[ ] Existencia de DESCRIPTION
[ ] Tests realmente existentes
[ ] Cobertura de tests
[ ] Implementación actual de procesar_excel_chunks()
[ ] Scripts legacy que todavía sean necesarios
[ ] Estado exacto de outputs
[ ] URLs exactas de fuentes de datos
[ ] Issues y PRs activos
```

---

# Estado de cierre del handoff

**Estado:** 🟡 Transferible con tareas críticas pendientes.

**Bloqueador principal:** completar y validar el procesamiento real de las bases, especialmente las hojas grandes de CNPV.

**Siguiente hito técnico:**

```text
PIPELINE AUDITADO Y REPRODUCIBLE
```

**Siguiente hito metodológico:**

```text
SELECCIÓN Y VALIDACIÓN DE VARIABLES
        ↓
PCA / ÍNDICE DE VULNERABILIDAD
```

**Siguiente hito analítico:**

```text
ÍNDICE DE VULNERABILIDAD
        +
SECOP II
        ↓
ASOCIACIÓN
        ↓
CORRESPONDENCIA
        ↓
BRECHAS TERRITORIALES
```

> **Principio rector del proyecto:** primero garantizar la calidad, trazabilidad y reproducibilidad de los datos; después realizar inferencias y análisis estadísticos.
