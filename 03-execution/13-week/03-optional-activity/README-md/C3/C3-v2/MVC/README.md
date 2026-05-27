# MVC — Model View Controller

## ¿Qué es?
Es un patrón de organización del código que separa cada microservicio en tres capas: Vista, Controlador y Modelo. Es uno de los patrones más usados en el desarrollo de aplicaciones web.

## ¿Para qué sirve?
Permite separar las responsabilidades del código de forma clara. El Controller recibe las peticiones, el Model contiene la lógica y los datos, y la View muestra el resultado al usuario.

## ¿Qué muestra?
- **View** → interfaz que ve el usuario (HTML / React)
- **Controller** → recibe peticiones HTTP y las dirige al Model
- **Model** → contiene Entity, Service y Repository
- **Database** → base de datos de cada microservicio

## En el proyecto SENA
Se escogió MVC porque es el patrón estándar para estructurar los endpoints REST de cada microservicio. El Controller expone los endpoints, el Service contiene la lógica de negocio y el Repository accede a la base de datos, manteniendo cada capa con una sola responsabilidad.
