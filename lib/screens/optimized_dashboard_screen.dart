import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
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
import 'optimized_screens.dart';
import '../providers/optimized_auth_provider.dart';

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

    final background = theme.colorScheme.background;
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
                      // Saludo y Perfil
                      _buildGreetingSection(ref.watch(currentUserProvider)),

                      // Calendario (ahora arriba)
                      _buildCalendarioTrabajosYMantenimientos(
                          _trabajos, _mantenimientos),
                      const SizedBox(height: 24),

                      // Lista de trabajos por estado

                      _buildTrabajosSection(_trabajos),
                      const SizedBox(height: 24),

                      // Calendario de trabajos y mantenimientos
                      // Calendario de trabajos y mantenimientos
                      // _buildCalendarioTrabajosYMantenimientos(_trabajos, _mantenimientos),
                      // const SizedBox(height: 24),
                      const SizedBox(height: 24),

                      // Superficies de máquinas
                      _buildMaquinasSection(_maquinas),
                      const SizedBox(height: 24),

                      // Superficies y horas de operadores
                      _buildPersonalSection(_personal),
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
              'Estado de Trabajos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTrabajosCards(trabajos),
      ],
    );
  }

  Widget _buildTrabajosCards(List<Trabajo> trabajos) {
    final pendientes = trabajos
        .where((t) =>
            t.estado?.toLowerCase() == 'pendiente' ||
            t.estado?.toLowerCase() == 'programado')
        .length;
    final enCurso = trabajos
        .where((t) =>
            t.estado?.toLowerCase() == 'en curso' ||
            t.estado?.toLowerCase() == 'en ejecución' ||
            t.estado?.toLowerCase() == 'ejecutando')
        .length;
    final completados = trabajos
        .where((t) =>
            t.estado?.toLowerCase() == 'completado' ||
            t.estado?.toLowerCase() == 'finalizado')
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Pendientes',
            pendientes.toString(),
            Icons.schedule,
            const Color(AppConstants.infoColor),
            onTap: () => _navegarAListaTrabajosPorEstado('Pendientes'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'En Curso',
            enCurso.toString(),
            Icons.play_circle,
            const Color(AppConstants.accentColor),
            onTap: () => _navegarAListaTrabajosPorEstado('En Curso'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completos',
            completados.toString(),
            Icons.check_circle,
            const Color(AppConstants.successColor),
            onTap: () => _navegarAListaTrabajosPorEstado('Completados'),
          ),
        ),
      ],
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
                shape: BoxShape.circle,
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
                shape: BoxShape.circle,
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
      margin: const EdgeInsets.all(4),
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
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
    // Determinar saludo según la hora
    final now = DateTime.now();
    String greeting = 'Buenos días,';
    if (now.hour >= 12 && now.hour < 20) {
      greeting = 'Buenas tardes,';
    } else if (now.hour >= 20) {
      greeting = 'Buenas noches,';
    }

    // Obtener nombre del usuario o usar fallback
    final userName = user?['username'] ?? user?['nombre'] ?? 'Pepito Juarez';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(AppConstants.secondaryColor),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: Text(
                userName.isNotEmpty
                    ? userName.substring(0, 1).toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Color(AppConstants.primaryColor),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              // Aquí podrías usar NetworkImage si el usuario tiene foto
              // backgroundImage: user?['photo_url'] != null ? NetworkImage(user!['photo_url']) : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1E),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('No tienes nuevas notificaciones')),
                );
              },
              icon: const Icon(Icons.notifications_none_rounded),
              color: Colors.black87,
            ),
          ),
        ],
      ),
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

  Widget _buildMaquinasSection(List<Maquina> maquinas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              'Superficies por Máquina',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMaquinasContent(maquinas),
      ],
    );
  }

  Widget _buildMaquinasContent(List<Maquina> maquinas) {
    return _buildMaquinasCards(maquinas);
  }

  Widget _buildMaquinasCards(List<Maquina> maquinas) {
    if (maquinas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.build_circle_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No hay máquinas registradas',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega máquinas para ver estadísticas',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: maquinas
          .take(3)
          .map(
            (maquina) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  Icon(
                    Icons.build,
                    color: const Color(AppConstants.primaryColor),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${maquina.marca} ${maquina.modelo}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Año: ${maquina.ano}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${maquina.superficieTotalHa?.toStringAsFixed(1) ?? '0.0'} ha',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPersonalSection(List<Personal> personal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              'Rendimiento de Operadores',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPersonalContent(personal),
      ],
    );
  }

  Widget _buildPersonalContent(List<Personal> personal) {
    return _buildPersonalCards(personal);
  }

  Widget _buildPersonalCards(List<Personal> personal) {
    if (personal.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.person_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No hay personal registrado',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega personal para ver estadísticas',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Preparar datos para el gráfico (máximo 5 operadores)
    final topOperadores = personal.take(5).toList();

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Título del gráfico

          const SizedBox(height: 16),

          // Gráfico de torta
          Expanded(
            child: Row(
              children: [
                // Gráfico de torta
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        enabled: true,
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // Manejar toque en el gráfico
                        },
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: topOperadores.asMap().entries.map((entry) {
                        final index = entry.key;
                        final operario = entry.value;
                        final ha = operario.superficieTotalHa ?? 0.0;
                        final totalHa = topOperadores.fold(0.0,
                            (sum, p) => sum + (p.superficieTotalHa ?? 0.0));
                        final percentage =
                            totalHa > 0 ? (ha / totalHa) * 100 : 0.0;

                        return PieChartSectionData(
                          color: _getBarColor(index),
                          value: ha,
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Leyenda con nombres y valores
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: topOperadores.asMap().entries.map((entry) {
                      final index = entry.key;
                      final operario = entry.value;
                      final ha = operario.superficieTotalHa ?? 0.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getBarColor(index),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    operario.nombre,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${ha.toStringAsFixed(1)} ha',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBarColor(int index) {
    final colors = [
      const Color(AppConstants.primaryColor), // Color primario de la app
      Colors.deepOrange, // Naranja intenso
      Colors.teal, // Verde azulado
      Colors.purple, // Púrpura
      Colors.red, // Rojo
      Colors.indigo, // Índigo
      Colors.amber, // Ámbar
      Colors.pink, // Rosa
      Colors.cyan, // Cian
      Colors.lime, // Lima
    ];
    return colors[index % colors.length];
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      {VoidCallback? onTap}) {
    final card = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w500,
              letterSpacing: -0.08,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      );
    }

    return card;
  }

  /// Nuevo Calendario con vista semanal personalizada
  Widget _buildCalendarioTrabajosYMantenimientos(
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

    // Crear mapa de fechas con mantenimientos próximos
    _mantenimientosPorFecha = {};
    final hoy = DateTime.now();
    final proximosDias = hoy.add(const Duration(days: 30));

    for (final mantenimiento in mantenimientos) {
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

    // Texto del mes actual
    final mesActual = DateFormat('MMMM yyyy', 'es_ES').format(_focusedDay);
    final semanaActual = _getWeekNumber(_focusedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header del Calendario (Mes y Selector de Vista)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mesActual[0].toUpperCase() + mesActual.substring(1),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                if (_calendarFormat == CalendarFormat.week)
                  const SizedBox(height: 4),
              ],
            ),
            Row(
              children: [
                if (_calendarFormat == CalendarFormat.week)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9), // Verde muy claro
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Semana $semanaActual',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
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
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _calendarFormat == CalendarFormat.week
                              ? 'Ver Mes'
                              : 'Ver Semana',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _calendarFormat == CalendarFormat.week
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_up_rounded,
                          color: Colors.grey[800],
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Cuerpo del Calendario
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _calendarFormat == CalendarFormat.week
              ? _buildCustomWeekCalendar()
              : _buildMonthCalendar(),
        ),
      ],
    );
  }

  /// Obtener número de semana
  int _getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat('D').format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  /// Construye la vista de calendario mensual estándar
  Widget _buildMonthCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildLeyendaColores(),
          ),
          TableCalendar<Trabajo>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            headerVisible: false, // Ya tenemos nuestro propio header
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _onDaySelected(selectedDay);
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              final fechaNormalizada = DateTime(day.year, day.month, day.day);
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
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red[400]),
              defaultTextStyle: const TextStyle(color: Colors.black87),
              markersMaxCount: 0,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la vista personalizada de semana (tipo tarjetas)
  Widget _buildCustomWeekCalendar() {
    // Calcular inicio de semana (Lunes)
    final inicioSemana =
        _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
    final diasSemana =
        List.generate(7, (index) => inicioSemana.add(Duration(days: index)));

    return SizedBox(
      height: 100, // Altura fija para las cards
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: diasSemana.map((dia) {
          final isSelected = isSameDay(_selectedDay ?? DateTime.now(), dia);

          final fechaNormalizada = DateTime(dia.year, dia.month, dia.day);
          final hasTrabajos =
              (_trabajosPorFecha[fechaNormalizada] ?? []).isNotEmpty;
          final hasMantenimientos =
              (_mantenimientosPorFecha[fechaNormalizada] ?? []).isNotEmpty;
          final hasEvents = hasTrabajos || hasMantenimientos;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = dia;
                  _focusedDay = dia;
                });
                _onDaySelected(dia);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF00C853) // Verde brillante seleccionado
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.grey.withOpacity(0.1)),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00C853).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE', 'es_ES')
                          .format(dia)
                          .substring(0, 3)
                          .replaceFirst('.', ''),
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isSelected ? Colors.white : const Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${dia.day}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            isSelected ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    if (hasEvents) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF00C853),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ] else
                      const SizedBox(height: 11),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
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
}
