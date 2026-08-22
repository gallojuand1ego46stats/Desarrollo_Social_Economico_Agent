# Política de seguridad y manejo de datos

## Principio general

Este repositorio es público. Por ello, **jamás** se versionan datos reales, personales o sensibles.

## Reglas obligatorias

1. **Datasets**: permanecen solo en local (`datos/`). El `.gitignore` bloquea `*.csv`, `*.xlsx` y formatos similares; no intentar subirlos con `git add -f`.
2. **Resultados**: las salidas con contenido derivado de datos reales quedan en `resultados/` (ignorada). Solo se documentan métodos y código.
3. **Secretos**: nunca commitear contraseñas, tokens ni claves de API. Usar archivos `.env` (ignorados) y cargarlos desde el código.
4. **Datos personales**: si un análisis involucra personas, trabajar con datos anonimizados/aggregateados y seguir la normativa aplicable.

## Si se compromete un dato por accidente

1. Eliminar el archivo en el commit siguiente.
2. Contactar al administrador del repo para reescribir el historial (`git filter-repo`) si el dato es sensible.
3. Rotar cualquier credencial expuesta inmediatamente.

## Reporte de vulnerabilidades

Si detectas información sensible expuesta en este repositorio, abre un issue o contacta al propietario para su eliminación inmediata.
