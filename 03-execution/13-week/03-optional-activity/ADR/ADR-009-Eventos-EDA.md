# ADR-009 — Eventos (Event-Driven Architecture)

## Contexto
La comunicación síncrona genera acoplamiento temporal: si ms-catalogos está caído cuando ms-horarios lo necesita, la operación falla.

## Decisión
Se adoptó Event-Driven Architecture para la comunicación asíncrona. Cuando algo ocurre, el servicio publica un evento y los demás lo consumen cuando estén disponibles.

## Razón
Los eventos desacoplan completamente los servicios. El publicador no necesita saber quién escucha ni esperar respuesta.

## Consecuencias
Se requiere un Message Broker como Kafka. La consistencia es eventual pero el sistema es mucho más resiliente ante fallos.
