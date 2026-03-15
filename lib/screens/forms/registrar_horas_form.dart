import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/optimized_providers.dart';
import '../../services/optimized_api_service.dart';
import '../../widgets/optimized_widgets.dart';
import '../../models/personal.dart';

class RegistrarHorasForm extends ConsumerStatefulWidget {
  final int trabajoId;
  final String trabajoTitulo;

  final int? trabajoPersonalId;
  final int? initialPersonalId;
  final double? initialHoras;
  final double? initialHectareas;
  final double? maxHectares;

  const RegistrarHorasForm({
    Key? key,
    required this.trabajoId,
    required this.trabajoTitulo,
    this.trabajoPersonalId,
    this.initialPersonalId,
    this.initialHoras,
    this.initialHectareas,
    this.maxHectares,
  }) : super(key: key);

  @override
  ConsumerState<RegistrarHorasForm> createState() => _RegistrarHorasFormState();
}

class _RegistrarHorasFormState extends ConsumerState<RegistrarHorasForm> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _fechaController = TextEditingController();
  final _horasTrabajadasController = TextEditingController();
  final _hectareasController = TextEditingController();

  // Estado
  Personal? _selectedPersonal;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fechaController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);

    if (widget.initialHoras != null) {
      _horasTrabajadasController.text = widget.initialHoras!.toStringAsFixed(0);
    }
    if (widget.initialHectareas != null) {
      _hectareasController.text = widget.initialHectareas!.toStringAsFixed(0);
    }

    // Cargar personal si no está cargado
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(personalProvider.notifier).loadPersonal();

      if (widget.initialPersonalId != null) {
        final state = ref.read(personalProvider);
        if (state is LoadedState<List<Personal>>) {
          setState(() {
            _selectedPersonal = state.data.firstWhere(
              (p) => p.id == widget.initialPersonalId,
              orElse: () => state.data.first,
            );
          });
        }
      }

      // Si tenemos un ID de TrabajoPersonal, cargamos sus datos específicos
      if (widget.trabajoPersonalId != null) {
        _loadTrabajoPersonalData();
      }
    });
  }

  /// Deduplicates a list of Personal by id to prevent DropdownButtonFormField assertion errors
  List<Personal> _deduplicatePersonal(List<Personal> list) {
    final seen = <int?>{};
    return list.where((p) => seen.add(p.id)).toList();
  }

  Future<void> _loadTrabajoPersonalData() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final data =
          await apiService.getTrabajoPersonal(widget.trabajoPersonalId!);

      if (mounted) {
        setState(() {
          if (data['horas'] != null) {
            _horasTrabajadasController.text = data['horas'].toString();
          } else if (data['horas_trabajadas'] != null) {
            _horasTrabajadasController.text =
                data['horas_trabajadas'].toString();
          }

          if (data['ha'] != null) {
            _hectareasController.text = data['ha'].toString();
          } else if (data['hectareas'] != null) {
            _hectareasController.text = data['hectareas'].toString();
          }

          if (data['fecha'] != null) {
            _selectedDate = DateTime.parse(data['fecha']);
            _fechaController.text =
                DateFormat('yyyy-MM-dd').format(_selectedDate);
          }
        });
      }
    } catch (e) {
      print('Error cargando datos de TrabajoPersonal: $e');
    }
  }

  Future<void> _deleteRegistro() async {
    if (widget.trabajoPersonalId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: const Text(
            '¿Está seguro de que desea eliminar este registro de horas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.deleteTrabajoPersonal(widget.trabajoPersonalId!);

      if (mounted) {
        OptimizedSnackBar.showSuccess(context,
            message: 'Registro eliminado exitosamente');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        OptimizedSnackBar.showError(context,
            message: 'Error al eliminar registro: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _horasTrabajadasController.dispose();
    _hectareasController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPersonal == null) {
      OptimizedSnackBar.showError(context, message: 'Selecciona un personal');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'trabajo': widget.trabajoId,
        'personal': _selectedPersonal!.id,
        'fecha': _fechaController.text,
        'horas_trabajadas':
            double.tryParse(_horasTrabajadasController.text) ?? 0,
        'hectareas': double.tryParse(_hectareasController.text) ?? 0,
      };

      final apiService = ref.read(apiServiceProvider);

      if (widget.trabajoPersonalId != null) {
        // Actualizar existente
        await apiService.updateTrabajoPersonal(widget.trabajoPersonalId!, data);
        if (mounted) {
          OptimizedSnackBar.showSuccess(context,
              message: 'Registro actualizado exitosamente');
          Navigator.pop(context);
        }
      } else {
        // Crear nuevo
        final result =
            await ref.read(trabajosProvider.notifier).registrarHoras(data);

        if (mounted) {
          if (result['detail'] != null) {
            OptimizedSnackBar.show(
              context,
              message: result['detail'],
              backgroundColor: Colors.amber[700],
            );
            // No hacemos pop aqui para permitir correccion
          } else {
            OptimizedSnackBar.showSuccess(context,
                message: 'Horas registradas exitosamente');
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        OptimizedSnackBar.showError(context,
            message: 'Error al registrar horas: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final personalState = ref.watch(personalProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Registrar Horas',
            style: TextStyle(color: Colors.black)),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Trabajo: ${widget.trabajoTitulo}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 24),

              // Selector de Personal
              DropdownButtonFormField<Personal>(
                decoration: InputDecoration(
                  labelText: 'Personal',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.person),
                ),
                value: _selectedPersonal,
                items: personalState is LoadedState<List<Personal>>
                    ? _deduplicatePersonal(personalState.data)
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.nombre),
                            ))
                        .toList()
                    : [],
                onChanged: (value) {
                  setState(() {
                    _selectedPersonal = value;
                  });
                },
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Fecha
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: OptimizedTextField(
                    controller: _fechaController,
                    label: 'Fecha',
                    prefixIcon: const Icon(Icons.calendar_today),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              OptimizedTextField(
                controller: _horasTrabajadasController,
                label: 'Horas Trabajadas',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(Icons.timer),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 16),

              OptimizedTextField(
                controller: _hectareasController,
                label: 'Hectáreas',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(Icons.confirmation_number),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),

              if (widget.maxHectares != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Text(
                    'Disponible: ${widget.maxHectares!.toStringAsFixed(2)} ha',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.amber[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              if (widget.trabajoPersonalId != null)
                Row(
                  children: [
                    Expanded(
                      child: OptimizedButton(
                        text: 'Guardar',
                        onPressed: _isLoading ? null : _submit,
                        isLoading: _isLoading,
                        isFullWidth: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OptimizedButton(
                        text: 'Eliminar',
                        onPressed: _isLoading ? null : _deleteRegistro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        isFullWidth: true,
                        icon: Icons.delete_outline,
                      ),
                    ),
                  ],
                )
              else
                OptimizedButton(
                  text: 'Guardar Horas',
                  onPressed: _isLoading ? null : _submit,
                  isLoading: _isLoading,
                  isFullWidth: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
