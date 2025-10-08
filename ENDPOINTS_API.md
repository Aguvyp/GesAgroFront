# GesAgro API - Documentación de Endpoints

Esta documentación contiene todos los endpoints disponibles en la API de GesAgro con ejemplos de request para cada uno.

## Base URL
```
http://localhost:8080
```

## Autenticación
La mayoría de endpoints requieren autenticación mediante JWT token. Incluir en el header:
```
Authorization: Bearer <token>
```

---

## 🔐 Autenticación (`/auth`)

### POST `/auth/login`
Iniciar sesión y obtener token de acceso.

**Request:**
```json
{
  "email": "usuario@ejemplo.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "role": "Administrador"
}
```

### POST `/auth/register`
Registrar nuevo usuario.

**Request:**
```json
{
  "nombre": "Juan Pérez",
  "dni": "12345678",
  "telefono": "+5491123456789",
  "email": "juan@ejemplo.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "message": "Usuario registrado exitosamente",
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "role": "Usuario",
  "personal_id": 1,
  "usuario_id": 1
}
```

### GET `/auth/test`
Endpoint de prueba sin autenticación.

**Response:**
```json
{
  "message": "API funcionando correctamente",
  "status": "ok"
}
```

---

## 👥 Usuarios (`/usuarios`)

### GET `/usuarios/`
Obtener lista de usuarios.

**Query Parameters:**
- `skip` (int, opcional): Número de registros a omitir (default: 0)
- `limit` (int, opcional): Número máximo de registros (default: 100)

### POST `/usuarios/`
Crear nuevo usuario.

**Request:**
```json
{
  "email": "nuevo@ejemplo.com",
  "password": "password123",
  "role": "Usuario"
}
```

### GET `/usuarios/{usuario_id}`
Obtener usuario por ID.

### PUT `/usuarios/{usuario_id}`
Actualizar usuario.

**Request:**
```json
{
  "email": "actualizado@ejemplo.com",
  "role": "Administrador"
}
```

### DELETE `/usuarios/{usuario_id}`
Eliminar usuario.

---

## 🏞️ Campos (`/campos`)

### GET `/campos/`
Obtener lista de campos.

**Query Parameters:**
- `skip` (int, opcional): Número de registros a omitir (default: 0)
- `limit` (int, opcional): Número máximo de registros (default: 100)

### GET `/campos/{campo_id}`
Obtener campo por ID.

### POST `/campos/`
Crear nuevo campo.

**Request:**
```json
{
  "nombre": "Campo Norte",
  "superficie_ha": 25.5,
  "latitud": -34.6037,
  "longitud": -58.3816,
  "detalles": "Campo con riego por aspersión"
}
```

### PUT `/campos/{campo_id}`
Actualizar campo.

**Request:**
```json
{
  "nombre": "Campo Norte Actualizado",
  "superficie_ha": 30.0,
  "detalles": "Campo con riego por goteo"
}
```

### DELETE `/campos/{campo_id}`
Eliminar campo.

---

## 🚜 Máquinas (`/maquinas`)

### GET `/maquinas/`
Obtener lista de máquinas.

### GET `/maquinas/{maquina_id}`
Obtener máquina por ID.

### POST `/maquinas/`
Crear nueva máquina.

**Request:**
```json
{
  "nombre": "Tractor John Deere",
  "marca": "John Deere",
  "modelo": "6120R",
  "anio": 2020,
  "ancho_trabajo": 3.5,
  "detalles": "Tractor con cabina climatizada"
}
```

### PUT `/maquinas/{maquina_id}`
Actualizar máquina.

**Request:**
```json
{
  "nombre": "Tractor John Deere Actualizado",
  "ancho_trabajo": 4.0
}
```

### DELETE `/maquinas/{maquina_id}`
Eliminar máquina.

---

## 👷 Personal (`/personal`)

### GET `/personal/`
Obtener lista de personal.

### GET `/personal/{personal_id}`
Obtener personal por ID.

### POST `/personal/`
Crear nuevo personal.

