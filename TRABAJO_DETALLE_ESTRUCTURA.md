# Estructura de Datos para Detalles de Trabajo

## Resumen

Esta documentación describe la estructura de datos optimizada para mostrar los detalles completos de un trabajo, adaptada a la respuesta de la API `/trabajos/detalle/{trabajo_id}`. Incluye información del campo, cliente completo, personal con sus hectáreas trabajadas y máquinas utilizadas.

## Endpoint de la API

### GET `/trabajos/detalle/{trabajo_id}`

Este endpoint devuelve toda la información estructurada de un trabajo específico en una sola llamada.

## Modelos de Datos

### 1. TrabajoDetalle

Modelo principal que contiene toda la información de un trabajo con sus relaciones completas.

```dart
class TrabajoDetalle {
  // Información básica del trabajo
  final int? id;
  final String tipo;
  final String cliente;
  final String cultivo;
  final String? observaciones;
  final String? estado;
  final bool aTerceros;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final int campoId;
  
  // Información del campo
  final Campo? campo;
  
  // Información completa del cliente
  final ClienteInfo? clienteInfo;
  
  // Máquinas utilizadas
  final List<MaquinaTrabajo> maquinas;
  
  // Personal con sus hectáreas trabajadas
  final List<PersonalTrabajo> personal;
  
  // Información de cobro
  final bool cobrado;
  final double? montoCobrado;
}
```

### 2. ClienteInfo

Modelo para información completa del cliente.

```dart
class ClienteInfo {
  final int id;
  final String nombreRazonSocial;
  final String cuit;
  final String direccion;
  final String telefono;
  final String email;
}
```

### 3. MaquinaTrabajo

Modelo para máquinas utilizadas en un trabajo específico.

```dart
class MaquinaTrabajo {
  final int id;
  final String nombre;
  final String marca;
  final String modelo;
}
```

### 4. PersonalTrabajo

Modelo para personal con sus hectáreas trabajadas en un trabajo específico.

```dart
class PersonalTrabajo {
  final int id;
  final String nombre;
  final String dni;
  final String? rol;
  final double ha; // Hectáreas trabajadas en este trabajo específico
}
```

## Estructura de Datos Esperada

### Respuesta de la API para `/trabajos/detalle/{trabajo_id}`

```json
{
  "id": 1,
  "tipo": "Siembra",
  "cliente": "Cliente Test SRL",
  "cultivo": "Maíz",
  "observaciones": "Trabajo de prueba para detalle completo",
  "estado": "Completado",
  "a_terceros": true,
  "fecha_inicio": "2025-01-21",
  "fecha_fin": "2025-01-21",
  "campo_id": 1,
  
  "campo": {
    "id": 1,
    "nombre": "Campo Norte",
    "superficie_ha": 100.5,
    "latitud": -34.6037,
    "longitud": -58.3816,
    "detalles": "Campo ubicado en zona norte"
  },
  
  "cliente_info": {
    "id": 1,
    "nombre_razon_social": "Cliente Test SRL",
    "cuit": "20-12345678-9",
    "direccion": "Av. Principal 123",
    "telefono": "011-1234-5678",
    "email": "cliente@test.com"
  },
  
  "maquinas": [
    {
      "id": 1,
      "nombre": "Tractor John Deere",
      "marca": "John Deere",
      "modelo": "6120R"
    },
    {
      "id": 2,
      "nombre": "Sembradora",
      "marca": "Agrometal",
      "modelo": "SX-3000"
    }
  ],
  
  "personal": [
    {
      "id": 1,
      "nombre": "Juan Pérez",
      "dni": "12345678",
      "rol": null,
      "ha": 25.5
    },
    {
      "id": 2,
      "nombre": "María García",
      "dni": "87654321",
      "rol": null,
      "ha": 30.0
    }
  ],
  
  "cobrado": true,
  "monto_cobrado": 25000.0
}
```

## Servicios

### TrabajoDetalleService

Servicio que maneja la obtención de detalles completos de trabajos usando el endpoint específico.

#### Métodos Principales

1. **getTrabajoDetalle(int trabajoId)**
   - Obtiene detalles completos de un trabajo específico usando `/trabajos/detalle/{trabajo_id}`
   - El endpoint devuelve toda la información estructurada en una sola llamada
   - Incluye campo, cliente completo, personal con hectáreas y máquinas

2. **getTrabajosDetalleOptimizado()**
   - Obtiene lista de trabajos con detalles de forma optimizada
   - Usa el endpoint específico para cada trabajo
   - Maneja errores individualmente para cada trabajo

