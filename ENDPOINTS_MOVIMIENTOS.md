# Documentación de Endpoints - Movimientos (Ingresos y Gastos)

## Resumen
Entidad unificada para registrar ingresos (cobros) y gastos (egresos), reemplazando Costos y Pagos. Incluye estado de pago, vencimientos y referencias a trabajos y facturas.

---

## Estructura de la tabla `movimientos`

Campos principales:
- id (int, PK)
- monto (numeric(14,2), requerido)
- fecha (date, opcional) — fecha general del movimiento
- descripcion (text, opcional)
- categoria (varchar(80), opcional)
- pagado (boolean, default false)
- forma_pago (varchar(50), opcional) — heredado de Costos
- metodo_pago (varchar(50), opcional) — heredado de Pagos
- es_cobro (boolean, requerido) — true=Ingreso, false=Gasto
- destinatario (varchar(150), opcional) — para gastos
- cobrar_a (varchar(150), opcional) — para ingresos pendientes
- fecha_pago_limite (date, opcional)
- id_trabajo (int, opcional, FK a trabajos.id)
- id_factura (int, opcional, FK a facturas.id)
- fecha_pago (date, opcional) — fecha efectiva del cobro/pago
- created_at (timestamptz)
- updated_at (timestamptz)

Índices recomendados:
- (es_cobro), (pagado), (fecha), (fecha_pago_limite), (id_trabajo), (id_factura)

---

## Script SQL (PostgreSQL)

```sql
-- Crear tabla movimientos
CREATE TABLE IF NOT EXISTS public.movimientos (
  id               SERIAL PRIMARY KEY,
  monto            NUMERIC(14, 2)         NOT NULL,
  fecha            DATE,
  descripcion      TEXT,
  categoria        VARCHAR(80),

  pagado           BOOLEAN                NOT NULL DEFAULT FALSE,
  forma_pago       VARCHAR(50),
  metodo_pago      VARCHAR(50),

  es_cobro         BOOLEAN                NOT NULL DEFAULT FALSE, -- TRUE=Ingreso, FALSE=Gasto
  destinatario     VARCHAR(150),
  cobrar_a         VARCHAR(150),

  fecha_pago_limite DATE,

  id_trabajo       INTEGER,
  id_factura       INTEGER,

  fecha_pago       DATE,

  created_at       TIMESTAMPTZ            NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ            NOT NULL DEFAULT NOW()
);

-- Llaves foráneas
ALTER TABLE public.movimientos
  ADD CONSTRAINT fk_mov_trabajo
  FOREIGN KEY (id_trabajo) REFERENCES public.trabajos (id)
  ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE public.movimientos
  ADD CONSTRAINT fk_mov_factura
  FOREIGN KEY (id_factura) REFERENCES public.facturas (id)
  ON UPDATE CASCADE ON DELETE SET NULL;

-- Índices
CREATE INDEX IF NOT EXISTS idx_mov_es_cobro ON public.movimientos (es_cobro);
CREATE INDEX IF NOT EXISTS idx_mov_pagado ON public.movimientos (pagado);
CREATE INDEX IF NOT EXISTS idx_mov_fecha ON public.movimientos (fecha);
CREATE INDEX IF NOT EXISTS idx_mov_fecha_pago_limite ON public.movimientos (fecha_pago_limite);
CREATE INDEX IF NOT EXISTS idx_mov_id_trabajo ON public.movimientos (id_trabajo);
CREATE INDEX IF NOT EXISTS idx_mov_id_factura ON public.movimientos (id_factura);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION set_updated_at_movimientos()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_set_updated_at_movimientos ON public.movimientos;
CREATE TRIGGER trg_set_updated_at_movimientos
BEFORE UPDATE ON public.movimientos
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_movimientos();
```

---

## Endpoints (Base URL: `/api/movimientos`)

