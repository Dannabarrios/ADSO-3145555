# ADR-001 — Decompose by Business Capability / by Subdomain (DDD)

## Contexto
El sistema manejaba múltiples responsabilidades en un solo lugar: catálogos, horarios, disponibilidad, reportes y observaciones, generando acoplamiento y dificultad para mantener cada parte de forma independiente.

## Decisión
Se descompuso el sistema por capacidades de negocio creando un microservicio independiente por cada responsabilidad: ms-catalogos, ms-horarios, ms-disponibilidad, ms-reportes y ms-observaciones.

## Razón
Cada capacidad de negocio tiene su propio ciclo de vida y reglas. Separarlas permite que cada equipo trabaje de forma independiente y que cada servicio escale según su propia demanda.

## Consecuencias
Mayor complejidad inicial pero mejor mantenibilidad y escalabilidad independiente por servicio.
