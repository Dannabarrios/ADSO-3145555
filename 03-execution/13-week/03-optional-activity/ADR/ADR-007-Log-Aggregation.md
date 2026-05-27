# ADR-007 — Log Aggregation

## Contexto
Con 8 microservicios corriendo simultáneamente, cada uno genera sus propios logs en su propio contenedor. Rastrear un error manualmente en cada servicio es inviable.

## Decisión
Se implementó Log Aggregation para centralizar los logs de todos los microservicios en un solo lugar donde pueden consultarse y filtrarse.

## Razón
Sin centralización de logs es inoperable un sistema distribuido en producción. Un error puede involucrar varios servicios al mismo tiempo.

## Consecuencias
El equipo puede diagnosticar errores en tiempo real desde un solo panel en lugar de conectarse a cada contenedor por separado.
