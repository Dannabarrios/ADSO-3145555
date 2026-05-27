# ADR-004 — Database per Service

## Contexto
Compartir la base de datos entre microservicios mantiene el acoplamiento a nivel de datos, perdiendo la independencia que se busca con la arquitectura de microservicios.

## Decisión
Cada microservicio tiene su propia base de datos independiente. La comunicación entre servicios se hace únicamente a través de APIs.

## Razón
La base de datos compartida es el mayor punto de acoplamiento. Una BD por servicio garantiza que cada microservicio puede cambiar su modelo de datos sin afectar a los demás.

## Consecuencias
Las transacciones distribuidas no pueden usar ACID tradicional. Se requiere el patrón Saga para coordinar transacciones entre ms-horarios, ms-catalogos y ms-disponibilidad.
