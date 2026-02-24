# Proyecto Spring Boot + Docker + PostgreSQL
### Arquitectura N-Capas — com.sena.test

---

##  Tecnologías usadas

- **Java 17**
- **Spring Boot**
- **PostgreSQL 15** (en contenedor Docker)
- **Docker & Docker Compose**
- **Eclipse IDE** con Spring Tools 4

---

##  Docker — Configuración del contenedor

### `docker-compose.yml`

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15
    container_name: postgres_sena
    environment:
      POSTGRES_DB: testdb
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin123
    ports:
      - "5433:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

### Comandos útiles

```bash
# Levantar el contenedor
docker-compose up -d

# Ver contenedores corriendo
docker ps

# Entrar a la base de datos
docker exec -it postgres_sena psql -U admin -d testdb

# Ver tablas creadas
\dt

# Salir
\q
```

>  Se usa el puerto **5433** porque el 5432 estaba ocupado por PostgreSQL local.

---

##  Spring Boot — Configuración

### `application.properties`

```properties
spring.datasource.url=jdbc:postgresql://localhost:5433/testdb
spring.datasource.username=admin
spring.datasource.password=admin123
spring.datasource.driver-class-name=org.postgresql.Driver

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
```

### `pom.xml` — Dependencias clave

```xml
<!-- Spring Data JPA -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- Driver PostgreSQL -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>

<!-- Spring Web -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

---

##  Arquitectura N-Capas

```
com.sena.test
├── entity
│   ├── Person.java
│   ├── User.java
│   └── Role.java
├── repository
│   ├── IPersonRepository.java
│   ├── IUserRepository.java
│   └── IRoleRepository.java
├── service
│   ├── IPersonService.java
│   ├── IUserService.java
│   ├── IRoleService.java
│   └── impl
│       ├── PersonService.java
│       ├── UserService.java
│       └── RoleService.java
├── controller
│   ├── PersonController.java
│   ├── UserController.java
│   └── RoleController.java
└── utils
```

---

##  Entidades

### Person
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | Long | Clave primaria |
| firstName | String | Nombre |
| lastName | String | Apellido |
| email | String | Correo (único) |
| phone | String | Teléfono |

### User
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | Long | Clave primaria |
| username | String | Usuario (único) |
| password | String | Contraseña |
| active | Boolean | Estado activo |
| person | Person | Relación OneToOne |

### Role
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | Long | Clave primaria |
| name | String | Nombre (único) |
| description | String | Descripción |

---

##  Endpoints disponibles

### Person
| Método | URL | Descripción |
|--------|-----|-------------|
| GET | `/api/person` | Obtener todas |
| GET | `/api/person/{id}` | Obtener por ID |
| POST | `/api/person` | Crear nueva |
| PUT | `/api/person/{id}` | Actualizar |
| DELETE | `/api/person/{id}` | Eliminar |

### User
| Método | URL | Descripción |
|--------|-----|-------------|
| GET | `/api/user` | Obtener todos |
| GET | `/api/user/{id}` | Obtener por ID |
| POST | `/api/user` | Crear nuevo |
| PUT | `/api/user/{id}` | Actualizar |
| DELETE | `/api/user/{id}` | Eliminar |

### Role
| Método | URL | Descripción |
|--------|-----|-------------|
| GET | `/api/role` | Obtener todos |
| GET | `/api/role/{id}` | Obtener por ID |
| POST | `/api/role` | Crear nuevo |
| PUT | `/api/role/{id}` | Actualizar |
| DELETE | `/api/role/{id}` | Eliminar |

>  La app corre en: `http://localhost:8080`

---

##  Estado del proyecto

- [x] Contenedor Docker creado y corriendo
- [x] Base de datos `testdb` creada
- [x] Tablas `person`, `users`, `role` creadas automáticamente por Hibernate
- [x] Proyecto Spring Boot corriendo en puerto 8080
- [x] Arquitectura N-Capas implementada