**Request:**
```json
{
  "nombre": "María González",
  "dni": "87654321",
  "telefono": "+5491123456789"
}
```

### PUT `/personal/{personal_id}`
Actualizar personal.

**Request:**
```json
{
  "nombre": "María González Actualizada",
  "telefono": "+5491123456780"
}
```

### DELETE `/personal/{personal_id}`
Eliminar personal.

### GET `/personal/validate-dni`
Validar disponibilidad de DNI.

**Query Parameters:**
- `dni` (string, requerido): DNI a validar
- `exclude_id` (int, opcional): ID a excluir de la validación

**Response:**
```json
{
  "available": true
}
```

---

## 👥 Clientes (`/clientes`)

### GET `/clientes/`
Obtener lista de clientes.

### GET `/clientes/{cliente_id}`
Obtener cliente por ID.

### POST `/clientes/`
Crear nuevo cliente.

**Request:**
```json
{
  "nombre_razon_social": "Agro S.A.",
  "cuit": "20-12345678-9",
  "direccion": "Av. Principal 123",
  "telefono": "+5491123456789",
  "email": "contacto@agro.com"
}
```

### PUT `/clientes/{cliente_id}`
Actualizar cliente.

**Request:**
```json
{
  "nombre_razon_social": "Agro S.A. Actualizada",
  "email": "nuevo@agro.com"
}
```

### DELETE `/clientes/{cliente_id}`
Eliminar cliente.

---

## 💰 Costos (`/costos`)

### GET `/costos/`
Obtener lista de costos.

### GET `/costos/{costo_id}`
Obtener costo por ID.

### POST `/costos/`
Crear nuevo costo.

**Request:**
```json
{
  "descripcion": "Compra de semillas",
  "monto": 15000.50,
  "fecha": "2024-01-15",
  "destinatario": "Semillas del Sur",
  "pagado": false,
  "forma_pago": "Transferencia",
  "categoria": "Insumos",
  "es_cobro": false,
  "cobrar_a": null,
  "fecha_pago_limite": "2024-02-15",
  "id_trabajo": 1
}
```

### PUT `/costos/{costo_id}`
Actualizar costo.

**Request:**
```json
{
  "pagado": true,
  "fecha_pago_limite": "2024-01-20"
}
```

### DELETE `/costos/{costo_id}`
Eliminar costo.

### GET `/costos/pagados/`
Obtener solo costos pagados.

### GET `/costos/pendientes/`
Obtener solo costos pendientes de pago.

---

## 📄 Facturas (`/facturas`)

### GET `/facturas/`
Obtener lista de facturas.
*Requiere roles: Contable, Administrador*

### GET `/facturas/{factura_id}`
Obtener factura por ID.
*Requiere roles: Contable, Administrador*

### POST `/facturas/`
Crear nueva factura.
*Requiere roles: Contable, Administrador*

**Request:**
```json
{
  "numero_factura": "FAC-001-2024",
  "fecha_emision": "2024-01-15",
  "fecha_vencimiento": "2024-02-15",
  "subtotal": 10000.00,
  "impuestos": 2100.00,
  "monto_total": 12100.00,
  "saldo_pendiente": 12100.00,
  "estado": "Borrador",
  "id_trabajo": 1,
  "id_cliente": 1
}
```

### PUT `/facturas/{factura_id}`
Actualizar factura.
*Requiere roles: Contable, Administrador*

**Request:**
```json
{
  "estado": "Enviada",
  "saldo_pendiente": 0.00
}
```

### DELETE `/facturas/{factura_id}`
Eliminar factura.
*Requiere roles: Contable, Administrador*

---

## 🔧 Trabajos (`/trabajos`)

### GET `/trabajos/`
Obtener lista de trabajos.

### GET `/trabajos/{trabajo_id}`
Obtener trabajo por ID.

### POST `/trabajos/`
Crear nuevo trabajo.

