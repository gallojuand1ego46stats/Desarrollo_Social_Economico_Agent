# Evaluación del RAG propio — qwen2.5-coder

- Fecha: 2026-10-13T13:02
- Modelo generador: `qwen2.5-coder` · Embeddings: `bge-m3` · Umbral: 0.45 · k = 5
- Conducta correcta (abstenerse / responder), chequeo automático: **13/14** (P4 se califica a mano)
- Citas que no corresponden a un fragmento recuperado: **0**
- Respuestas sin ninguna cita (y sin abstención): **3**

> El chequeo automático solo mira si se abstuvo cuando debía y si las citas apuntan a fragmentos reales.
> Que el contenido sea fiel lo califica una persona: llenar la columna **Fiel (S/N)**.

| ID | Tipo | Sim. máx. | Conducta | Citas inválidas | Fiel (S/N) | Calificó |
|---|---|---|---|---|---|---|
| P1 | con_respuesta | 0.496 | responde (ok) | 0 |  |  |
| P2 | con_respuesta | 0.608 | responde (ok) | 0 |  |  |
| P3 | con_respuesta | 0.602 | responde (ok) | 0 |  |  |
| P4 | abstencion_parcial | 0.631 | abstiene (manual) | 0 |  |  |
| P5 | con_respuesta | 0.598 | responde (ok) | 0 |  |  |
| P6 | con_respuesta | 0.603 | responde (ok) | 0 |  |  |
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
- **Respuesta del sistema:** Según Bonet-Morón (2006, p. 8), propone tres pilares para consolidar la equidad territorial:

1. Involucrar una mayor equidad en el sistema de transferencias del gobierno nacional a los subnacionales.
2. Fortalecer el aparato tributario subnacional.
3. Establecer unos incentivos claros para mejorar la eficiencia del gasto.
- **Fragmentos recuperados:** Bonet-Morón 2006, 58 (0.50); Monsalvo Herrera y Jiménez 2025, 38 (0.49); Bonet-Morón 2006, 7 (0.49); Bonet-Morón 2006, 58 (0.48); Bonet-Morón 2006, 8 (0.47)

### P2. ¿Qué encontró Ardila-Rueda (2004) sobre inversión pública y posición relativa de los departamentos?
- **Respuesta conocida:** Persistencia en la distribución del ingreso; la inversión pública afecta la posición relativa
- **Respuesta del sistema:** Ardila-Rueda (2004) encontró que la inversión pública, especialmente la inversión, ha afectado la posición relativa de algunos departamentos, pero no ha cambiado la dinámica de la distribución del ingreso per cápita en su conjunto [Ardila-Rueda, 2004, p. 3].
- **Fragmentos recuperados:** Ardila-Rueda 2004, 3 (0.61); Ardila-Rueda 2004, 2 (0.56); Ardila-Rueda 2004, 21 (0.56); Ardila-Rueda 2004, 20 (0.55); Ardila-Rueda 2004, 35 (0.55)

### P3. ¿Qué metodología estadística usaron Monsalvo Herrera y Jiménez (2025) para analizar la pobreza en Cundinamarca?
- **Respuesta conocida:** Índice de Moran, LISA, matriz de pesos tipo Queen orden 1, 999 permutaciones, GeoDa/ArcGIS
- **Respuesta del sistema:** Usaron la metodología de los Indicadores Locales de Asociación Espacial (LISA) para identificar clusters, considerando tanto el índice de pobreza multidimensional (MPI) como un indicador promedio de las variables dentro de cada una de sus dimensiones.
- **Fragmentos recuperados:** Monsalvo Herrera y Jiménez 2025, 1 (0.60); Monsalvo Herrera y Jiménez 2025, 4 (0.58); Monsalvo Herrera y Jiménez 2025, 3 (0.57); Monsalvo Herrera y Jiménez 2025, 12 (0.57); Monsalvo Herrera y Jiménez 2025, 4 (0.56)

