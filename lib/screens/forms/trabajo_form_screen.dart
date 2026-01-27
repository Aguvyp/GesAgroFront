import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/optimized_providers.dart';
import '../../providers/trabajo_detalle_provider.dart';
import '../../models/campo.dart';
import '../../models/maquina.dart';
import '../../models/personal.dart';
import '../../models/cliente.dart';
import '../../models/personal_con_hectareas.dart';
import '../../models/trabajo_detalle.dart';
import '../../models/tipo_trabajo.dart';
import '../../services/cliente_service.dart';
import '../../services/tipo_trabajo_service.dart';
import '../../widgets/optimized_widgets.dart';
import '../../utils/validators.dart';

import 'campo_form_screen.dart';
import 'maquina_form_screen.dart';
import 'personal_form_screen.dart';
import 'cliente_form_screen.dart';

/// Enum para el tipo de trabajo en el formulario
enum TipoTrabajoForm {
  propio,
  aTerceros,
  deTercerosHaciaMi,
}

/// Pantalla completa para crear/editar trabajos
class TrabajoFormScreen extends ConsumerStatefulWidget {
  final dynamic trabajo;
  final DateTime? fechaInicial;

  const TrabajoFormScreen({Key? key, this.trabajo, this.fechaInicial})
      : super(key: key);

  @override
  ConsumerState<TrabajoFormScreen> createState() => _TrabajoFormScreenState();
}

