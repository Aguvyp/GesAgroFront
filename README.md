# 🌾 GesAgro - Aplicación Móvil Flutter

Una aplicación móvil completa para la gestión agrícola desarrollada en Flutter, diseñada para ayudar a agricultores y gestores a administrar sus campos, trabajos, personal, maquinaria y costos de manera eficiente.

## 📱 Características Principales

### 🏞️ Gestión de Campos
- Registro y edición de campos agrícolas
- Superficie en hectáreas
- Coordenadas GPS opcionales
- Detalles y observaciones
- Búsqueda y filtrado

### 🚜 Gestión de Máquinas
- Inventario de maquinaria agrícola
- Información detallada (marca, modelo, año)
- Estado de disponibilidad
- Ancho de trabajo
- Búsqueda por características

### 👥 Gestión de Personal
- Registro de trabajadores
- Validación de DNI único
- Información de contacto
- Búsqueda por nombre o DNI

### 🔧 Gestión de Trabajos
- Registro de trabajos agrícolas
- Tipos de trabajo (siembra, cosecha, etc.)
- Asignación de personal y maquinaria
- Estados (pendiente, en curso, completado)
- Filtros por estado y fecha

### 💰 Control de Costos
- Registro de gastos agrícolas
- Categorización de costos
- Estados de pago
- Formas de pago
- Resúmenes mensuales

### 📊 Dashboard
- Estadísticas generales
- Gráficos de costos
- Trabajos recientes
- Acciones rápidas

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo móvil
- **Provider**: Gestión de estado
- **HTTP**: Comunicación con API
- **SharedPreferences**: Persistencia local
- **Charts Flutter**: Gráficos y visualizaciones
- **Material Design**: UI/UX

## 📦 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  intl: ^0.19.0
  cupertino_icons: ^1.0.6
  flutter_svg: ^2.0.9
  charts_flutter: ^0.12.0
  date_picker_timeline: ^1.2.1
  pull_to_refresh: ^2.0.0
  cached_network_image: ^3.3.0
  url_launcher: ^6.2.1
  permission_handler: ^11.0.1
  geolocator: ^10.1.0
  flutter_map: ^6.1.0
  latlong2: ^0.8.1
```

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK (versión 3.0.0 o superior)
- Dart SDK
- Android Studio / VS Code
- Dispositivo Android/iOS o emulador

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <url-del-repositorio>
   cd GesAgroFront
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar el backend**
   - Asegúrate de que tu backend Flask esté ejecutándose en `http://localhost:5000`
   - O cambia la URL en `lib/utils/constants.dart`

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 🏗️ Estructura del Proyecto

```
lib/
├── models/              # Modelos de datos
│   ├── campo.dart
│   ├── maquina.dart
│   ├── personal.dart
│   ├── trabajo.dart
│   └── costo.dart
├── services/            # Servicios de API
│   ├── api_service.dart
│   ├── campo_service.dart
│   ├── maquina_service.dart
│   ├── personal_service.dart
│   ├── trabajo_service.dart
│   └── costo_service.dart
├── providers/           # State management
│   ├── campo_provider.dart
│   ├── maquina_provider.dart
│   ├── personal_provider.dart
│   ├── trabajo_provider.dart
│   └── costo_provider.dart
├── screens/             # Pantallas
│   ├── splash_screen.dart
│   ├── dashboard_screen.dart
│   ├── main_screen.dart
│   ├── campos/
│   ├── trabajos/
│   ├── costos/
│   ├── maquinas/
│   ├── personal/
│   └── profile/
├── widgets/             # Widgets reutilizables
│   ├── custom_app_bar.dart
│   ├── custom_card.dart
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   └── loading_widget.dart
├── utils/               # Utilidades
│   ├── constants.dart
│   ├── validators.dart
│   ├── date_utils.dart
│   └── api_config.dart
├── themes/              # Temas
│   └── app_theme.dart
└── main.dart
```

## 🎨 Diseño y UI/UX

### Tema de Colores
- **Primario**: Verde agrícola `#2E7D32`
- **Secundario**: Verde claro `#4CAF50`
- **Acento**: Naranja `#FF9800`
- **Fondo**: Blanco/Gris muy claro `#FAFAFA`
- **Texto**: Gris oscuro `#212121`

### Características de Diseño
- Material Design 3
- Navegación con Bottom Navigation
- Cards con sombras suaves
- Formularios con validación en tiempo real
- Loading states y manejo de errores
- Diseño responsive

## 🔌 Integración con Backend

La aplicación se conecta a un backend Flask con los siguientes endpoints:

- `GET/POST /campos` - Gestión de campos
- `GET/POST /maquinas` - Inventario de maquinaria
- `GET/POST /personal` - Gestión de personal
- `GET/POST /trabajos` - Registro de trabajos
- `GET/POST /costos` - Control de costos

### Configuración de API
La URL del backend se puede configurar desde la pantalla de perfil o modificando `lib/utils/constants.dart`.

## 📱 Funcionalidades

### Modo Offline
- Cache de datos para consulta sin conexión
- Sincronización automática cuando se recupera la conexión
- Indicador visual del estado de conexión

### Búsqueda y Filtros
- Búsqueda en tiempo real en todas las listas
- Filtros múltiples por fecha, estado, categoría
- Ordenamiento por diferentes criterios

### Validaciones
- Formularios con validación en tiempo real
- Campos requeridos marcados claramente
- Validación de DNI único
- Validación de formatos de fecha y números

## 🧪 Testing

```bash
# Ejecutar tests unitarios
flutter test

# Ejecutar tests de integración
flutter test integration_test/
```

## 📦 Build y Deploy

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build iOS
flutter build ios --release
```

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👥 Equipo de Desarrollo

- **GesAgro Team** - Desarrollo y diseño

## 📞 Soporte

Para soporte técnico o preguntas sobre la aplicación, contacta al equipo de desarrollo.

---

**¡Gracias por usar GesAgro! 🌾📱✨**