### P4. ¿Cuántos municipios y corregimientos se usaron para el cálculo de pobreza municipal del DANE 2018?
- **Respuesta conocida:** El documento cargado (nota metodológica) no trae la cifra; está en el boletín técnico. Lo correcto es decir que no está en el documento cargado.
- **Respuesta del sistema:** No encuentro esto en las fuentes del corpus.
- **Fragmentos recuperados:** DANE 2020, 1 (0.63); DANE 2020, 2 (0.63); Repositorio desarrollo_social_y_economico 2025, sección «5. Datos y Fuentes» (0.58); DANE 2020, 1 (0.57); Monsalvo Herrera y Jiménez 2025, 12 (0.56)

### P5. ¿Qué estructura de dimensiones e indicadores tiene el IPM censal municipal del DANE?
- **Respuesta conocida:** 5 dimensiones (20% c/u), 15 indicadores, corte k = 33,3%
- **Respuesta del sistema:** El IPM censal municipal del DANE tiene una estructura compuesta por cinco dimensiones y 15 indicadores. Cada dimensión tiene un peso del 20%, y los indicadores dentro de cada dimensión tienen el mismo peso. La definición detallada se encuentra en [DANE, 2020, p. 2].
- **Fragmentos recuperados:** DANE 2020, 5 (0.60); DANE 2020, 2 (0.60); DANE 2020, 2 (0.58); DANE 2020, 1 (0.55); Ardila-Rueda 2004, 15 (0.54)

### P6. ¿Qué metodología usaron Arachi et al. (2024) para estudiar cooperación intermunicipal en Italia?
- **Respuesta conocida:** Efectos fijos + estimadores de matching, 50.905 contratos (2012-2020)
- **Respuesta del sistema:** Arachi et al. (2024) utilizaron un modelo de regresión de efectos fijos y estimadores de emparejamiento alternativos para analizar una muestra de 50.905 contratos de obras públicas italianos adjudicados por municipios [Arachi et al., 2024, p. 1].
- **Fragmentos recuperados:** Arachi et al. 2024, 1 (0.60); Arachi et al. 2024, 1 (0.60); Eckersley et al. 2023, 72 (0.52); Arachi et al. 2024, 9 (0.52); Arachi et al. 2024, 6 (0.52)

### P7. ¿Cuántos contratos analizaron Ferry et al. (2023) en Reino Unido?
- **Respuesta conocida:** Más de 90.000 contratos de autoridades locales, 2015-2019 (autores en Crossref: Eckersley, Flynn, Lakoma y Ferry)
- **Respuesta del sistema:** No encuentro esto en las fuentes del corpus.
- **Fragmentos recuperados:** Eckersley et al. 2023, 46 (0.50); Eckersley et al. 2023, 35 (0.49); Eckersley et al. 2023, 66 (0.48); Eckersley et al. 2023, 73 (0.48); Eckersley et al. 2023, 47 (0.48)

### P8. ¿Para qué se usaron los modelos de clasificación de Figueroa-Gómez y Galpin (2024)?
- **Respuesta conocida:** Clasificación supervisada para identificar licitaciones de interés en SECOP II
- **Respuesta del sistema:** Los modelos de clasificación se utilizaron para automatizar la identificación de ofertas públicas de interés para la Universidad Minuto de Dios.
- **Fragmentos recuperados:** Figueroa-Gómez y Galpin 2024, 1 (0.48); Figueroa-Gómez y Galpin 2024, 2 (0.44); Figueroa-Gómez y Galpin 2024, 5 (0.43); Figueroa-Gómez y Galpin 2024, 5 (0.43); Figueroa-Gómez y Galpin 2024, 6 (0.42)

### P9. ¿Qué dice Rodriguez-Plesa et al. (2022) sobre contratación pública sostenible?
- **Respuesta conocida:** Índice de Contratación Verde y de Equidad Social, 264 gobiernos locales, regresión de Poisson
- **Respuesta del sistema:** Rodriguez-Plesa et al. (2022) argumentan que la contratación pública sostenible (CPS) ofrece un mecanismo para que los gobiernos locales aborden problemas ambientales, sociales y económicos mediante la utilización estratégica de los fondos públicos para lograr resultados de políticas que promueven el bienestar del medio ambiente, la economía y la sociedad [Rodriguez-Plesa et al., 2022, p. 1].
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
