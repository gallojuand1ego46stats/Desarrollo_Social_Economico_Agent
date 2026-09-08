# Arquitectura de datos

La carpeta `data/` sigue un flujo Bronze -> Silver -> Gold y separa las fuentes originales de las tablas analíticas.

```text
data/
├── raw/
│   ├── secop_ii/   # fuente SECOP II sin transformaciones
│   ├── dane_ipm/   # fuentes DANE/IPM sin transformaciones
│   └── divipola/   # catálogo territorial maestro
├── bronze/         # copias/particiones preparadas para procesamiento
├── silver/         # datos limpios, tipificados y homologados
└── gold/           # tablas analíticas listas para modelación
```

## Reglas

1. `raw/` nunca se modifica manualmente.
2. Toda transformación debe quedar en un script de `R/`.
3. `silver/` debe conservar la trazabilidad hacia `raw/`.
4. `gold/` contiene únicamente tablas derivadas para el análisis estadístico.
5. Los archivos pesados se mantienen localmente y están protegidos por `.gitignore`.
6. La llave territorial de integración será `divipola_key` o una variable equivalente documentada, no el nombre del municipio.
7. Antes de construir el IVS o medidas de contratación se documentarán cobertura, faltantes, duplicados, tipos y homologaciones.

## Fuentes iniciales

- SECOP II: Datos Abiertos Colombia, dataset `jbjy-vk9h`.
- DIVIPOLA: Datos Abiertos Colombia, dataset `gdxc-w37w`.
- IPM municipal censal 2018: DANE.

Ver `docs/calidad/fuentes_datos.md` para procedencia y enlaces oficiales.