## Providers (Riverpod)

### trabajoDetalleProvider
- Maneja el estado de un trabajo específico con detalles
- Incluye métodos para cargar y limpiar datos

### trabajosDetalleProvider
- Maneja el estado de la lista de trabajos con detalles
- Incluye métodos de filtrado y estadísticas
- Soporte para refresh y recarga de datos

## Widgets

### TrabajoDetalleWidget
Widget completo para mostrar todos los detalles de un trabajo.

**Características:**
- Información básica del trabajo
- Detalles del campo (nombre y hectáreas)
- Información del cliente
- Lista de operarios con sus hectáreas trabajadas
- Lista de máquinas utilizadas
- Manejo de estados de carga y error

### TrabajoDetalleCompacto
Widget compacto para mostrar información esencial.

**Características:**
- Información básica resumida
- Campo y cliente
- Operarios y máquinas (opcional)
- Ideal para listas y tarjetas

## Getters Útiles

### TrabajoDetalle
- `campoNombre`: Nombre del campo
- `campoHectareas`: Hectáreas del campo
- `campoInfo`: Información completa del campo
- `clienteNombre`: Nombre del cliente
- `clienteInfoCompleta`: Información completa del cliente con CUIT
- `totalPersonal`: Cantidad total de personal
- `totalHectareasPersonal`: Hectáreas totales trabajadas por personal
- `personalInfo`: Información resumida de personal
- `totalMaquinas`: Cantidad total de máquinas
- `maquinasInfo`: Información resumida de máquinas
- `trabajoInfo`: Información del tipo de trabajo (propio/terceros)
- `formattedDateRange`: Rango de fechas formateado
- `durationDays`: Duración en días

## Filtros Disponibles

### TrabajosDetalleNotifier
- `getTrabajosByEstado(String estado)`: Filtrar por estado
- `getTrabajosByTipo(String tipo)`: Filtrar por tipo
- `getTrabajosByCultivo(String cultivo)`: Filtrar por cultivo
- `getTrabajosByCampo(String campoNombre)`: Filtrar por campo
- `getTrabajosTerceros()`: Trabajos a terceros
- `getTrabajosPropios()`: Trabajos propios
- `getTrabajosCobrados()`: Trabajos cobrados
- `getTrabajosPendientesCobro()`: Trabajos pendientes de cobro

## Estadísticas

### getEstadisticas()
Retorna un mapa con estadísticas completas:

```dart
{
  'total': 25,
  'completados': 20,
  'en_curso': 3,
  'pendientes': 2,
  'terceros': 15,
  'propios': 10,
  'cobrados': 18,
  'pendientes_cobro': 7,
  'total_hectareas': 1250.5,
  'total_operarios': 45,
  'total_maquinas': 12,
}
```

## Ejemplo de Uso

```dart
// En un widget Consumer
final trabajoDetalleState = ref.watch(trabajoDetalleProvider);

trabajoDetalleState.when(
  data: (trabajoDetalle) {
    if (trabajoDetalle != null) {
      return Column(
        children: [
          Text('Campo: ${trabajoDetalle.campoInfo}'),
          Text('Cliente: ${trabajoDetalle.clienteInfoCompleta}'),
          Text('Personal: ${trabajoDetalle.personalInfo}'),
          Text('Máquinas: ${trabajoDetalle.maquinasInfo}'),
          Text('Trabajo: ${trabajoDetalle.trabajoInfo}'),
        ],
      );
    }
    return Text('Trabajo no encontrado');
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stackTrace) => Text('Error: $error'),
);
```

## Ventajas de esta Estructura

1. **Completa**: Incluye toda la información necesaria en una sola estructura
2. **Optimizada**: Usa un endpoint específico que devuelve toda la información estructurada
3. **Flexible**: Permite filtrado y estadísticas avanzadas
4. **Reutilizable**: Widgets modulares para diferentes contextos
5. **Mantenible**: Separación clara de responsabilidades
6. **Escalable**: Fácil agregar nuevos campos y funcionalidades
7. **Eficiente**: Una sola llamada a la API para obtener todos los detalles

## Consideraciones de Rendimiento

1. **Endpoint Específico**: Usa `/trabajos/detalle/{trabajo_id}` que devuelve toda la información
2. **Cache**: Los providers manejan el estado para evitar recargas innecesarias
3. **Lazy Loading**: Los detalles se cargan solo cuando se necesitan
4. **Error Handling**: Manejo individual de errores para cada trabajo
5. **Memory Management**: Limpieza automática de estado cuando no se necesita
