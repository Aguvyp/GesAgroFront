-- =====================================================
-- GESAGRO - ESQUEMA COMPLETO DE BASE DE DATOS
-- =====================================================
-- Script para crear la base de datos y todas las tablas
-- Compatible con MySQL/MariaDB y PostgreSQL
-- =====================================================

-- Crear base de datos (descomentar si es necesario)
-- CREATE DATABASE IF NOT EXISTS gesagro CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE gesagro;

-- =====================================================
-- TABLA: usuarios
-- =====================================================
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    rol ENUM('Administrador', 'Contable', 'Operario') NOT NULL DEFAULT 'Operario',
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_rol (rol),
    INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: tipo_trabajo
-- =====================================================
CREATE TABLE IF NOT EXISTS tipo_trabajo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    trabajo VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_trabajo (trabajo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: campos
-- =====================================================
CREATE TABLE IF NOT EXISTS campos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    hectareas DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    latitud DECIMAL(10, 8) NULL,
    longitud DECIMAL(11, 8) NULL,
    detalles TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_nombre (nombre),
    INDEX idx_hectareas (hectareas)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: clientes
-- =====================================================
CREATE TABLE IF NOT EXISTS clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) NULL,
    telefono VARCHAR(50) NULL,
    direccion VARCHAR(500) NULL,
    cuit VARCHAR(20) NULL,
    observaciones TEXT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_nombre (nombre),
    INDEX idx_cuit (cuit),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: campos_cliente (Asignaciones de campos a clientes)
-- =====================================================
CREATE TABLE IF NOT EXISTS campos_cliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    campo_id INT NOT NULL,
    fecha_asignacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observaciones TEXT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_campo_cliente_activo (cliente_id, campo_id, activo),
    INDEX idx_cliente_id (cliente_id),
    INDEX idx_campo_id (campo_id),
    INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: maquinas
-- =====================================================
CREATE TABLE IF NOT EXISTS maquinas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    ano INT NOT NULL,
    detalles TEXT NULL,
    ancho_trabajo DECIMAL(5, 2) NULL,
    estado VARCHAR(50) NULL DEFAULT 'Disponible',
    superficie_total_ha DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    horas_trabajadas DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    ultimo_trabajo VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_nombre (nombre),
    INDEX idx_marca (marca),
    INDEX idx_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: personal
