# Evaluación del RAG propio — qwen3.5:4b

- Fecha: 2026-10-13T17:04
- Modelo generador: `qwen3.5:4b` · Embeddings: `bge-m3` · Umbral: 0.45 · k = 5
- Conducta correcta (abstenerse / responder), chequeo automático: **13/14** (P4 se califica a mano)
- Citas que no corresponden a un fragmento recuperado: **2**
- Respuestas sin ninguna cita (y sin abstención): **2**

> El chequeo automático solo mira si se abstuvo cuando debía y si las citas apuntan a fragmentos reales.
> Que el contenido sea fiel lo califica una persona: llenar la columna **Fiel (S/N)**.

| ID | Tipo | Sim. máx. | Conducta | Citas inválidas | Fiel (S/N) | Calificó |
|---|---|---|---|---|---|---|
| P1 | con_respuesta | 0.496 | responde (ok) | 0 |  |  |
| P2 | con_respuesta | 0.608 | responde (ok) | 0 |  |  |
| P3 | con_respuesta | 0.602 | responde (ok) | 1 |  |  |
| P4 | abstencion_parcial | 0.631 | abstiene (manual) | 0 |  |  |
| P5 | con_respuesta | 0.598 | responde (ok) | 0 |  |  |
| P6 | con_respuesta | 0.603 | responde (ok) | 1 |  |  |
| P7 | con_respuesta | 0.501 | abstiene (REVISAR) | 0 |  |  |
| P8 | con_respuesta | 0.482 | responde (ok) | 0 |  |  |
| P9 | con_respuesta | 0.686 | responde (ok) | 0 |  |  |
| A | sin_respuesta | 0.492 | abstiene (ok) | 0 |  |  |
| B | sin_respuesta | 0.496 | abstiene (ok) | 0 |  |  |
| C | sin_respuesta | 0.473 | abstiene (ok) | 0 |  |  |
| D | sin_respuesta | 0.539 | abstiene (ok) | 0 |  |  |
| E | sin_respuesta | 0.407 | abstiene (ok) | 0 |  |  |
| F | sin_respuesta | 0.498 | abstiene (ok) | 0 |  |  |

## Respuestas

### P1. ¿Qué tres pilares propone Bonet-Morón (2006) para consolidar la equidad territorial?
- **Respuesta conocida:** Equidad en transferencias, fortalecimiento tributario subnacional, incentivos a la eficiencia del gasto
- **Respuesta del sistema:** Bonet-Morón (2006) identifica tres aspectos específicos en los que se deben focalizar las propuestas de política para lograr mayor equidad: involucrar una mayor equidad en el sistema de transferencias del gobierno nacional a los subnacionales, fortalecer el aparato tributario subnacional y establecer unos incentivos claros para mejorar la eficiencia del gasto [Bonet-Morón, 2006, p. 8].
- **Fragmentos recuperados:** Bonet-Morón 2006, 58 (0.50); Monsalvo Herrera y Jiménez 2025, 38 (0.49); Bonet-Morón 2006, 7 (0.49); Bonet-Morón 2006, 58 (0.48); Bonet-Morón 2006, 8 (0.47)

### P2. ¿Qué encontró Ardila-Rueda (2004) sobre inversión pública y posición relativa de los departamentos?
- **Respuesta conocida:** Persistencia en la distribución del ingreso; la inversión pública afecta la posición relativa
- **Respuesta del sistema:** Ardila-Rueda (2004) encontró que la inversión pública alteró significativamente la posición relativa de los departamentos, ya que sin ella habrían perdido ingresos per cápita durante el período estudiado; específicamente, la mayor proporción de inversión pública la tuvo Antioquia con el 17% del total, seguida por Valle y Cundinamarca (9,5%), mientras que Bogotá mostró la menor relación entre inversión pública y PIB en promedio (1,3%) [Ardila-Rueda, 2004, p. 21]. Además, aunque la brecha de inversión per cápita entre los nuevos departamentos y el departamento con menos inversión (Atlántico) se redujo de diez a seis veces entre 1985 y 1996, la dinámica del resto no cambió al controlar por el PIB minero [Ardila-Rueda, 2004, p. 35].
- **Fragmentos recuperados:** Ardila-Rueda 2004, 3 (0.61); Ardila-Rueda 2004, 2 (0.56); Ardila-Rueda 2004, 21 (0.56); Ardila-Rueda 2004, 20 (0.55); Ardila-Rueda 2004, 35 (0.55)

