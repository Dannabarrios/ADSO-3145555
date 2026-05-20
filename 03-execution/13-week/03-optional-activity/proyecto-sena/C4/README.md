# C4 — Code Diagram
## Clases, atributos y métodos de cada componente

```txt
ms-horarios
│
├── Horario (Entity)
│   ├── - id: Long
│   ├── - fichaId: Long
│   ├── - instructorId: Long
│   ├── - ambienteId: Long
│   ├── - fecha: Date
│   ├── - franjaInicio: Time
│   ├── - franjaFin: Time
│   └── - estado: String
│
├── IHorarioRepository (IRepository)
│   ├── + findById(id): Horario
│   ├── + findAll(): List<Horario>
│   ├── + save(h): Horario
│   ├── + delete(id): void
│   └── + existeConflicto(...): Boolean
│
├── IHorarioService (IService)
│   ├── + asignarHorario(dto): HorarioDTO
│   ├── + validarConflicto(dto): Boolean
│   ├── + consultarHorario(id): HorarioDTO
│   ├── + listarHorarios(): List<HorarioDTO>
│   └── + eliminarHorario(id): void
│
├── HorarioService (Service)
│   ├── - repository: IHorarioRepository
│   ├── - validador: ValidadorConflictos
│   ├── + asignarHorario(dto): HorarioDTO
│   ├── + validarConflicto(dto): Boolean
│   └── - mapearAEntity(dto): Horario
│
├── HorarioController (Controller)
│   ├── - service: IHorarioService
│   ├── + POST /horarios
│   ├── + GET /horarios/{id}
│   ├── + GET /horarios
│   ├── + PUT /horarios/{id}
│   └── + DELETE /horarios/{id}
│
├── HorarioDTO (DTO)
│   ├── - id: Long
│   ├── - fichaId: Long
│   ├── - instructorId: Long
│   ├── - ambienteId: Long
│   ├── - fecha: Date
│   ├── - franjaInicio: Time
│   └── - franjaFin: Time
│
├── IHorarioDTO (IDTO)
│   ├── + getId(): Long
│   ├── + getFichaId(): Long
│   └── + getInstructorId(): Long
│
└── ValidadorConflictos (Utils)
    ├── + verificarInstructor(...): Boolean
    ├── + verificarAmbiente(...): Boolean
    └── + verificarFicha(...): Boolean
```
