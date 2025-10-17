# Documentación de Endpoints - Créditos y Cuotas

## 📋 Resumen
Este documento describe todos los endpoints disponibles para el ABM (Alta, Baja, Modificación) y consulta de créditos con sus respectivas cuotas en la API GesAgro.

---

## 🏦 **Endpoints para Créditos**

### **Base URL:** `/api/creditos`

| Método | Endpoint | Descripción | Permisos Requeridos |
|--------|----------|-------------|---------------------|
| `GET` | `/api/creditos/` | **Listar todos los créditos** (con paginación) | Contable, Administrador |
| `GET` | `/api/creditos/{credito_id}` | **Obtener crédito específico** | Sin restricción |
| `POST` | `/api/creditos/` | **Crear nuevo crédito** | Contable, Administrador |
| `PUT` | `/api/creditos/{credito_id}` | **Modificar crédito existente** | Contable, Administrador |
| `DELETE` | `/api/creditos/{credito_id}` | **Eliminar crédito** | Contable, Administrador |

### **Parámetros de Consulta (GET /api/creditos/)**
- `skip` (int, opcional): Número de registros a omitir (default: 0)
- `limit` (int, opcional): Número máximo de registros a retornar (default: 100)

### **Ejemplos de Uso:**

#### **Listar créditos:**
```http
GET /api/creditos/?skip=0&limit=10
```

#### **Obtener crédito específico:**
```http
GET /api/creditos/1
```

#### **Crear nuevo crédito:**
```http
POST /api/creditos/
Content-Type: application/json

{
  "entidad": "Banco Santander",
  "monto_otorgado": 500000.00,
  "tasa_interes_anual": 12.5,
  "plazo_meses": 24,
  "fecha_desembolso": "2024-01-15",
  "estado": "Activo"
}
```

#### **Modificar crédito:**
```http
PUT /api/creditos/1
Content-Type: application/json

{
  "estado": "Finalizado",
  "tasa_interes_anual": 11.0
}
```

#### **Eliminar crédito:**
```http
DELETE /api/creditos/1
```

---

## 💰 **Endpoints para Cuotas de Crédito**

### **Base URL:** `/api/cuotas-credito`

| Método | Endpoint | Descripción | Permisos Requeridos |
|--------|----------|-------------|---------------------|
| `GET` | `/api/cuotas-credito/` | **Listar todas las cuotas** (con paginación) | Contable, Administrador |
| `GET` | `/api/cuotas-credito/{cuota_id}` | **Obtener cuota específica** | Sin restricción |
| `POST` | `/api/cuotas-credito/` | **Crear nueva cuota** | Contable, Administrador |
| `PUT` | `/api/cuotas-credito/{cuota_id}` | **Modificar cuota existente** | Contable, Administrador |
| `DELETE` | `/api/cuotas-credito/{cuota_id}` | **Eliminar cuota** | Contable, Administrador |

### **Parámetros de Consulta (GET /api/cuotas-credito/)**
- `skip` (int, opcional): Número de registros a omitir (default: 0)
- `limit` (int, opcional): Número máximo de registros a retornar (default: 100)

### **Ejemplos de Uso:**

#### **Listar cuotas:**
```http
GET /api/cuotas-credito/?skip=0&limit=20
```

#### **Obtener cuota específica:**
```http
GET /api/cuotas-credito/1
```

#### **Crear nueva cuota:**
```http
POST /api/cuotas-credito/
Content-Type: application/json

{
  "id_credito": 1,
  "numero_cuota": 1,
  "fecha_vencimiento": "2024-02-15",
  "monto_total": 25000.00,
  "estado": "Pendiente"
}
```

#### **Modificar cuota:**
```http
PUT /api/cuotas-credito/1
Content-Type: application/json

{
  "estado": "Pagada",
  "monto_total": 25000.00
}
```

#### **Eliminar cuota:**
```http
DELETE /api/cuotas-credito/1
```

---

## 📊 **Estructura de Datos**

### **Modelo Crédito:**
```json
{
  "id": 1,
  "entidad": "Banco Santander",
  "monto_otorgado": 500000.00,
  "tasa_interes_anual": 12.5,
  "plazo_meses": 24,
  "fecha_desembolso": "2024-01-15",
  "estado": "Activo"
}
```

**Campos:**
- `id` (int): Identificador único del crédito
- `entidad` (string): Nombre de la entidad financiera
- `monto_otorgado` (decimal): Monto total del crédito otorgado
- `tasa_interes_anual` (float): Tasa de interés anual en porcentaje
- `plazo_meses` (int): Plazo del crédito en meses
- `fecha_desembolso` (date): Fecha de desembolso del crédito
- `estado` (string): Estado actual del crédito

