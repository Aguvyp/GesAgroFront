# 🗺️ Configuración de Google Maps SDK para GesAgro

## ¿Es gratis o de pago?

✅ **Google da un crédito gratuito de $200 USD por mes**
- La mayoría de apps pequeñas/medianas **NO pagan nada**
- Te alcanza para **decenas de miles de cargas de mapa al mes**
- Solo pagas si tu app escala mucho (miles de usuarios activos diarios)

## Paso 1: Obtener API Key de Google Cloud Console

### 1.1 Crear/Seleccionar Proyecto
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Anota el **Project ID** (lo necesitarás después)

### 1.2 Habilitar APIs Necesarias
Ve a **"APIs y servicios" > "Biblioteca"** y habilita:

- ✅ **Maps SDK for Android** (obligatorio)
- ✅ **Maps SDK for iOS** (si usas iOS)
- ✅ **Geocoding API** (para convertir direcciones a coordenadas)
- ✅ **Places API** (opcional, para búsqueda de lugares)

### 1.3 Crear API Key
1. Ve a **"APIs y servicios" > "Credenciales"**
2. Haz clic en **"Crear credenciales" > "Clave de API"**
3. **Copia la API key generada** (empieza con `AIza...`)

### 1.4 Restringir la API Key (Recomendado)
1. Haz clic en la API key creada
2. En **"Restricciones de aplicación"**:
   - Selecciona **"Aplicaciones Android"**
   - Agrega el **nombre del paquete**: `com.example.ges_agro_front`
   - Agrega la **huella SHA-1** (opcional pero recomendado)
3. En **"Restricciones de API"**:
   - Selecciona **"Restringir clave"**
   - Selecciona solo las APIs que habilitaste

## Paso 2: Configurar en tu App

### 2.1 Android (android/app/src/main/AndroidManifest.xml)
Reemplaza `TU_API_KEY_AQUI` con tu API key real:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyC...tu_api_key_aqui" />
```

### 2.2 iOS (ios/Runner/Info.plist)
Reemplaza `TU_API_KEY_AQUI` con tu API key real:

```xml
<key>GMSApiKey</key>
<string>AIzaSyC...tu_api_key_aqui</string>
```

### 2.3 Configuración Flutter (lib/utils/maps_config.dart)
Reemplaza `TU_API_KEY_AQUI` con tu API key real:

```dart
static const String googleMapsApiKey = 'AIzaSyC...tu_api_key_aqui';
```

## Paso 3: Probar la Configuración

### 3.1 Rebuild de la App
```bash
flutter clean
flutter pub get
flutter run
```

### 3.2 Verificar en Logs
Busca en la consola:
- ✅ `GoogleMap: Map created successfully`
- ❌ `GoogleMap: API key not found` (si hay error)

## Paso 4: Obtener Huella SHA-1 (Opcional pero Recomendado)

### Para Debug (desarrollo):
```bash
cd android
./gradlew signingReport
```

### Para Release (producción):
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

## Solución de Problemas

### ❌ "API key not found"
- Verifica que la API key esté en `AndroidManifest.xml`
- Asegúrate de hacer `flutter clean` y rebuild

### ❌ "This API project is not authorized"
- Verifica que las APIs estén habilitadas en Google Cloud Console
- Revisa las restricciones de la API key

### ❌ "Map not loading"
- Verifica conexión a internet
- Revisa los logs de la consola
- Confirma que la API key sea válida

### ❌ "Quota exceeded"
- Revisa el uso en Google Cloud Console
- Considera agregar restricciones a la API key

## Costos Estimados

Con el crédito gratuito de $200 USD:
- **~28,000 cargas de mapa por mes** (Android)
- **~40,000 cargas de mapa por mes** (iOS)
- **~40,000 geocoding requests por mes**

Para una app pequeña/mediana, esto es **más que suficiente**.

## Seguridad

⚠️ **NUNCA subas tu API key a repositorios públicos**
- Usa variables de entorno en producción
- Restringe la API key por aplicación
- Monitorea el uso regularmente

## Soporte

Si tienes problemas:
1. Revisa los logs de la consola
2. Verifica la configuración en Google Cloud Console
3. Consulta la [documentación oficial de Google Maps](https://developers.google.com/maps/documentation)