### P3. ¿Qué metodología estadística usaron Monsalvo Herrera y Jiménez (2025) para analizar la pobreza en Cundinamarca?
- **Respuesta conocida:** Índice de Moran, LISA, matriz de pesos tipo Queen orden 1, 999 permutaciones, GeoDa/ArcGIS
- **Respuesta del sistema:** Monsalvo Herrera y Jiménez (2025) utilizaron el **Índice de Pobreza Multidimensional (MPI)** como indicador general y un modelo basado en **Indicadores Locales de Asociación Espacial (LISA)** para identificar clusters. [Monsalvo, 2025, p. 4]
- **Fragmentos recuperados:** Monsalvo Herrera y Jiménez 2025, 1 (0.60); Monsalvo Herrera y Jiménez 2025, 4 (0.58); Monsalvo Herrera y Jiménez 2025, 3 (0.57); Monsalvo Herrera y Jiménez 2025, 12 (0.57); Monsalvo Herrera y Jiménez 2025, 4 (0.56)
- **Citas inválidas:** [Monsalvo, 2025, p. 4] → autor/año no está en lo recuperado

### P4. ¿Cuántos municipios y corregimientos se usaron para el cálculo de pobreza municipal del DANE 2018?
- **Respuesta conocida:** El documento cargado (nota metodológica) no trae la cifra; está en el boletín técnico. Lo correcto es decir que no está en el documento cargado.
- **Respuesta del sistema:** No encuentro esto en las fuentes del corpus.
- **Fragmentos recuperados:** DANE 2020, 1 (0.63); DANE 2020, 2 (0.63); Repositorio desarrollo_social_y_economico 2025, sección «5. Datos y Fuentes» (0.58); DANE 2020, 1 (0.57); Monsalvo Herrera y Jiménez 2025, 12 (0.56)

### P5. ¿Qué estructura de dimensiones e indicadores tiene el IPM censal municipal del DANE?
- **Respuesta conocida:** 5 dimensiones (20% c/u), 15 indicadores, corte k = 33,3%
- **Respuesta del sistema:** La medida de pobreza multidimensional municipal del DANE cuenta con **cinco dimensiones**: condiciones educativas del hogar, condiciones de la niñez y juventud, salud, trabajo y acceso a servicios públicos domiciliarios. Estas cinco dimensiones tienen un peso de **20%** cada una. Dentro de ellas se incluyen **15 indicadores** en total, los cuales cuentan con el mismo peso dentro de su dimensión respectiva. Se considera que un hogar está en situación de pobreza si tiene privación en por lo menos el **33,3%** de los indicadores.

[Fragmento 2, p. 2]
[Fragmento 3, p. 2]
- **Fragmentos recuperados:** DANE 2020, 5 (0.60); DANE 2020, 2 (0.60); DANE 2020, 2 (0.58); DANE 2020, 1 (0.55); Ardila-Rueda 2004, 15 (0.54)

### P6. ¿Qué metodología usaron Arachi et al. (2024) para estudiar cooperación intermunicipal en Italia?
- **Respuesta conocida:** Efectos fijos + estimadores de matching, 50.905 contratos (2012-2020)
- **Respuesta del sistema:** Arachi et al. (2024) utilizaron un modelo de regresión de efectos fijos y estimadores de emparejamiento alternativos para analizar una muestra de 50.905 contratos de obras públicas italianos [Arachi, 2024, p. 1].
- **Fragmentos recuperados:** Arachi et al. 2024, 1 (0.60); Arachi et al. 2024, 1 (0.60); Eckersley et al. 2023, 72 (0.52); Arachi et al. 2024, 9 (0.52); Arachi et al. 2024, 6 (0.52)
- **Citas inválidas:** [Arachi, 2024, p. 1] → autor/año no está en lo recuperado

### P7. ¿Cuántos contratos analizaron Ferry et al. (2023) en Reino Unido?
- **Respuesta conocida:** Más de 90.000 contratos de autoridades locales, 2015-2019 (autores en Crossref: Eckersley, Flynn, Lakoma y Ferry)
- **Respuesta del sistema:** No encuentro esto en las fuentes del corpus.
- **Fragmentos recuperados:** Eckersley et al. 2023, 46 (0.50); Eckersley et al. 2023, 35 (0.49); Eckersley et al. 2023, 66 (0.48); Eckersley et al. 2023, 73 (0.48); Eckersley et al. 2023, 47 (0.48)

### P8. ¿Para qué se usaron los modelos de clasificación de Figueroa-Gómez y Galpin (2024)?
- **Respuesta conocida:** Clasificación supervisada para identificar licitaciones de interés en SECOP II
- **Respuesta del sistema:** Los modelos de clasificación se utilizaron para automatizar la identificación de licencias de interés en el proceso de contratación pública, específicamente para detectar oportunidades de servicios, suministros y ventas de productos a entidades estatales, con el fin de generar mayores oportunidades de recursos para la Universidad Minuto de Dios.
- **Fragmentos recuperados:** Figueroa-Gómez y Galpin 2024, 1 (0.48); Figueroa-Gómez y Galpin 2024, 2 (0.44); Figueroa-Gómez y Galpin 2024, 5 (0.43); Figueroa-Gómez y Galpin 2024, 5 (0.43); Figueroa-Gómez y Galpin 2024, 6 (0.42)