### **Modelo Cuota de Crédito:**
```json
{
  "id": 1,
  "id_credito": 1,
  "numero_cuota": 1,
  "fecha_vencimiento": "2024-02-15",
  "monto_total": 25000.00,
  "estado": "Pendiente"
}
```

**Campos:**
- `id` (int): Identificador único de la cuota
- `id_credito` (int): ID del crédito al que pertenece la cuota
- `numero_cuota` (int): Número de cuota dentro del crédito
- `fecha_vencimiento` (date): Fecha de vencimiento de la cuota
- `monto_total` (decimal): Monto total a pagar en la cuota
- `estado` (string): Estado actual de la cuota

---

## 🔐 **Sistema de Permisos**

### **Roles con Acceso Completo:**
- **Contable**: Puede realizar todas las operaciones CRUD
- **Administrador**: Puede realizar todas las operaciones CRUD

### **Operaciones Sin Restricción:**
- Consulta individual de créditos (`GET /api/creditos/{id}`)
- Consulta individual de cuotas (`GET /api/cuotas-credito/{id}`)

---

## 📝 **Esquemas de Request/Response**

### **CreditoCreate (POST):**
```json
{
  "entidad": "string",
  "monto_otorgado": "number",
  "tasa_interes_anual": "number",
  "plazo_meses": "integer",
  "fecha_desembolso": "date",
  "estado": "string"
}
```

### **CreditoUpdate (PUT):**
```json
{
  "entidad": "string (opcional)",
  "monto_otorgado": "number (opcional)",
  "tasa_interes_anual": "number (opcional)",
  "plazo_meses": "integer (opcional)",
  "fecha_desembolso": "date (opcional)",
  "estado": "string (opcional)"
}
```

### **CuotaCreditoCreate (POST):**
```json
{
  "id_credito": "integer",
  "numero_cuota": "integer",
  "fecha_vencimiento": "date",
  "monto_total": "number",
  "estado": "string"
}
```

### **CuotaCreditoUpdate (PUT):**
```json
{
  "id_credito": "integer (opcional)",
  "numero_cuota": "integer (opcional)",
  "fecha_vencimiento": "date (opcional)",
  "monto_total": "number (opcional)",
  "estado": "string (opcional)"
}
```

---

## ⚠️ **Códigos de Respuesta HTTP**

| Código | Descripción |
|--------|-------------|
| `200` | Operación exitosa |
| `201` | Recurso creado exitosamente |
| `400` | Error en la solicitud (datos inválidos) |
| `401` | No autorizado (token inválido) |
| `403` | Prohibido (permisos insuficientes) |
| `404` | Recurso no encontrado |
| `422` | Error de validación de datos |
| `500` | Error interno del servidor |

---

## 🔍 **Endpoints Adicionales Relacionados**

### **Dashboard:**
- `/api/dashboard/` - Incluye métricas de cuotas vencidas

### **Mobile:**
- Endpoints móviles incluyen información de cuotas vencidas

---

## 📋 **Estados Válidos**

### **Estados de Crédito:**
- `Activo`
- `Finalizado`
- `Cancelado`
- `Suspendido`

### **Estados de Cuota:**
- `Pendiente`
- `Pagada`
- `Vencida`
- `Cancelada`

---

## 🚀 **Ejemplos de Integración**

### **Flujo Completo - Crear Crédito y Cuotas:**

1. **Crear el crédito:**
```bash
curl -X POST "http://localhost:8080/api/creditos/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "entidad": "Banco Santander",
    "monto_otorgado": 500000.00,
    "tasa_interes_anual": 12.5,
    "plazo_meses": 24,
    "fecha_desembolso": "2024-01-15",
    "estado": "Activo"
  }'
```

2. **Crear las cuotas (ejemplo para cuota 1):**
```bash
curl -X POST "http://localhost:8080/api/cuotas-credito/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "id_credito": 1,
    "numero_cuota": 1,
    "fecha_vencimiento": "2024-02-15",
    "monto_total": 25000.00,
    "estado": "Pendiente"
  }'
```

3. **Consultar crédito con sus cuotas:**
```bash
# Obtener crédito
curl -X GET "http://localhost:8080/api/creditos/1"

# Obtener cuotas del crédito
curl -X GET "http://localhost:8080/api/cuotas-credito/?skip=0&limit=100"
```

---

## 📚 **Notas Técnicas**

1. **Relación**: Las cuotas están relacionadas con créditos mediante `id_credito`
2. **Paginación**: Todos los endpoints de listado soportan paginación
3. **Validación**: Los endpoints incluyen validación de existencia antes de operaciones de modificación/eliminación
4. **Transacciones**: Las operaciones de creación y modificación son transaccionales
5. **Auditoría**: Se recomienda implementar logs de auditoría para operaciones críticas

---

*Documentación generada para GesAgro API v1.0.0*
