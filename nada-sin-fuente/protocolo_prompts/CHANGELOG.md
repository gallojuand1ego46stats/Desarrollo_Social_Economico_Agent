# Changelog — Protocolo de prompts

## v1
- Versión inicial. Ver `v1.md`.

## v2
- El sistema pasa de NotebookLM (vía empaquetada) a un RAG propio (`sistema/rag.py`), por orientación del profesor después de la sustentación.
- Fuentes permitidas: los fragmentos recuperados, con cabecera Apellido, año, página.
- Abstención doble (umbral de similitud + regla del prompt) y verificación automática de citas.
- Temperatura 0.
- Detalle y razones en `v2.md`.
## v2.1
- Alias de documentos en la cabecera de los fragmentos y regla nueva para reconocerlos (corrige la causa del fallo P7).
- El código (`sistema/rag.py` v2.1) guarda el texto de los fragmentos y los parámetros de cada corrida, mejora el verificador de citas y agrega pruebas. Detalle en `v2.md`.
