# MVC — Model View Controller

```txt
MVC
├── View
│   └── HTML / React (Frontend)
│
├── Controller
│   └── HTTP Request
│       ├── HorarioController
│       ├── InstructorController
│       ├── AmbienteController
│       ├── FichaController
│       ├── DisponibilidadController
│       ├── ObservacionController
│       ├── ReporteController
│       └── AuthController
│
├── Model
│   ├── Entity
│   │   ├── Horario
│   │   ├── Instructor
│   │   ├── Ambiente
│   │   └── Ficha
│   ├── Service
│   │   ├── HorarioService
│   │   ├── InstructorService
│   │   └── DisponibilidadService
│   └── Repository
│       ├── IHorarioRepository
│       ├── IInstructorRepository
│       └── IAmbienteRepository
│
└── Database
    └── BD por cada microservicio (PostgreSQL)
```
