import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../providers/trabajo_detalle_provider.dart';
import '../../models/campo.dart';
import '../../models/maquina.dart';
import '../../models/personal.dart';
import '../../models/cliente.dart';
import '../../models/personal_con_hectareas.dart';
import '../../models/trabajo_detalle.dart';
import '../../services/cliente_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';
import 'campo_form_screen.dart';
import 'maquina_form_screen.dart';
import 'personal_form_screen.dart';
import 'cliente_form_screen.dart';

/// Pantalla completa para crear/editar trabajos
class TrabajoFormScreen extends ConsumerStatefulWidget {
  final dynamic trabajo;
  
  const TrabajoFormScreen({Key? key, this.trabajo}) : super(key: key);

  @override
  ConsumerState<TrabajoFormScreen> createState() => _TrabajoFormScreenState();
}

class _TrabajoFormScreenState extends ConsumerState<TrabajoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tipoController;
  late TextEditingController _cultivoController;
  late TextEditingController _descripcionController;
  late TextEditingController _fechaInicioController;
  late TextEditingController _fechaFinController;
  late TextEditingController _clienteController;
  late TextEditingController _montoCobradoController;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  
  // Estados adicionales
  String? _estadoSeleccionado;
  bool _esTercero = false;
  bool _cobrado = false;
  
  // Selectores
  Campo? _campoSeleccionado;
  List<Maquina> _maquinasSeleccionadas = [];
  List<PersonalConHectareas> _personalSeleccionado = [];
  
  // Listas para los selectores
  List<Campo> _campos = [];
  List<Maquina> _maquinas = [];
  List<Personal> _personal = [];
  
  // Variables para cliente y campos filtrados
  Cliente? _clienteSeleccionado;
  List<Campo> _camposFiltrados = []; // Campos filtrados por cliente
  List<Cliente> _clientes = [];
  
  // Estados para selectores expandibles
  bool _maquinasExpanded = false;
  bool _personalExpanded = false;
  bool _camposExpanded = false;
  bool _clientesExpanded = false;
  
  bool _isLoadingData = false;
  bool _isSaving = false;
  
  // Detalles del trabajo para edición
  TrabajoDetalle? _trabajoDetalle;

  @override
  void initState() {
    super.initState();
    _tipoController = TextEditingController(text: widget.trabajo?.tipo ?? '');
    _cultivoController = TextEditingController(text: widget.trabajo?.cultivo ?? '');
    _descripcionController = TextEditingController(text: widget.trabajo?.observaciones ?? '');
    _fechaInicioController = TextEditingController(text: widget.trabajo?.fechaInicio?.toString() ?? '');
    _fechaFinController = TextEditingController(text: widget.trabajo?.fechaFin?.toString() ?? '');
    _clienteController = TextEditingController(text: widget.trabajo?.cliente ?? '');
    _montoCobradoController = TextEditingController(text: widget.trabajo?.montoCobrado?.toString() ?? '');
    _fechaInicio = widget.trabajo?.fechaInicio ?? DateTime.now();
    _fechaFin = widget.trabajo?.fechaFin ?? DateTime.now();
    
    // Estados adicionales
    _estadoSeleccionado = widget.trabajo?.estado ?? 'Pendiente';
    
    // FORZAR VALORES CORRECTOS PARA DEBUG
    if (widget.trabajo != null) {
      // Si hay un trabajo, usar sus valores reales
      _esTercero = widget.trabajo!.esTercero;
      _cobrado = widget.trabajo!.cobrado;
    } else {
      // Si es un trabajo nuevo, valores por defecto
      _esTercero = false;
      _cobrado = false;
    }
    
    // Cargar datos necesarios para los selectores
    Future.microtask(() => _loadDataForSelectors());
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _cultivoController.dispose();
    _descripcionController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _clienteController.dispose();
    _montoCobradoController.dispose();
    super.dispose();
  }

  Future<void> _loadDataForSelectors() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      // Si estamos editando un trabajo, cargar sus detalles completos primero
      if (widget.trabajo != null && widget.trabajo!.id != null) {
        try {
          await ref.read(trabajoDetalleProvider.notifier).loadTrabajoDetalle(widget.trabajo!.id!);
          final trabajoDetalleState = ref.read(trabajoDetalleProvider);
          if (trabajoDetalleState is AsyncData<TrabajoDetalle?>) {
            _trabajoDetalle = trabajoDetalleState.value;
          }
        } catch (e) {
          print('Error cargando detalles del trabajo: $e');
        }
      }

      // Cargar campos
      final camposState = ref.read(camposProvider);
      if (camposState is LoadedState<List<Campo>>) {
        _campos = camposState.data;
      } else {
        await ref.read(camposProvider.notifier).loadCampos();
        final newCamposState = ref.read(camposProvider);
        if (newCamposState is LoadedState<List<Campo>>) {
          _campos = newCamposState.data;
        }
      }

      // Cargar clientes
      try {
        _clientes = await ClienteService.getClientes();
      } catch (e) {
        print('Error cargando clientes: $e');
        _clientes = [];
      }

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

      // Cargar personal
      final personalState = ref.read(personalProvider);
      if (personalState is LoadedState<List<Personal>>) {
        _personal = personalState.data;
      } else {
        await ref.read(personalProvider.notifier).loadPersonal();
        final newPersonalState = ref.read(personalProvider);
        if (newPersonalState is LoadedState<List<Personal>>) {
          _personal = newPersonalState.data;
        }
      }

      // Aplicar filtros según el estado actual
      await _aplicarFiltrosCampos();

      // Seleccionar elementos existentes del trabajo usando los detalles completos
      if (_trabajoDetalle != null) {
        // Seleccionar cliente si es trabajo a terceros
        if (_trabajoDetalle!.aTerceros && _trabajoDetalle!.clienteInfo != null) {
          _clienteSeleccionado = _clientes.firstWhere(
            (cliente) => cliente.id == _trabajoDetalle!.clienteInfo!.id,
            orElse: () => _clientes.isNotEmpty ? _clientes.first : Cliente(id: 0, nombre: ''),
          );
        }

        // Seleccionar campo
        _campoSeleccionado = _camposFiltrados.firstWhere(
          (campo) => campo.id == _trabajoDetalle!.campoId,
          orElse: () => _camposFiltrados.isNotEmpty ? _camposFiltrados.first : Campo(id: 0, nombre: '', superficieHa: 0),
        );

        // Seleccionar máquinas usando los detalles completos
        _maquinasSeleccionadas = _maquinas.where(
          (maquina) => _trabajoDetalle!.maquinas.any((maq) => maq.id == maquina.id),
        ).toList();

        // Seleccionar personal usando los detalles completos
        _personalSeleccionado = _personal.where(
          (persona) => _trabajoDetalle!.personal.any((per) => per.id == persona.id),
        ).map((persona) {
          // Buscar las hectáreas específicas de este personal en el trabajo
          final personalTrabajo = _trabajoDetalle!.personal.firstWhere(
            (per) => per.id == persona.id,
            orElse: () => PersonalTrabajo(id: persona.id!, nombre: persona.nombre, dni: persona.dni, ha: _campoSeleccionado?.superficieHa ?? 0.0),
          );
          
          return PersonalConHectareas(
            id: persona.id!,
            nombre: persona.nombre,
            dni: persona.dni,
            hectareas: personalTrabajo.ha,
          );
        }).toList();
      } else if (widget.trabajo != null) {
        // Fallback para trabajos sin detalles completos
        // Seleccionar cliente si es trabajo a terceros
        if (_esTercero && widget.trabajo!.cliente != null) {
          _clienteSeleccionado = _clientes.firstWhere(
            (cliente) => cliente.nombre == widget.trabajo!.cliente,
            orElse: () => _clientes.isNotEmpty ? _clientes.first : Cliente(id: 0, nombre: ''),
          );
        }

        // Seleccionar campo
        _campoSeleccionado = _camposFiltrados.firstWhere(
          (campo) => campo.id == widget.trabajo!.idCampo,
          orElse: () => _camposFiltrados.isNotEmpty ? _camposFiltrados.first : Campo(id: 0, nombre: '', superficieHa: 0),
        );
      }
    } catch (e) {
      // Manejar errores silenciosamente
      print('Error cargando datos para selectores: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  // Método para aplicar filtros de campos según el cliente seleccionado
  Future<void> _aplicarFiltrosCampos() async {
    if (_esTercero && _clienteSeleccionado != null) {
      // Si es trabajo a terceros y hay cliente seleccionado, cargar solo sus campos
      try {
        _camposFiltrados = await ClienteService.getCamposByCliente(_clienteSeleccionado!.id!);
      } catch (e) {
        print('Error cargando campos del cliente: $e');
        _camposFiltrados = [];
      }
    } else {
      // Si no es trabajo a terceros, mostrar todos los campos propios
      _camposFiltrados = List.from(_campos);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.trabajo == null ? 'Nuevo Trabajo' : 'Editar Trabajo',
        showBackButton: true,
        actions: [
          if (!_isLoadingData)
            TextButton(
              onPressed: _isSaving ? null : _submitForm,
              child: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    widget.trabajo == null ? 'Guardar' : 'Actualizar',
                    style: const TextStyle(color: Colors.white),
                  ),
            ),
        ],
      ),
      body: _isLoadingData
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando datos...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo de trabajo
                    CustomTextField(
                      controller: _tipoController,
                      label: 'Tipo de Trabajo',
                      hint: 'Ej: Siembra, Cosecha, Pulverización',
                      prefixIcon: const Icon(Icons.work),
                      validator: (value) => Validators.validateRequired(value, 'Tipo de trabajo'),
                    ),
                    const SizedBox(height: 16),

                    // Cultivo
                    CustomTextField(
                      controller: _cultivoController,
                      label: 'Cultivo',
                      hint: 'Ej: Soja, Maíz, Trigo',
                      prefixIcon: const Icon(Icons.eco),
                      validator: (value) => Validators.validateRequired(value, 'Cultivo'),
                    ),
                    const SizedBox(height: 16),

                    // Tercero?
                    SwitchListTile(
                      title: const Text('Trabajo a terceros'),
                      subtitle: const Text('Marcar si el trabajo es para un cliente'),
                      value: _esTercero,
                      onChanged: (value) async {
                        setState(() {
                          _esTercero = value;
                        });
                        
                        // Limpiar selecciones si se desactiva "a terceros"
                        if (!value) {
                          _clienteSeleccionado = null;
                          _clienteController.clear();
                          _campoSeleccionado = null;
                        }
                        
                        // Aplicar filtros de campos
                        await _aplicarFiltrosCampos();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Selector de Cliente (solo visible si es a terceros)
                    if (_esTercero) ...[
                      _buildExpandableSelector(
                        title: 'Cliente',
                        subtitle: _clienteSeleccionado?.nombre ?? 'Seleccionar cliente',
                        isExpanded: _clientesExpanded,
                        onToggle: () => setState(() => _clientesExpanded = !_clientesExpanded),
                        onAddPressed: () => _showClienteForm(),
                        addButtonText: 'Nuevo',
                        child: _buildClientesSelector(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Campo
                    _buildExpandableSelector(
                      title: 'Campo',
                      subtitle: _campoSeleccionado?.nombre ?? 'Seleccionar campo',
                      isExpanded: _camposExpanded,
                      onToggle: () => setState(() => _camposExpanded = !_camposExpanded),
                      onAddPressed: () => _showCampoForm(),
                      addButtonText: 'Nuevo',
                      child: _buildCamposSelector(),
                    ),
                    const SizedBox(height: 16),

                    // Máquinas
                    _buildExpandableSelector(
                      title: 'Máquinas',
                      subtitle: '${_maquinasSeleccionadas.length} seleccionadas',
                      isExpanded: _maquinasExpanded,
                      onToggle: () => setState(() => _maquinasExpanded = !_maquinasExpanded),
                      onAddPressed: () => _showMaquinaForm(),
                      addButtonText: 'Nueva',
                      child: _buildMaquinasSelector(),
                    ),
                    const SizedBox(height: 16),

                    // Personal/Operarios
                    _buildExpandableSelector(
                      title: 'Personal/Operarios',
                      subtitle: '${_personalSeleccionado.length} seleccionados',
                      isExpanded: _personalExpanded,
                      onToggle: () => setState(() => _personalExpanded = !_personalExpanded),
                      onAddPressed: () => _showPersonalForm(),
                      addButtonText: 'Nuevo',
                      child: _buildPersonalSelector(),
                    ),
                    const SizedBox(height: 16),

                    // Fechas
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _fechaInicioController,
                            label: 'Fecha de Inicio',
                            hint: 'Seleccione la fecha',
                            prefixIcon: const Icon(Icons.calendar_today),
                            readOnly: true,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _fechaInicio ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() {
                                  _fechaInicio = date;
                                  _fechaInicioController.text = '${date.day}/${date.month}/${date.year}';
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _fechaFinController,
                            label: 'Fecha de Fin',
                            hint: 'Seleccione la fecha',
                            prefixIcon: const Icon(Icons.calendar_today),
                            readOnly: true,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _fechaFin ?? DateTime.now(),
                                firstDate: _fechaInicio ?? DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() {
                                  _fechaFin = date;
                                  _fechaFinController.text = '${date.day}/${date.month}/${date.year}';
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Estado
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(),
                      ),
                      value: _estadoSeleccionado,
                      items: const [
                        DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                        DropdownMenuItem(value: 'En progreso', child: Text('En progreso')),
                        DropdownMenuItem(value: 'Completado', child: Text('Completado')),
                        DropdownMenuItem(value: 'Cancelado', child: Text('Cancelado')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _estadoSeleccionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Cobrado
                    SwitchListTile(
                      title: const Text('Cobrado'),
                      subtitle: const Text('Marcar si ya se cobró el trabajo'),
                      value: _cobrado,
                      onChanged: (value) {
                        setState(() {
                          _cobrado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Monto total (solo si está cobrado)
                    if (_cobrado) ...[
                      CustomTextField(
                        controller: _montoCobradoController,
                        label: 'Monto Total',
                        hint: 'Ingrese el monto cobrado',
                        prefixIcon: const Icon(Icons.attach_money),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (_cobrado && (value == null || value.isEmpty)) {
                            return 'El monto es requerido si está cobrado';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Descripción
                    CustomTextField(
                      controller: _descripcionController,
                      label: 'Descripción',
                      hint: 'Detalles adicionales del trabajo',
                      prefixIcon: const Icon(Icons.description),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving ? null : () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _submitForm,
                            child: _isSaving 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(widget.trabajo == null ? 'Crear Trabajo' : 'Actualizar Trabajo'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildExpandableSelector({
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onToggle,
    required VoidCallback onAddPressed,
    required String addButtonText,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add, size: 18),
              label: Text(addButtonText),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          child,
        ],
      ],
    );
  }

  Widget _buildClientesSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _clientes.isEmpty
          ? const Text(
              'No hay clientes disponibles',
              style: TextStyle(color: Colors.grey),
            )
          : Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _clientes.length,
                itemBuilder: (context, index) {
                  final cliente = _clientes[index];
                  return ListTile(
                    title: Text(cliente.nombre),
                    subtitle: cliente.email != null ? Text(cliente.email!) : null,
                    leading: Radio<Cliente>(
                      value: cliente,
                      groupValue: _clienteSeleccionado,
                      onChanged: (Cliente? value) async {
                        setState(() {
                          _clienteSeleccionado = value;
                          _clienteController.text = value?.nombre ?? '';
                          _campoSeleccionado = null; // Limpiar campo seleccionado
                        });
                        // Aplicar filtros de campos para el cliente seleccionado
                        await _aplicarFiltrosCampos();
                      },
                    ),
                    onTap: () async {
                      setState(() {
                        _clienteSeleccionado = cliente;
                        _clienteController.text = cliente.nombre;
                        _campoSeleccionado = null; // Limpiar campo seleccionado
                      });
                      // Aplicar filtros de campos para el cliente seleccionado
                      await _aplicarFiltrosCampos();
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCamposSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _camposFiltrados.isEmpty
          ? const Text(
              'No hay campos disponibles',
              style: TextStyle(color: Colors.grey),
            )
          : Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _camposFiltrados.length,
                itemBuilder: (context, index) {
                  final campo = _camposFiltrados[index];
                  return ListTile(
                    title: Text(campo.nombre),
                    subtitle: Text('${campo.superficieHa.toStringAsFixed(2)} hectáreas'),
                    leading: Radio<Campo>(
                      value: campo,
                      groupValue: _campoSeleccionado,
                      onChanged: (Campo? value) {
                        setState(() {
                          _campoSeleccionado = value;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _campoSeleccionado = campo;
                      });
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildMaquinasSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.build, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Máquinas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          if (_maquinas.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'No hay máquinas disponibles',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _maquinas.map((maquina) {
                final isSelected = _maquinasSeleccionadas.contains(maquina);
                return FilterChip(
                  label: Text(
                    maquina.nombre,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _maquinasSeleccionadas.add(maquina);
                      } else {
                        _maquinasSeleccionadas.remove(maquina);
                      }
                    });
                  },
                  selectedColor: const Color(AppConstants.primaryColor).withValues(alpha: 0.2),
                  checkmarkColor: const Color(AppConstants.primaryColor),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected 
                        ? const Color(AppConstants.primaryColor)
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Operarios',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          if (_personal.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'No hay operarios disponibles',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _personal.map((persona) {
                final isSelected = _personalSeleccionado.any((p) => p.id == persona.id);
                return FilterChip(
                  label: Text(
                    persona.nombre,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _personalSeleccionado.add(PersonalConHectareas(
                          id: persona.id!,
                          nombre: persona.nombre,
                          dni: persona.dni,
                          hectareas: _campoSeleccionado?.superficieHa ?? 0.0,
                        ));
                      } else {
                        _personalSeleccionado.removeWhere((p) => p.id == persona.id);
                      }
                    });
                  },
                  selectedColor: const Color(AppConstants.primaryColor).withValues(alpha: 0.2),
                  checkmarkColor: const Color(AppConstants.primaryColor),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected 
                        ? const Color(AppConstants.primaryColor)
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                );
              }).toList(),
            ),
          if (_personalSeleccionado.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Hectáreas por operario:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ..._personalSeleccionado.map((personal) => _buildHectareasInput(personal)),
          ],
        ],
      ),
    );
  }

  Widget _buildHectareasInput(PersonalConHectareas personal) {
    final controller = TextEditingController(text: personal.hectareas.toStringAsFixed(1));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personal.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'DNI: ${personal.dni}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Ha',
                labelStyle: TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                final hectareas = double.tryParse(value) ?? 0.0;
                final index = _personalSeleccionado.indexWhere((p) => p.id == personal.id);
                if (index != -1) {
                  setState(() {
                    _personalSeleccionado[index] = personal.copyWith(hectareas: hectareas);
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final data = {
          'tipo': _tipoController.text,
          'cultivo': _cultivoController.text,
          'observaciones': _descripcionController.text,
          'cliente': _esTercero && _clienteSeleccionado != null 
              ? _clienteSeleccionado!.nombre 
              : (_esTercero ? 'Cliente no seleccionado' : 'Trabajo propio'),
          'estado': _estadoSeleccionado ?? 'Pendiente',
          'a_terceros': _esTercero,
          'cobrado': _cobrado,
          'monto_cobrado': _cobrado && _montoCobradoController.text.isNotEmpty 
              ? double.tryParse(_montoCobradoController.text) 
              : null,
          'fecha_inicio': _fechaInicio?.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
          'fecha_fin': _fechaFin?.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
          'campo_id': _campoSeleccionado?.id ?? 1,
          'maquina_ids': _maquinasSeleccionadas.map((m) => m.id).where((id) => id != null).cast<int>().toList(),
          'personal_ids': _personalSeleccionado.map((p) => p.toJson()).toList(),
        };

        if (widget.trabajo == null) {
          await ref.read(trabajosProvider.notifier).createTrabajo(data);
        } else {
          await ref.read(trabajosProvider.notifier).updateTrabajo(widget.trabajo.id, data);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.trabajo == null ? 'Trabajo creado exitosamente' : 'Trabajo actualizado exitosamente'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
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

  void _showClienteForm() async {
    final result = await Navigator.push<Cliente>(
      context,
      MaterialPageRoute(
        builder: (context) => const ClienteFormScreen(),
      ),
    );
    
    if (result != null) {
      // Recargar clientes y seleccionar el nuevo
      await _loadDataForSelectors();
      setState(() {
        _clienteSeleccionado = result;
        _clienteController.text = result.nombre;
      });
    }
  }

  void _showCampoForm() async {
    final result = await Navigator.push<Campo>(
      context,
      MaterialPageRoute(
        builder: (context) => const CampoFormScreen(),
      ),
    );
    
    if (result != null) {
      // Recargar campos y seleccionar el nuevo
      await _loadDataForSelectors();
      setState(() {
        _campoSeleccionado = result;
      });
    }
  }

  void _showMaquinaForm() async {
    final result = await Navigator.push<Maquina>(
      context,
      MaterialPageRoute(
        builder: (context) => const MaquinaFormScreen(),
      ),
    );
    
    if (result != null) {
      // Recargar máquinas y seleccionar la nueva
      await _loadDataForSelectors();
      setState(() {
        _maquinasSeleccionadas.add(result);
      });
    }
  }

  void _showPersonalForm() async {
    final result = await Navigator.push<Personal>(
      context,
      MaterialPageRoute(
        builder: (context) => const PersonalFormScreen(),
      ),
    );
    
    if (result != null) {
      // Recargar personal y seleccionar el nuevo
      await _loadDataForSelectors();
      setState(() {
        _personalSeleccionado.add(PersonalConHectareas(
          id: result.id!,
          nombre: result.nombre,
          dni: result.dni,
          hectareas: _campoSeleccionado?.superficieHa ?? 0.0,
        ));
      });
    }
  }
}