**Request:**
```json
{
  "tipo": "Siembra",
  "cultivo": "Soja",
  "cliente": "Cliente ABC",
  "estado": "En progreso",
  "a_terceros": false,
  "fecha_inicio": "2024-01-15",
  "fecha_fin": null,
  "campo_id": 1,
  "maquina_ids": [1, 2],
  "personal_ids": [1, 2]
}
```

### PUT `/trabajos/{trabajo_id}`
Actualizar trabajo.

**Request:**
```json
{
  "estado": "Completado",
  "fecha_fin": "2024-01-20"
}
```

### DELETE `/trabajos/{trabajo_id}`
Eliminar trabajo.

---

## 📦 Insumos (`/insumos`)

### GET `/insumos/`
Obtener lista de insumos.

### GET `/insumos/{insumo_id}`
Obtener insumo por ID.

### POST `/insumos/`
Crear nuevo insumo.

**Request:**
```json
{
  "nombre": "Herbicida Glifosato",
  "descripcion": "Herbicida sistémico",
  "unidad": "Litros",
  "precio_unitario": 2500.00,
  "stock_actual": 100,
  "stock_minimo": 20
}
```

### PUT `/insumos/{insumo_id}`
Actualizar insumo.

### DELETE `/insumos/{insumo_id}`
Eliminar insumo.

---

## 📱 Flutter (`/flutter`)

### GET `/flutter/trabajos/lista`
Lista de trabajos optimizada para Flutter.

