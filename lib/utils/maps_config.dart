class MapsConfig {
  // Configuración de Google Maps
  static const String googleMapsApiKey = 'TU_API_KEY_AQUI';
  
  // Configuración por defecto del mapa
  static const double defaultZoom = 13.0;
  static const double defaultLatitude = -34.6037; // Buenos Aires, Argentina
  static const double defaultLongitude = -58.3816;
  
  // Configuración de tipos de mapa
  static const List<String> mapTypes = [
    'Relieve',
    'Satelital', 
    'Híbrido',
  ];
  
  // Configuración de marcadores
  static const double markerHue = 0.0; // Rojo por defecto
  
  // Mensajes de error comunes
  static const String mapLoadError = 'Error al cargar el mapa. Verifica tu conexión a internet.';
  static const String apiKeyError = 'Error de configuración de API key. Contacta al administrador.';
  static const String locationError = 'No se pudo obtener la ubicación actual.';
  
  // Verificar si la API key está configurada
  static bool get isApiKeyConfigured => googleMapsApiKey != 'TU_API_KEY_AQUI';
}
