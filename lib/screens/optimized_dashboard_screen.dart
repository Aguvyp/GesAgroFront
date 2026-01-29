import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/trabajo.dart';
import '../models/maquina.dart';
import '../models/personal.dart';
import '../models/mantenimiento.dart';
import '../utils/constants.dart';
import '../services/optimized_api_service.dart';
import '../core/logger/app_logger.dart';
import 'trabajos/trabajo_detail_screen.dart';
import 'forms/trabajo_form_screen.dart';
import 'forms/mantenimiento_form_screen.dart';
import 'forms/registrar_horas_form.dart';
import 'optimized_screens.dart';
import '../providers/optimized_auth_provider.dart';
import '../providers/optimized_providers.dart';
import '../widgets/optimized_widgets.dart';
import '../widgets/dashboard_widgets.dart';

class OptimizedDashboardScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateToIndex;

  const OptimizedDashboardScreen({
    Key? key,
    this.onNavigateToIndex,
  }) : super(key: key);

  @override
  ConsumerState<OptimizedDashboardScreen> createState() =>
      _OptimizedDashboardScreenState();
}

class _OptimizedDashboardScreenState
    extends ConsumerState<OptimizedDashboardScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  // Estados para datos reales
  List<Trabajo> _trabajos = [];
  List<Maquina> _maquinas = [];
  List<Personal> _personal = [];
  List<Mantenimiento> _mantenimientos = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Mapas por fecha para el calendario
  Map<DateTime, List<Trabajo>> _trabajosPorFecha = {};
  Map<DateTime, List<Mantenimiento>> _mantenimientosPorFecha = {};

  final ApiService _apiService = ApiService();
  final AppLogger _logger = AppLogger.instance;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null).then((_) {
      if (mounted) {
        setState(() {}); // Rebuild once locale data is loaded
      }
    });
    _loadDashboardData();
  }

  /// Cargar datos del dashboard desde la API
  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _logger.info('🔄 Cargando datos del dashboard...');

      // Inicializar el servicio API solo si no está inicializado
      if (!_apiService.isInitialized) {
        await _apiService.initialize();
      }

      // Cargar datos usando el endpoint del dashboard que contiene toda la información
      // Usar manejo individual de errores para que si uno falla, los otros continúen
      List<Trabajo> trabajos = [];
      Map<String, dynamic> dashboardResponse = {};
      List<Mantenimiento> mantenimientos = [];

      // Cargar trabajos
      try {
        trabajos = await _apiService.getTrabajos();
        _logger.info('✅ Trabajos cargados: ${trabajos.length}');
      } catch (e) {
        _logger.error('❌ Error cargando trabajos: $e');
        trabajos = [];
      }

      // Cargar resumen del dashboard
      try {
        final response = await _apiService.get('/api/dashboard/resumen');
        if (response is Map<String, dynamic>) {
          dashboardResponse = response;
        }
        _logger.info('✅ Dashboard resumen cargado');
      } catch (e) {
        _logger.error('❌ Error cargando dashboard resumen: $e');
        dashboardResponse = {};
      }

      // Cargar mantenimientos (este puede fallar con 500, pero ya está manejado en el servicio)
      try {
        mantenimientos = await _apiService.getMantenimientos();
        _logger.info('✅ Mantenimientos cargados: ${mantenimientos.length}');
      } catch (e) {
        _logger.error('❌ Error cargando mantenimientos: $e');
        mantenimientos = [];
      }

      setState(() {
        _trabajos = trabajos;

        // Procesar datos del resumen del dashboard
        // Extraer máquinas del resumen
        if (dashboardResponse['maquinas'] != null) {
          final maquinasData = dashboardResponse['maquinas'] as List<dynamic>;
          _maquinas =
              maquinasData.map((json) => Maquina.fromJson(json)).toList();
        } else {
          _maquinas = [];
        }

        // Ordenar máquinas por hectáreas (mayor a menor)
        _maquinas.sort((a, b) {
          final haA = a.superficieTotalHa ?? 0.0;
          final haB = b.superficieTotalHa ?? 0.0;
          return haB.compareTo(haA); // Orden descendente
        });

        // Extraer personal del resumen
        if (dashboardResponse['personal'] != null) {
          final personalData = dashboardResponse['personal'] as List<dynamic>;
          _personal =
              personalData.map((json) => Personal.fromJson(json)).toList();
        } else {
          _personal = [];
        }

        // Ordenar personal por hectáreas (mayor a menor)
        _personal.sort((a, b) {
          final haA = a.superficieTotalHa ?? 0.0;
          final haB = b.superficieTotalHa ?? 0.0;
          return haB.compareTo(haA); // Orden descendente
        });

        // Asignar mantenimientos (ya viene como List<Mantenimiento> del método getMantenimientos)
        _mantenimientos = mantenimientos;

        _isLoading = false;
      });

      _logger.info(
          '✅ Datos del dashboard cargados: ${_trabajos.length} trabajos, ${_maquinas.length} máquinas, ${_personal.length} personal, ${_mantenimientos.length} mantenimientos');

      // Mostrar datos detallados de los endpoints específicos
      _logger.info('📊 Datos de máquinas desde endpoint específico:');
      for (int i = 0; i < _maquinas.length; i++) {
        final maquina = _maquinas[i];
        _logger.info(
            '   Máquina $i: id=${maquina.id}, nombre=${maquina.nombre}, superficieTotalHa=${maquina.superficieTotalHa}, horasTrabajadas=${maquina.horasTrabajadas}');
      }

      _logger.info('📊 Datos de personal desde endpoint específico:');
      for (int i = 0; i < _personal.length; i++) {
        final operario = _personal[i];
        _logger.info(
            '   Operario $i: id=${operario.id}, nombre=${operario.nombre}, superficieTotalHa=${operario.superficieTotalHa}, horasTrabajadas=${operario.horasTrabajadas}, trabajosCompletados=${operario.trabajosCompletados}');
      }

      // Probar los nuevos endpoints específicos
      await _testNewEndpoints();
    } catch (e) {
      _logger.error('❌ Error cargando datos del dashboard: $e');
      setState(() {
        _errorMessage = 'Error cargando datos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Probar el endpoint del dashboard
  Future<void> _testNewEndpoints() async {
    try {
      _logger.info('🧪 Probando endpoint /api/dashboard/resumen...');

      final dashboardResponse = await _apiService.get('/api/dashboard/resumen');
      _logger.info('📊 Respuesta del dashboard resumen:');
      _logger.info('   Tipo: ${dashboardResponse.runtimeType}');
      _logger.info('   Contenido: $dashboardResponse');

      if (dashboardResponse is Map<String, dynamic>) {
        _logger
            .info('   Campos disponibles: ${dashboardResponse.keys.toList()}');

        if (dashboardResponse['maquinas'] != null) {
          final maquinas = dashboardResponse['maquinas'];
          _logger.info('   Máquinas: $maquinas');
          if (maquinas is List) {
            _logger.info('   Cantidad de máquinas: ${maquinas.length}');
          }
        }

        if (dashboardResponse['personal'] != null) {
          final personal = dashboardResponse['personal'];
          _logger.info('   Personal: $personal');
          if (personal is List) {
            _logger.info('   Cantidad de personal: ${personal.length}');
          }
        }
      }
    } catch (e) {
      _logger.error('❌ Error en endpoint dashboard/resumen: $e');
    }
  }

  /// Refrescar datos del dashboard
  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en el dashboardRefreshProvider para recargar datos
    ref.listen<int>(dashboardRefreshProvider, (previous, next) {
      _refreshDashboard();
    });

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Cargando dashboard...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar datos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshDashboard,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarBackground =
        theme.appBarTheme.backgroundColor ?? colorScheme.surfaceVariant;
    final titleBaseStyle = theme.appBarTheme.titleTextStyle ??
        theme.textTheme.titleLarge ??
        const TextStyle();
    final appBarTitleStyle = titleBaseStyle.copyWith(
      color: theme.appBarTheme.foregroundColor ?? colorScheme.primary,
      letterSpacing: -0.41,
    );

    final background = const Color(0xFFF8F9FA); // Slightly gray background
    return Scaffold(
      backgroundColor: background,
      body: RefreshIndicator(
        backgroundColor: background,
        color: theme.colorScheme.primary,
        onRefresh: _refreshDashboard,
        child: Container(
          color: background,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Contenido
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Saludo y Avatar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildGreetingSection(ref.watch(currentUserProvider)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.calendar_month_rounded,
                                  color: Color(AppConstants.primaryColor),
                                  size: 28,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _focusedDay = DateTime.now();
                                    _calendarFormat = CalendarFormat.month;
                                  });
                                  _showFullCalendarModal(context);
                                },
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        const Color(AppConstants.primaryColor)
                                            .withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      const Color(AppConstants.primaryColor)
                                          .withOpacity(0.1),
                                  child: Text(
                                    (ref.watch(currentUserProvider)?[
                                                'nombre'] ??
                                            'U')
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(AppConstants.primaryColor),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Clima en una fila entera
                      const WeatherWidget(),
                      const SizedBox(height: 20),

                      // Ticker de Precios BCR
                      const PriceTickerWidget(),
                      const SizedBox(height: 24),

                      // Lista de trabajos por estado
                      _buildTrabajosSection(_trabajos),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navega a la lista de trabajos filtrada por estado
  void _navegarAListaTrabajosPorEstado(String estado) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OptimizedTrabajosListScreen(
          showAppBar: true,
          estadoFiltro: estado,
        ),
      ),
    );
  }

  Widget _buildTrabajosSection(List<Trabajo> trabajos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 24,
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(AppConstants.primaryColor),
                        const Color(AppConstants.primaryColor).withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Trabajos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2.0,
                        color: Colors.black12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () => _navegarAListaTrabajosPorEstado('Todos'),
              tooltip: 'Ver todos',
            ),
          ],
        ),
        const SizedBox(height: 0),
        _buildTrabajosList(trabajos),
      ],
    );
  }

  Widget _buildTrabajosList(List<Trabajo> trabajos) {
    List<Trabajo> enCurso = [];
    List<Trabajo> pendientes = [];
    List<Trabajo> completados = [];

    for (var t in trabajos) {
      final estado = t.estado?.toLowerCase().trim() ?? '';
      if ([
        'en curso',
        'en_curso',
        'en progreso',
        'en_progreso',
        'ejecutando',
        'en ejecución'
      ].contains(estado)) {
        enCurso.add(t);
      } else if (['pendiente', 'programado'].contains(estado)) {
        pendientes.add(t);
      } else {
        completados.add(t);
      }
    }

    // Sort priority
    List<Trabajo> sorted = [...enCurso, ...pendientes, ...completados];
    final displayList = sorted.take(5).toList();

    if (displayList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("No hay trabajos recientes."),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildActiveTrabajoCard(displayList[index]);
      },
    );
  }

  Widget _buildActiveTrabajoCard(Trabajo trabajo) {
    final estado = trabajo.estado?.toLowerCase().trim() ?? '';
    final isEnCurso = [
      'en curso',
      'en_curso',
      'en progreso',
      'en_progreso',
      'ejecutando',
      'en ejecución'
    ].contains(estado);

    final isCompletado = ['completado', 'finalizado'].contains(estado);

    IconData laborIcon;
    final tipoLabor = trabajo.tipo.toLowerCase();
    if (tipoLabor.contains('siembra')) {
      laborIcon = Icons.grass;
    } else if (tipoLabor.contains('cosecha')) {
      laborIcon = Icons.agriculture;
    } else if (tipoLabor.contains('pulver')) {
      laborIcon = Icons.opacity;
    } else if (tipoLabor.contains('fertiliz')) {
      laborIcon = Icons.science;
    } else {
      laborIcon = Icons.work_outline;
    }

    Color statusColor;

    if (isEnCurso) {
      statusColor = const Color(AppConstants.accentColor);
    } else if (isCompletado) {
      statusColor = const Color(AppConstants.successColor);
    } else {
      statusColor = const Color(AppConstants.infoColor);
    }

    String ownershipInfo = 'Propio';
    if (trabajo.esTercero) {
      ownershipInfo = trabajo.cliente != null && trabajo.cliente!.isNotEmpty
          ? 'Cliente: ${trabajo.cliente}'
          : 'A terceros';
    } else if (trabajo.servicioContratado) {
      ownershipInfo = 'Servicio Contratado';
    }

    return OptimizedCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrabajoDetailScreen(trabajo: trabajo),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: statusColor,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      laborIcon,
                      color: statusColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${trabajo.tipo} - ${trabajo.cultivo}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        Text(
                          ownershipInfo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEnCurso)
                    IconButton(
                      icon: const Icon(Icons.add_circle, size: 24),
                      color: const Color(AppConstants.primaryColor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrarHorasForm(
                              trabajoId: trabajo.id!,
                              trabajoTitulo:
                                  '${trabajo.tipo} - ${trabajo.cultivo}',
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.landscape_rounded,
                      size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    trabajo.campoInfo,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      trabajo.estado?.toUpperCase() ?? 'PENDIENTE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (isEnCurso) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (trabajo.porcentajeProgreso ?? 0.0) / 100,
                    backgroundColor: statusColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (trabajo.haRealizadas != null && trabajo.campoHa != null)
                      Text(
                        '${trabajo.haRealizadas!.toStringAsFixed(1)} / ${trabajo.campoHa!.toStringAsFixed(1)} ha',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Text(
                      '${(trabajo.porcentajeProgreso ?? 0.0).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarioOld(
      List<Trabajo> trabajos, List<Mantenimiento> mantenimientos) {
    // Mostrar TODOS los trabajos sin importar el estado
    final todosLosTrabajos = trabajos;

    // Crear mapa de fechas con trabajos
    _trabajosPorFecha = {};
    for (final trabajo in todosLosTrabajos) {
      final fecha = DateTime(trabajo.fechaInicio.year,
          trabajo.fechaInicio.month, trabajo.fechaInicio.day);
      _trabajosPorFecha[fecha] = [...(_trabajosPorFecha[fecha] ?? []), trabajo];
    }

    // Crear mapa de fechas con mantenimientos próximos (solo pendientes y próximos)
    _mantenimientosPorFecha = {};
    final hoy = DateTime.now();
    final proximosDias = hoy.add(const Duration(days: 30)); // Próximos 30 días

    for (final mantenimiento in mantenimientos) {
      // Solo mostrar mantenimientos pendientes que estén próximos (hasta 30 días)
      if (mantenimiento.estado.toLowerCase() == 'pendiente' &&
          mantenimiento.fecha.isAfter(hoy.subtract(const Duration(days: 1))) &&
          mantenimiento.fecha.isBefore(proximosDias)) {
        final fecha = DateTime(mantenimiento.fecha.year,
            mantenimiento.fecha.month, mantenimiento.fecha.day);
        _mantenimientosPorFecha[fecha] = [
          ...(_mantenimientosPorFecha[fecha] ?? []),
          mantenimiento
        ];
      }
    }

    _logger.info('📅 Calendario: ${todosLosTrabajos.length} trabajos totales');
    _logger
        .info('📅 Calendario: ${_trabajosPorFecha.length} fechas con trabajos');
    _logger
        .info('📅 Calendario: ${mantenimientos.length} mantenimientos totales');
    _logger.info(
        '📅 Calendario: ${_mantenimientosPorFecha.length} fechas con mantenimientos próximos');

    // Debug: mostrar algunos trabajos
    for (int i = 0; i < todosLosTrabajos.length && i < 3; i++) {
      final trabajo = todosLosTrabajos[i];
      _logger.info(
          '📅 Trabajo $i: ${trabajo.tipo} - ${trabajo.cultivo} - ${DateFormat('dd/MM/yyyy').format(trabajo.fechaInicio)} - Estado: ${trabajo.estado}');
    }

    // Debug: mostrar fechas con trabajos
    _logger.info('📅 Fechas con trabajos:');
    _trabajosPorFecha.forEach((fecha, trabajos) {
      _logger.info(
          '📅   ${DateFormat('dd/MM/yyyy').format(fecha)}: ${trabajos.length} trabajos');
    });

    // Debug: mostrar algunos mantenimientos
    for (int i = 0; i < mantenimientos.length && i < 3; i++) {
      final mantenimiento = mantenimientos[i];
      _logger.info(
          '📅 Mantenimiento $i: ${mantenimiento.descripcion} - ${DateFormat('dd/MM/yyyy').format(mantenimiento.fecha)} - Estado: ${mantenimiento.estado}');
    }

    // Debug: mostrar fechas con mantenimientos
    _logger.info('📅 Fechas con mantenimientos próximos:');
    _mantenimientosPorFecha.forEach((fecha, mantenimientos) {
      _logger.info(
          '📅   ${DateFormat('dd/MM/yyyy').format(fecha)}: ${mantenimientos.length} mantenimientos');
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 24,
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(AppConstants.primaryColor),
                        const Color(AppConstants.primaryColor).withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Calendario',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _calendarFormat = _calendarFormat == CalendarFormat.week
                      ? CalendarFormat.month
                      : CalendarFormat.week;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      const Color(AppConstants.primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _calendarFormat == CalendarFormat.week
                          ? 'Ver Mes'
                          : 'Ver Semana',
                      style: const TextStyle(
                        color: Color(AppConstants.primaryColor),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _calendarFormat == CalendarFormat.week
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_up_rounded,
                      color: const Color(AppConstants.primaryColor),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Leyenda de colores
        _buildLeyendaColores(),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TableCalendar<Trabajo>(
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            rowHeight: 52,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              // Solo actualizar si es un día diferente
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                // Normalizar la fecha seleccionada para comparar correctamente
                final fechaNormalizada = DateTime(
                    selectedDay.year, selectedDay.month, selectedDay.day);
                final trabajosDelDia =
                    _trabajosPorFecha[fechaNormalizada] ?? [];
                final mantenimientosDelDia =
                    _mantenimientosPorFecha[fechaNormalizada] ?? [];

                _logger.info(
                    '📅 Clic en día: ${DateFormat('dd/MM/yyyy').format(selectedDay)}');
                _logger.info(
                    '📅 Fecha normalizada: ${DateFormat('dd/MM/yyyy').format(fechaNormalizada)}');
                _logger
                    .info('📅 Trabajos encontrados: ${trabajosDelDia.length}');
                _logger.info(
                    '📅 Mantenimientos encontrados: ${mantenimientosDelDia.length}');

                _mostrarDetallesTrabajosYMantenimientos(
                    context, trabajosDelDia, mantenimientosDelDia, selectedDay);
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              final fechaNormalizada = DateTime(day.year, day.month, day.day);
              final trabajosDelDia = _trabajosPorFecha[fechaNormalizada] ?? [];
              if (trabajosDelDia.isNotEmpty) {
                _logger.info(
                    '📅 EventLoader - Día ${DateFormat('dd/MM/yyyy').format(day)}: ${trabajosDelDia.length} trabajos');
              }
              return trabajosDelDia;
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, focusedDay);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, focusedDay, isSelected: true);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, focusedDay, isToday: true);
              },
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red[400]),
              holidayTextStyle: TextStyle(color: Colors.red[400]),
              defaultTextStyle: const TextStyle(color: Colors.black87),
              selectedDecoration: BoxDecoration(
                color: const Color(AppConstants.primaryColor).withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(AppConstants.primaryColor),
                  width: 2,
                ),
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              todayDecoration: BoxDecoration(
                color: const Color(AppConstants.primaryColor).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      const Color(AppConstants.primaryColor).withOpacity(0.5),
                  width: 1,
                ),
              ),
              todayTextStyle: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              markersMaxCount: 0, // Desactivar los marcadores
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              leftChevronIcon: const Icon(
                Icons.chevron_left,
                color: Color(AppConstants.primaryColor),
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right,
                color: Color(AppConstants.primaryColor),
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye una celda del calendario con círculo de color según trabajos y mantenimientos
  Widget _buildDayCell(DateTime day, DateTime focusedDay,
      {bool isSelected = false, bool isToday = false}) {
    final fechaNormalizada = DateTime(day.year, day.month, day.day);
    final trabajosDelDia = _trabajosPorFecha[fechaNormalizada] ?? [];
    final mantenimientosDelDia =
        _mantenimientosPorFecha[fechaNormalizada] ?? [];

    // Determinar el color del círculo según trabajos y mantenimientos
    Color circleColor = Colors.transparent;
    Color textColor = Colors.black87;

    if (mantenimientosDelDia.isNotEmpty) {
      // Si hay mantenimientos próximos, usar color amarillo
      circleColor = Colors.yellow[600]!;
      textColor = Colors.black87;
    } else if (trabajosDelDia.isNotEmpty) {
      // Si hay trabajos, usar el color del estado predominante
      final estadoPredominante = _getEstadoPredominante(trabajosDelDia);
      circleColor = _getColorPorEstado(estadoPredominante);
      textColor = Colors.white;
    } else if (isSelected) {
      circleColor = const Color(AppConstants.primaryColor).withOpacity(0.7);
      textColor = Colors.white;
    } else if (isToday) {
      circleColor = const Color(AppConstants.primaryColor).withOpacity(0.2);
      textColor = Colors.black87;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: circleColor,
            borderRadius:
                BorderRadius.circular(8), // Square with rounded corners
            border: isSelected
                ? Border.all(
                    color: const Color(AppConstants.primaryColor),
                    width: 2,
                  )
                : null,
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Obtiene el estado predominante de una lista de trabajos
  String _getEstadoPredominante(List<Trabajo> trabajos) {
    if (trabajos.isEmpty) return 'pendiente';

    // Contar estados
    final Map<String, int> estadoCount = {};
    for (final trabajo in trabajos) {
      final estado = trabajo.estado?.toLowerCase() ?? 'pendiente';
      estadoCount[estado] = (estadoCount[estado] ?? 0) + 1;
    }

    // Encontrar el estado con más trabajos
    String estadoPredominante = 'pendiente';
    int maxCount = 0;

    estadoCount.forEach((estado, count) {
      if (count > maxCount) {
        maxCount = count;
        estadoPredominante = estado;
      }
    });

    return estadoPredominante;
  }

  /// Obtiene el color correspondiente a un estado
  Color _getColorPorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
      case 'finalizado':
        return Colors.green;
      case 'en curso':
      case 'en_progreso':
        return Colors.orange;
      case 'pendiente':
      case 'programado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Métodos auxiliares
  Widget _buildGreetingSection(Map<String, dynamic>? user) {
    final userName =
        user?['nombre'] ?? user?['username'] ?? user?['email'] ?? 'Usuario';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Hola,',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1E),
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'San Justo, Santa Fe',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  void _mostrarDetallesTrabajosYMantenimientos(
      BuildContext context,
      List<Trabajo> trabajos,
      List<Mantenimiento> mantenimientos,
      DateTime fecha) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: const Color(AppConstants.primaryColor),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd/MM/yyyy').format(fecha),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trabajos.isEmpty && mantenimientos.isEmpty) ...[
                    Icon(
                      Icons.event_busy,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay trabajos ni mantenimientos',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'programados para esta fecha',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ] else ...[
                    if (trabajos.isNotEmpty) ...[
                      Text(
                        '${trabajos.length} trabajo${trabajos.length > 1 ? 's' : ''} programado${trabajos.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...trabajos
                          .map((trabajo) => _buildTrabajoCard(trabajo))
                          .toList(),
                    ],
                    if (mantenimientos.isNotEmpty) ...[
                      if (trabajos.isNotEmpty) const SizedBox(height: 16),
                      Text(
                        '${mantenimientos.length} mantenimiento${mantenimientos.length > 1 ? 's' : ''} próximo${mantenimientos.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...mantenimientos
                          .map((mantenimiento) =>
                              _buildMantenimientoCard(mantenimiento))
                          .toList(),
                    ],
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el modal primero
                _navegarAFormularioMantenimiento(fecha);
              },
              icon: const Icon(Icons.build, size: 18),
              label: const Text('Agregar Mantenimiento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[600],
                foregroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el modal primero
                _navegarAFormularioTrabajo(fecha);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar Trabajo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.primaryColor),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMantenimientoCard(Mantenimiento mantenimiento) {
    return InkWell(
      onTap: () => _navegarADetallesMantenimiento(mantenimiento),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.yellow.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.yellow.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.build,
              color: Colors.yellow[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mantenimiento.descripcion,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Estado: ${mantenimiento.estado}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (mantenimiento.costoTotal != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Costo: \$${mantenimiento.costoTotal!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navegarADetallesMantenimiento(Mantenimiento mantenimiento) {
    // TODO: Implementar navegación a detalles de mantenimiento
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Detalles de mantenimiento: ${mantenimiento.descripcion}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Navega al formulario de mantenimientos con fecha preestablecida
  void _navegarAFormularioMantenimiento(DateTime fecha) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MantenimientoFormScreen(fechaInicial: fecha),
      ),
    );
  }

  /// Navega al formulario de trabajos con fecha preestablecida
  void _navegarAFormularioTrabajo(DateTime fecha) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrabajoFormScreen(fechaInicial: fecha),
      ),
    );
  }

  Widget _buildTrabajoCard(Trabajo trabajo) {
    // Determinar color según el estado
    Color cardColor = Colors.grey.withOpacity(0.05);
    Color borderColor = Colors.grey.withOpacity(0.2);
    Color iconColor = Colors.grey;

    final estado = trabajo.estado?.toLowerCase() ?? '';
    if (estado == 'pendiente' || estado == 'programado') {
      cardColor = Colors.blue.withOpacity(0.05);
      borderColor = Colors.blue.withOpacity(0.2);
      iconColor = Colors.blue;
    } else if (estado == 'en curso' || estado == 'en_progreso') {
      cardColor = Colors.orange.withOpacity(0.05);
      borderColor = Colors.orange.withOpacity(0.2);
      iconColor = Colors.orange;
    } else if (estado == 'completado' || estado == 'finalizado') {
      cardColor = Colors.green.withOpacity(0.05);
      borderColor = Colors.green.withOpacity(0.2);
      iconColor = Colors.green;
    }

    return InkWell(
      onTap: () => _navegarADetallesTrabajo(trabajo),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.work,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${trabajo.tipo} - ${trabajo.cultivo}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (trabajo.cliente != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Cliente: ${trabajo.cliente}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ] else ...[
              Row(
                children: [
                  Icon(
                    Icons.home,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Trabajo propio',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.landscape,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Campo ID: ${trabajo.idCampo}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Inicio: ${DateFormat('HH:mm').format(trabajo.fechaInicio)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (trabajo.fechaFin != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Fin: ${DateFormat('HH:mm').format(trabajo.fechaFin!)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
            if (trabajo.observaciones != null &&
                trabajo.observaciones!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                trabajo.observaciones!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            // Estado del trabajo
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: iconColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Estado: ${trabajo.estado ?? 'Sin estado'}',
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeyendaColores() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLeyendaItem(Colors.blue, 'Pendientes'),
          _buildLeyendaItem(Colors.orange, 'En Curso'),
          _buildLeyendaItem(Colors.green, 'Completados'),
        ],
      ),
    );
  }

  Widget _buildLeyendaItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _navegarADetallesTrabajo(Trabajo trabajo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrabajoDetailScreen(trabajo: trabajo),
      ),
    );
  }

  void _onDaySelected(DateTime dia) {
    final fechaNormalizada = DateTime(dia.year, dia.month, dia.day);
    final trabajosDelDia = _trabajosPorFecha[fechaNormalizada] ?? [];
    final mantenimientosDelDia =
        _mantenimientosPorFecha[fechaNormalizada] ?? [];

    _mostrarDetallesTrabajosYMantenimientos(
        context, trabajosDelDia, mantenimientosDelDia, dia);
  }

  /// Muestra el calendario completo en un diálogo modal
  void _showFullCalendarModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final mesActual =
              DateFormat('MMMM yyyy', 'es_ES').format(_focusedDay);

          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mesActual[0].toUpperCase() + mesActual.substring(1),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLeyendaColores(),
                  const SizedBox(height: 16),
                  TableCalendar<Trabajo>(
                    firstDay:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    headerVisible: true,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setModalState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _onDaySelected(selectedDay);
                    },
                    onPageChanged: (focusedDay) {
                      setModalState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (day) {
                      final fechaNormalizada =
                          DateTime(day.year, day.month, day.day);
                      return _trabajosPorFecha[fechaNormalizada] ?? [];
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        return _buildDayCell(day, focusedDay);
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return _buildDayCell(day, focusedDay, isSelected: true);
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return _buildDayCell(day, focusedDay, isToday: true);
                      },
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      markersMaxCount: 0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
