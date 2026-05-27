# ByModule

## ¿Qué es?
Es una vista que organiza el código separado por cada microservicio independiente. Cada módulo contiene su propia estructura completa de capas.

## ¿Para qué sirve?
Permite entender qué clases pertenecen a cada microservicio de forma independiente. Es la forma en que el código se despliega en producción, cada microservicio como una unidad autónoma.

## ¿Qué muestra?
- Cada microservicio como una carpeta independiente
- Dentro de cada uno: Entity, IRepository, IService, Service, Controller, DTO, IDTO, Utils
- Las clases específicas de cada módulo de negocio

## En el proyecto SENA
ByModule separa el sistema en: ms-security, ms-catalogos, ms-horarios, ms-disponibilidad, ms-observaciones, ms-reportes, workflow-api y workflow-worker, cada uno con su propia estructura interna completa e independiente.
