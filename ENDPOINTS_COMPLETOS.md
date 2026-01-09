# Documentación Completa de Endpoints y Configuración API

## 📍 URL BASE

**URL Base del Servidor:**
```
http://168.181.185.234:8080
```

**Configuración:**
- Timeout: 30 segundos
- Headers por defecto: `Content-Type: application/json; charset=utf-8`
- Headers adicionales: `Accept: application/json`

---

## 🔐 AUTENTICACIÓN

### Token Bearer
- **Formato:** `Authorization: Bearer {token}`
- **Origen del token:**
  1. Primero intenta obtener el token del login (AuthService) - token JWT del login
  2. Si no hay token del login, usa el token fijo de `AuthConfig` (SecurityConfig)
  3. El token se almacena en FlutterSecureStorage
- **Token fijo (fallback):** `aB3xK9mP2qR7sT1vW4yZ6cD8eF0gH5jL3nM9pQ2rS7tU1vX4yA6bC8dE0fG5hI` (64 caracteres)
- **Ubicación del token:** `lib/core/config/security_config.dart`

### Endpoints SIN autenticación (no requieren Authorization header):
- `/api/auth/login/` - Login
- `/api/auth/register/` - Registro
- `/api/auth/test/` - Test de conexión
- `/api/health/` - Health check

### Endpoints CON autenticación (requieren Authorization header):
**TODOS los demás endpoints requieren el header `Authorization: Bearer {token}`**

---

## 📋 ENDPOINTS COMPLETOS DEL SISTEMA

### 🔑 AUTENTICACIÓN
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| POST | `/api/auth/login/` | Login de usuario | ❌ |
| POST | `/api/auth/register/` | Registro de usuario | ❌ |
| GET | `/api/auth/test/` | Test de conexión | ❌ |

### 👥 USUARIOS
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/usuarios/` | Listar usuarios (con paginación: skip, limit) | ✅ |
| GET | `/api/usuarios/{id}` | Obtener usuario por ID | ✅ |
| POST | `/api/usuarios/create` | Crear usuario | ✅ |
| PUT | `/api/usuarios/{id}/update` | Actualizar usuario | ✅ |
| DELETE | `/api/usuarios/{id}/delete` | Eliminar usuario | ✅ |

### 🌾 CAMPOS
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/campos/` | Listar campos (con paginación: skip, limit) | ✅ |
| GET | `/api/campos/{id}` | Obtener campo por ID | ✅ |
| POST | `/api/campos/create` | Crear campo | ✅ |
| PUT | `/api/campos/{id}/update` | Actualizar campo | ✅ |
| DELETE | `/api/campos/{id}/delete` | Eliminar campo | ✅ |

### 🚜 MÁQUINAS
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/maquinas/` | Listar máquinas | ✅ |
| GET | `/api/maquinas/{id}` | Obtener máquina por ID | ✅ |
| POST | `/api/maquinas/create` | Crear máquina | ✅ |
| PUT | `/api/maquinas/{id}/update` | Actualizar máquina | ✅ |
| DELETE | `/api/maquinas/{id}/delete` | Eliminar máquina | ✅ |

### 👷 PERSONAL
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/personal/` | Listar personal | ✅ |
| GET | `/api/personal/{id}` | Obtener personal por ID | ✅ |
| POST | `/api/personal/create` | Crear personal | ✅ |
| PUT | `/api/personal/{id}/update` | Actualizar personal | ✅ |
| DELETE | `/api/personal/{id}/delete` | Eliminar personal | ✅ |
| GET | `/api/personal/validate-dni` | Validar DNI (query: dni, exclude_id) | ✅ |

### 👤 CLIENTES
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/clientes/` | Listar clientes | ✅ |
| GET | `/api/clientes/{id}` | Obtener cliente por ID | ✅ |
| POST | `/api/clientes/create` | Crear cliente | ✅ |
| PUT | `/api/clientes/{id}/update` | Actualizar cliente | ✅ |
| DELETE | `/api/clientes/{id}/delete` | Eliminar cliente | ✅ |

### 🔗 CAMPOS-CLIENTE (Asignaciones)
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/campos-cliente/` | Listar todas las asignaciones | ✅ |
| GET | `/api/campos-cliente/?cliente_id={id}` | Obtener campos de un cliente | ✅ |
| GET | `/api/campos-cliente/{id}` | Obtener asignación por ID | ✅ |
| POST | `/api/campos-cliente/create` | Asignar campo a cliente | ✅ |
| PUT | `/api/campos-cliente/{id}/update` | Actualizar asignación | ✅ |
| DELETE | `/api/campos-cliente/{id}/delete` | Eliminar asignación (hard delete) | ✅ |
| PATCH | `/api/campos-cliente/{id}/desactivar` | Desactivar asignación (soft delete) | ✅ |

