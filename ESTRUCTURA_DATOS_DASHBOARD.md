# Estructura de Datos para APIs del Dashboard

## Resumen
Este documento describe la estructura de datos necesaria para las APIs que alimentan el dashboard principal de la aplicación GesAgroFront.

## APIs Requeridas

### 1. API de Trabajos por Estado
**Endpoint:** `GET /api/dashboard/trabajos-estado`

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "pendientes": 2,
    "en_ejecucion": 1,
    "completados": 1
  }
}
```

### 2. API de Trabajos Próximos
**Endpoint:** `GET /api/dashboard/trabajos-proximos`

**Parámetros:**
- `dias`: número de días hacia adelante (default: 30)

**Respuesta:**
```json
{
  "success": true,
  "data": [
    {
      "id": 3,
      "tipo": "Cosecha",
      "cultivo": "Trigo",
      "fecha_inicio": "2024-01-15T08:00:00Z",
      "fecha_fin": "2024-01-19T18:00:00Z",
      "estado": "Pendiente",
      "campo": {
        "id": 3,
        "nombre": "Campo Norte"
      },
      "cliente": "Agro Norte S.A.",
      "es_tercero": true
    },
    {
      "id": 4,
      "tipo": "Preparación",
      "cultivo": "Girasol",
      "fecha_inicio": "2024-01-22T08:00:00Z",
      "fecha_fin": "2024-01-24T18:00:00Z",
      "estado": "Pendiente",
      "campo": {
        "id": 1,
        "nombre": "Campo Sur"
      },
      "cliente": null,
      "es_tercero": false
    }
  ]
}
```

### 3. API de Superficies por Máquina
**Endpoint:** `GET /api/dashboard/maquinas-superficies`

**Respuesta:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nombre": "Tractor John Deere",
      "marca": "John Deere",
      "modelo": "6120R",
      "ano": 2020,
      "superficie_total_ha": 125.5,
      "horas_trabajadas": 45.5,
      "ultimo_trabajo": "2024-01-10T18:00:00Z"
    },
    {
      "id": 2,
      "nombre": "Sembradora",
      "marca": "Kinze",
      "modelo": "3600",
      "ano": 2019,
      "superficie_total_ha": 98.0,
      "horas_trabajadas": 32.0,
      "ultimo_trabajo": "2024-01-08T16:30:00Z"
    },
    {
      "id": 3,
      "nombre": "Pulverizadora",
      "marca": "Jacto",
      "modelo": "Uniport 3030",
      "ano": 2021,
      "superficie_total_ha": 76.5,
      "horas_trabajadas": 28.5,
      "ultimo_trabajo": "2024-01-12T14:00:00Z"
    }
  ]
}
```

### 4. API de Rendimiento de Operadores
**Endpoint:** `GET /api/dashboard/personal-rendimiento`

**Respuesta:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nombre": "Carlos López",
      "dni": "12345678",
      "telefono": "011-1234-5678",
      "superficie_total_ha": 89.5,
      "horas_trabajadas": 67.5,
      "trabajos_completados": 8,
      "ultimo_trabajo": "2024-01-10T18:00:00Z"
    },
    {
      "id": 2,
      "nombre": "María García",
      "dni": "87654321",
      "telefono": "011-8765-4321",
      "superficie_total_ha": 76.0,
      "horas_trabajadas": 54.0,
      "trabajos_completados": 6,
      "ultimo_trabajo": "2024-01-08T16:30:00Z"
    },
    {
      "id": 3,
      "nombre": "Roberto Silva",
      "dni": "11223344",
      "telefono": "011-1122-3344",
      "superficie_total_ha": 18.0,
      "horas_trabajadas": 15.5,
      "trabajos_completados": 2,
      "ultimo_trabajo": "2024-01-12T14:00:00Z"
    }
  ]
}
```

## Campos Calculados Requeridos

### Para Máquinas:
- `superficie_total_ha`: Suma de todas las superficies trabajadas por la máquina
- `horas_trabajadas`: Suma de todas las horas trabajadas por la máquina
- `ultimo_trabajo`: Fecha del último trabajo realizado

### Para Personal:
- `superficie_total_ha`: Suma de todas las superficies trabajadas por el operador
- `horas_trabajadas`: Suma de todas las horas trabajadas por el operador
- `trabajos_completados`: Cantidad de trabajos completados
- `ultimo_trabajo`: Fecha del último trabajo realizado

## Consideraciones de Performance

1. **Caché**: Estas APIs deberían implementar caché para mejorar el rendimiento
2. **Paginación**: Para grandes volúmenes de datos, considerar paginación
3. **Filtros**: Permitir filtros por fecha, estado, etc.
4. **Agregaciones**: Pre-calcular las métricas en la base de datos

## Estados de Trabajo

Los estados válidos para los trabajos son:
- `Pendiente`: Trabajo programado pero no iniciado
- `En Ejecución`: Trabajo actualmente en curso
- `Completado`: Trabajo finalizado
- `Cancelado`: Trabajo cancelado

## Fechas

Todas las fechas deben estar en formato ISO 8601 con timezone UTC:
- Formato: `YYYY-MM-DDTHH:mm:ssZ`
- Ejemplo: `2024-01-15T08:00:00Z`

## Manejo de Errores

Todas las APIs deben seguir el formato estándar:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Descripción del error",
    "details": "Detalles adicionales si es necesario"
  }
}
```

## Códigos de Error Comunes

- `DASHBOARD_DATA_ERROR`: Error al obtener datos del dashboard
- `INVALID_DATE_RANGE`: Rango de fechas inválido
- `DATABASE_ERROR`: Error de base de datos
- `PERMISSION_DENIED`: Usuario sin permisos para ver estos datos