-- =====================================================
CREATE TABLE IF NOT EXISTS personal (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(50) NULL,
    superficie_total_ha DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    horas_trabajadas DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    trabajos_completados INT NOT NULL DEFAULT 0,
    ultimo_trabajo VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_nombre (nombre),
    INDEX idx_dni (dni),
    INDEX idx_telefono (telefono)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: trabajos
-- =====================================================
CREATE TABLE IF NOT EXISTS trabajos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo_trabajo INT NOT NULL,
    cultivo VARCHAR(255) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NULL,
    campo_id INT NOT NULL,
    estado VARCHAR(50) NULL DEFAULT 'Pendiente',
    observaciones TEXT NULL,
    a_terceros BOOLEAN NOT NULL DEFAULT FALSE,
    cobrado BOOLEAN NOT NULL DEFAULT FALSE,
    monto_cobrado DECIMAL(12, 2) NULL,
    cliente VARCHAR(255) NULL,
    servicio_contratado BOOLEAN NOT NULL DEFAULT FALSE,
    rinde_cosecha DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    humedad_cosecha DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_id_tipo_trabajo (id_tipo_trabajo),
    INDEX idx_campo_id (campo_id),
    INDEX idx_fecha_inicio (fecha_inicio),
    INDEX idx_estado (estado),
    INDEX idx_cobrado (cobrado),
    INDEX idx_a_terceros (a_terceros)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: trabajo_personal (Relación muchos a muchos con hectáreas)
-- =====================================================
CREATE TABLE IF NOT EXISTS trabajo_personal (
    id INT AUTO_INCREMENT PRIMARY KEY,
    trabajo_id INT NOT NULL,
    personal_id INT NOT NULL,
    hectareas DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_trabajo_personal (trabajo_id, personal_id),
    INDEX idx_trabajo_id (trabajo_id),
    INDEX idx_personal_id (personal_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: trabajo_maquinas (Relación muchos a muchos)
-- =====================================================
CREATE TABLE IF NOT EXISTS trabajo_maquinas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    trabajo_id INT NOT NULL,
    maquina_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_trabajo_maquina (trabajo_id, maquina_id),
    INDEX idx_trabajo_id (trabajo_id),
    INDEX idx_maquina_id (maquina_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: costos
-- =====================================================
CREATE TABLE IF NOT EXISTS costos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    monto DECIMAL(12, 2) NOT NULL,
    fecha DATE NOT NULL,
    destinatario VARCHAR(255) NOT NULL,
    pagado BOOLEAN NOT NULL DEFAULT FALSE,
    forma_pago VARCHAR(50) NULL,
    descripcion TEXT NULL,
    categoria VARCHAR(100) NULL,
    fecha_pago_limite DATE NULL,
    es_cobro BOOLEAN NOT NULL DEFAULT FALSE,
    cobrar_a VARCHAR(255) NULL,
    id_trabajo INT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_fecha (fecha),
    INDEX idx_pagado (pagado),
    INDEX idx_es_cobro (es_cobro),
    INDEX idx_categoria (categoria),
    INDEX idx_id_trabajo (id_trabajo),
    INDEX idx_fecha_pago_limite (fecha_pago_limite)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: facturas
-- =====================================================
CREATE TABLE IF NOT EXISTS facturas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    numero VARCHAR(100) NOT NULL UNIQUE,
    fecha_emision DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    monto_total DECIMAL(12, 2) NOT NULL,
    monto_pagado DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
    observaciones TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_cliente_id (cliente_id),
    INDEX idx_numero (numero),
    INDEX idx_fecha_emision (fecha_emision),
    INDEX idx_fecha_vencimiento (fecha_vencimiento),
    INDEX idx_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: factura_items
-- =====================================================
CREATE TABLE IF NOT EXISTS factura_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    factura_id INT NOT NULL,
    descripcion VARCHAR(500) NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(12, 2) NOT NULL,
    subtotal DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_factura_id (factura_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: creditos
-- =====================================================
CREATE TABLE IF NOT EXISTS creditos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entidad VARCHAR(255) NOT NULL,
    monto_otorgado DECIMAL(12, 2) NOT NULL,
    tasa_interes_anual DECIMAL(5, 2) NOT NULL,
    plazo_meses INT NOT NULL,
    fecha_desembolso DATE NOT NULL,
    estado VARCHAR(50) NOT NULL DEFAULT 'Activo',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_entidad (entidad),
    INDEX idx_estado (estado),
    INDEX idx_fecha_desembolso (fecha_desembolso)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: cuotas_credito
-- =====================================================
CREATE TABLE IF NOT EXISTS cuotas_credito (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_credito INT NOT NULL,
    numero_cuota INT NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    monto_total DECIMAL(12, 2) NOT NULL,
    estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_credito_cuota (id_credito, numero_cuota),
    INDEX idx_id_credito (id_credito),
    INDEX idx_fecha_vencimiento (fecha_vencimiento),
    INDEX idx_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: pagos
-- =====================================================
CREATE TABLE IF NOT EXISTS pagos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    monto DECIMAL(12, 2) NOT NULL,
    fecha DATE NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    descripcion TEXT NULL,
    id_factura INT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_fecha (fecha),
    INDEX idx_id_factura (id_factura),
    INDEX idx_metodo_pago (metodo_pago)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: movimientos
-- =====================================================
CREATE TABLE IF NOT EXISTS movimientos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    monto DECIMAL(12, 2) NOT NULL,
    fecha DATE NULL,
    descripcion TEXT NULL,
    categoria VARCHAR(100) NULL,
    pagado BOOLEAN NOT NULL DEFAULT FALSE,
    forma_pago VARCHAR(50) NULL,
    metodo_pago VARCHAR(50) NULL,
    es_cobro BOOLEAN NOT NULL DEFAULT FALSE,
    destinatario VARCHAR(255) NULL,
    cobrar_a VARCHAR(255) NULL,
    fecha_pago_limite DATE NULL,
    id_trabajo INT NULL,
    id_factura INT NULL,
    fecha_pago DATE NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_fecha (fecha),
    INDEX idx_pagado (pagado),
    INDEX idx_es_cobro (es_cobro),
    INDEX idx_categoria (categoria),
    INDEX idx_id_trabajo (id_trabajo),
    INDEX idx_id_factura (id_factura),
    INDEX idx_fecha_pago_limite (fecha_pago_limite)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: mantenimientos
-- =====================================================
CREATE TABLE IF NOT EXISTS mantenimientos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_maquina INT NOT NULL,
    fecha DATE NOT NULL,
    descripcion TEXT NOT NULL,
    estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
    costo_total DECIMAL(12, 2) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_id_maquina (id_maquina),
    INDEX idx_fecha (fecha),
    INDEX idx_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: insumos
-- =====================================================
CREATE TABLE IF NOT EXISTS insumos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    unidad VARCHAR(50) NOT NULL,
    stock_actual DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    stock_minimo DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    precio_unitario DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    proveedor VARCHAR(255) NULL,
    fecha_vencimiento DATE NULL,
    observaciones TEXT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_nombre (nombre),
    INDEX idx_categoria (categoria),
    INDEX idx_activo (activo),
    INDEX idx_fecha_vencimiento (fecha_vencimiento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- DATOS INICIALES (INSERTS)
-- =====================================================

-- Insertar tipos de trabajo básicos
INSERT INTO tipo_trabajo (trabajo) VALUES
('Siembra'),
('Cosecha'),
('Laboreo'),
('Pulverización'),
('Fertilización'),
('Rollos'),
('Fardos'),
('Picado')
ON DUPLICATE KEY UPDATE trabajo = VALUES(trabajo);

-- Insertar usuario administrador por defecto
-- Password: admin123 (debe ser hasheado en producción)
INSERT INTO usuarios (nombre, email, password, rol, activo) VALUES
('Administrador', 'admin@gesagro.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrador', TRUE)
ON DUPLICATE KEY UPDATE email = VALUES(email);

-- =====================================================
-- VISTAS ÚTILES (OPCIONAL)
-- =====================================================

-- Vista: Trabajos con información completa
CREATE OR REPLACE VIEW v_trabajos_completos AS
SELECT 
    t.id,
    t.id_tipo_trabajo,
    tt.trabajo AS tipo,
    t.cultivo,
    t.fecha_inicio,
    t.fecha_fin,
    t.campo_id,
    c.nombre AS campo_nombre,
    c.hectareas AS campo_ha,
    t.estado,
    t.observaciones,
    t.a_terceros,
    t.cobrado,
    t.monto_cobrado,
    t.cliente,
    t.servicio_contratado,
    t.rinde_cosecha,
    t.humedad_cosecha,
    GROUP_CONCAT(DISTINCT p.id) AS id_personal,
    GROUP_CONCAT(DISTINCT m.id) AS id_maquinas
FROM trabajos t
LEFT JOIN tipo_trabajo tt ON t.id_tipo_trabajo = tt.id
LEFT JOIN campos c ON t.campo_id = c.id
LEFT JOIN trabajo_personal tp ON t.id = tp.trabajo_id
LEFT JOIN personal p ON tp.personal_id = p.id
LEFT JOIN trabajo_maquinas tm ON t.id = tm.trabajo_id
LEFT JOIN maquinas m ON tm.maquina_id = m.id
GROUP BY t.id;

-- Vista: Resumen de dashboard
CREATE OR REPLACE VIEW v_dashboard_resumen AS
SELECT 
    (SELECT COUNT(*) FROM trabajos WHERE estado = 'Pendiente') AS trabajos_pendientes,
    (SELECT COUNT(*) FROM trabajos WHERE estado = 'En curso') AS trabajos_en_curso,
    (SELECT COUNT(*) FROM trabajos WHERE estado = 'Completado') AS trabajos_completados,
    (SELECT COALESCE(SUM(monto), 0) FROM movimientos WHERE es_cobro = TRUE AND MONTH(fecha) = MONTH(CURRENT_DATE) AND YEAR(fecha) = YEAR(CURRENT_DATE)) AS ingresos_mes,
    (SELECT COALESCE(SUM(monto), 0) FROM movimientos WHERE es_cobro = FALSE AND MONTH(fecha) = MONTH(CURRENT_DATE) AND YEAR(fecha) = YEAR(CURRENT_DATE)) AS gastos_mes,
    (SELECT COUNT(*) FROM facturas WHERE estado = 'Pendiente') AS facturas_pendientes,
    (SELECT COUNT(*) FROM facturas WHERE estado = 'Vencida' OR (estado = 'Pendiente' AND fecha_vencimiento < CURRENT_DATE)) AS facturas_vencidas,
    (SELECT COUNT(*) FROM mantenimientos WHERE estado = 'Pendiente') AS mantenimientos_pendientes,
    (SELECT COUNT(*) FROM insumos WHERE stock_actual <= stock_minimo AND activo = TRUE) AS insumos_bajo_stock;

-- =====================================================
-- PROCEDIMIENTOS ALMACENADOS ÚTILES (OPCIONAL)
-- =====================================================

-- Procedimiento: Actualizar estadísticas de personal
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS sp_actualizar_estadisticas_personal()
BEGIN
    UPDATE personal p
    SET 
        superficie_total_ha = (
            SELECT COALESCE(SUM(tp.hectareas), 0)
            FROM trabajo_personal tp
            JOIN trabajos t ON tp.trabajo_id = t.id
            WHERE tp.personal_id = p.id AND t.estado = 'Completado'
        ),
        trabajos_completados = (
            SELECT COUNT(DISTINCT tp.trabajo_id)
            FROM trabajo_personal tp
            JOIN trabajos t ON tp.trabajo_id = t.id
            WHERE tp.personal_id = p.id AND t.estado = 'Completado'
        );
END //
DELIMITER ;

-- Procedimiento: Actualizar estadísticas de máquinas
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS sp_actualizar_estadisticas_maquinas()
BEGIN
    UPDATE maquinas m
    SET 
        superficie_total_ha = (
            SELECT COALESCE(SUM(c.hectareas), 0)
            FROM trabajo_maquinas tm
            JOIN trabajos t ON tm.trabajo_id = t.id
            JOIN campos c ON t.campo_id = c.id
            WHERE tm.maquina_id = m.id AND t.estado = 'Completado'
        );
END //
DELIMITER ;

-- =====================================================
-- TRIGGERS ÚTILES (OPCIONAL)
-- =====================================================

-- Trigger: Actualizar fecha_modificacion en clientes
DELIMITER //
CREATE TRIGGER IF NOT EXISTS tr_clientes_update
BEFORE UPDATE ON clientes
FOR EACH ROW
BEGIN
    SET NEW.fecha_modificacion = CURRENT_TIMESTAMP;
END //
DELIMITER ;

-- Trigger: Actualizar monto_pagado en facturas cuando se crea un pago
DELIMITER //
CREATE TRIGGER IF NOT EXISTS tr_pagos_insert
AFTER INSERT ON pagos
FOR EACH ROW
BEGIN
    IF NEW.id_factura IS NOT NULL THEN
        UPDATE facturas
        SET monto_pagado = (
            SELECT COALESCE(SUM(monto), 0)
            FROM pagos
            WHERE id_factura = NEW.id_factura
        ),
        estado = CASE
            WHEN (SELECT COALESCE(SUM(monto), 0) FROM pagos WHERE id_factura = NEW.id_factura) >= monto_total THEN 'Pagada'
            WHEN fecha_vencimiento < CURRENT_DATE THEN 'Vencida'
            ELSE 'Pendiente'
        END
        WHERE id = NEW.id_factura;
    END IF;
END //
DELIMITER ;

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================