### 💰 COSTOS
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/costos/{id}` | Obtener costo por ID | ✅ |
| POST | `/api/costos/create` | Crear costo | ✅ |
| PUT | `/api/costos/{id}/update` | Actualizar costo | ✅ |
| DELETE | `/api/costos/{id}/delete` | Eliminar costo | ✅ |
| GET | `/api/costos/pagados` | Obtener costos pagados | ✅ |
| GET | `/api/costos/pendientes` | Obtener costos pendientes | ✅ |

### 📄 FACTURAS
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/facturas/` | Listar facturas | ✅ |
| GET | `/api/facturas/{id}` | Obtener factura por ID | ✅ |
| POST | `/api/facturas/create` | Crear factura | ✅ |
| PUT | `/api/facturas/{id}/update` | Actualizar factura | ✅ |
| DELETE | `/api/facturas/{id}/delete` | Eliminar factura | ✅ |

### 🔨 TRABAJOS
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/trabajos/` | Listar trabajos | ✅ |
| GET | `/api/trabajos/{id}` | Obtener trabajo por ID | ✅ |
| GET | `/api/trabajos/detalle/{id}` | Obtener detalle completo de trabajo | ✅ |
| POST | `/api/trabajos/create` | Crear trabajo | ✅ |
| PUT | `/api/trabajos/{id}/update` | Actualizar trabajo | ✅ |
| DELETE | `/api/trabajos/{id}/delete` | Eliminar trabajo | ✅ |

### 📦 INSUMOS
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/insumos/` | Listar insumos | ✅ |
| GET | `/api/insumos/{id}` | Obtener insumo por ID | ✅ |
| POST | `/api/insumos/create` | Crear insumo | ✅ |
| PUT | `/api/insumos/{id}/update` | Actualizar insumo | ✅ |
| DELETE | `/api/insumos/{id}/delete` | Eliminar insumo | ✅ |

### 🔧 MANTENIMIENTOS
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/mantenimientos/` | Listar mantenimientos | ✅ |
| GET | `/api/mantenimientos/{id}` | Obtener mantenimiento por ID | ✅ |
| POST | `/api/mantenimientos/create` | Crear mantenimiento | ✅ |
| PUT | `/api/mantenimientos/{id}/update` | Actualizar mantenimiento | ✅ |
| DELETE | `/api/mantenimientos/{id}/delete` | Eliminar mantenimiento | ✅ |

### 💳 CRÉDITOS
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/creditos/` | Listar créditos | ✅ |
| GET | `/api/creditos/{id}` | Obtener crédito por ID | ✅ |
| POST | `/api/creditos/create` | Crear crédito | ✅ |
| PUT | `/api/creditos/{id}/update` | Actualizar crédito | ✅ |
| DELETE | `/api/creditos/{id}/delete` | Eliminar crédito | ✅ |

### 💸 CUOTAS DE CRÉDITO
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/cuotas-credito/` | Listar cuotas de crédito | ✅ |
| GET | `/api/cuotas-credito/{id}` | Obtener cuota por ID | ✅ |
| POST | `/api/cuotas-credito/create` | Crear cuota | ✅ |
| PUT | `/api/cuotas-credito/{id}/update` | Actualizar cuota | ✅ |
| DELETE | `/api/cuotas-credito/{id}/delete` | Eliminar cuota | ✅ |

### 💵 MOVIMIENTOS
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/movimientos/` | Listar movimientos | ✅ |
| GET | `/api/movimientos/{id}` | Obtener movimiento por ID | ✅ |
| POST | `/api/movimientos/create` | Crear movimiento | ✅ |
| PUT | `/api/movimientos/{id}/update` | Actualizar movimiento | ✅ |
| DELETE | `/api/movimientos/{id}/delete` | Eliminar movimiento | ✅ |

