# Nada sin fuente

Actividad evaluativa del curso **Consultoría** (Pregrado en Estadística, USTA — docente Javier Mauricio Sierra), 30% del corte. Construida sobre las fuentes del estado del arte del artículo de grado "Contratación pública y vulnerabilidad socioeconómica municipal en Colombia".

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
│   └── papers/                                 ← PDFs (no versionados en git, ver .gitignore)
├── tabla_trazabilidad.md                       ← Entregable 3c
├── protocolo_prompts/                          ← Entregable 3d
│   ├── v1.md                                   ← para NotebookLM (versión 1 del sistema)
│   ├── v2.md                                   ← para el RAG propio (versión 2)
│   └── CHANGELOG.md
├── sistema/                                    ← RAG propio (vía propia)
│   ├── README.md                               ← cómo instalarlo y usarlo
│   ├── rag.py                                  ← indexar, calibrar, preguntar, evaluar
│   ├── fuentes.json · banco.json · requirements.txt
│   └── resultados/                             ← reportes de cada evaluación
├── evaluacion/                                 ← Entregable 4
│   ├── banco_preguntas.md
│   ├── caso_de_fallo.md
│   └── acta_auditoria_cruzada.md
└── memoria/memoria_final.md                    ← Entregable 5
```

## Estado actual (actualizado 2026-10-13)

- [x] Inventario de fallos (Juan David)
- [x] Inventario de fallos (Juan Diego / David Sánchez)
- [x] Experimento: **2 de 3 tratamientos** formales (A control, B búsqueda). El C (contexto cerrado) se evalúa con el banco de preguntas
- [x] Decisión de herramienta: **RAG propio (vía propia)**, que reemplazó a NotebookLM (vía empaquetada) después de la sustentación
- [x] Biblioteca de referencias: 10 documentos; 3 fuentes del Informe 1 quedaron fuera (Salazar et al., Gutiérrez Vanegas, Díaz Díez)
- [~] Tabla de trazabilidad: 14 afirmaciones; 5 con verificación directa, 7 solo contra NotebookLM (no independiente), 2 pendientes o parciales
- [x] Protocolo de prompts v1 (NotebookLM) y v2 (RAG propio)
- [x] Sistema construido y respondiendo con cita: RAG propio con `qwen2.5-coder`
- [x] Banco de evaluación: 15 preguntas (9 con respuesta + 6 abstenciones), corrido en NotebookLM (15/15) y en el RAG propio (14/15)
- [x] Caso de fallo documentado (P7 del RAG: abstención falsa por el nombre del autor)
- [ ] Evaluación del RAG con Qwen 3.5 (pendiente)
- [ ] Auditoría cruzada (pendiente de asignación del profesor)
- [x] Memoria final
- [ ] Visto bueno del profesor

## Nota sobre el corpus

Todas las fuentes usadas en este corpus son **públicas** (papers de la matriz bibliográfica del estado del arte, y el repositorio público `ustadistica/desarrollo_social_y_economico`). No hay documentos de contraparte no públicos involucrados, por lo que no aplica Acta de Datos de la Contraparte para esta actividad.
