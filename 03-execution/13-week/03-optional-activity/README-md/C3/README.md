# C3 — Component Diagram

## ¿Qué es?
Es el tercer nivel del modelo C4. Hace zoom sobre cada contenedor y muestra los componentes que lo forman. Responde la pregunta: ¿qué hay dentro de cada microservicio?

## ¿Para qué sirve?
Permite entender la estructura interna de cada microservicio siguiendo los patrones DDD y MVC.

## ¿Qué muestra?
- Las capas internas: Entity, IRepository, IService, Service, Controller, DTO, IDTO, Utils
- La organización AllProject y ByModule
- Los patrones MVC y DDD aplicados

## En el proyecto SENA
Cada microservicio sigue la misma estructura interna organizada en AllProject (vista global) y ByModule (por microservicio independiente).
