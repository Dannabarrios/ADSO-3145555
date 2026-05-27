# C4 — Code Diagram

## ¿Qué es?
Es el cuarto y último nivel del modelo C4. Hace zoom sobre cada componente y muestra las clases concretas con sus atributos y métodos. Responde la pregunta: **¿cómo está escrito el código?**

## ¿Para qué sirve?
Es el esqueleto real del código del backend. No es documentación sino la estructura de archivos lista para que el equipo empiece a programar. Cada archivo representa una clase real del sistema.

## ¿Qué muestra?
- Las clases concretas de cada microservicio
- Los atributos de cada clase
- Los métodos de cada clase
- Las relaciones entre clases (implementa, usa, retorna)

## En el proyecto SENA
Cada microservicio tiene sus clases organizadas en: Entity (datos del dominio), IRepository (contrato de acceso a datos), IService (contrato de negocio), Service (lógica de negocio), Controller (endpoints HTTP), DTO (transferencia de datos), IDTO (contrato del DTO) y Utils (utilidades).
