# Changelog — Protocolo de prompts

## v1
- Versión inicial. Ver `v1.md`.

## v2
- El sistema pasa de NotebookLM (vía empaquetada) a un RAG propio (`sistema/rag.py`), por orientación del profesor después de la sustentación.
- Fuentes permitidas: los fragmentos recuperados, con cabecera Apellido, año, página.
- Abstención doble (umbral de similitud + regla del prompt) y verificación automática de citas.
- Temperatura 0.
- Detalle y razones en `v2.md`.