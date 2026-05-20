# C1 — System Context
## Sistema de Gestión de Horarios Académicos SENA

```txt
Sistema de Gestión de Horarios SENA
├── Coordinador Académico
│   └── Asigna horarios y valida conflictos en tiempo real
├── Instructor
│   └── Consulta su horario y registra observaciones
├── Admin de Ambientes
│   └── Gestiona inventario de salones y laboratorios
├── Camunda (Sistema Externo)
│   └── Motor BPMN que orquesta los workflows de asignación
└── Base de Datos (Sistema Externo)
    └── Persiste horarios, instructores, ambientes y fichas
```
