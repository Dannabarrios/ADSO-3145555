# ADR-003 — Service Discovery

## Contexto
Los microservicios corren en contenedores que cambian de dirección IP dinámicamente. Un microservicio no puede tener la dirección de otro hardcodeada.

## Decisión
Se implementó Service Discovery para que los microservicios se registren automáticamente y puedan encontrarse entre sí de forma dinámica.

## Razón
En Kubernetes las IPs cambian constantemente. Sin Service Discovery, cualquier reinicio rompería la comunicación entre microservicios.

## Consecuencias
Los microservicios son independientes en cuanto a ubicación. El sistema puede escalar y reorganizar servicios sin afectar la comunicación entre ellos.
