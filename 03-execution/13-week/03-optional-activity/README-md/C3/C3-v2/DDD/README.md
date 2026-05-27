# DDD — Domain Driven Design

## ¿Qué es?
Es un patrón de organización del código que estructura cada microservicio en capas basadas en el dominio de negocio. Separa claramente la lógica de negocio de la infraestructura técnica.

## ¿Para qué sirve?
Permite que el código refleje directamente el lenguaje y las reglas del negocio. Facilita el mantenimiento porque cada capa tiene una responsabilidad clara y bien definida.

## ¿Qué muestra?
- **Web Controller** → entrada de peticiones HTTP
- **Application Layer** → casos de uso, Services y DTOs
- **Domain Layer** → Entities, IRepository e interfaces del dominio
- **Infrastructure Layer** → implementaciones de BD, Kafka y Camunda

## En el proyecto SENA
Se escogió DDD porque el sistema de horarios tiene reglas de negocio complejas como la validación de la triple restricción (instructor + ambiente + ficha). DDD permite que esa lógica viva en el dominio sin mezclarse con detalles técnicos de infraestructura.
