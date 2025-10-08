# Configuración Temporal - Mapas Deshabilitados

## Estado Actual
Los mapas y la funcionalidad de coordenadas están **temporalmente deshabilitados** en la aplicación.

## Cambios Realizados

### 1. Campo Form Screen (`lib/screens/campos/campo_form_screen.dart`)
- ✅ **Inputs de latitud/longitud removidos**
- ✅ **Botón "Seleccionar en Mapa" deshabilitado**
- ✅ **Método `_openMapLocation()` comentado**
- ✅ **Valores por defecto: lat=0.0, lon=0.0**
- ✅ **Mensaje informativo agregado**

### 2. Campos List Screen (`lib/screens/campos/campos_list_screen.dart`)
- ✅ **Coordenadas (0,0) no se muestran en la lista**
- ✅ **Solo muestra coordenadas si no son valores por defecto**

### 3. Archivos de Configuración
- ✅ **Google Maps SDK configurado pero no activo**
- ✅ **API key placeholder en lugar de key real**

## Valores por Defecto
```dart
latitud: 0.0
longitud: 0.0
```

## Para Reactivar Mapas

### Paso 1: Configurar API Key
1. Obtener API key de Google Cloud Console
2. Reemplazar `TU_API_KEY_AQUI` en:
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/Info.plist`
   - `lib/utils/maps_config.dart`

### Paso 2: Descomentar Código
En `lib/screens/campos/campo_form_screen.dart`:
```dart
// Descomentar el método _openMapLocation()
// Restaurar los inputs de latitud/longitud
// Remover el mensaje de "deshabilitado temporalmente"
```

### Paso 3: Actualizar Lógica
Cambiar de valores fijos a valores dinámicos:
```dart
// De:
'latitud': 0.0,
'longitud': 0.0,

// A:
'latitud': _latitudController.text.isNotEmpty
    ? double.parse(_latitudController.text)
    : null,
'longitud': _longitudController.text.isNotEmpty
    ? double.parse(_longitudController.text)
    : null,
```

## Beneficios de esta Configuración
- ✅ **App funciona sin dependencias de mapas**
- ✅ **No requiere API key de Google Maps**
- ✅ **Fácil de reactivar cuando sea necesario**
- ✅ **No afecta otras funcionalidades**
- ✅ **Valores por defecto claros y consistentes**

## Notas
- Los campos se guardan correctamente con coordenadas (0,0)
- La lista no muestra coordenadas por defecto
- El formulario es más simple y rápido de usar
- Cuando se reactive, los campos existentes mantendrán sus coordenadas
