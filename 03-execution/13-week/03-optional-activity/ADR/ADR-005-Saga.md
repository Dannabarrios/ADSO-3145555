# ADR-005 — Saga

## Contexto
Al asignar un horario se involucran múltiples microservicios: ms-horarios valida el cruce, ms-catalogos verifica el instructor y ms-disponibilidad confirma el ambiente. Con bases de datos separadas no existe una transacción ACID que abarque los tres.

## Decisión
Se implementó el patrón Saga para coordinar la transacción distribuida de asignación de horarios con compensaciones si algo falla.

## Razón
Es el único mecanismo que permite coordinar transacciones entre microservicios con bases de datos independientes garantizando consistencia eventual.

## Consecuencias
La consistencia es eventual. Si falla la asignación a mitad del proceso se ejecutan las compensaciones en orden inverso para deshacer lo ya hecho.
