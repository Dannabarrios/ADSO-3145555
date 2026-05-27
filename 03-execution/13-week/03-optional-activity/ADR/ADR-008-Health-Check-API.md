# ADR-008 — Health Check API

## Contexto
Con múltiples microservicios corriendo era necesario saber en todo momento cuáles están funcionando correctamente sin esperar a que un coordinador reporte un error.

## Decisión
Cada microservicio expone un endpoint GET /health. Kubernetes lo consulta automáticamente cada 30 segundos y toma decisiones de reinicio según la respuesta.

## Razón
La detección automática de fallos es fundamental en producción. Sin Health Check un microservicio caído puede pasar desapercibido hasta que un usuario reporte el problema.

## Consecuencias
El sistema se recupera solo ante fallos sin intervención humana. El coordinador del SENA nunca se entera cuando un microservicio falla.
