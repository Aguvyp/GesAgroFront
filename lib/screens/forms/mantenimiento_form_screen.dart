import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/mantenimiento.dart';
import '../../models/maquina.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/optimized_widgets.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

/// Pantalla completa para crear/editar mantenimientos
class MantenimientoFormScreen extends ConsumerStatefulWidget {
  final Mantenimiento? mantenimiento;
  final DateTime? fechaInicial;
  
  const MantenimientoFormScreen({Key? key, this.mantenimiento, this.fechaInicial}) : super(key: key);

  @override
  ConsumerState<MantenimientoFormScreen> createState() => _MantenimientoFormScreenState();
}

class _MantenimientoFormScreenState extends ConsumerState<MantenimientoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _descripcionController;
  late TextEditingController _costoTotalController;
  DateTime? _fechaSeleccionada;
  
  // Estados del formulario
  Maquina? _maquinaSeleccionada;
  String? _estadoSeleccionado;
  
  // Listas para los selectores
  List<Maquina> _maquinas = [];
  
  bool _isLoadingData = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _descripcionController = TextEditingController(text: widget.mantenimiento?.descripcion ?? '');
    _costoTotalController = TextEditingController(text: widget.mantenimiento?.costoTotal?.toString() ?? '');
    _fechaSeleccionada = widget.fechaInicial ?? widget.mantenimiento?.fecha ?? DateTime.now();
    _estadoSeleccionado = widget.mantenimiento?.estado ?? 'Pendiente';
    
    // Cargar datos necesarios para los selectores
    Future.microtask(() => _loadDataForSelectors());
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _costoTotalController.dispose();
    super.dispose();
  }

  Future<void> _loadDataForSelectors() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      // Cargar máquinas
      final maquinasState = ref.read(maquinasProvider);
      if (maquinasState is LoadedState<List<Maquina>>) {
        _maquinas = maquinasState.data;
      } else {
        await ref.read(maquinasProvider.notifier).loadMaquinas();
        final newMaquinasState = ref.read(maquinasProvider);
        if (newMaquinasState is LoadedState<List<Maquina>>) {
          _maquinas = newMaquinasState.data;
        }
      }

      // Seleccionar máquina existente si estamos editando
      if (widget.mantenimiento != null) {
        _maquinaSeleccionada = _maquinas.firstWhere(
          (maquina) => maquina.id == widget.mantenimiento!.idMaquina,
          orElse: () => _maquinas.isNotEmpty ? _maquinas.first : Maquina(id: 0, nombre: '', modelo: '', marca: '', ano: 0),
        );
      }

      setState(() {
        _isLoadingData = false;
      });
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final data = {
          'id_maquina': _maquinaSeleccionada?.id ?? 0,
          'fecha': _fechaSeleccionada?.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
          'descripcion': _descripcionController.text,
          'costo_total': _costoTotalController.text.isNotEmpty 
              ? double.tryParse(_costoTotalController.text) 
              : null,
          'estado': _estadoSeleccionado ?? 'Pendiente',
        };

        if (widget.mantenimiento == null) {
          // Crear nuevo mantenimiento
          await ref.read(mantenimientosProvider.notifier).createMantenimiento(data);
        } else {
          // Actualizar mantenimiento existente
          await ref.read(mantenimientosProvider.notifier).updateMantenimiento(widget.mantenimiento!.id!, data);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.mantenimiento == null ? 'Mantenimiento creado exitosamente' : 'Mantenimiento actualizado exitosamente'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.mantenimiento == null ? 'Nuevo Mantenimiento' : 'Editar Mantenimiento',
        showBackButton: true,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información básica
                    OptimizedCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información Básica',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          DropdownButtonFormField<Maquina>(
                            decoration: const InputDecoration(
                              labelText: 'Máquina',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.build),
                            ),
                            value: _maquinaSeleccionada,
                            items: _maquinas.map((Maquina maquina) {
                              return DropdownMenuItem<Maquina>(
                                value: maquina,
                                child: Text('${maquina.nombre} - ${maquina.modelo}'),
                              );
                            }).toList(),
                            onChanged: (Maquina? newValue) {
                              setState(() {
                                _maquinaSeleccionada = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'La máquina es requerida';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Seleccione la fecha',
                                  suffixIcon: const Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).cardColor,
                                ),
                                readOnly: true,
                                controller: TextEditingController(
                                  text: _fechaSeleccionada != null
                                      ? '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}'
                                      : 'Seleccionar fecha',
                                ),
                                onTap: _selectDate,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Detalles del mantenimiento
                    OptimizedCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalles del Mantenimiento',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          OptimizedTextField(
                            controller: _descripcionController,
                            label: 'Descripción',
                            hint: 'Descripción del mantenimiento',
                            prefixIcon: const Icon(Icons.description),
                            maxLines: 3,
                            validator: (value) => Validators.validateRequired(value, 'Descripción'),
                          ),
                          const SizedBox(height: 24),
                          OptimizedTextField(
                            controller: _costoTotalController,
                            label: 'Costo Total',
                            hint: 'Ingrese el costo total',
                            prefixIcon: const Icon(Icons.attach_money),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 24),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Estado',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.check_circle),
                            ),
                            value: _estadoSeleccionado,
                            items: AppConstants.estadosMantenimiento.map((String estado) {
                              return DropdownMenuItem<String>(
                                value: estado,
                                child: Text(estado.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _estadoSeleccionado = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El estado es requerido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Guardando...'),
                                ],
                              )
                            : Text(widget.mantenimiento == null ? 'Crear Mantenimiento' : 'Actualizar Mantenimiento'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}