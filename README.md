# TourCap Capachica - Aplicación Móvil de Turismo

## 🏖️ Bienvenido a TourCap Capachica

TourCap Capachica es una aplicación móvil desarrollada en Flutter que ofrece una experiencia completa para explorar y descubrir los atractivos turísticos de la península de Capachica, Puno. La aplicación proporciona información detallada sobre lugares turísticos, servicios de hospedaje, restaurantes y actividades culturales de la región.

## ✨ Características Principales

- 📍 Mapa interactivo con puntos de interés turístico
- 🏨 Información detallada de hoteles y hospedajes
- 🍽️ Directorio de restaurantes y gastronomía local
- 🎭 Eventos culturales y actividades turísticas
- 📸 Galería de imágenes de lugares turísticos
- 🔍 Búsqueda avanzada de servicios
- 📱 Interfaz intuitiva y fácil de usar

## 🚀 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- Flutter SDK (versión 3.0.0 o superior)
- Dart SDK (versión 2.17.0 o superior)
- Android Studio o Visual Studio Code
- Git
- Un emulador Android/iOS o un dispositivo físico

## 📥 Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/tu-usuario/tourcap-capachica.git
cd tourcap-capachica
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Configura las variables de entorno:
   - Crea un archivo `.env` en la raíz del proyecto
   - Copia el contenido de `.env.example`
   - Completa las variables necesarias

## 🏃‍♂️ Ejecución del Proyecto

1. Asegúrate de tener un emulador corriendo o un dispositivo físico conectado:
```bash
flutter devices
```

2. Ejecuta la aplicación:
```bash
flutter run
```

## 🛠️ Configuración del Backend

La aplicación requiere un backend funcionando. Asegúrate de:

1. Tener el servidor backend corriendo en `http://localhost:8000`
2. Configurar correctamente las variables de entorno en el archivo `.env`
3. Tener una base de datos PostgreSQL configurada

## 📱 Estructura del Proyecto

```
lib/
├── config/           # Configuraciones de la aplicación
├── models/          # Modelos de datos
├── providers/       # Proveedores de estado
├── screens/         # Pantallas de la aplicación
├── services/        # Servicios y APIs
├── utils/           # Utilidades y helpers
└── widgets/         # Widgets reutilizables
```

## 🔑 Credenciales de Prueba

Para probar la aplicación, puedes usar las siguientes credenciales:

```
Email: admin@example.com
Password: password123
```

## 🤝 Contribución

1. Haz un Fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE.md](LICENSE.md) para más detalles.

## 📞 Contacto

Si tienes alguna pregunta o sugerencia, no dudes en contactarnos:

- Email: tu-email@ejemplo.com
- Twitter: [@tu-usuario](https://twitter.com/tu-usuario)
- LinkedIn: [Tu Nombre](https://linkedin.com/in/tu-usuario)

## 🙏 Agradecimientos

- A todos los contribuidores que han ayudado en el desarrollo
- A la comunidad de Flutter por su excelente documentación
- A los habitantes de Capachica por su invaluable apoyo

---

⭐️ Si te gusta el proyecto, no olvides darle una estrella en GitHub!
