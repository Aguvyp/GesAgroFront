# Prompt para Actualización Frontend Flutter/Dart - GesAgro v2.0

## Contexto del Proyecto
GesAgro es una app móvil Flutter/Dart para gestión agropecuaria. El backend FastAPI fue refactorizado a la versión 2.0 con nuevas funcionalidades, autenticación JWT y endpoints optimizados para móvil.

## Cambios Principales en Backend v2.0

### Autenticación JWT
- Endpoint: `POST /auth/login`
- Payload: `{ "email": "string", "password": "string" }`
- Response: `{ "access_token": "string", "token_type": "bearer", "role": "string" }`
- Roles: `Administrador`, `Contable`, `Operario`
- Header: `Authorization: Bearer {token}`

### Endpoints móviles optimizados
- `/mobile/resumen`, `/mobile/estadisticas`, `/mobile/trabajos/recientes`, `/mobile/mantenimientos/proximos`, `/mobile/insumos/bajo-stock`, `/mobile/finanzas/resumen`

### Endpoints Flutter
- `/flutter/trabajos/lista`, `/flutter/campos/lista`, `/flutter/maquinas/lista`, `/flutter/personal/lista`, `/flutter/clientes/lista`, `/flutter/costos/lista`, `/flutter/facturas/lista`, `/flutter/dashboard/resumen`

### Nuevos módulos 2.0
- CRUD: `/clientes`, `/facturas`, `/pagos`, `/creditos`, `/cuotas-credito`, `/insumos`, `/movimientos`, `/mantenimientos`, `/usuarios` (solo Admin)

### Reportes y exportación
- JSON: `GET /reportes/{tipo}` (rentabilidad, maquinas, clientes, campos)
- Excel: `GET /reportes/{tipo}/excel` (CSV)
- PDF: `GET /reportes/{tipo}/pdf` (texto)

## Convenciones de API para Flutter
- Fechas ISO 8601
- Respuestas con `{ success, data, pagination? }` en endpoints `/flutter` y `/mobile`
- Paginación: query params `skip`, `limit`

## Tareas de Implementación

### 1) Autenticación
- Implementar servicio de login
- Guardar token en `flutter_secure_storage`
- Interceptor HTTP que añada `Authorization`
- Manejar expiración de token y 401/403

### 2) Actualizar pantallas
- Dashboard → `/flutter/dashboard/resumen`
- Trabajos → `/flutter/trabajos/lista` (filtros por estado)
- Campos → `/flutter/campos/lista`
- Máquinas → `/flutter/maquinas/lista`
- Personal → `/flutter/personal/lista`
- Costos → `/flutter/costos/lista` (filtros `categoria`, `pagado`)

### 3) Nuevas pantallas
- Clientes (CRUD)
- Facturación (facturas y pagos)
- Créditos y cuotas
- Inventario (insumos y movimientos)
- Mantenimientos
- Usuarios (solo Admin)

### 4) Reportes
- Selector de tipo (`rentabilidad`, `maquinas`, `clientes`, `campos`)
- Tabla/gráficos
- Exportación CSV/PDF descargable

### 5) Optimización móvil
- Resumen móvil y alertas (`/mobile/resumen`)
- Estadísticas rápidas (`/mobile/estadisticas`)
- Trabajos recientes (`/mobile/trabajos/recientes`)
- Mantenimientos próximos (`/mobile/mantenimientos/proximos`)

### 6) Control de acceso por roles
- Ocultar/mostrar módulos según `role`
- Bloquear acciones financieras a `Contable`/`Administrador`

### 7) Técnica
- Paginación, filtros, pull-to-refresh
- Loading y manejo de errores unificado
- Cache básico para endpoints frecuentes

## Estructura sugerida Flutter
```
lib/
  services/ (auth_service.dart, api_service.dart, storage_service.dart)
  models/ (...)
  screens/ (...)
  widgets/ (role_guard.dart, loading_widget.dart)
  utils/ (constants.dart, validators.dart)
```

## Base URL
- Desarrollo: `http://localhost:8080`
- Producción: `https://api.gesagro.com`

## Ejemplo de login
```dart
class ApiService {
  static const String baseUrl = 'http://localhost:8080';
}

class AuthService {
  final http.Client _client;
  AuthService(this._client);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await _client.post(
      Uri.parse('${ApiService.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Login fallido (${resp.statusCode})');
  }
}
```
