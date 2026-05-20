# C3 — Component Diagram
## Estructura interna de cada microservicio

```txt
C3
├── AllProject (vista global de todas las clases juntas)
│   ├── Entity
│   ├── IRepository
│   ├── IService
│   ├── Service
│   ├── Controller
│   ├── DTO
│   ├── IDTO
│   └── Utils
│
├── ByModule (vista por microservicio)
│   ├── ms-security
│   ├── ms-catalogos
│   ├── ms-horarios
│   ├── ms-disponibilidad
│   ├── ms-observaciones
│   ├── ms-reportes
│   ├── workflow-api
│   └── workflow-worker
│
├── MVC (patrón Model View Controller)
│   ├── View        → HTML / React
│   ├── Controller  → HTTP Request
│   ├── Model       → Entity, Service, Repository
│   └── Database    → PostgreSQL
│
└── DDD (Domain Driven Design)
    ├── Web Controller
    ├── Application Layer  → UseCases, Services, DTOs
    ├── Domain Layer       → Entities, IRepository, Domain Services
    └── Infrastructure Layer → RepositoryImpl, PostgreSQL, Camunda
```
