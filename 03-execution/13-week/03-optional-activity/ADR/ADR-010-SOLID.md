# ADR-010 — SOLID

## Contexto
Al desarrollar el código interno de cada microservicio se necesitaba un conjunto de principios que garantizaran mantenibilidad y extensibilidad del código.

## Decisión
Se adoptaron los 5 principios SOLID como guía de diseño para el código interno de cada microservicio.

## Razón
Sin principios de diseño claros el código crece descontrolado. SOLID garantiza que cada clase tenga una sola responsabilidad y que las dependencias sean sobre abstracciones.

## Consecuencias
El código es más fácil de testear y mantener. Agregar nuevas funcionalidades no requiere modificar clases existentes sino extenderlas.
