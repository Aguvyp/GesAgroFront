import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/movimiento.dart';
import '../../models/trabajo.dart';
import '../../services/optimized_api_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/logger/app_logger.dart';
import '../../utils/validators.dart';

class MovimientoFormScreen extends ConsumerStatefulWidget {
  final Movimiento? movimiento;
  const MovimientoFormScreen({Key? key, this.movimiento}) : super(key: key);

  @override
  ConsumerState<MovimientoFormScreen> createState() => _MovimientoFormScreenState();
}

class _MovimientoFormScreenState extends ConsumerState<MovimientoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final AppLogger _logger = AppLogger.instance;
  
  // Controladores de texto
  late TextEditingController _montoController;
  late TextEditingController _descripcionController;
  late TextEditingController _destinatarioController;
  late TextEditingController _fechaController;
  late TextEditingController _fechaPagoLimiteController;
  late TextEditingController _fechaPagoController;
  
  // Estados del formulario
  DateTime? _fecha;
  DateTime? _fechaPagoLimite;
  DateTime? _fechaPago;
  bool _esCobro = false; // Por defecto es gasto
  bool _pagado = false;
  String? _categoriaSeleccionada;
  String? _formaPagoSeleccionada;
  int? _idTrabajo;
  bool _isSaving = false;
  bool _isLoadingTrabajos = false;
  
  // Listas para dropdowns
  List<Trabajo> _trabajos = [];
  final List<String> _formasPago = [
    'Efectivo',
    'Transferencia bancaria',
    'Cheque',
    'Tarjeta de crédito',
    'Tarjeta de débito',
    'Otro'
  ];
  
  final List<String> _categorias = [
    'Trabajo agrícola',
    'Insumos agrícolas',
    'Mantenimiento',
    'Combustible',
    'Personal',
    'Servicios',
    'Otros gastos',
    'Ventas',
    'Servicios prestados',
    'Otros ingresos'
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.movimiento;
    
    // Inicializar controladores
    _montoController = TextEditingController(text: m?.monto.toString() ?? '');
    _descripcionController = TextEditingController(text: m?.descripcion ?? '');
    _destinatarioController = TextEditingController(text: m?.destinatario ?? '');
    _fechaController = TextEditingController();
    _fechaPagoLimiteController = TextEditingController();
    _fechaPagoController = TextEditingController();
    
    // Inicializar estados
    _fecha = m?.fecha ?? DateTime.now();
    _fechaPagoLimite = m?.fechaPagoLimite;
    _fechaPago = m?.fechaPago;
    _esCobro = m?.esCobro ?? false;
    _pagado = m?.pagado ?? false;
    _categoriaSeleccionada = m?.categoria ?? _categorias.first;
    _formaPagoSeleccionada = m?.formaPago ?? _formasPago.first;
    _idTrabajo = m?.idTrabajo;
    
    // Actualizar controladores de fecha
    _updateFechaController();
    _updateFechaPagoLimiteController();
    _updateFechaPagoController();
    
    // Inicializar el servicio API y luego cargar trabajos
    _initializeApiService();
  }

  /// Inicializar el servicio API
  Future<void> _initializeApiService() async {
    try {
      await _apiService.initialize();
      _logger.info('✅ ApiService inicializado correctamente');
      
      // Cargar trabajos después de 1 segundo para que el formulario se renderice primero
      Future.delayed(const Duration(seconds: 1), () {
        _loadTrabajos();
      });
    } catch (e) {
      _logger.error('❌ Error inicializando ApiService: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inicializando servicio: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    _destinatarioController.dispose();
    _fechaController.dispose();
    _fechaPagoLimiteController.dispose();
    _fechaPagoController.dispose();
    super.dispose();
  }

  /// Cargar lista de trabajos para el dropdown
  Future<void> _loadTrabajos() async {
    setState(() => _isLoadingTrabajos = true);
    try {
      _logger.info('🔄 Iniciando carga de trabajos...');
      
      // Verificar que el servicio esté inicializado
      if (!_apiService.isInitialized) {
        _logger.warning('⚠️ ApiService no está inicializado, inicializando...');
        await _apiService.initialize();
      }
      
      final trabajos = await _apiService.getTrabajos();
      setState(() => _trabajos = trabajos);
      _logger.info('📋 Cargados ${trabajos.length} trabajos para el formulario');
    } catch (e) {
      _logger.error('❌ Error cargando trabajos: $e');
      _logger.error('❌ Tipo de error: ${e.runtimeType}');
      
      // Mostrar error más específico
      String errorMessage = 'Error cargando trabajos';
      if (e.toString().contains('field has not been initialized')) {
        errorMessage = 'Error de inicialización en los datos de trabajos';
      } else if (e.toString().contains('Connection')) {
        errorMessage = 'Error de conexión con el servidor';
      } else {
        errorMessage = 'Error cargando trabajos: ${e.toString()}';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      setState(() => _isLoadingTrabajos = false);
    }
  }

  /// Actualiza el controlador de fecha principal
  void _updateFechaController() {
    if (_fecha != null) {
      _fechaController.text = '${_fecha!.day}/${_fecha!.month}/${_fecha!.year}';
    }
  }

  /// Actualiza el controlador de fecha límite de pago
  void _updateFechaPagoLimiteController() {
    if (_fechaPagoLimite != null) {
      _fechaPagoLimiteController.text = '${_fechaPagoLimite!.day}/${_fechaPagoLimite!.month}/${_fechaPagoLimite!.year}';
    }
  }

  /// Actualiza el controlador de fecha efectiva de pago
  void _updateFechaPagoController() {
    if (_fechaPago != null) {
      _fechaPagoController.text = '${_fechaPago!.day}/${_fechaPago!.month}/${_fechaPago!.year}';
    }
  }

  /// Selecciona una fecha usando el date picker
  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime?) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7E57C2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
      
      // Actualizar el controlador correspondiente
      if (initialDate == _fecha) {
        _updateFechaController();
      } else if (initialDate == _fechaPagoLimite) {
        _updateFechaPagoLimiteController();
      } else if (initialDate == _fechaPago) {
        _updateFechaPagoController();
      }
    }
  }

  /// Construye una sección con título y línea vertical distintiva
  Widget _buildSection({
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título con línea vertical distintiva
        Row(
          children: [
            Container(
              height: 24,
              width: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7E57C2),
                    const Color(0xFF7E57C2).withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Contenido
        content,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.movimiento != null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos'),
        elevation: 0,
        backgroundColor: const Color(0xFF7E57C2), // Color lila de finanzas
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrabajos,
            tooltip: 'Recargar trabajos',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información básica
              _buildSection(
                title: 'Información Básica',
                content: Column(
                  children: [
                    // Tipo de movimiento
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            title: Text(_esCobro ? 'Cobro' : 'Pago'),
                            subtitle: Text(_esCobro ? 'Dinero que recibes' : 'Dinero que pagas'),
                            value: _esCobro,
                            onChanged: (value) => setState(() => _esCobro = value),
                            activeColor: const Color(0xFF7E57C2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Monto
                    CustomTextField(
                      controller: _montoController,
                      label: 'Monto',
                      hint: '0.00',
                      prefixIcon: const Icon(Icons.attach_money),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validateRequired(value, 'Monto'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Descripción
                    CustomTextField(
                      controller: _descripcionController,
                      label: 'Descripción',
                      hint: 'Descripción del movimiento',
                      prefixIcon: const Icon(Icons.description),
                      validator: (value) => Validators.validateRequired(value, 'Descripción'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Categorización
              _buildSection(
                title: 'Categorización',
                content: Column(
                  children: [
                    // Categoría
                    DropdownButtonFormField<String>(
                      value: _categoriaSeleccionada,
                      items: _categorias.map((categoria) => 
                        DropdownMenuItem(
                          value: categoria,
                          child: Text(categoria),
                        )
                      ).toList(),
                      onChanged: (value) => setState(() => _categoriaSeleccionada = value),
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      validator: (value) => Validators.validateRequired(value, 'Categoría'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Forma de pago
                    DropdownButtonFormField<String>(
                      value: _formaPagoSeleccionada,
                      items: _formasPago.map((forma) => 
                        DropdownMenuItem(
                          value: forma,
                          child: Text(forma),
                        )
                      ).toList(),
                      onChanged: (value) => setState(() => _formaPagoSeleccionada = value),
                      decoration: const InputDecoration(
                        labelText: 'Forma de Pago',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payment),
                      ),
                      validator: (value) => Validators.validateRequired(value, 'Forma de pago'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Fechas
              _buildSection(
                title: 'Fechas',
                content: Column(
                  children: [
                    // Fecha del movimiento
                    CustomTextField(
                      controller: _fechaController,
                      label: 'Fecha del Movimiento',
                      hint: 'Seleccionar fecha',
                      prefixIcon: const Icon(Icons.calendar_today),
                      readOnly: true,
                      onTap: () => _selectDate(context, _fecha, (date) => setState(() => _fecha = date)),
                      validator: (value) => Validators.validateRequired(value, 'Fecha'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Fecha límite de pago
                    CustomTextField(
                      controller: _fechaPagoLimiteController,
                      label: 'Fecha Límite de Pago',
                      hint: 'Seleccionar fecha límite',
                      prefixIcon: const Icon(Icons.schedule),
                      readOnly: true,
                      onTap: () => _selectDate(context, _fechaPagoLimite, (date) => setState(() => _fechaPagoLimite = date)),
                    ),
                    const SizedBox(height: 16),
                    
                    // Fecha efectiva de pago
                    CustomTextField(
                      controller: _fechaPagoController,
                      label: 'Fecha Efectiva de Pago',
                      hint: 'Seleccionar fecha de pago',
                      prefixIcon: const Icon(Icons.check_circle),
                      readOnly: true,
                      onTap: () => _selectDate(context, _fechaPago, (date) => setState(() => _fechaPago = date)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Información adicional
              _buildSection(
                title: 'Información Adicional',
                content: Column(
                  children: [
                    // Destinatario
                    CustomTextField(
                      controller: _destinatarioController,
                      label: _esCobro ? 'Cobrar a' : 'Destinatario',
                      hint: _esCobro ? 'Nombre del cliente' : 'Nombre del proveedor',
                      prefixIcon: _esCobro ? const Icon(Icons.person_add) : const Icon(Icons.person),
                    ),
                    const SizedBox(height: 16),
                    
                    // Trabajo relacionado
                    DropdownButtonFormField<int?>(
                      value: _idTrabajo,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null, 
                          child: Text('Sin trabajo relacionado'),
                        ),
                        ..._trabajos.map((trabajo) => 
                          DropdownMenuItem<int?>(
                            value: trabajo.id,
                            child: Text('${trabajo.tipo} - ${trabajo.cultivo}'),
                          )
                        ),
                      ],
                      onChanged: (value) => setState(() => _idTrabajo = value),
                      decoration: InputDecoration(
                        labelText: 'Trabajo Relacionado',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.work),
                        suffixIcon: _isLoadingTrabajos 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Estado de pago
                    SwitchListTile(
                      title: const Text('Pagado'),
                      subtitle: const Text('Marcar si ya fue pagado'),
                      value: _pagado,
                      onChanged: (value) => setState(() => _pagado = value),
                      activeColor: const Color(0xFF7E57C2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF7E57C2)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7E57C2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(isEditing ? 'Actualizar' : 'Crear'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Método para enviar el formulario
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _fecha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos requeridos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      // Verificar que el servicio esté inicializado
      if (!_apiService.isInitialized) {
        _logger.warning('⚠️ ApiService no está inicializado, inicializando...');
        await _apiService.initialize();
      }
      
      _logger.info('💰 ${widget.movimiento == null ? 'Creando' : 'Actualizando'} movimiento...');
      
      // Preparar datos del movimiento
      final movimientoData = {
        'monto': double.parse(_montoController.text.trim()),
        'fecha': _fecha!.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
        'descripcion': _descripcionController.text.trim(),
        'categoria': _categoriaSeleccionada ?? '',
        'pagado': _pagado,
        'forma_pago': _formaPagoSeleccionada ?? '',
        'es_cobro': _esCobro,
        if (_destinatarioController.text.trim().isNotEmpty) 
          'destinatario': _destinatarioController.text.trim(),
        if (_fechaPagoLimite != null) 
          'fecha_pago_limite': _fechaPagoLimite!.toIso8601String().split('T')[0],
        if (_fechaPago != null) 
          'fecha_pago': _fechaPago!.toIso8601String().split('T')[0],
        if (_idTrabajo != null) 
          'id_trabajo': _idTrabajo,
      };

      Movimiento movimiento;

      if (widget.movimiento == null) {
        // Crear nuevo movimiento
        movimiento = await _apiService.createMovimientoCompleto(
          monto: movimientoData['monto'] as double,
          fecha: _fecha!,
          descripcion: movimientoData['descripcion'] as String,
          categoria: movimientoData['categoria'] as String,
          pagado: movimientoData['pagado'] as bool,
          formaPago: movimientoData['forma_pago'] as String,
          esCobro: movimientoData['es_cobro'] as bool,
          destinatario: movimientoData['destinatario'] as String?,
          fechaPagoLimite: _fechaPagoLimite,
          fechaPago: _fechaPago,
          idTrabajo: _idTrabajo,
        );
        
        _logger.info('✅ Movimiento creado exitosamente con ID: ${movimiento.id}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Movimiento creado exitosamente'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Ver',
                textColor: Colors.white,
                onPressed: () {
                  // TODO: Navegar a detalles del movimiento
                },
              ),
            ),
          );
        }
      } else {
        // Actualizar movimiento existente
        movimiento = await _apiService.updateMovimiento(
          widget.movimiento!.id,
          movimientoData,
        );
        
        _logger.info('✅ Movimiento actualizado exitosamente con ID: ${movimiento.id}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Movimiento actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      // Regresar a la pantalla anterior
      if (mounted) {
        Navigator.pop(context, movimiento);
      }
      
    } catch (e) {
      _logger.error('❌ Error ${widget.movimiento == null ? 'creando' : 'actualizando'} movimiento: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${widget.movimiento == null ? 'creando' : 'actualizando'} movimiento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}