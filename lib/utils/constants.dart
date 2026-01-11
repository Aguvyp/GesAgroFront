class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://65e70006b9ca.ngrok-free.app';
  static const int apiTimeoutSeconds = 30;
  static const Map<String, String> headers = {
    'Content-Type': 'application/json; charset=utf-8',
  };

  // App Information
  static const String appName = 'GesAgro';
  static const String appVersion = '1.0.0';

  // Colors
  static const int primaryColor = 0xFF2E7D32; // Verde agrícola
  static const int secondaryColor = 0xFF4CAF50; // Verde claro
  static const int accentColor = 0xFFFF9800; // Naranja
  static const int backgroundColor = 0xFFFAFAFA; // Fondo
  static const int textColor = 0xFF212121; // Texto
  static const int errorColor = 0xFFF44336; // Rojo
  static const int successColor = 0xFF4CAF50; // Verde
  static const int infoColor = 0xFF2196F3; // Azul información
  static const int cancelColor = 0xFFE57373; // Rojo clarito para botones de cancelar
  static const int deleteColor = 0xFFE57373; // Rojo clarito para botones de eliminar

  // User Roles
  static const String roleAdministrador = 'Administrador';
  static const String roleContable = 'Contable';
  static const String roleOperario = 'Operario';

  // API Endpoints (lista) - Flutter optimizados
  static const String camposListEndpoint = '/api/flutter/campos/lista/';
  static const String maquinasListEndpoint = '/api/flutter/maquinas/lista/';
  static const String personalListEndpoint = '/api/flutter/personal/lista/';
  static const String trabajosListEndpoint = '/api/flutter/trabajos/lista/';
  static const String costosListEndpoint = '/api/flutter/costos/lista/';

  // API Endpoints (CRUD base)
  static const String camposEndpoint = '/api/campos/';
  static const String maquinasEndpoint = '/api/maquinas/';
  static const String personalEndpoint = '/api/personal/';
  static const String trabajosEndpoint = '/api/trabajos/';
  static const String costosEndpoint = '/api/costo/';
  
  // Nuevos endpoints v2.0
  static const String clientesEndpoint = '/api/clientes/';
  static const String facturasEndpoint = '/api/facturas/';
  static const String pagosEndpoint = '/api/pagos/';
  static const String creditosEndpoint = '/api/creditos/';
  static const String cuotasCreditoEndpoint = '/api/cuotas-credito/';
  static const String insumosEndpoint = '/api/insumos/';
  static const String movimientosEndpoint = '/api/movimientos/';
  static const String mantenimientosEndpoint = '/api/mantenimientos/';
  static const String usuariosEndpoint = '/api/usuarios/';

  // Mobile endpoints
  static const String trabajosRecientesEndpoint = '/api/mobile/trabajos/recientes/';
  static const String mantenimientosProximosEndpoint = '/api/mobile/mantenimientos/proximos/';
  static const String insumosBajoStockEndpoint = '/api/mobile/insumos/bajo-stock/';
  static const String finanzasResumenEndpoint = '/api/mobile/finanzas/resumen/';
  static const String resumenMobileEndpoint = '/api/mobile/resumen/';
  static const String estadisticasMobileEndpoint = '/api/mobile/estadisticas/';

  // Reportes endpoints
  static const String reportesEndpoint = '/api/reportes/';

  // Work Types
  static const List<String> workTypes = [
    'Siembra',
    'Cosecha',
    'Laboreo',
    'Pulverización',
    'Fertilización',
    'Rollos',
    'Fardos',
    'Picado',
  ];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Efectivo',
    'Transferencia',
    'Cheque',
    'Tarjeta de Crédito',
    'Tarjeta de Débito',
    'Otros'
  ];

  // Cost Categories
  static const List<String> costCategories = [
    'Semillas',
    'Fertilizantes',
    'Combustible',
    'Mano de obra',
    'Maquinaria',
    'Otros'
  ];

  // Estados de mantenimiento
  static const List<String> estadosMantenimiento = [
    'Completado',
    'Pendiente',
    'Atrasado',
  ];

  // Tipos de mantenimiento
  static const List<String> tiposMantenimiento = [
    'Preventivo',
    'Correctivo',
    'Predictivo',
  ];

  // Work Status
  static const String pendingStatus = 'Pendiente';
  static const String inProgressStatus = 'En curso';
  static const String completedStatus = 'Completado';

  // Machine Status
  static const String availableStatus = 'Disponible';
  static const String inUseStatus = 'En uso';
  static const String maintenanceStatus = 'Mantenimiento';
}