**Query Parameters:**
- `skip` (int, opcional): Número de registros a omitir (default: 0)
- `limit` (int, opcional): Número máximo de registros (default: 50)
- `estado` (string, opcional): Filtrar por estado

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "tipo": "Siembra",
      "cultivo": "Soja",
      "cliente": "Cliente ABC",
      "estado": "En progreso",
      "a_terceros": false,
      "fecha_inicio": "2024-01-15T00:00:00",
      "fecha_fin": null,
      "campo": {
        "id": 1,
        "nombre": "Campo Norte",
        "superficie_ha": 25.5
      },
      "maquinas": [
        {
          "id": 1,
          "nombre": "Tractor John Deere",
          "marca": "John Deere",
          "modelo": "6120R"
        }
      ],
      "personal": [
        {
          "id": 1,
          "nombre": "María González",
          "dni": "87654321",
          "telefono": "+5491123456789"
        }
      ]
    }
  ],
  "pagination": {
    "skip": 0,
    "limit": 50,
    "total": 1
  }
}
```

### GET `/flutter/campos/lista`
Lista de campos optimizada para Flutter.

### GET `/flutter/maquinas/lista`
Lista de máquinas optimizada para Flutter.

### GET `/flutter/personal/lista`
Lista de personal optimizada para Flutter.

### GET `/flutter/clientes/lista`
Lista de clientes optimizada para Flutter.

### GET `/flutter/costos/lista`
Lista de costos optimizada para Flutter.

**Query Parameters:**
- `categoria` (string, opcional): Filtrar por categoría
- `pagado` (boolean, opcional): Filtrar por estado de pago

### GET `/flutter/facturas/lista`
Lista de facturas optimizada para Flutter.

**Query Parameters:**
- `estado` (string, opcional): Filtrar por estado

### GET `/flutter/dashboard/resumen`
Dashboard resumen optimizado para Flutter.

**Response:**
```json
{
  "success": true,
  "data": {
    "trabajos_activos": 5,
    "facturas_pendientes": 3,
    "ingresos_mes": 50000.00,
    "egresos_mes": 30000.00,
    "balance_mes": 20000.00,
    "fecha_actualizacion": "2024-01-15T10:30:00"
  }
}
```

---

## 📊 Dashboard (`/dashboard`)

### GET `/dashboard/resumen`
Obtener resumen del dashboard.

### GET `/dashboard/estadisticas`
Obtener estadísticas generales.

---

## 📈 Reportes (`/reportes`)

### GET `/reportes/trabajos`
Generar reporte de trabajos.

### GET `/reportes/financiero`
Generar reporte financiero.

---

## 🔧 Mantenimientos (`/mantenimientos`)

### GET `/mantenimientos/`
Obtener lista de mantenimientos.

### POST `/mantenimientos/`
Crear nuevo mantenimiento.

**Request:**
```json
{
  "maquina_id": 1,
  "tipo": "Preventivo",
  "descripcion": "Cambio de aceite",
  "fecha": "2024-01-15",
  "costo": 5000.00,
  "proximo_mantenimiento": "2024-04-15"
}
```

---

## 💳 Pagos (`/pagos`)

### GET `/pagos/`
Obtener lista de pagos.

### POST `/pagos/`
Crear nuevo pago.

**Request:**
```json
{
  "monto": 10000.00,
  "fecha": "2024-01-15",
  "metodo_pago": "Transferencia",
  "descripcion": "Pago a proveedor",
  "factura_id": 1
}
```

---

## 💰 Créditos (`/creditos`)

### GET `/creditos/`
Obtener lista de créditos.

### POST `/creditos/`
Crear nuevo crédito.

**Request:**
```json
{
  "cliente_id": 1,
  "monto": 50000.00,
  "fecha_inicio": "2024-01-15",
  "fecha_vencimiento": "2024-12-15",
  "tasa_interes": 12.5,
  "estado": "Activo"
}
```

---

## 📋 Cuotas de Crédito (`/cuotas-credito`)

### GET `/cuotas-credito/`
Obtener lista de cuotas de crédito.

### POST `/cuotas-credito/`
Crear nueva cuota de crédito.

**Request:**
```json
{
  "credito_id": 1,
  "numero_cuota": 1,
  "monto": 5000.00,
  "fecha_vencimiento": "2024-02-15",
  "fecha_pago": null,
  "estado": "Pendiente"
}
```

---

## 📦 Movimientos de Inventario (`/movimientos-inventario`)

### GET `/movimientos-inventario/`
Obtener lista de movimientos de inventario.

### POST `/movimientos-inventario/`
Crear nuevo movimiento de inventario.

**Request:**
```json
{
  "insumo_id": 1,
  "tipo": "Entrada",
  "cantidad": 50,
  "fecha": "2024-01-15",
  "descripcion": "Compra de insumo",
  "precio_unitario": 2500.00
}
```

---

## 📱 Mobile (`/mobile`)

### GET `/mobile/sync`
Sincronización para aplicación móvil.

### POST `/mobile/sync`
Enviar datos desde aplicación móvil.

---

## 🏠 Endpoints Raíz

### GET `/`
Endpoint raíz de la API.

**Response:**
```json
{
  "message": "Bienvenido a GesAgro API",
  "version": "1.0.0",
  "docs": "/docs",
  "redoc": "/redoc"
}
```

### GET `/health`
Endpoint de verificación de salud.

**Response:**
```json
{
  "status": "healthy"
}
```

---

## 📚 Documentación Interactiva

- **Swagger UI:** `http://localhost:8080/docs`
- **ReDoc:** `http://localhost:8080/redoc`

---

## 🔒 Notas de Seguridad

1. **Autenticación:** La mayoría de endpoints requieren token JWT válido
2. **Roles:** Algunos endpoints requieren roles específicos (Administrador, Contable)
3. **Validación:** Todos los datos de entrada son validados usando Pydantic
4. **CORS:** Configurado para permitir requests desde cualquier origen (ajustar en producción)

---

## 📝 Notas Importantes

1. **Formato de Fechas:** Usar formato ISO 8601 (`YYYY-MM-DD` o `YYYY-MM-DDTHH:MM:SS`)
2. **Paginación:** Usar parámetros `skip` y `limit` para paginación
3. **Respuestas:** Los endpoints de Flutter devuelven formato `{"success": true, "data": [...], "pagination": {...}}`
4. **Errores:** Los errores devuelven formato `{"detail": "mensaje de error"}`
5. **IDs:** Todos los IDs son enteros positivos
6. **Monedas:** Los montos se manejan como números decimales (float)
