🛫 Unix Travel
Proyecto académico y experimental que combina backend en Python y una aplicación móvil en Flutter para gestionar viajes, reservas y datos relacionados. Incluye scripts SQL para la base de datos y pruebas iniciales en Python.

📂 Estructura del repositorio
backend/

app.py: Punto de entrada del servidor backend.

Scripts auxiliares para lógica de negocio y conexión con la base de datos.

flutter_unix_travel/

Proyecto Flutter para la aplicación móvil.

Carpetas estándar: android/, ios/, lib/, web/, etc.

Archivos de configuración: pubspec.yaml, .gitignore, README.md.

entorno_ia/

Scripts iniciales relacionados con inteligencia artificial (pendiente de documentación).

Base de datos

Unix Travel.sql: Script principal de creación de tablas y relaciones.

sql.sql: Consultas adicionales para pruebas.

Otros archivos

test.py: Script de prueba en Python.

Taller semana 3.docx: Documento académico relacionado.

🚀 Instalación y uso
Backend (Python)
Clonar el repositorio:

bash
git clone https://github.com/marlonsarm/Unix_Travel.git
cd Unix_Travel/backend
Instalar dependencias:

bash
pip install -r requirements.txt
Ejecutar el servidor:

bash
python app.py
Aplicación Flutter
Ir al directorio:

bash
cd Unix_Travel/flutter_unix_travel
Instalar dependencias:

bash
flutter pub get
Ejecutar en emulador o dispositivo:

bash
flutter run
Base de datos
Importar Unix Travel.sql en tu gestor de base de datos (MySQL/PostgreSQL).

Ajustar credenciales en el backend (app.py).

🛠 Tecnologías utilizadas
Python (backend, lógica de negocio)

Flutter/Dart (aplicación móvil multiplataforma)

SQL (gestión de datos)

Otros lenguajes presentes: Cython, C, C++, Fortran (mínimos porcentajes en el repo)

📌 Estado del proyecto
Proyecto en desarrollo inicial.

Última actualización: hace 3 semanas.

Objetivo: servir como práctica de integración entre backend, frontend móvil y base de datos.

🤝 Contribuciones
Este es un proyecto académico, pero se aceptan sugerencias y mejoras.
Para contribuir:

Haz un fork del repositorio.

Crea una rama (feature/nueva-funcionalidad).

Envía un pull request.

📄 Licencia
Actualmente no se especifica licencia. Se recomienda añadir una (ej. MIT) para facilitar colaboraciones.
