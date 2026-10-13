# Nada sin fuente

Actividad evaluativa del curso **Consultoría** (Pregrado en Estadística, USTA — docente Javier Mauricio Sierra). Construida sobre las fuentes del estado del arte del artículo de grado "Contratación pública y vulnerabilidad socioeconómica municipal en Colombia".

**Equipo:** Juan Diego Gallo Quintero, Juan David Parada Fonseca, David Santiago Sanchez.

## Cómo está organizado este repo

```
nada-sin-fuente/
├── README.md                                   ← este archivo
├── inventario_fallos/                          ← Entregable 1
│   ├── inventario_juan_david.md
│   └── inventario_juan_diego_David_Sanchez.md
├── experimento/                                ← Entregable 2
│   ├── experimento_y_decision.md
│   └── clasificacion_independiente/
│       ├── clasificacion_juan_david.md
│       └── clasificacion_juan_diego_David_Sanchez.md
├── corpus/                                     ← Entregable 3a-3b
│   ├── README_PROCEDENCIA.md
│   ├── MANIFIESTO.md                           ← huella de cada archivo indexado (python rag.py manifiesto)
│   └── papers/                                 ← PDFs (no versionados en git, ver .gitignore)
├── tabla_trazabilidad.md                       ← Entregable 3c
├── protocolo_prompts/                          ← Entregable 3d
│   ├── v1.md                                   ← NotebookLM (versión 1 del sistema)
│   ├── v2.md                                   ← RAG propio (versión 2 y 2.1)
│   └── CHANGELOG.md
├── sistema/                                    ← RAG propio (vía propia)
│   ├── README.md                               ← cómo instalarlo y usarlo
│   ├── rag.py                                  ← indexar, calibrar, manifiesto, preguntar, evaluar, reverificar
│   ├── fuentes.json · banco.json · requirements.txt
│   ├── tests/test_rag.py                       ← pruebas sin Ollama
│   └── resultados/                             ← reporte de cada evaluación
├── evaluacion/                                 ← Entregable 4
│   ├── banco_preguntas.md
│   ├── caso_de_fallo.md
│   └── acta_auditoria_cruzada.md
└── memoria/memoria_final.md                    ← Entregable 5
```

## Estado actual (2026-10-13)

- [x] Inventario de fallos (Juan David)
- [x] Inventario de fallos (Juan Diego y David Sánchez)
- [x] Experimento: 2 de 3 tratamientos (A control, B búsqueda); el C se evalúa con el banco de preguntas
- [x] Decisión de herramienta: RAG propio (vía propia), que reemplazó a NotebookLM después de la sustentación
- [x] Corpus: 10 documentos; Salazar et al., Gutiérrez Vanegas y Díaz Díez no se incorporaron
- [~] Tabla de trazabilidad: 14 afirmaciones; 5 con verificación directa (2 de ellas hechas por Claude, por confirmar), 7 solo contra NotebookLM, 2 pendientes o parciales
- [x] Protocolo de prompts v1 (NotebookLM), v2 y v2.1 (RAG)
- [x] Sistema: RAG propio con `qwen3.5:4b`, `rag.py` v2.1 con pruebas automáticas
- [~] Banco de evaluación: 15 preguntas corridas en NotebookLM (15/15) y en el RAG (14/15); P2 y P9 por verificar contra el PDF; falta re-correr con la v2.1
- [x] Caso de fallo documentado (P7)
- [ ] Auditoría cruzada con un equipo par (el acta está vacía; pendiente de asignación del profesor)
- [x] Memoria final
- [ ] Visto bueno del profesor

## Nota sobre el corpus

Todas las fuentes usadas en este corpus son **públicas** (papers de la matriz bibliográfica del estado del arte, y el repositorio público `ustadistica/desarrollo_social_y_economico`). No hay documentos de contraparte no públicos involucrados, por lo que no aplica Acta de Datos de la Contraparte para esta actividad.
