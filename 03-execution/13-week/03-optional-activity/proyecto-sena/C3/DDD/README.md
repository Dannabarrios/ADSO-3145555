# DDD — Domain Driven Design

```txt
DDD
├── Web Controller
│   ├── HorarioController
│   ├── InstructorController
│   ├── AmbienteController
│   └── AuthController
│
├── Application Layer
│   ├── UseCases
│   │   ├── AsignarHorario
│   │   ├── ValidarConflicto
│   │   └── ConsultarDisponibilidad
│   ├── Services
│   │   ├── HorarioService
│   │   ├── InstructorService
│   │   └── DisponibilidadService
│   └── DTOs
│       ├── HorarioDTO
│       ├── InstructorDTO
│       └── AmbienteDTO
│
├── Domain Layer
│   ├── Entities
│   │   ├── Horario
│   │   ├── Instructor
│   │   ├── Ambiente
│   │   └── Ficha
│   ├── IRepository
│   │   ├── IHorarioRepository
│   │   ├── IInstructorRepository
│   │   └── IAmbienteRepository
│   └── Domain Services
│       └── ValidadorConflictos
│
└── Infrastructure Layer
    ├── RepositoryImpl
    │   ├── HorarioRepositoryImpl
    │   └── InstructorRepositoryImpl
    ├── PostgreSQL
    ├── Kafka
    └── Camunda
```
