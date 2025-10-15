# 📋 **Servicio ClienteService Actualizado**

## 🔗 **Endpoints Implementados**

### **Gestión de Clientes:**
- `GET /clientes/` - Listar todos los clientes
- `GET /clientes/{id}` - Obtener cliente por ID
- `POST /clientes/` - Crear nuevo cliente
- `PUT /clientes/{id}` - Actualizar cliente
- `DELETE /clientes/{id}` - Eliminar cliente

### **Gestión de Asignaciones Campos-Cliente:**
- `GET /campos-cliente/` - Listar todas las asignaciones
- `GET /campos-cliente/{asignacion_id}` - Obtener asignación por ID
- `POST /campos-cliente/` - Crear nueva asignación
- `PUT /campos-cliente/{asignacion_id}` - Actualizar asignación
- `DELETE /campos-cliente/{asignacion_id}` - Eliminar asignación (hard delete)
- `PATCH /campos-cliente/{asignacion_id}/desactivar` - Desactivar asignación (soft delete)

### **Filtros Especiales:**
- `GET /campos-cliente/?cliente_id={id}` - Obtener campos asignados a un cliente específico

## 📊 **Estructura de Respuesta**

```json
[
  {
    "id": 1,
    "nombre": "Campo Norte",
    "superficie_ha": 25.5,
    "latitud": -34.123456,
    "longitud": -58.789012,
    "detalles": "Campo con riego por goteo",
    "fecha_asignacion": "2024-01-15T10:30:00",
    "observaciones": "Asignado para temporada 2024",
    "activo": true
  }
]
```

## 🚀 **Métodos del Servicio**

### **1. Gestión de Clientes:**
```dart
// Obtener todos los clientes
List<Cliente> clientes = await ClienteService.getClientes();

// Obtener cliente específico
Cliente cliente = await ClienteService.getCliente(1);

// Crear nuevo cliente
Cliente nuevoCliente = await ClienteService.createCliente({
  'nombre': 'Nuevo Cliente S.A.',
  'email': 'contacto@nuevocliente.com',
  'telefono': '+54 11 1234-5678',
  'direccion': 'Av. Principal 123',
  'cuit': '30-12345678-9',
  'observaciones': 'Cliente nuevo'
});

// Actualizar cliente
Cliente clienteActualizado = await ClienteService.updateCliente(1, {
  'nombre': 'Cliente Actualizado S.A.',
  'email': 'nuevo@cliente.com'
});

// Eliminar cliente
await ClienteService.deleteCliente(1);
```

### **2. Gestión de Asignaciones:**
```dart
// Obtener campos de un cliente específico
List<Campo> camposCliente = await ClienteService.getCamposByCliente(1);

// Obtener todas las asignaciones
List<Map<String, dynamic>> asignaciones = await ClienteService.getAsignaciones();

// Obtener asignación específica
Map<String, dynamic> asignacion = await ClienteService.getAsignacion(1);

// Asignar campo a cliente
Map<String, dynamic> nuevaAsignacion = await ClienteService.asignarCampoACliente(
  1, // clienteId
  2, // campoId
  observaciones: 'Asignación para temporada 2024'
);

// Actualizar asignación
Map<String, dynamic> asignacionActualizada = await ClienteService.actualizarAsignacion(1, {
  'observaciones': 'Observaciones actualizadas',
  'activo': true
});

// Desactivar asignación (soft delete)
await ClienteService.desactivarAsignacion(1);

// Eliminar asignación (hard delete)
await ClienteService.eliminarAsignacion(1);

// Desasignar campo de cliente (busca y desactiva)
await ClienteService.desasignarCampoDeCliente(1, 2);
```

## 🔄 **Flujo de Trabajo en el Formulario**

### **1. Trabajo Propio (a_terceros = false):**
```dart
// Mostrar todos los campos propios
_camposFiltrados = List.from(_campos);
```

### **2. Trabajo a Terceros (a_terceros = true):**
```dart
// 1. Usuario selecciona cliente
_clienteSeleccionado = cliente;

// 2. Filtrar campos del cliente seleccionado
_camposFiltrados = await ClienteService.getCamposByCliente(cliente.id!);

// 3. Mostrar solo campos asignados a ese cliente
```

## 📝 **Datos Enviados al Backend**

```dart
final data = {
  'tipo': _tipoController.text,
  'cultivo': _cultivoController.text,
  'observaciones': _descripcionController.text,
  'cliente': _esTercero && _clienteSeleccionado != null 
      ? _clienteSeleccionado!.nombre 
      : (_esTercero ? 'Cliente no seleccionado' : 'Trabajo propio'),
  'estado': _estadoSeleccionado ?? 'Pendiente',
  'a_terceros': _esTercero,
  'cobrado': _cobrado,
  'monto_cobrado': _cobrado && _montoCobradoController.text.isNotEmpty 
      ? double.tryParse(_montoCobradoController.text) 
      : null,
  'fecha_inicio': _fechaInicio?.toIso8601String().split('T')[0],
  'fecha_fin': _fechaFin?.toIso8601String().split('T')[0],
  'campo_id': _campoSeleccionado?.id ?? 1,
  'maquina_ids': _maquinasSeleccionadas.map((m) => m.id).toList(),
  'personal_ids': _personalSeleccionado.map((p) => p.id).toList(),
};
```

## ✅ **Funcionalidades Implementadas**

- ✅ **Selector de cliente** con dropdown
- ✅ **Filtrado dinámico** de campos por cliente
- ✅ **Validaciones contextuales** según tipo de trabajo
- ✅ **Limpieza automática** de selecciones
- ✅ **Métodos CRUD completos** para clientes y asignaciones
- ✅ **Soft delete** para asignaciones
- ✅ **Manejo de errores** robusto
- ✅ **Logging detallado** para debugging

## 🎯 **Próximos Pasos Sugeridos**

1. **Crear pantallas de gestión de clientes** (listado, formulario, detalles)
2. **Implementar pantalla de asignaciones** campos-cliente
3. **Agregar navegación** al menú principal
4. **Implementar búsqueda y filtros** en listados
5. **Agregar validaciones** adicionales en el backend
