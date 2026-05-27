# C3 — Component Diagram

## ¿Qué es?
Es el tercer nivel del modelo C4. Hace zoom sobre cada contenedor y muestra los componentes internos que lo forman. Responde la pregunta: **¿qué hay dentro de cada microservicio?**

## ¿Para qué sirve?
Permite entender la estructura interna de cada microservicio. Muestra cómo se organizan las capas de código siguiendo los patrones DDD y MVC, tanto en vista global (AllProject) como por módulo independiente (ByModule).

## ¿Qué muestra?
- Las capas internas de cada microservicio
- Los componentes: Entity, IRepository, IService, Service, Controller, DTO, IDTO, Utils
- Las relaciones entre componentes
- La organización AllProject y ByModule

## En el proyecto SENA
Cada microservicio del sistema de horarios sigue la misma estructura interna de capas, organizada tanto en vista global como por módulo independiente, aplicando los patrones MVC y DDD.
