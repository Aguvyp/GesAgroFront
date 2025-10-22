import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/credito.dart';
import '../../services/optimized_api_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/logger/app_logger.dart';
import '../../utils/validators.dart';

/// Pantalla completa para crear/editar créditos
class CreditoFormScreen extends ConsumerStatefulWidget {
  final Credito? credito;
  
  const CreditoFormScreen({Key? key, this.credito}) : super(key: key);

  @override
  ConsumerState<CreditoFormScreen> createState() => _CreditoFormScreenState();
}

class _CreditoFormScreenState extends ConsumerState<CreditoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final AppLogger _logger = AppLogger.instance;
  
  // Controladores de texto
  late TextEditingController _entidadController;
  late TextEditingController _montoOtorgadoController;
  late TextEditingController _tasaInteresController;
  late TextEditingController _plazoMesesController;
  late TextEditingController _fechaDesembolsoController;
  
  // Estados del formulario
  DateTime? _fechaDesembolso;
  String? _estadoSeleccionado;
  bool _isSaving = false;

  final List<String> _estados = [
    'Activo',
    'Finalizado',
    'Cancelado',
    'Suspendido',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.credito;
    
    // Inicializar controladores
    _entidadController = TextEditingController(text: c?.entidad ?? '');
    _montoOtorgadoController = TextEditingController(text: c?.montoOtorgado.toString() ?? '');
    _tasaInteresController = TextEditingController(text: c?.tasaInteresAnual.toString() ?? '');
    _plazoMesesController = TextEditingController(text: c?.plazoMeses.toString() ?? '');
    _fechaDesembolsoController = TextEditingController();
    
    // Inicializar estados
    _fechaDesembolso = c?.fechaDesembolso ?? DateTime.now();
    _estadoSeleccionado = c?.estado ?? _estados.first;
    
    // Actualizar controladores de fecha
    _updateFechaDesembolsoController();
    
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
    _entidadController.dispose();
    _montoOtorgadoController.dispose();
    _tasaInteresController.dispose();
    _plazoMesesController.dispose();
    _fechaDesembolsoController.dispose();
    super.dispose();
  }

  /// Actualiza el controlador de fecha de desembolso
  void _updateFechaDesembolsoController() {
    if (_fechaDesembolso != null) {
      _fechaDesembolsoController.text = '${_fechaDesembolso!.day}/${_fechaDesembolso!.month}/${_fechaDesembolso!.year}';
    }
  }

  /// Selecciona una fecha usando el date picker
  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime?) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)), // 10 años
    );
    
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
      
      // Actualizar el controlador correspondiente
      if (initialDate == _fechaDesembolso) {
        _updateFechaDesembolsoController();
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

  /// Guarda el crédito
  Future<void> _saveCredito() async {
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

      _logger.info('💳 ${widget.credito == null ? 'Creando' : 'Actualizando'} crédito...');

      // Preparar datos del crédito
      final creditoData = {
        'entidad': _entidadController.text.trim(),
        'monto_otorgado': double.parse(_montoOtorgadoController.text.trim()),
        'tasa_interes_anual': double.parse(_tasaInteresController.text.trim()),
        'plazo_meses': int.parse(_plazoMesesController.text.trim()),
        'fecha_desembolso': _fechaDesembolso!.toIso8601String().split('T')[0],
        'estado': _estadoSeleccionado ?? '',
      };

      if (widget.credito == null) {
        // Crear nuevo crédito
        await _apiService.createCredito(creditoData);
        _logger.info('✅ Crédito creado exitosamente');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Crédito creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Actualizar crédito existente
        await _apiService.updateCredito(widget.credito!.id, creditoData);
        _logger.info('✅ Crédito actualizado exitosamente');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Crédito actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _logger.error('❌ Error ${widget.credito == null ? 'creando' : 'actualizando'} crédito: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${widget.credito == null ? 'creando' : 'actualizando'} crédito: $e'),
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
    final isEditing = widget.credito != null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créditos'),
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
                    // Entidad
                    CustomTextField(
                      controller: _entidadController,
                      label: 'Entidad Financiera',
                      hint: 'Ingrese el nombre de la entidad',
                      prefixIcon: const Icon(Icons.account_balance),
                      validator: (value) => Validators.validateRequired(value, 'Entidad financiera'),
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
              
              // Montos y términos
              _buildSection(
                title: 'Montos y Términos',
                content: Column(
                  children: [
                    // Monto otorgado
                    CustomTextField(
                      controller: _montoOtorgadoController,
                      label: 'Monto Otorgado',
                      hint: 'Ingrese el monto del crédito',
                      prefixIcon: const Icon(Icons.attach_money),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validateRequired(value, 'Monto otorgado'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Tasa de interés
                    CustomTextField(
                      controller: _tasaInteresController,
                      label: 'Tasa de Interés (%)',
                      hint: 'Ingrese la tasa de interés',
                      prefixIcon: const Icon(Icons.percent),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validateRequired(value, 'Tasa de interés'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Plazo en meses
                    CustomTextField(
                      controller: _plazoMesesController,
                      label: 'Plazo (Meses)',
                      hint: 'Ingrese el plazo en meses',
                      prefixIcon: const Icon(Icons.schedule),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validateRequired(value, 'Plazo en meses'),
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
                    // Fecha de desembolso
                    CustomTextField(
                      controller: _fechaDesembolsoController,
                      label: 'Fecha de Desembolso',
                      hint: 'Seleccione la fecha de desembolso',
                      prefixIcon: const Icon(Icons.calendar_today),
                      readOnly: true,
                      onTap: () => _selectDate(context, _fechaDesembolso, (date) {
                        setState(() => _fechaDesembolso = date);
                      }),
                      validator: (value) => Validators.validateRequired(value, 'Fecha de desembolso'),
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
                  onPressed: _isSaving ? null : _saveCredito,
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
                          isEditing ? 'Actualizar Crédito' : 'Crear Crédito',
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