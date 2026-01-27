# GesAgro API Reference

Este documento proporciona un resumen de los endpoints de la API disponibles para el backend de GesAgro.

**Nota:** Para los endpoints `POST` y `PUT`, los campos exactos requeridos pueden variar según la configuración del serializador. Los ejemplos a continuación se basan en los campos principales del modelo.

---

## Autenticación y Salud del Sistema

### Registrar Usuario
- **Endpoint:** `POST /auth/register/`
- **Descripción:** Registra un nuevo usuario en el sistema.
- **Cuerpo de la Solicitud (JSON):**
  ```json
  {
    "email": "user@example.com",
    "password": "yoursecurepassword",
    "nombre": "Nombre Apellido"
  }
  ```
- **Respuesta Exitosa (201 Created):**
  ```json
  {
    "id": 1,
    "email": "user@example.com",
    "nombre": "Nombre Apellido",
    "rol": "Operario"
  }
  ```

### Iniciar Sesión
- **Endpoint:** `POST /auth/login/`
- **Descripción:** Autentica a un usuario y devuelve tokens de acceso y refresco.
- **Cuerpo de la Solicitud (JSON):**
  ```json
  {
    "email": "user@example.com",
    "password": "yoursecurepassword"
  }
  ```
- **Respuesta Exitosa (200 OK):**
  ```json
  {
    "refresh": "ey...",
    "access": "ey..."
  }
  ```

### Cerrar Sesión
- **Endpoint:** `POST /auth/logout/`
- **Descripción:** Invalida el token de refresco del usuario. Requiere autenticación.
- **Cuerpo de la Solicitud (JSON):**
  ```json
  {
    "refresh": "ey..."
  }
  ```
- **Respuesta Exitosa (200 OK):**
  ```json
  {
    "detail": "Logout successful"
  }
  ```

### Actualizar Contraseña
- **Endpoint:** `POST /auth/update-password/`
- **Descripción:** Permite a un usuario autenticado cambiar su contraseña.
- **Cuerpo de la Solicitud (JSON):**
  ```json
  {
    "old_password": "currentpassword",
    "new_password": "newsecurepassword"
  }
  ```
- **Respuesta Exitosa (200 OK):**
  ```json
  {
    "status": "password set successfully"
  }
  ```

### Health Check
- **Endpoint:** `GET /health/`
- **Descripción:** Endpoint de prueba para verificar que el servidor está funcionando.
- **Respuesta Exitosa (200 OK):**
  ```json
  {
    "status": "ok"
  }
  ```

---

## CRUD Genérico

Para los siguientes recursos (Usuarios, Campos, Clientes, etc.), el patrón de endpoints es generalmente el mismo.

- `GET /{recurso}/`: Lista todos los objetos.
- `GET /{recurso}/{id}/`: Obtiene un objeto específico.
- `POST /{recurso}/create/`: Crea un nuevo objeto.
- `PUT /{recurso}/{id}/update/`: Actualiza un objeto existente.
- `DELETE /{recurso}/{id}/delete/`: Elimina un objeto.

A continuación se detallan los cuerpos de solicitud para la creación (`POST`). La actualización (`PUT`) utiliza una estructura similar.

### Usuarios
- **Recurso:** `usuarios`
- **Cuerpo de Creación (JSON):**
  ```json
  {
    "nombre": "Nombre Apellido",
    "email": "operario@example.com",
    "password": "securepassword",
    "rol": "Operario",
    "telefono": "123456789"
  }
  ```

### Campos
- **Recurso:** `campos`
- **Cuerpo de Creación (JSON):**
  ```json
  {
    "nombre": "Campo Norte",
    "hectareas": 150.5,
    "latitud": -34.6037,
    "longitud": -58.3816,
    "detalles": "Campo principal.",
    "propio": true,
    "cliente_id": null
  }
  ```

### Clientes
- **Recurso:** `clientes`
- **Cuerpo de Creación (JSON):**
  ```json
  {
    "nombre": "Cliente Agro S.A.",
    "email": "contacto@clienteagro.com",
    "telefono": "987654321",
    "direccion": "Calle Falsa 123",
    "cuit": "30-12345678-9",
    "observaciones": "Cliente importante."
  }
  ```