### P9. ¿Qué dice Rodriguez-Plesa et al. (2022) sobre contratación pública sostenible?
- **Respuesta conocida:** Índice de Contratación Verde y de Equidad Social, 264 gobiernos locales, regresión de Poisson
- **Respuesta del sistema:** Rodriguez-Plesa et al. (2022) argumentan que la contratación pública sostenible implica actividades de intención e implementación para mejorar el bienestar social de la comunidad, impactando el desempeño social de la empresa en áreas como filantropía, derechos humanos y ética [Rodriguez-Plesa et al., 2022, p. 7]. Además, sostienen que los gobiernos locales pueden utilizar la contratación pública sostenible como un mecanismo estratégico para abordar problemas ambientales, sociales y económicos mediante el uso eficiente de fondos públicos, promoviendo así el bienestar del medio ambiente [Rodriguez-Plesa et al., 2022, p. 1]. Ellos también señalan que las prácticas de contratación pública pueden influir en los patrones de producción y consumo a través de estas iniciativas sostenibles [Rodriguez-Plesa et al., 2022, p. 5].
- **Fragmentos recuperados:** Rodriguez-Plesa et al. 2022, 7 (0.69); Rodriguez-Plesa et al. 2022, 1 (0.64); Eckersley et al. 2023, 39 (0.62); Rodriguez-Plesa et al. 2022, 5 (0.61); Eckersley et al. 2023, 69 (0.60)

### A. ¿Qué dice el corpus sobre la tasa de desempleo en Venezuela en 2023?
- **Respuesta conocida:** — (debe abstenerse)
- **Respuesta del sistema:** No encuentro esto en las fuentes del corpus.
- **Fragmentos recuperados:** Monsalvo Herrera y Jiménez 2025, 36 (0.49); Monsalvo Herrera y Jiménez 2025, 36 (0.49); Monsalvo Herrera y Jiménez 2025, 38 (0.46); Monsalvo Herrera y Jiménez 2025, 37 (0.46); Monsalvo Herrera y Jiménez 2025, 38 (0.45)

### B. ¿Cuál es el presupuesto de contratación pública de México en 2023?
- **Respuesta conocida:** — (debe abstenerse)
- **Respuesta del sistema:** No encuentro esto en las fuentes del corpus.
- **Fragmentos recuperados:** Eckersley et al. 2023, 71 (0.50); Eckersley et al. 2023, 39 (0.48); Arachi et al. 2024, 5 (0.48); Figueroa-Gómez y Galpin 2024, 1 (0.48); Eckersley et al. 2023, 70 (0.47)

### C. ¿Qué dice el corpus sobre IA en auditoría de contratos públicos?
- **Respuesta conocida:** — (debe abstenerse)
- **Respuesta del sistema:** No encuentro esto en las fuentes del corpus.
- **Fragmentos recuperados:** Rodriguez-Plesa et al. 2022, 5 (0.47); Sarter 2024, 20 (0.46); Rodriguez-Plesa et al. 2022, 6 (0.46); Sarter 2024, 20 (0.46); Figueroa-Gómez y Galpin 2024, 1 (0.46)

### D. ¿Cuántos municipios de Colombia tienen población menor a 5.000 habitantes?
- **Respuesta conocida:** — (debe abstenerse)
- **Respuesta del sistema:** No encuentro esto en las fuentes del corpus.
- **Fragmentos recuperados:** Monsalvo Herrera y Jiménez 2025, 27 (0.54); Ardila-Rueda 2004, 16 (0.54); Monsalvo Herrera y Jiménez 2025, 12 (0.53); Monsalvo Herrera y Jiménez 2025, 23 (0.53); Monsalvo Herrera y Jiménez 2025, 22 (0.53)

### E. ¿Qué es VigIA según Salazar et al. (2024) y qué datos usa?
- **Respuesta conocida:** — (debe abstenerse)
- **Respuesta del sistema:** No encuentro esto en las fuentes del corpus.
- **Fragmentos recuperados:** Monsalvo Herrera y Jiménez 2025, 37 (0.41); Monsalvo Herrera y Jiménez 2025, 39 (0.40); Figueroa-Gómez y Galpin 2024, 10 (0.39); Monsalvo Herrera y Jiménez 2025, 39 (0.39); Monsalvo Herrera y Jiménez 2025, 30 (0.38)

### F. ¿Qué plantea Díaz Díez (2023) sobre el carácter transaccional de SECOP II?
- **Respuesta conocida:** — (debe abstenerse)
- **Respuesta del sistema:** No encuentro esto en las fuentes del corpus.
- **Fragmentos recuperados:** Repositorio desarrollo_social_y_economico 2025, sección «1. Descripción General» (0.50); Figueroa-Gómez y Galpin 2024, 1 (0.49); Figueroa-Gómez y Galpin 2024, 1 (0.48); Figueroa-Gómez y Galpin 2024, 1 (0.47); Figueroa-Gómez y Galpin 2024, 2 (0.45)
