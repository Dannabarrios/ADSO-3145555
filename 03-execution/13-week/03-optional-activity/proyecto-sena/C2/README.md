# C2 — Container Diagram
## Contenedores del Sistema

```txt
Sistema de Gestión de Horarios SENA
├── Frontend
│   └── Interfaz web responsive para todos los usuarios
├── API Gateway
│   └── Punto de entrada único — enruta peticiones a cada microservicio
├── Microservicios
│   ├── ms-security       → Autenticación y autorización JWT
│   ├── ms-catalogos      → CRUD instructores, fichas y ambientes
│   ├── ms-horarios       → Motor de asignación y validación de conflictos
│   ├── ms-disponibilidad → Consulta ambientes libres por franja horaria
│   ├── ms-observaciones  → Registra y hace seguimiento de observaciones
│   ├── ms-reportes       → Carga horaria acumulada por instructor
│   ├── workflow-api      → Recibe y expone endpoints de workflow
│   └── workflow-worker   → Ejecuta las tareas del workflow
├── Camunda
│   └── Motor BPMN — orquesta los procesos de asignación
└── Base de Datos (una por cada microservicio)
```
