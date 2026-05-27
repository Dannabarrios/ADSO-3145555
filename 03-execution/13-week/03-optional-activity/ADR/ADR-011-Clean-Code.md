# ADR-011 — Clean Code

## Contexto
Con 3 integrantes desarrollando el mismo sistema era necesario un estándar de escritura para que cualquier miembro pudiera entender y modificar el código de otro.

## Decisión
Se adoptaron las prácticas de Clean Code de Robert C. Martin: nombres descriptivos, funciones pequeñas, manejo explícito de errores, DRY y cobertura de pruebas por servicio.

## Razón
Sin estándar de escritura cada desarrollador escribe diferente. En microservicios donde varios tocan el mismo código, debe ser autoexplicativo y consistente.

## Consecuencias
El código es legible y mantenible a largo plazo. El tiempo de incorporación de nuevos desarrolladores se reduce porque el código se explica solo.
