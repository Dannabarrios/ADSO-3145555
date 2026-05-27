# ADR-002 — API Gateway

## Contexto
Con 8 microservicios independientes, el Frontend necesitaría conocer la dirección de cada uno, generando acoplamiento directo con la infraestructura interna.

## Decisión
Se implementó un API Gateway como punto de entrada único. El Frontend solo conoce la dirección del Gateway y este enruta cada petición al microservicio correspondiente.

## Razón
Centralizar la entrada permite manejar autenticación, rate limiting y enrutamiento en un solo lugar sin duplicar lógica en cada microservicio.

## Consecuencias
El Gateway es un componente crítico. Si cae, ningún cliente puede acceder. Debe tener alta disponibilidad y estar respaldado por Circuit Breaker.
