import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/optimized_providers.dart';
import '../../widgets/optimized_widgets.dart';
import '../../models/personal.dart';

class RegistrarHorasForm extends ConsumerStatefulWidget {
  final int trabajoId;
  final String trabajoTitulo;

  const RegistrarHorasForm({
    Key? key,
    required this.trabajoId,
    required this.trabajoTitulo,
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

    // Cargar personal si no está cargado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(personalProvider.notifier).loadPersonal();
    });
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
        'hora_inicio': null,
        'hora_fin': null,
        'horas_trabajadas':
            double.tryParse(_horasTrabajadasController.text) ?? 0,
        'hectareas': double.tryParse(_hectareasController.text) ?? 0,
      };

      await ref.read(trabajosProvider.notifier).registrarHoras(data);

      if (mounted) {
        Navigator.pop(context);
        OptimizedSnackBar.showSuccess(context,
            message: 'Horas registradas exitosamente');
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
                    ? personalState.data
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
              OptimizedTextField(
                controller: _fechaController,
                label: 'Fecha',
                prefixIcon: const Icon(Icons.calendar_today),
                onChanged: (_) {}, // ReadOnly handled by tap
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              // Overlay transparente para detectar tap en fecha
              // Mejor usamos un InkWell wrapping el TextField o un GestureDetector,
              // pero como OptimizedTextField es complejo, vamos a asumir que el usuario toca el icono
              // O mejor: Reemplacemos con un InkWell que simula el input

              const SizedBox(height: 16),
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

              const SizedBox(height: 16),

              OptimizedTextField(
                controller: _horasTrabajadasController,
                label: 'Horas Trabajadas',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(Icons.timer),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),

              OptimizedTextField(
                controller: _hectareasController,
                label: 'Hectáreas',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(Icons.confirmation_number),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 32),

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
