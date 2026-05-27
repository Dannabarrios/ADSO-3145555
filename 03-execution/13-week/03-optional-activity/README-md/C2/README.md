# C2 — Container Diagram

## ¿Qué es?
Es el segundo nivel del modelo C4. Hace zoom sobre el sistema y muestra las aplicaciones que lo componen. Responde la pregunta: **¿qué aplicaciones forman el sistema?**

## ¿Para qué sirve?
Permite entender cómo está dividido el sistema internamente. Está dirigido a desarrolladores y arquitectos de software.

## ¿Qué muestra?
- Los microservicios del sistema
- El frontend
- El API Gateway
- Las bases de datos
- Las conexiones entre contenedores

## En el proyecto SENA
El sistema está compuesto por 8 microservicios: ms-security, ms-catalogos, ms-horarios, ms-disponibilidad, ms-observaciones, ms-reportes, workflow-api y workflow-worker, todos conectados a través del API Gateway.