### 🏷️ TIPOS DE TRABAJO
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/tipo-trabajo/` | Listar tipos de trabajo | ✅ |
| GET | `/api/tipo-trabajo/{id}` | Obtener tipo de trabajo por ID | ✅ |
| POST | `/api/tipo-trabajo/create` | Crear tipo de trabajo | ✅ |
| PUT | `/api/tipo-trabajo/{id}/update` | Actualizar tipo de trabajo | ✅ |
| DELETE | `/api/tipo-trabajo/{id}/delete` | Eliminar tipo de trabajo | ✅ |

### 💰 PAGOS
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/pagos/` | Listar pagos | ✅ |
| GET | `/api/pagos/{id}` | Obtener pago por ID | ✅ |
| POST | `/api/pagos/create` | Crear pago | ✅ |
| PUT | `/api/pagos/{id}/update` | Actualizar pago | ✅ |
| DELETE | `/api/pagos/{id}/delete` | Eliminar pago | ✅ |

### 📱 ENDPOINTS FLUTTER OPTIMIZADOS
| Método | Endpoint | Descripción | Auth | Parámetros |
|--------|----------|-------------|------|------------|
| GET | `/api/flutter/trabajos/lista` | Lista optimizada de trabajos | ✅ | skip, limit, estado |
| GET | `/api/flutter/campos/lista` | Lista optimizada de campos | ✅ | - |
| GET | `/api/flutter/maquinas/lista` | Lista optimizada de máquinas | ✅ | - |
| GET | `/api/flutter/personal/lista` | Lista optimizada de personal | ✅ | - |
| GET | `/api/flutter/clientes/lista` | Lista optimizada de clientes | ✅ | - |
| GET | `/api/flutter/costos/lista` | Lista optimizada de costos | ✅ | categoria, pagado |
| GET | `/api/flutter/facturas/lista` | Lista optimizada de facturas | ✅ | estado |
| GET | `/api/flutter/dashboard/resumen` | Resumen del dashboard | ✅ | - |

### 📊 DASHBOARD
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/dashboard/resumen` | Resumen general del dashboard | ✅ |
| GET | `/api/dashboard/estadisticas` | Estadísticas generales | ✅ |

### 📈 REPORTES
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/reportes/trabajos` | Reporte de trabajos | ✅ |
| GET | `/api/reportes/financiero` | Reporte financiero | ✅ |

### 📱 MÓVIL
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/mobile/sync` | Sincronización móvil | ✅ |
| POST | `/api/mobile/sync` | Enviar datos desde móvil | ✅ |

### 🏥 HEALTH CHECK
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/health/` | Verificar salud del servidor | ❌ |

---

## 🔄 REQUESTS CON AUTHORIZATION

### Cómo funciona la autenticación:

1. **Interceptor de autenticación** (`OptimizedHttpClient`):
   - Se ejecuta automáticamente en TODAS las peticiones
   - Excluye endpoints de autenticación y health check
   - Agrega el header: `Authorization: Bearer {token}`

2. **Orden de obtención del token:**
   - Primero intenta obtener el token del login (AuthService)
   - Si no hay token del login, usa el token fijo de AuthConfig
   - El token se almacena en FlutterSecureStorage

3. **Endpoints que NO requieren Authorization:**
   - `/api/auth/login/`
   - `/api/auth/register/`
   - `/api/auth/test/`
   - `/api/health/`

4. **Todos los demás endpoints SÍ requieren Authorization:**
   - Se agrega automáticamente el header `Authorization: Bearer {token}`
   - El token puede ser:
     - Token JWT obtenido del login
     - Token fijo configurado en SecurityConfig

---

## 📝 RESUMEN DE MÉTODOS HTTP

- **GET**: Obtener datos (listar, obtener por ID)
- **POST**: Crear nuevos recursos
- **PUT**: Actualizar recursos existentes
- **PATCH**: Actualización parcial (algunos endpoints usan PUT para esto)
- **DELETE**: Eliminar recursos

---

## 🔍 NOTAS IMPORTANTES

1. **URL Base:** Configurada en `lib/core/config/app_config.dart` y `lib/utils/constants.dart`
2. **Timeout:** 30 segundos por defecto
3. **Autenticación:** Automática mediante interceptor en `OptimizedHttpClient`
4. **Formato de datos:** JSON en todas las peticiones
5. **Paginación:** Algunos endpoints soportan `skip` y `limit` como query parameters