| Método | Endpoint | Descripción | Permisos |
|---|---|---|---|
| GET | `/api/movimientos/` | Listar movimientos (paginado) | Contable, Administrador |
| GET | `/api/movimientos/{id}` | Obtener movimiento por id | Público |
| POST | `/api/movimientos/` | Crear movimiento (ingreso o gasto) | Contable, Administrador |
| PUT | `/api/movimientos/{id}` | Actualizar movimiento | Contable, Administrador |
| DELETE | `/api/movimientos/{id}` | Eliminar movimiento | Contable, Administrador |

Parámetros de consulta (GET `/api/movimientos/`):
- `skip` (int, default: 0)
- `limit` (int, default: 100)

Futuros filtros sugeridos: `es_cobro`, `pagado`, `fecha_desde/fecha_hasta`, `categoria`, `id_trabajo`, `id_factura`.

---

## Esquemas (request/response)

MovimientoCreate / MovimientoUpdate (campos):
- monto (number)
- fecha (date)
- descripcion (string)
- categoria (string)
- pagado (bool)
- forma_pago (string)
- metodo_pago (string)
- es_cobro (bool)
- destinatario (string)
- cobrar_a (string)
- fecha_pago_limite (date)
- id_trabajo (int)
- id_factura (int)
- fecha_pago (date)

Respuesta Movimiento (ejemplo):
```json
{
  "id": 10,
  "monto": 80000.0,
  "fecha": "2025-01-12",
  "descripcion": "Trabajo de siembra",
  "categoria": "Servicios",
  "pagado": true,
  "forma_pago": null,
  "metodo_pago": "Transferencia",
  "es_cobro": true,
  "destinatario": null,
  "cobrar_a": "Cliente ABC",
  "fecha_pago_limite": null,
  "id_trabajo": 7,
  "id_factura": 123,
  "fecha_pago": "2025-01-15",
  "created_at": "2025-01-12T10:00:00Z",
  "updated_at": "2025-01-15T12:30:00Z"
}
```

---

## Ejemplos de uso

### Crear Gasto (es_cobro: false)
```http
POST /api/movimientos/
Content-Type: application/json

{
  "monto": 15000.00,
  "fecha": "2025-01-10",
  "descripcion": "Compra de combustible",
  "categoria": "Combustible",
  "es_cobro": false,
  "destinatario": "YPF",
  "forma_pago": "Transferencia",
  "id_trabajo": 5,
  "fecha_pago_limite": "2025-01-20"
}
```

### Crear Ingreso pendiente (es_cobro: true)
```http
POST /api/movimientos/
Content-Type: application/json

{
  "monto": 80000.00,
  "fecha": "2025-01-12",
  "descripcion": "Trabajo de siembra",
  "categoria": "Servicios",
  "es_cobro": true,
  "cobrar_a": "Cliente ABC",
  "id_trabajo": 7,
  "id_factura": 123,
  "pagado": false
}
```

### Marcar ingreso como cobrado
```http
PUT /api/movimientos/10
Content-Type: application/json

{
  "pagado": true,
  "metodo_pago": "Transferencia",
  "fecha_pago": "2025-01-15"
}
```

### Listar (paginado)
```http
GET /api/movimientos/?skip=0&limit=20
```

### Obtener por id
```http
GET /api/movimientos/10
```

### Eliminar
```http
DELETE /api/movimientos/10
```

---

## Integración con Dashboard
- Ingresos del mes: `sum(monto) WHERE es_cobro=true AND fecha IN rango`
- Egresos del mes: `sum(monto) WHERE es_cobro=false AND fecha IN rango`
- Cuentas por cobrar: `es_cobro=true AND pagado=false` (usar `fecha_pago_limite` para vencidos)
- Cuentas por pagar: `es_cobro=false AND pagado=false`

---

## Notas
- Unifica ingresos y gastos en una sola entidad.
- Mantiene compatibilidad de negocio al conservar atributos de Costos y Pagos.
- Recomendado despublicar gradualmente endpoints antiguos tras migración.
