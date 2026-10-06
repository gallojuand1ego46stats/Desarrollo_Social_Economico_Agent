# Nada sin fuente

Actividad evaluativa del curso **Consultoría** (Pregrado en Estadística, USTA — docente Javier Mauricio Sierra), 30% del corte. Construida sobre las fuentes del estado del arte del artículo de grado "Contratación pública y vulnerabilidad socioeconómica municipal en Colombia".

**Equipo (3 integrantes):** Juan Diego Gallo Quintero, Juan David Parada Fonseca, David Santiago Sánchez.

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
│   ├── v1.md
│   └── CHANGELOG.md
├── evaluacion/                                 ← Entregable 4
│   ├── banco_preguntas.md
│   ├── caso_de_fallo.md
│   └── acta_auditoria_cruzada.md
├── sistema/README.md                           ← vía empaquetada (NotebookLM), no hay RAG propio
└── memoria/memoria_final.md                    ← Entregable 5
```

## Estado actual (actualizado 2026-10-06)

- [x] Inventario de fallos (Juan David)
- [x] Inventario de fallos (Juan Diego / David Sánchez)
- [x] Experimento corrido: **2 de 3 tratamientos** formales (A control, B búsqueda). El tratamiento C (contexto cerrado) no se corrió con la misma consulta; su evidencia sustituta es el banco de evaluación sobre NotebookLM (ver `experimento_y_decision.md`, sección 1.1)
- [x] Tabla de decisión de herramienta (NotebookLM, vía empaquetada)
- [x] Biblioteca de referencias armada: 10 documentos cargados en NotebookLM; 3 fuentes del Informe 1 quedaron fuera (Salazar et al., Gutiérrez Vanegas, Díaz Díez)
- [~] Tabla de trazabilidad: 14 afirmaciones; 5 con verificación directa (4, 8, 10, 13, 14), 7 solo contra NotebookLM (no independiente), 2 pendientes o parciales (11 y 12)
- [x] Protocolo de prompts v1
- [x] Sistema construido y respondiendo con cita (NotebookLM)
- [x] Banco de evaluación: 15 preguntas (9 con respuesta + 6 abstenciones)
- [x] Caso de fallo documentado
- [ ] Auditoría cruzada (pendiente de asignación/decisión del profesor)
- [x] Memoria final (versión para sustentación)
- [ ] Visto bueno del profesor (obligatorio, pendiente)

## Nota sobre el corpus

Todas las fuentes usadas en este corpus son **públicas** (papers de la matriz bibliográfica del estado del arte, y el repositorio público `ustadistica/desarrollo_social_y_economico`). No hay documentos de contraparte no públicos involucrados, por lo que no aplica Acta de Datos de la Contraparte para esta actividad.