# Desarrollo_Social_Economico_Agent

![Deploy Docs](https://github.com/gallojuand1ego46stats/Desarrollo_Social_Economico_Agent/actions/workflows/docs.yml/badge.svg)

Trabajo universitario. Sitio del proyecto: <https://gallojuand1ego46stats.github.io/Desarrollo_Social_Economico_Agent/>

## Estructura

| Carpeta | Uso | ¿Sube a GitHub? |
|---|---|---|
| `datos/` | Datasets de trabajo (CSV, Excel) | **NO** (protegido por `.gitignore`) |
| `src/` | Código fuente / notebooks | Sí |
| `resultados/` | Salidas generadas (figuras, tablas) | **NO** (protegido) |
| `docs/` | Documentación y landing del sitio | Sí |

## Flujo de trabajo diario

```powershell
git add .
git commit -m "descripcion del cambio"
git push
```

Cada push actualiza automáticamente el sitio web (workflow Deploy Docs).

## Protección de datos

Este repositorio tiene un `.gitignore` agresivo: los datasets y resultados **nunca** se publican en GitHub. Solo suben código y documentación. Ver [SECURITY.md](SECURITY.md).
