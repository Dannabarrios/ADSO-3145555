# ADR-006 — Circuit Breaker

## Contexto
ms-horarios depende de ms-catalogos para verificar instructores y ambientes. Si ms-catalogos falla, ms-horarios seguiría intentando llamarlo generando una falla en cascada.

## Decisión
Se implementó Circuit Breaker en la comunicación entre microservicios. Cuando un servicio falla repetidamente el circuito se abre y se devuelve una respuesta alternativa (fallback).

## Razón
Proteger el sistema ante fallos en cascada es crítico. Un servicio caído no debe tumbar a todos los que dependen de él.

## Consecuencias
El sistema sigue funcionando de forma degradada cuando un servicio falla. El coordinador recibe una respuesta alternativa y el sistema se recupera automáticamente.
