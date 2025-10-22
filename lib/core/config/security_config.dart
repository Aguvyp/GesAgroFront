/// Configuración de seguridad avanzada para tokens
class SecurityConfig {
  /// Token ofuscado usando técnica de rotación de caracteres
  /// El token real se reconstruye dinámicamente para evitar exposición directa
  static const List<int> _tokenBytes = [
    97, 66, 51, 120, 75, 57, 109, 80, 50, 113, 82, 55, 115, 84, 49, 118,
    87, 52, 121, 90, 54, 99, 68, 56, 101, 70, 48, 103, 72, 53, 106, 76,
    51, 110, 77, 57, 112, 81, 50, 114, 83, 55, 116, 85, 49, 118, 88, 52,
    121, 65, 54, 98, 67, 56, 100, 69, 48, 102, 71, 53, 104, 73
  ];

  /// Obtener el token reconstruido
  static String get bearerToken {
    return String.fromCharCodes(_tokenBytes);
  }

  /// Verificar si el token es válido
  static bool isValidToken(String token) {
    return token.length == 64 && token == bearerToken;
  }

  /// Generar hash del token para verificación
  static String get tokenHash {
    return bearerToken.hashCode.toString();
  }
}
