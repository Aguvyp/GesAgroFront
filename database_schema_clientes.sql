-- Script PostgreSQL para crear las tablas de Clientes y Campos_x_Cliente
-- GesAgro Database Schema

-- Tabla de Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    telefono VARCHAR(50),
    direccion TEXT,
    cuit VARCHAR(20),
    observaciones TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla intermedia Campos_x_Cliente (relación muchos a muchos)
CREATE TABLE IF NOT EXISTS campos_x_cliente (
    id SERIAL PRIMARY KEY,
    id_campo INTEGER NOT NULL,
    id_cliente INTEGER NOT NULL,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observaciones TEXT,
    activo BOOLEAN DEFAULT TRUE,
    
    -- Claves foráneas
    CONSTRAINT fk_campo_cliente_campo 
        FOREIGN KEY (id_campo) REFERENCES campos(id) ON DELETE CASCADE,
    CONSTRAINT fk_campo_cliente_cliente 
        FOREIGN KEY (id_cliente) REFERENCES clientes(id) ON DELETE CASCADE,
    
    -- Restricción única para evitar duplicados
    CONSTRAINT unique_campo_cliente 
        UNIQUE (id_campo, id_cliente)
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_clientes_nombre ON clientes(nombre);
CREATE INDEX IF NOT EXISTS idx_clientes_email ON clientes(email);
CREATE INDEX IF NOT EXISTS idx_clientes_cuit ON clientes(cuit);
CREATE INDEX IF NOT EXISTS idx_clientes_activo ON clientes(activo);

CREATE INDEX IF NOT EXISTS idx_campos_x_cliente_campo ON campos_x_cliente(id_campo);
CREATE INDEX IF NOT EXISTS idx_campos_x_cliente_cliente ON campos_x_cliente(id_cliente);
CREATE INDEX IF NOT EXISTS idx_campos_x_cliente_activo ON campos_x_cliente(activo);

-- Trigger para actualizar fecha_modificacion en clientes
CREATE OR REPLACE FUNCTION update_clientes_modification_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_modificacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_clientes_modification_date
    BEFORE UPDATE ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION update_clientes_modification_date();

-- Datos de ejemplo para testing
INSERT INTO clientes (nombre, email, telefono, direccion, cuit, observaciones) VALUES
('Stangaferro S.A.', 'contacto@stangaferro.com', '+54 11 1234-5678', 'Av. Corrientes 1234, CABA', '30-12345678-9', 'Cliente principal para trabajos de siembra'),
('Agro Norte SRL', 'info@agronorte.com', '+54 341 987-6543', 'Ruta 9 Km 123, Santa Fe', '30-87654321-0', 'Cliente para trabajos de cosecha'),
('Campo Verde', 'ventas@campoverde.com', '+54 261 555-1234', 'Ruta 40 Km 456, Mendoza', '30-11223344-5', 'Cliente para trabajos de pulverización')
ON CONFLICT DO NOTHING;

-- Asignar algunos campos a clientes (ejemplo)
-- Nota: Ajusta los IDs según tus datos existentes
INSERT INTO campos_x_cliente (id_campo, id_cliente, observaciones) VALUES
(1, 1, 'Campo principal asignado a Stangaferro'),
(2, 2, 'Campo secundario para Agro Norte')
ON CONFLICT (id_campo, id_cliente) DO NOTHING;

-- Vista para consultar campos con sus clientes asignados
CREATE OR REPLACE VIEW vista_campos_clientes AS
SELECT 
    c.id as campo_id,
    c.nombre as campo_nombre,
    c.superficie_ha,
    cl.id as cliente_id,
    cl.nombre as cliente_nombre,
    cl.email as cliente_email,
    cl.telefono as cliente_telefono,
    ccx.fecha_asignacion,
    ccx.observaciones as asignacion_observaciones,
    ccx.activo as asignacion_activa
FROM campos c
LEFT JOIN campos_x_cliente ccx ON c.id = ccx.id_campo AND ccx.activo = TRUE
LEFT JOIN clientes cl ON ccx.id_cliente = cl.id AND cl.activo = TRUE;

-- Vista para consultar clientes con sus campos asignados
CREATE OR REPLACE VIEW vista_clientes_campos AS
SELECT 
    cl.id as cliente_id,
    cl.nombre as cliente_nombre,
    cl.email,
    cl.telefono,
    cl.direccion,
    cl.cuit,
    c.id as campo_id,
    c.nombre as campo_nombre,
    c.superficie_ha,
    ccx.fecha_asignacion,
    ccx.observaciones as asignacion_observaciones,
    ccx.activo as asignacion_activa
FROM clientes cl
LEFT JOIN campos_x_cliente ccx ON cl.id = ccx.id_cliente AND ccx.activo = TRUE
LEFT JOIN campos c ON ccx.id_campo = c.id
WHERE cl.activo = TRUE;

-- Comentarios en las tablas
COMMENT ON TABLE clientes IS 'Tabla de clientes para trabajos a terceros';
COMMENT ON TABLE campos_x_cliente IS 'Tabla intermedia para relacionar campos con clientes';

COMMENT ON COLUMN clientes.nombre IS 'Nombre o razón social del cliente';
COMMENT ON COLUMN clientes.email IS 'Email de contacto del cliente';
COMMENT ON COLUMN clientes.telefono IS 'Teléfono de contacto del cliente';
COMMENT ON COLUMN clientes.direccion IS 'Dirección del cliente';
COMMENT ON COLUMN clientes.cuit IS 'CUIT del cliente';
COMMENT ON COLUMN clientes.observaciones IS 'Observaciones adicionales del cliente';

COMMENT ON COLUMN campos_x_cliente.id_campo IS 'ID del campo asignado';
COMMENT ON COLUMN campos_x_cliente.id_cliente IS 'ID del cliente asignado';
COMMENT ON COLUMN campos_x_cliente.fecha_asignacion IS 'Fecha de asignación del campo al cliente';
COMMENT ON COLUMN campos_x_cliente.observaciones IS 'Observaciones de la asignación';
COMMENT ON COLUMN campos_x_cliente.activo IS 'Indica si la asignación está activa';

-- Verificar que las tablas se crearon correctamente
SELECT 'Tablas creadas exitosamente' as resultado;
SELECT COUNT(*) as total_clientes FROM clientes;
SELECT COUNT(*) as total_asignaciones FROM campos_x_cliente;