class _TrabajoFormScreenState extends ConsumerState<TrabajoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _tipoTrabajoSeleccionado; // ID del tipo de trabajo seleccionado
  List<TipoTrabajo> _tiposTrabajo = [];
  late TextEditingController _cultivoController;
  late TextEditingController _descripcionController;
  late TextEditingController _fechaInicioController;
  late TextEditingController _fechaFinController;
  late TextEditingController _clienteController;
  late TextEditingController _montoCobradoController;
  late TextEditingController _rindeCosechaController;
  late TextEditingController _humedadCosechaController;
  late TextEditingController _horasTrabajadasController;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  // Tipo de trabajo en el formulario
  TipoTrabajoForm? _tipoTrabajoForm;

  // Estados adicionales
  String? _estadoSeleccionado;
  bool _esTercero = false;
  bool _cobrado = false;
  bool _servicioContratado = false;

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

  bool _isLoadingData = false;
  bool _isSaving = false;

  // Detalles del trabajo para edición
  TrabajoDetalle? _trabajoDetalle;

  @override
  void initState() {
    super.initState();
    // Si el trabajo tiene idTipoTrabajo, usarlo directamente
    // Si no, intentar encontrarlo por el nombre del tipo
    _tipoTrabajoSeleccionado = widget.trabajo?.idTipoTrabajo;
    _cultivoController =
        TextEditingController(text: widget.trabajo?.cultivo ?? '');
    _descripcionController =
        TextEditingController(text: widget.trabajo?.observaciones ?? '');
    _fechaInicio =
        widget.fechaInicial ?? widget.trabajo?.fechaInicio ?? DateTime.now();
    _fechaFin = widget.trabajo?.fechaFin ?? DateTime.now();

    _fechaInicioController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_fechaInicio!));

    _fechaFinController = TextEditingController(
        text: widget.trabajo?.fechaFin != null
            ? DateFormat('dd/MM/yyyy').format(widget.trabajo!.fechaFin!)
            : '');

    _clienteController =
        TextEditingController(text: widget.trabajo?.cliente ?? '');
    _montoCobradoController = TextEditingController(
        text: widget.trabajo?.montoCobrado?.toString() ?? '');
    _rindeCosechaController = TextEditingController(
        text: widget.trabajo?.rindeCosecha?.toString() ?? '');
    _humedadCosechaController = TextEditingController(
        text: widget.trabajo?.humedadCosecha?.toString() ?? '');
    _horasTrabajadasController = TextEditingController(
        text: widget.trabajo?.horasTrabajadas?.toString() ?? '');

    // Estados adicionales
    _estadoSeleccionado = widget.trabajo?.estado ?? 'Pendiente';

    // Determinar tipo de trabajo form según el trabajo existente
    if (widget.trabajo != null) {
      // Si hay un trabajo, determinar el tipo según sus valores
      if (widget.trabajo!.servicioContratado) {
        _tipoTrabajoForm = TipoTrabajoForm.deTercerosHaciaMi;
        _esTercero = false;
        _servicioContratado = true;
        _cobrado = false;
      } else if (widget.trabajo!.esTercero) {
        _tipoTrabajoForm = TipoTrabajoForm.aTerceros;
        _esTercero = true;
        _servicioContratado = false;
        _cobrado = widget.trabajo!.cobrado;
      } else {
        _tipoTrabajoForm = TipoTrabajoForm.propio;
        _esTercero = false;
        _servicioContratado = false;
        _cobrado = false;
      }
    } else {
      // Si es un trabajo nuevo, no establecer tipo aún (usuario debe seleccionar)
      _tipoTrabajoForm = null;
      _esTercero = false;
      _cobrado = false;
      _servicioContratado = false;
    }

    // Cargar datos necesarios para los selectores
    Future.microtask(() => _loadDataForSelectors());
  }

  @override
  void dispose() {
    _cultivoController.dispose();
    _descripcionController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _clienteController.dispose();
    _montoCobradoController.dispose();
    _rindeCosechaController.dispose();
    _humedadCosechaController.dispose();
    _horasTrabajadasController.dispose();
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
          await ref
              .read(trabajoDetalleProvider.notifier)
              .loadTrabajoDetalle(widget.trabajo!.id!);
          final trabajoDetalleState = ref.read(trabajoDetalleProvider);
          if (trabajoDetalleState is AsyncData<TrabajoDetalle?>) {
            _trabajoDetalle = trabajoDetalleState.value;
          }
        } catch (e) {
          print('Error cargando detalles del trabajo: $e');
        }
      }

      // Cargar tipos de trabajo
      try {
        _tiposTrabajo = await TipoTrabajoService.getTiposTrabajo();
        print('Tipos de trabajo cargados: ${_tiposTrabajo.length}');

        // Si el trabajo tiene tipoTrabajoNombre pero no idTipoTrabajo, buscar el ID
        if (widget.trabajo != null &&
            widget.trabajo!.idTipoTrabajo == null &&
            widget.trabajo!.tipoTrabajoNombre != null) {
          final tipoEncontrado = _tiposTrabajo.firstWhere(
            (tipo) => tipo.trabajo == widget.trabajo!.tipoTrabajoNombre,
            orElse: () => _tiposTrabajo.isNotEmpty
                ? _tiposTrabajo.first
                : TipoTrabajo(id: 0, trabajo: ''),
          );
          if (tipoEncontrado.id != 0) {
            setState(() {
              _tipoTrabajoSeleccionado = tipoEncontrado.id;
            });
          }
        }
      } catch (e) {
        print('Error cargando tipos de trabajo: $e');
        _tiposTrabajo = [];
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
        // Seleccionar cliente si es servicio contratado o trabajo a terceros
        if ((_servicioContratado || _esTercero) &&
            _trabajoDetalle!.clienteInfo != null) {
          _clienteSeleccionado = _clientes.firstWhere(
            (cliente) => cliente.id == _trabajoDetalle!.clienteInfo!.id,
            orElse: () => _clientes.isNotEmpty
                ? _clientes.first
                : Cliente(id: 0, nombre: ''),
          );
        }

        // Seleccionar campo
        _campoSeleccionado = _camposFiltrados.firstWhere(
          (campo) => campo.id == _trabajoDetalle!.campoId,
          orElse: () => _camposFiltrados.isNotEmpty
              ? _camposFiltrados.first
              : Campo(id: 0, nombre: '', superficieHa: 0),
        );

        // Seleccionar máquinas usando los detalles completos
        _maquinasSeleccionadas = _maquinas
            .where(
              (maquina) =>
                  _trabajoDetalle!.maquinas.any((maq) => maq.id == maquina.id),
            )
            .toList();

        // Seleccionar personal usando los detalles completos
        _personalSeleccionado = _personal
            .where(
          (persona) =>
              _trabajoDetalle!.personal.any((per) => per.id == persona.id),
        )
            .map((persona) {
          // Buscar las hectáreas específicas de este personal en el trabajo
          final personalTrabajo = _trabajoDetalle!.personal.firstWhere(
            (per) => per.id == persona.id,
            orElse: () => PersonalTrabajo(
                id: persona.id!,
                nombre: persona.nombre,
                dni: persona.dni,
                ha: _campoSeleccionado?.superficieHa ?? 0.0,
                horas: 0.0),
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
        // Seleccionar cliente si es servicio contratado o trabajo a terceros
        if ((_servicioContratado || _esTercero) &&
            widget.trabajo!.cliente != null) {
          _clienteSeleccionado = _clientes.firstWhere(
            (cliente) => cliente.nombre == widget.trabajo!.cliente,
            orElse: () => _clientes.isNotEmpty
                ? _clientes.first
                : Cliente(id: 0, nombre: ''),
          );
        }

        // Seleccionar campo
        _campoSeleccionado = _camposFiltrados.firstWhere(
          (campo) => campo.id == widget.trabajo!.idCampo,
          orElse: () => _camposFiltrados.isNotEmpty
              ? _camposFiltrados.first
              : Campo(id: 0, nombre: '', superficieHa: 0),
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
    if (_tipoTrabajoForm == TipoTrabajoForm.aTerceros &&
        _clienteSeleccionado != null &&
        _clienteSeleccionado!.id != null) {
      // Si es tipo "A terceros" y hay cliente seleccionado, cargar solo sus campos
      try {
        await _filtrarCamposPorCliente(_clienteSeleccionado!.id!);
      } catch (e) {
        print('Error cargando campos del cliente: $e');
        setState(() {
          _camposFiltrados = [];
        });
      }
    } else {
      // Para otros tipos, mostrar todos los campos propios
      setState(() {
        _camposFiltrados = List.from(_campos);
      });
    }
  }

  Widget _buildTipoSelector(String label, IconData icon, Color color,
      bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected ? color : const Color(0xFF8E8E93), size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? color : const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _filtrarCamposPorCliente(int clienteId) async {
    try {
      setState(() {
        _camposFiltrados = [];
        _isLoadingData =
            true; // Show loading indicator specifically for filtering if needed, or just rely on fast local filter
      });

      // 1. Intentar filtrar localmente de _campos
      // Esto es más rápido y funciona si camposProvider ya tiene todos los campos
      final camposLocales =
          _campos.where((c) => c.clienteId == clienteId).toList();

      if (camposLocales.isNotEmpty) {
        print(
            'Encontrados ${camposLocales.length} campos locales para cliente $clienteId');
        setState(() {
          _camposFiltrados = camposLocales;
          _campoSeleccionado = null;
          _isLoadingData = false;
        });
        return;
      }

      print(
          'No se encontraron campos locales. Consultando API para cliente $clienteId...');

      // 2. Si no hay locales, consultar API
      final camposApi = await ClienteService.getCamposByCliente(clienteId);

      setState(() {
        _camposFiltrados = camposApi;
        _campoSeleccionado = null;
        _isLoadingData = false;
      });
    } catch (e) {
      print('Error filtrando campos: $e');
      setState(() {
        _camposFiltrados = [];
        _isLoadingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.trabajo == null ? 'Nuevo Trabajo' : 'Editar Trabajo',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          color: const Color(0xFF1C1C1E),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: (_isLoadingData || _isSaving) ? null : _submitForm,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Guardar',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
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
                    // Selector de tipo de trabajo
                    OptimizedCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tipo de Trabajo',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTipoSelector(
                                  'Propio',
                                  Icons.home_rounded,
                                  const Color(0xFF2E7D32),
                                  _tipoTrabajoForm == TipoTrabajoForm.propio,
                                  () {
                                    setState(() {
                                      _tipoTrabajoForm = TipoTrabajoForm.propio;
                                      _esTercero = false;
                                      _servicioContratado = false;
                                      _cobrado = false;
                                      _clienteSeleccionado = null;
                                      _campoSeleccionado = null;
                                      _camposFiltrados = List.from(_campos);
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTipoSelector(
                                  'A terceros',
                                  Icons.person_outline_rounded,
                                  const Color(0xFF2196F3),
                                  _tipoTrabajoForm == TipoTrabajoForm.aTerceros,
                                  () {
                                    setState(() {
                                      _tipoTrabajoForm =
                                          TipoTrabajoForm.aTerceros;
                                      _esTercero = true;
                                      _servicioContratado = false;
                                      _cobrado = false;
                                      _campoSeleccionado = null;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTipoSelector(
                                  'De terceros hacia mi',
                                  Icons.arrow_downward_rounded,
                                  const Color(0xFFFF9800),
                                  _tipoTrabajoForm ==
                                      TipoTrabajoForm.deTercerosHaciaMi,
                                  () {
                                    setState(() {
                                      _tipoTrabajoForm =
                                          TipoTrabajoForm.deTercerosHaciaMi;
                                      _esTercero = false;
                                      _servicioContratado = true;
                                      _cobrado = false;
                                      _campoSeleccionado = null;
                                      _camposFiltrados = List.from(_campos);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campos condicionales según el tipo
                    if (_tipoTrabajoForm != null) ...[
                      _buildCamposCondicionales(),
                      const SizedBox(height: 16),
                      // Descripción al final del formulario
                      OptimizedCard(
                        padding: const EdgeInsets.all(16),
                        child: OptimizedTextField(
                          controller: _descripcionController,
                          label: 'Descripción',
                          hint: 'Detalles adicionales del trabajo',
                          prefixIcon:
                              const Icon(Icons.description_rounded, size: 20),
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botón Guardar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Guardar',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ] else ...[
                      const OptimizedCard(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'Selecciona el tipo de trabajo para continuar',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCamposCondicionales() {
    switch (_tipoTrabajoForm) {
      case TipoTrabajoForm.propio:
        return _buildCamposPropio();
      case TipoTrabajoForm.aTerceros:
        return _buildCamposATerceros();
      case TipoTrabajoForm.deTercerosHaciaMi:
        return _buildCamposDeTercerosHaciaMi();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCamposPropio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información General
        OptimizedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información General',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Trabajo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 17, color: Color(0xFF1C1C1E)),
                value: _tipoTrabajoSeleccionado,
                items: _tiposTrabajo.map((tipo) {
                  return DropdownMenuItem<int>(
                    value: tipo.id,
                    child: Text(tipo.trabajo),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _tipoTrabajoSeleccionado = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'El tipo de trabajo es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              OptimizedTextField(
                controller: _cultivoController,
                label: 'Cultivo',
                hint: 'Ej: Soja, Maíz, Trigo',
                prefixIcon: const Icon(Icons.eco_rounded, size: 20),
                validator: (value) =>
                    Validators.validateRequired(value, 'Cultivo'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Campo
        OptimizedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Campo',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              _buildCamposSelector(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Recursos (Máquinas y Personal)
        OptimizedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recursos',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              _buildMaquinasSelector(),
              const SizedBox(height: 16),
              _buildPersonalSelector(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Fechas
        OptimizedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fechas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Fecha de Inicio',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _fechaInicioController,
                    decoration: InputDecoration(
                      hintText: 'Seleccione la fecha',
                      hintStyle: const TextStyle(
                          fontSize: 17, color: Color(0xFF8E8E93)),
                      suffixIcon:
                          const Icon(Icons.calendar_today_rounded, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2), width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2), width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF2E7D32), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      isDense: true,
                    ),
                    style:
                        const TextStyle(fontSize: 17, color: Color(0xFF1C1C1E)),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _fechaInicio ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _fechaInicio = date;
                          _fechaInicioController.text =
                              DateFormat('dd/MM/yyyy').format(date);
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 17, color: Color(0xFF1C1C1E)),
                value: _estadoSeleccionado,
                items: const [
                  DropdownMenuItem(
                      value: 'Pendiente', child: Text('Pendiente')),
                  DropdownMenuItem(
                      value: 'En progreso', child: Text('En progreso')),
                  DropdownMenuItem(
                      value: 'Completado', child: Text('Completado')),
                  DropdownMenuItem(
                      value: 'Cancelado', child: Text('Cancelado')),
                ],
                onChanged: (value) {
                  setState(() {
                    _estadoSeleccionado = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCamposATerceros() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información General
        OptimizedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información General',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Trabajo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 17, color: Color(0xFF1C1C1E)),
                value: _tipoTrabajoSeleccionado,
                items: _tiposTrabajo.map((tipo) {
                  return DropdownMenuItem<int>(
                    value: tipo.id,
                    child: Text(tipo.trabajo),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _tipoTrabajoSeleccionado = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'El tipo de trabajo es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              OptimizedTextField(
                controller: _cultivoController,
                label: 'Cultivo',
                hint: 'Ej: Soja, Maíz, Trigo',
                prefixIcon: const Icon(Icons.eco_rounded, size: 20),
                validator: (value) =>
                    Validators.validateRequired(value, 'Cultivo'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Cliente y Campo
        OptimizedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cliente y Campo',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              _buildClientesSelector(),
              const SizedBox(height: 16),
              if (_clienteSeleccionado != null) ...[
                if (_clienteSeleccionado != null) _buildCamposSelector(),
                if (_camposFiltrados.isEmpty &&
                    _clienteSeleccionado != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFFFF9800).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Color(0xFFFF9800), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Este cliente no tiene campos asignados. Puedes crear uno nuevo.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: Color(0xFF8E8E93), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Selecciona un cliente para ver sus campos',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Recursos
        OptimizedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recursos',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              _buildMaquinasSelector(),
              const SizedBox(height: 16),
              _buildPersonalSelector(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Fechas y Estado
        OptimizedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fechas y Estado',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Fecha de Inicio',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _fechaInicioController,
                    decoration: InputDecoration(
                      hintText: 'Seleccione la fecha',
                      hintStyle: const TextStyle(
                          fontSize: 17, color: Color(0xFF8E8E93)),
                      suffixIcon:
                          const Icon(Icons.calendar_today_rounded, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2), width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2), width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF2E7D32), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      isDense: true,
                    ),
                    style:
                        const TextStyle(fontSize: 17, color: Color(0xFF1C1C1E)),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _fechaInicio ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _fechaInicio = date;
                          _fechaInicioController.text =
                              DateFormat('dd/MM/yyyy').format(date);
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 17, color: Color(0xFF1C1C1E)),
                value: _estadoSeleccionado,
                items: const [
                  DropdownMenuItem(
                      value: 'Pendiente', child: Text('Pendiente')),
                  DropdownMenuItem(
                      value: 'En progreso', child: Text('En progreso')),
                  DropdownMenuItem(
                      value: 'Completado', child: Text('Completado')),
                  DropdownMenuItem(
                      value: 'Cancelado', child: Text('Cancelado')),
                ],
                onChanged: (value) {
                  setState(() {
                    _estadoSeleccionado = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Cobro
        OptimizedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cobro',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Cobrado'),
                subtitle: const Text('Marcar si ya se cobró el trabajo'),
                value: _cobrado,
                onChanged: (value) {
                  setState(() {
                    _cobrado = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              if (_cobrado) ...[
                const SizedBox(height: 16),
                OptimizedTextField(
                  controller: _montoCobradoController,
                  label: 'Monto Cobrado',
                  hint: 'Ingrese el monto cobrado',
                  prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_cobrado && (value == null || value.isEmpty)) {
                      return 'El monto es requerido si está cobrado';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCamposDeTercerosHaciaMi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información General
        OptimizedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información General',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Trabajo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 17, color: Color(0xFF1C1C1E)),
                value: _tipoTrabajoSeleccionado,
                items: _tiposTrabajo.map((tipo) {
                  return DropdownMenuItem<int>(
                    value: tipo.id,
                    child: Text(tipo.trabajo),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _tipoTrabajoSeleccionado = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'El tipo de trabajo es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              OptimizedTextField(
                controller: _cultivoController,
                label: 'Cultivo',
                hint: 'Ej: Soja, Maíz, Trigo',
                prefixIcon: const Icon(Icons.eco_rounded, size: 20),
                validator: (value) =>
                    Validators.validateRequired(value, 'Cultivo'),
              ),
              // Descripción removida de aquí
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Prestador y Campo
        OptimizedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Prestador y Campo',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              _buildClientesSelector(),
              const SizedBox(height: 16),
              _buildCamposSelector(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Fechas y Estado
        OptimizedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fechas y Estado',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Fecha de Inicio',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _fechaInicioController,
                    decoration: InputDecoration(
                      hintText: 'Seleccione la fecha',
                      hintStyle: const TextStyle(
                          fontSize: 17, color: Color(0xFF8E8E93)),
                      suffixIcon:
                          const Icon(Icons.calendar_today_rounded, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2), width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2), width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF2E7D32), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      isDense: true,
                    ),
                    style:
                        const TextStyle(fontSize: 17, color: Color(0xFF1C1C1E)),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _fechaInicio ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _fechaInicio = date;
                          _fechaInicioController.text =
                              DateFormat('dd/MM/yyyy').format(date);
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 17, color: Color(0xFF1C1C1E)),
                value: _estadoSeleccionado,
                items: const [
                  DropdownMenuItem(
                      value: 'Pendiente', child: Text('Pendiente')),
                  DropdownMenuItem(
                      value: 'En progreso', child: Text('En progreso')),
                  DropdownMenuItem(
                      value: 'Completado', child: Text('Completado')),
                  DropdownMenuItem(
                      value: 'Cancelado', child: Text('Cancelado')),
                ],
                onChanged: (value) {
                  setState(() {
                    _estadoSeleccionado = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<dynamic>(
          decoration: const InputDecoration(
            labelText: 'Cliente',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_rounded, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            isDense: true,
          ),
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight: 300,
          style: const TextStyle(fontSize: 17, color: Color(0xFF1C1C1E)),
          value: _clienteSeleccionado,
          items: [
            const DropdownMenuItem<dynamic>(
              value: 'NEW_CLIENTE',
              child: Row(
                children: [
                  Icon(Icons.add, color: Color(0xFF2E7D32), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Nuevo Cliente',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_clientes.isEmpty)
              const DropdownMenuItem<dynamic>(
                enabled: false,
                value: 'EMPTY',
                child: Text('No hay clientes disponibles'),
              )
            else
              ..._clientes.map((cliente) {
                return DropdownMenuItem<dynamic>(
                  value: cliente,
                  child: Text(
                    cliente.nombre ?? 'Sin nombre',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
          ],
          onChanged: (dynamic value) async {
            if (value == 'NEW_CLIENTE') {
              // Reset selection to previous or null to avoid stuck on "New"
              // But onChanged fires after selection. We'll handle the action then usually reset or update.
              _showClienteForm();
              // Prevent the dropdown from showing "New Cliente" as selected value visually if possible
              // by not updating state to 'NEW_CLIENTE'.
              // However, the dropdown needs a valid value.
              // If we don't setState with the new value, it might revert to old.
              // We will rely on _showClienteForm updating the state with the NEW client once created.
            } else if (value != 'EMPTY') {
              setState(() {
                _clienteSeleccionado = value as Cliente;
                _clienteController.text = _clienteSeleccionado?.nombre ?? '';
                _campoSeleccionado = null; // Reset campo
              });
              await _aplicarFiltrosCampos();
            }
          },
          validator: (value) {
            if (_tipoTrabajoForm == TipoTrabajoForm.aTerceros &&
                value == null) {
              return 'El cliente es requerido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCamposSelector() {
    List<Campo> camposParaMostrar;
    if (_tipoTrabajoForm == TipoTrabajoForm.aTerceros) {
      camposParaMostrar = _camposFiltrados;
    } else {
      camposParaMostrar = _campos;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<dynamic>(
          decoration: const InputDecoration(
            labelText: 'Campo',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.landscape_rounded, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            isDense: true,
          ),
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight: 300,
          style: const TextStyle(fontSize: 17, color: Color(0xFF1C1C1E)),
          value: _campoSeleccionado,
          items: [
            const DropdownMenuItem<dynamic>(
              value: 'NEW_CAMPO',
              child: Row(
                children: [
                  Icon(Icons.add, color: Color(0xFF2E7D32), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Nuevo Campo',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (camposParaMostrar.isEmpty)
              const DropdownMenuItem<dynamic>(
                enabled: false,
                value: 'EMPTY',
                child: Text('No hay campos disponibles'),
              )
            else
              ...camposParaMostrar.map((campo) {
                return DropdownMenuItem<dynamic>(
                  value: campo,
                  child: Text(
                    campo.nombre,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
          ],
          onChanged: (dynamic value) {
            if (value == 'NEW_CAMPO') {
              _showCampoForm();
            } else if (value != 'EMPTY') {
              setState(() {
                _campoSeleccionado = value as Campo;
              });
            }
          },
          validator: (value) {
            if (_campoSeleccionado == null) {
              return 'El campo es requerido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMaquinasSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<dynamic>(
          decoration: const InputDecoration(
            labelText: 'Agregar Máquina',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.agriculture_rounded, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            isDense: true,
          ),
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight: 300,
          style: const TextStyle(fontSize: 17, color: Color(0xFF1C1C1E)),
          value:
              null, // Always null so we can select "Add" again or another machine
          items: [
            const DropdownMenuItem<dynamic>(
              value: 'NEW_MAQUINA',
              child: Row(
                children: [
                  Icon(Icons.add, color: Color(0xFF2E7D32), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Nueva Máquina',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_maquinas.isEmpty)
              const DropdownMenuItem<dynamic>(
                enabled: false,
                value: 'EMPTY',
                child: Text('No hay máquinas disponibles'),
              )
            else
              ..._maquinas
                  .where((m) => !_maquinasSeleccionadas.contains(m))
                  .map((maquina) {
                return DropdownMenuItem<dynamic>(
                  value: maquina,
                  child: Text(
                    maquina.nombre,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
          ],
          onChanged: (dynamic value) {
            if (value == 'NEW_MAQUINA') {
              _showMaquinaForm();
            } else if (value != null && value != 'EMPTY') {
              setState(() {
                _maquinasSeleccionadas.add(value as Maquina);
              });
            }
          },
        ),
        if (_maquinasSeleccionadas.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _maquinasSeleccionadas.map((maquina) {
              return Chip(
                label: Text(maquina.nombre),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _maquinasSeleccionadas.remove(maquina);
                  });
                },
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPersonalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<dynamic>(
          decoration: const InputDecoration(
            labelText: 'Agregar Operario',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            isDense: true,
          ),
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight: 300,
          style: const TextStyle(fontSize: 17, color: Color(0xFF1C1C1E)),
          value: null,
          items: [
            const DropdownMenuItem<dynamic>(
              value: 'NEW_PERSONAL',
              child: Row(
                children: [
                  Icon(Icons.add, color: Color(0xFF2E7D32), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Nuevo Operario',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_personal.isEmpty)
              const DropdownMenuItem<dynamic>(
                enabled: false,
                value: 'EMPTY',
                child: Text('No hay operarios disponibles'),
              )
            else
              ..._personal
                  .where((p) => !_personalSeleccionado
                      .any((selected) => selected.id == p.id))
                  .map((persona) {
                return DropdownMenuItem<dynamic>(
                  value: persona,
                  child: Text(
                    persona.nombre,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
          ],
          onChanged: (dynamic value) {
            if (value == 'NEW_PERSONAL') {
              _showPersonalForm();
            } else if (value != null && value != 'EMPTY') {
              final persona = value as Personal;
              setState(() {
                _personalSeleccionado.add(PersonalConHectareas(
                  id: persona.id!,
                  nombre: persona.nombre,
                  dni: persona.dni,
                  hectareas: _campoSeleccionado?.superficieHa ?? 0.0,
                ));
              });
            }
          },
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
          ..._personalSeleccionado
              .map((personal) => _buildHectareasInput(personal)),
        ],
      ],
    );
  }

  Widget _buildHectareasInput(PersonalConHectareas personal) {
    final controller =
        TextEditingController(text: personal.hectareas.toStringAsFixed(1));

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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                final hectareas = double.tryParse(value) ?? 0.0;
                final index = _personalSeleccionado
                    .indexWhere((p) => p.id == personal.id);
                if (index != -1) {
                  setState(() {
                    _personalSeleccionado[index] =
                        personal.copyWith(hectareas: hectareas);
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
    print('🔵 _submitForm llamado');
    if (_formKey.currentState!.validate()) {
      print('🔵 Validación del formulario exitosa');
      setState(() {
        _isSaving = true;
      });

      try {
        print('🔵 Iniciando construcción del request...');

        // Establecer valores por defecto según el tipo de trabajo
        bool esTercero = false;
        bool servicioContratado = false;
        bool cobrado = false;
        String? clienteNombre;

        switch (_tipoTrabajoForm) {
          case TipoTrabajoForm.propio:
            esTercero = false;
            servicioContratado = false;
            cobrado = false;
            clienteNombre = null;
            break;
          case TipoTrabajoForm.aTerceros:
            esTercero = true;
            servicioContratado = false;
            cobrado = _cobrado; // Usar el valor del toggle
            clienteNombre = _clienteSeleccionado?.nombre;
            break;
          case TipoTrabajoForm.deTercerosHaciaMi:
            esTercero = false;
            servicioContratado = true;
            cobrado = false;
            clienteNombre = _clienteSeleccionado?.nombre;
            break;
          default:
            // Si no hay tipo seleccionado, usar valores actuales (para edición)
            esTercero = _esTercero;
            servicioContratado = _servicioContratado;
            cobrado = _cobrado;
            clienteNombre = (_servicioContratado || _esTercero) &&
                    _clienteSeleccionado != null
                ? _clienteSeleccionado!.nombre
                : null;
        }

        // Construir el request según el formato requerido por el endpoint
        final data = <String, dynamic>{
          'id_tipo_trabajo': _tipoTrabajoSeleccionado,
          'cliente': clienteNombre,
          'fecha_inicio': _fechaInicio
              ?.toIso8601String()
              .split('T')[0], // Formato YYYY-MM-DD
          'campo': _campoSeleccionado?.id,
          'cultivo': _cultivoController.text,
          'observaciones': _descripcionController.text.isNotEmpty
              ? _descripcionController.text
              : null,
          'estado': _estadoSeleccionado ?? 'Pendiente',
          'a_terceros': esTercero,
          'servicio_contratado': servicioContratado,
          'cobrado': cobrado,
          'fecha_fin': (_fechaFin ?? _fechaInicio)
              ?.toIso8601String()
              .split('T')[0], // Formato YYYY-MM-DD
        };

        // Agregar monto cobrado si está cobrado
        if (cobrado && _montoCobradoController.text.isNotEmpty) {
          data['monto_cobrado'] = double.tryParse(_montoCobradoController.text);
        }

        // Agregar campos de cosecha: si es cosecha (id = 1) usar valores ingresados, sino enviar 0
        if (_tipoTrabajoSeleccionado == 1) {
          // Para cosecha, usar valores ingresados (o null si están vacíos)
          if (_rindeCosechaController.text.isNotEmpty) {
            data['rinde_cosecha'] =
                double.tryParse(_rindeCosechaController.text);
          }
          if (_humedadCosechaController.text.isNotEmpty) {
            data['humedad_cosecha'] =
                double.tryParse(_humedadCosechaController.text);
          }
        } else {
          // Para otros tipos de trabajo, enviar 0 por defecto
          data['rinde_cosecha'] = 0.0;
          data['humedad_cosecha'] = 0.0;
        }

        // Agregar horas trabajadas
        if (_horasTrabajadasController.text.isNotEmpty) {
          data['horas_trabajadas'] =
              double.tryParse(_horasTrabajadasController.text);
        }

        // Agregar máquinas
        if (_maquinasSeleccionadas.isNotEmpty) {
          data['id_maquinas'] =
              _maquinasSeleccionadas.map((m) => m.id).toList();
        }

        // Agregar personal con hectáreas
        if (_personalSeleccionado.isNotEmpty) {
          data['personal_hectareas'] = _personalSeleccionado.map((p) {
            return {
              'id': p.id,
              'ha': p.hectareas,
            };
          }).toList();
        }

        // Imprimir el body del request por consola
        debugPrint(
            '═══════════════════════════════════════════════════════════════');
        debugPrint(
            '📤 REQUEST BODY - ${widget.trabajo == null ? "CREAR" : "ACTUALIZAR"} TRABAJO');
        debugPrint(
            '═══════════════════════════════════════════════════════════════');
        try {
          final jsonString = JsonEncoder.withIndent('  ').convert(data);
          debugPrint(jsonString);
          print(jsonString); // También usar print normal
        } catch (e) {
          debugPrint('Error al convertir a JSON: $e');
          debugPrint('Data raw: $data');
          print('Error al convertir a JSON: $e');
          print('Data raw: $data');
        }
        debugPrint(
            '═══════════════════════════════════════════════════════════════');

        if (widget.trabajo == null) {
          await ref.read(trabajosProvider.notifier).createTrabajo(data);
        } else {
          await ref
              .read(trabajosProvider.notifier)
              .updateTrabajo(widget.trabajo.id, data);
        }

        // Actualizar el provider para invalidar el dashboard
        ref.read(dashboardRefreshProvider.notifier).state++;

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.trabajo == null
                  ? 'Trabajo creado exitosamente'
                  : 'Trabajo actualizado exitosamente'),
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
        _clienteController.text = result.nombre ?? '';
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
      // Invalidar provider para forzar recarga de datos frescos
      ref.invalidate(camposProvider);
      // Recargar campos para que el nuevo aparezca en la lista
      await _loadDataForSelectors();
      // No se auto-selecciona. El usuario debe elegirlo.
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
      ref.invalidate(maquinasProvider);
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
      ref.invalidate(personalProvider);
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