### Máquinas
- **Recurso:** `maquinas`
- **Cuerpo de Creación (JSON):**
  ```json
  {
    "nombre": "Cosechadora 01",
    "marca": "John Deere",
    "modelo": "S780",
    "ano": 2022,
    "detalles": "Cosechadora de alto rendimiento.",
    "ancho_trabajo": 9.15
  }
  ```

### Personal
- **Recurso:** `personal`
- **Cuerpo de Creación (JSON):**
  ```json
  {
    "nombre": "Juan Perez",
    "dni": "12345678",
    "telefono": "1122334455"
  }
  ```
- **Endpoint Adicional:** `POST /personal/validate-dni/` para verificar si un DNI ya existe.

### Trabajos
- **Recurso:** `trabajos`
- **Cuerpo de Creación (JSON):**
  ```json
  {
    "id_tipo_trabajo": 1,
    "cultivo": "Soja",
    "fecha_inicio": "2024-10-01",
    "campo": 1,
    "estado": "Pendiente",
    "observaciones": "Siembra de soja.",
    "personal": [1, 2],
    "maquinas": [1]
  }
  ```
- **Endpoint Adicional:** `POST /trabajos/registrar-horas/` para registrar horas en un trabajo.

### Tipo de Trabajo
- **Recurso:** `tipo-trabajo`
- **Cuerpo de Creación (JSON):**
  ```json
  {
    "trabajo": "Siembra"
  }
  ```

### Costos
- **Recurso:** `costos`
- **Cuerpo de Creación (JSON):**
  ```json
  {
    "monto": 5000.00,
    "fecha": "2024-09-15",
    "destinatario": "Proveedor de Insumos",
    "descripcion": "Compra de semillas.",
    "categoria": "Insumos",
    "es_cobro": false,
    "id_trabajo": 1
  }
  ```

### Facturas
- **Recurso:** `facturas`
- **Cuerpo de Creación (JSON):**
  ```json
  {
    "cliente": 1,
    "numero": "FC-001-000123",
    "fecha_emision": "2024-11-01",
    "fecha_vencimiento": "2024-12-01",
    "monto_total": 12100.00,
    "estado": "Pendiente",
    "items": [
      {
        "descripcion": "Servicio de Siembra - Campo Norte",
        "cantidad": 1,
        "precio_unitario": 10000.00
      }
    ]
  }
  ```

### Insumos
- **Recurso:** `insumos`
- **Cuerpo de Creación (JSON):**
  ```json
  {
    "nombre": "Semilla de Soja",
    "categoria": "Semillas",
    "unidad": "Bolsa",
    "stock_actual": 100,
    "stock_minimo": 20,
    "precio_unitario": 50.00,
    "proveedor": "AgroProveedor S.R.L."
  }
  ```

---

## Endpoints Específicos

### Asignación de Campos a Clientes
- **Recurso:** `campos-cliente`
- **Endpoint:** `POST /campos-cliente/create/`
- **Cuerpo (JSON):**
  ```json
  {
    "cliente": 1,
    "campo": 2,
    "observaciones": "Campo arrendado."
  }
  ```
- **Endpoint Adicional:** `POST /campos-cliente/{id}/desactivar/` para marcar una asignación como inactiva.

### Endpoints Optimizados para Flutter
Estos endpoints devuelven listas de datos optimizadas para vistas en la aplicación móvil. Todos usan el método `GET`.
- `/flutter/trabajos/lista/`
- `/flutter/campos/lista/`
- `/flutter/maquinas/lista/`
- `/flutter/personal/lista/`
- `/flutter/clientes/lista/`
- `/flutter/costos/lista/`
- `/flutter/facturas/lista/`
- `/flutter/dashboard/resumen/`

### Dashboard y Reportes
Endpoints que devuelven datos agregados. Todos usan el método `GET`.
- `/dashboard/resumen/`
- `/dashboard/estadisticas/`
- `/reportes/trabajos/`
- `/reportes/financiero/`

### Sincronización Móvil
- **Endpoint:** `POST /mobile/sync/`
- **Descripción:** Endpoint genérico para la sincronización de datos con dispositivos móviles. El cuerpo de la solicitud y la respuesta dependen de la lógica de sincronización implementada.

### WhatsApp Webhook
- **Endpoint:** `POST /whatsapp/webhook/`
- **Descripción:** Recibe notificaciones y mensajes entrantes desde la API de Twilio para WhatsApp.
- **Cuerpo de la Solicitud:** El formato es definido por Twilio.
