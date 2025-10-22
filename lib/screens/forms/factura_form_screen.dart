import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/factura.dart';
import '../../services/optimized_api_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/logger/app_logger.dart';
import '../../utils/validators.dart';

/// Pantalla completa para crear/editar facturas
class FacturaFormScreen extends ConsumerStatefulWidget {
  final Factura? factura;
  
  const FacturaFormScreen({Key? key, this.factura}) : super(key: key);

  @override
  ConsumerState<FacturaFormScreen> createState() => _FacturaFormScreenState();
}

class _FacturaFormScreenState extends ConsumerState<FacturaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final AppLogger _logger = AppLogger.instance;
  
  // Controladores de texto
  late TextEditingController _numeroController;
  late TextEditingController _clienteController;
  late TextEditingController _subtotalController;
  late TextEditingController _impuestosController;
  late TextEditingController _totalController;
  late TextEditingController _fechaEmisionController;
  late TextEditingController _fechaVencimientoController;
  
  // Estados del formulario
  DateTime? _fechaEmision;
  DateTime? _fechaVencimiento;
  String? _estadoSeleccionado;
  bool _isSaving = false;

  final List<String> _estados = [
    'Borrador',
    'Enviada',
    'Pagada',
    'Vencida',
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.factura;
    
    // Inicializar controladores
    _numeroController = TextEditingController(text: f?.numero ?? '');
    _clienteController = TextEditingController(text: f?.clienteId.toString() ?? '');
    _subtotalController = TextEditingController(text: f?.montoTotal.toString() ?? '');
    _impuestosController = TextEditingController(text: '0.0');
    _totalController = TextEditingController(text: f?.montoTotal.toString() ?? '');
    _fechaEmisionController = TextEditingController();
    _fechaVencimientoController = TextEditingController();
    
    // Inicializar estados
    _fechaEmision = f?.fechaEmision ?? DateTime.now();
    _fechaVencimiento = f?.fechaVencimiento;
    _estadoSeleccionado = f?.estado ?? _estados.first;
    
    // Actualizar controladores de fecha
    _updateFechaEmisionController();
    _updateFechaVencimientoController();
    
    // Inicializar el servicio API
    _initializeApiService();
  }

  /// Inicializar el servicio API
  Future<void> _initializeApiService() async {
    try {
      await _apiService.initialize();
      _logger.info('✅ ApiService inicializado correctamente');
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
    _numeroController.dispose();
    _clienteController.dispose();
    _subtotalController.dispose();
    _impuestosController.dispose();
    _totalController.dispose();
    _fechaEmisionController.dispose();
    _fechaVencimientoController.dispose();
    super.dispose();
  }

  /// Actualiza el controlador de fecha de emisión
  void _updateFechaEmisionController() {
    if (_fechaEmision != null) {
      _fechaEmisionController.text = '${_fechaEmision!.day}/${_fechaEmision!.month}/${_fechaEmision!.year}';
    }
  }

  /// Actualiza el controlador de fecha de vencimiento
  void _updateFechaVencimientoController() {
    if (_fechaVencimiento != null) {
      _fechaVencimientoController.text = '${_fechaVencimiento!.day}/${_fechaVencimiento!.month}/${_fechaVencimiento!.year}';
    }
  }

  /// Selecciona una fecha usando el date picker
  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime?) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
      
      // Actualizar el controlador correspondiente
      if (initialDate == _fechaEmision) {
        _updateFechaEmisionController();
      } else if (initialDate == _fechaVencimiento) {
        _updateFechaVencimientoController();
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

  /// Calcula el total automáticamente
  void _calculateTotal() {
    final subtotal = double.tryParse(_subtotalController.text) ?? 0.0;
    final impuestos = double.tryParse(_impuestosController.text) ?? 0.0;
    final total = subtotal + impuestos;
    _totalController.text = total.toStringAsFixed(2);
  }

  /// Guarda la factura
  Future<void> _saveFactura() async {
    if (!_formKey.currentState!.validate()) {
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

      _logger.info('📄 ${widget.factura == null ? 'Creando' : 'Actualizando'} factura...');

      // Preparar datos de la factura
      final facturaData = {
        'numero': _numeroController.text.trim(),
        'cliente_id': int.parse(_clienteController.text.trim()),
        'monto_total': double.parse(_totalController.text.trim()),
        'fecha_emision': _fechaEmision!.toIso8601String().split('T')[0],
        'estado': _estadoSeleccionado ?? '',
        if (_fechaVencimiento != null)
          'fecha_vencimiento': _fechaVencimiento!.toIso8601String().split('T')[0],
      };

      if (widget.factura == null) {
        // Crear nueva factura
        await _apiService.createFactura(facturaData);
        _logger.info('✅ Factura creada exitosamente');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Factura creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Actualizar factura existente
        await _apiService.updateFactura(widget.factura!.id, facturaData);
        _logger.info('✅ Factura actualizada exitosamente');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Factura actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _logger.error('❌ Error ${widget.factura == null ? 'creando' : 'actualizando'} factura: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${widget.factura == null ? 'creando' : 'actualizando'} factura: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.factura != null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturas'),
        elevation: 0,
        backgroundColor: const Color(0xFF7E57C2), // Color lila de finanzas
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                    // Número de factura
                    CustomTextField(
                      controller: _numeroController,
                      label: 'Número de Factura',
                      hint: 'Ingrese el número de factura',
                      prefixIcon: const Icon(Icons.receipt_long),
                      validator: (value) => Validators.validateRequired(value, 'Número de factura'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Cliente ID
                    CustomTextField(
                      controller: _clienteController,
                      label: 'ID Cliente',
                      hint: 'Ingrese el ID del cliente',
                      prefixIcon: const Icon(Icons.person),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validateRequired(value, 'ID Cliente'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Estado
                    DropdownButtonFormField<String>(
                      value: _estadoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(Icons.flag),
                        border: OutlineInputBorder(),
                      ),
                      items: _estados.map((String estado) {
                        return DropdownMenuItem<String>(
                          value: estado,
                          child: Text(estado),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _estadoSeleccionado = newValue;
                        });
                      },
                      validator: (value) => Validators.validateRequired(value, 'Estado'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Fechas
              _buildSection(
                title: 'Fechas',
                content: Column(
                  children: [
                    // Fecha de emisión
                    CustomTextField(
                      controller: _fechaEmisionController,
                      label: 'Fecha de Emisión',
                      hint: 'Seleccione la fecha de emisión',
                      prefixIcon: const Icon(Icons.calendar_today),
                      readOnly: true,
                      onTap: () => _selectDate(context, _fechaEmision, (date) {
                        setState(() => _fechaEmision = date);
                      }),
                      validator: (value) => Validators.validateRequired(value, 'Fecha de emisión'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Fecha de vencimiento
                    CustomTextField(
                      controller: _fechaVencimientoController,
                      label: 'Fecha de Vencimiento',
                      hint: 'Seleccione la fecha de vencimiento',
                      prefixIcon: const Icon(Icons.event),
                      readOnly: true,
                      onTap: () => _selectDate(context, _fechaVencimiento, (date) {
                        setState(() => _fechaVencimiento = date);
                      }),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Montos
              _buildSection(
                title: 'Montos',
                content: Column(
                  children: [
                    // Subtotal
                    CustomTextField(
                      controller: _subtotalController,
                      label: 'Subtotal',
                      hint: 'Ingrese el subtotal',
                      prefixIcon: const Icon(Icons.attach_money),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateTotal(),
                      validator: (value) => Validators.validateRequired(value, 'Subtotal'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Impuestos
                    CustomTextField(
                      controller: _impuestosController,
                      label: 'Impuestos',
                      hint: 'Ingrese los impuestos',
                      prefixIcon: const Icon(Icons.calculate),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateTotal(),
                      validator: (value) => Validators.validateRequired(value, 'Impuestos'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Total (calculado automáticamente)
                    CustomTextField(
                      controller: _totalController,
                      label: 'Total',
                      hint: 'Total calculado automáticamente',
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                      readOnly: true,
                      enabled: false,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Botón de guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveFactura,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E57C2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Guardando...'),
                          ],
                        )
                      : Text(
                          isEditing ? 'Actualizar Factura' : 'Crear Factura',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}