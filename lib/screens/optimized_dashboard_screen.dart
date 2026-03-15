import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/trabajo.dart';
import '../models/maquina.dart';
import '../models/personal.dart';
import '../models/mantenimiento.dart';
import '../themes/app_theme.dart';
import '../services/optimized_api_service.dart';
import '../core/logger/app_logger.dart';
import 'trabajos/trabajo_detail_screen.dart';
import 'forms/trabajo_form_screen.dart';
import 'forms/mantenimiento_form_screen.dart';
import 'forms/registrar_horas_form.dart';
import 'optimized_screens.dart';
import '../providers/optimized_auth_provider.dart';
import '../providers/optimized_providers.dart';
import '../widgets/dashboard_widgets.dart';

class OptimizedDashboardScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateToIndex;

  const OptimizedDashboardScreen({Key? key, this.onNavigateToIndex})
      : super(key: key);

  @override
  ConsumerState<OptimizedDashboardScreen> createState() =>
      _OptimizedDashboardScreenState();
}

class _OptimizedDashboardScreenState
    extends ConsumerState<OptimizedDashboardScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Trabajo> _trabajos = [];
  List<Maquina> _maquinas = [];
  List<Personal> _personal = [];
  List<Mantenimiento> _mantenimientos = [];
  bool _isLoading = true;
  String? _errorMessage;

  Map<DateTime, List<Trabajo>> _trabajosPorFecha = {};
  Map<DateTime, List<Mantenimiento>> _mantenimientosPorFecha = {};

  final ApiService _apiService = ApiService();
  final AppLogger _logger = AppLogger.instance;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null).then((_) {
      if (mounted) setState(() {});
    });
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (!_apiService.isInitialized) {
        await _apiService.initialize();
      }

      List<Trabajo> trabajos = [];
      Map<String, dynamic> dashboardResponse = {};
      List<Mantenimiento> mantenimientos = [];

      try {
        trabajos = await _apiService.getTrabajos();
      } catch (e) {
        _logger.error('Error cargando trabajos: $e');
      }

      try {
        final response = await _apiService.get('/api/dashboard/resumen');
        if (response is Map<String, dynamic>) {
          dashboardResponse = response;
        }
      } catch (e) {
        _logger.error('Error cargando resumen: $e');
      }

      try {
        mantenimientos = await _apiService.getMantenimientos();
      } catch (e) {
        _logger.error('Error cargando mantenimientos: $e');
      }

      if (!mounted) return;

      setState(() {
        _trabajos = trabajos;

        if (dashboardResponse['maquinas'] != null) {
          final maquinasData = dashboardResponse['maquinas'] as List<dynamic>;
          _maquinas =
              maquinasData.map((json) => Maquina.fromJson(json)).toList();
        } else {
          _maquinas = [];
        }
        _maquinas.sort((a, b) =>
            (b.superficieTotalHa ?? 0.0).compareTo(a.superficieTotalHa ?? 0.0));

        if (dashboardResponse['personal'] != null) {
          final personalData = dashboardResponse['personal'] as List<dynamic>;
          _personal =
              personalData.map((json) => Personal.fromJson(json)).toList();
        } else {
          _personal = [];
        }
        _personal.sort((a, b) =>
            (b.superficieTotalHa ?? 0.0).compareTo(a.superficieTotalHa ?? 0.0));

        _mantenimientos = mantenimientos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error cargando datos';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(dashboardRefreshProvider, (previous, next) {
      _refreshDashboard();
    });

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cargando tu campo...',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wifi_off_rounded,
                      size: 40, color: AppTheme.error),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sin conexión',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _refreshDashboard,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text('Reintentar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Classify jobs
    final enCurso = <Trabajo>[];
    final pendientes = <Trabajo>[];
    final completados = <Trabajo>[];
    for (var t in _trabajos) {
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

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        onRefresh: _refreshDashboard,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ─── Top safe area + greeting ───
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(ref.watch(currentUserProvider)),
                        const SizedBox(height: 16),
                        const WeatherWidget(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Content ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Stats row ───
                    _buildStatsRow(enCurso.length, pendientes.length,
                        completados.length),
                    const SizedBox(height: 24),

                    // ─── Precios ───
                    const PriceTickerWidget(),
                    const SizedBox(height: 24),

                    // ─── En curso ───
                    if (enCurso.isNotEmpty) ...[
                      _buildSectionHeader(
                        'En curso',
                        '${enCurso.length}',
                        AppTheme.warning,
                        () => _navegarAListaTrabajosPorEstado('En curso'),
                      ),
                      const SizedBox(height: 10),
                      ...enCurso
                          .take(3)
                          .map((t) => _buildTrabajoCard(t, true, false)),
                      const SizedBox(height: 20),
                    ],

                    // ─── Pendientes ───
                    if (pendientes.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Pendientes',
                        '${pendientes.length}',
                        AppTheme.info,
                        () => _navegarAListaTrabajosPorEstado('Pendiente'),
                      ),
                      const SizedBox(height: 10),
                      ...pendientes
                          .take(3)
                          .map((t) => _buildTrabajoCard(t, false, false)),
                      const SizedBox(height: 20),
                    ],

                    // ─── Completados recientes ───
                    if (completados.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Completados',
                        '${completados.length}',
                        AppTheme.success,
                        () => _navegarAListaTrabajosPorEstado('Todos'),
                      ),
                      const SizedBox(height: 10),
                      ...completados
                          .take(2)
                          .map((t) => _buildTrabajoCard(t, false, true)),
                      const SizedBox(height: 20),
                    ],

                    // ─── Empty state ───
                    if (_trabajos.isEmpty) _buildEmptyState(),

                    // Bottom padding for FAB
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════
  //  HEADER
  // ════════════════════════════════════════════════

  Widget _buildHeader(Map<String, dynamic>? user) {
    final userName =
        user?['nombre'] ?? user?['username'] ?? user?['email'] ?? 'Usuario';
    final now = DateTime.now();
    String greeting;
    if (now.hour < 12) {
      greeting = 'Buenos días';
    } else if (now.hour < 19) {
      greeting = 'Buenas tardes';
    } else {
      greeting = 'Buenas noches';
    }

    String dateStr;
    try {
      dateStr = DateFormat('EEEE d \'de\' MMMM', 'es_ES').format(now);
      dateStr = dateStr[0].toUpperCase() + dateStr.substring(1);
    } catch (_) {
      dateStr = DateFormat('dd/MM/yyyy').format(now);
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textHint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildHeaderIconButton(
          Icons.calendar_month_outlined,
          () {
            setState(() {
              _focusedDay = DateTime.now();
            });
            _showFullCalendarModal(context);
          },
        ),
        const SizedBox(width: 8),
        _buildAvatar(userName),
      ],
    );
  }

  Widget _buildHeaderIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppTheme.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 20),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════
  //  STATS ROW
  // ════════════════════════════════════════════════

  Widget _buildStatsRow(int enCurso, int pendientes, int completados) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'En curso',
            '$enCurso',
            AppTheme.warning,
            Icons.play_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            'Pendientes',
            '$pendientes',
            AppTheme.info,
            Icons.schedule_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            'Listos',
            '$completados',
            AppTheme.success,
            Icons.check_circle_outline_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════
  //  SECTION HEADERS
  // ════════════════════════════════════════════════

  Widget _buildSectionHeader(
      String title, String count, Color color, VoidCallback onSeeAll) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ver todos',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppTheme.primary),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════
  //  TRABAJO CARD
  // ════════════════════════════════════════════════

  Widget _buildTrabajoCard(
      Trabajo trabajo, bool isEnCurso, bool isCompletado) {
    final estado = trabajo.estado?.toLowerCase().trim() ?? '';
    Color statusColor;
    if (isEnCurso) {
      statusColor = AppTheme.warning;
    } else if (isCompletado) {
      statusColor = AppTheme.success;
    } else {
      statusColor = AppTheme.info;
    }

    IconData laborIcon;
    final tipoLabor = trabajo.tipo.toLowerCase();
    if (tipoLabor.contains('siembra')) {
      laborIcon = Icons.grass_rounded;
    } else if (tipoLabor.contains('cosecha')) {
      laborIcon = Icons.agriculture_rounded;
    } else if (tipoLabor.contains('pulver')) {
      laborIcon = Icons.water_drop_outlined;
    } else if (tipoLabor.contains('fertiliz')) {
      laborIcon = Icons.science_outlined;
    } else {
      laborIcon = Icons.work_outline_rounded;
    }

    String subtitle = 'Propio';
    if (trabajo.esTercero) {
      subtitle = trabajo.cliente != null && trabajo.cliente!.isNotEmpty
          ? trabajo.cliente!
          : 'A terceros';
    } else if (trabajo.servicioContratado) {
      subtitle = 'Servicio contratado';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TrabajoDetailScreen(trabajo: trabajo)),
          ),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(laborIcon, color: statusColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    // Title & subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${trabajo.tipo} · ${trabajo.cultivo}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.landscape_outlined,
                                  size: 13, color: AppTheme.textHint),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  trabajo.campoInfo,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '· $subtitle',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textHint,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action buttons
                    if (isEnCurso)
                      _buildAddHoursButton(trabajo)
                    else
                      Icon(Icons.chevron_right_rounded,
                          size: 20, color: AppTheme.textHint),
                  ],
                ),

                // Progress bar for en-curso
                if (isEnCurso) ...[
                  const SizedBox(height: 12),
                  _buildProgressBar(trabajo, statusColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddHoursButton(Trabajo trabajo) {
    return Material(
      color: AppTheme.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {
          double? maxHectares;
          if (trabajo.campoHa != null && trabajo.haRealizadas != null) {
            maxHectares = trabajo.campoHa! - trabajo.haRealizadas!;
            if (maxHectares < 0) maxHectares = 0;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegistrarHorasForm(
                trabajoId: trabajo.id!,
                trabajoTitulo: '${trabajo.tipo} - ${trabajo.cultivo}',
                maxHectares: maxHectares,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.add_rounded, color: AppTheme.primary, size: 20),
        ),
      ),
    );
  }

  Widget _buildProgressBar(Trabajo trabajo, Color color) {
    final progress = (trabajo.porcentajeProgreso ?? 0.0) / 100;
    final haRealiz = trabajo.haRealizadas;
    final campoHa = trabajo.campoHa;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (haRealiz != null && campoHa != null)
              Text(
                '${haRealiz.toStringAsFixed(1)} / ${campoHa.toStringAsFixed(1)} ha',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              const SizedBox.shrink(),
            Text(
              '${(trabajo.porcentajeProgreso ?? 0.0).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════
  //  EMPTY STATE
  // ════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              size: 44,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sin trabajos aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Creá tu primer trabajo con el botón +\npara empezar a gestionar tu campo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════
  //  NAVIGATION
  // ════════════════════════════════════════════════

  void _navegarAListaTrabajosPorEstado(String estado) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OptimizedTrabajosListScreen(
          showAppBar: true,
          estadoFiltro: estado,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════
  //  CALENDAR MODAL
  // ════════════════════════════════════════════════

  void _showFullCalendarModal(BuildContext context) {
    _trabajosPorFecha = {};
    for (final trabajo in _trabajos) {
      final fecha = DateTime(trabajo.fechaInicio.year,
          trabajo.fechaInicio.month, trabajo.fechaInicio.day);
      _trabajosPorFecha[fecha] = [
        ...(_trabajosPorFecha[fecha] ?? []),
        trabajo
      ];
    }

    _mantenimientosPorFecha = {};
    final hoy = DateTime.now();
    final proximosDias = hoy.add(const Duration(days: 30));
    for (final m in _mantenimientos) {
      if (m.estado.toLowerCase() == 'pendiente' &&
          m.fecha.isAfter(hoy.subtract(const Duration(days: 1))) &&
          m.fecha.isBefore(proximosDias)) {
        final fecha = DateTime(m.fecha.year, m.fecha.month, m.fecha.day);
        _mantenimientosPorFecha[fecha] = [
          ...(_mantenimientosPorFecha[fecha] ?? []),
          m
        ];
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          String mesActual;
          try {
            mesActual = DateFormat('MMMM yyyy', 'es_ES').format(_focusedDay);
            mesActual = mesActual[0].toUpperCase() + mesActual.substring(1);
          } catch (_) {
            mesActual = DateFormat('MM/yyyy').format(_focusedDay);
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.72,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mesActual,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendDot(AppTheme.info, 'Pendiente'),
                      const SizedBox(width: 16),
                      _buildLegendDot(AppTheme.warning, 'En curso'),
                      const SizedBox(width: 16),
                      _buildLegendDot(AppTheme.success, 'Listo'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Calendar
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TableCalendar<Trabajo>(
                      firstDay: DateTime.now()
                          .subtract(const Duration(days: 365)),
                      lastDay:
                          DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      calendarFormat: CalendarFormat.month,
                      headerVisible: true,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        leftChevronIcon: Icon(Icons.chevron_left_rounded,
                            color: AppTheme.primary),
                        rightChevronIcon: Icon(
                            Icons.chevron_right_rounded,
                            color: AppTheme.primary),
                      ),
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setModalState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        final fechaN = DateTime(selectedDay.year,
                            selectedDay.month, selectedDay.day);
                        final trabajosDelDia =
                            _trabajosPorFecha[fechaN] ?? [];
                        final mantDelDia =
                            _mantenimientosPorFecha[fechaN] ?? [];
                        _mostrarDetallesDia(context, trabajosDelDia,
                            mantDelDia, selectedDay);
                      },
                      onPageChanged: (focusedDay) {
                        setModalState(() => _focusedDay = focusedDay);
                      },
                      eventLoader: (day) {
                        final fechaN =
                            DateTime(day.year, day.month, day.day);
                        return _trabajosPorFecha[fechaN] ?? [];
                      },
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (ctx, day, focused) =>
                            _buildDayCell(day, focused),
                        selectedBuilder: (ctx, day, focused) =>
                            _buildDayCell(day, focused, isSelected: true),
                        todayBuilder: (ctx, day, focused) =>
                            _buildDayCell(day, focused, isToday: true),
                      ),
                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                        markersMaxCount: 0,
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                        weekendStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildDayCell(DateTime day, DateTime focusedDay,
      {bool isSelected = false, bool isToday = false}) {
    final fechaN = DateTime(day.year, day.month, day.day);
    final trabajosDelDia = _trabajosPorFecha[fechaN] ?? [];
    final mantDelDia = _mantenimientosPorFecha[fechaN] ?? [];

    Color? dotColor;
    if (mantDelDia.isNotEmpty) {
      dotColor = AppTheme.warning;
    } else if (trabajosDelDia.isNotEmpty) {
      final estado = _getEstadoPredominante(trabajosDelDia);
      dotColor = _getColorPorEstado(estado);
    }

    Color bgColor = Colors.transparent;
    Color textColor = AppTheme.textPrimary;
    if (isSelected) {
      bgColor = AppTheme.primary;
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = AppTheme.primary.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.all(3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          if (dotColor != null)
            Container(
              width: 5,
              height: 5,
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle),
            )
          else
            const SizedBox(height: 5),
        ],
      ),
    );
  }

  String _getEstadoPredominante(List<Trabajo> trabajos) {
    if (trabajos.isEmpty) return 'pendiente';
    final Map<String, int> count = {};
    for (final t in trabajos) {
      final e = t.estado?.toLowerCase() ?? 'pendiente';
      count[e] = (count[e] ?? 0) + 1;
    }
    String best = 'pendiente';
    int max = 0;
    count.forEach((e, c) {
      if (c > max) {
        max = c;
        best = e;
      }
    });
    return best;
  }

  Color _getColorPorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
      case 'finalizado':
        return AppTheme.success;
      case 'en curso':
      case 'en_progreso':
        return AppTheme.warning;
      case 'pendiente':
      case 'programado':
        return AppTheme.info;
      default:
        return AppTheme.textHint;
    }
  }

  // ════════════════════════════════════════════════
  //  DAY DETAILS BOTTOM SHEET
  // ════════════════════════════════════════════════

  void _mostrarDetallesDia(BuildContext context, List<Trabajo> trabajos,
      List<Mantenimiento> mantenimientos, DateTime fecha) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.55,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDayTitle(fecha),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            if (trabajos.isEmpty && mantenimientos.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                child: Column(
                  children: [
                    Icon(Icons.event_available_rounded,
                        size: 40, color: AppTheme.textHint),
                    const SizedBox(height: 12),
                    const Text(
                      'Día libre',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'No hay actividades programadas',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textHint),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    ...trabajos.map((t) => _buildDayTrabajoItem(t)),
                    ...mantenimientos
                        .map((m) => _buildDayMantenimientoItem(m)),
                  ],
                ),
              ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MantenimientoFormScreen(fechaInicial: fecha),
                          ),
                        );
                      },
                      icon: const Icon(Icons.build_outlined, size: 18),
                      label: const Text('Manten.'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TrabajoFormScreen(fechaInicial: fecha),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Trabajo'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDayTitle(DateTime fecha) {
    try {
      final str =
          DateFormat('EEEE d \'de\' MMMM', 'es_ES').format(fecha);
      return str[0].toUpperCase() + str.substring(1);
    } catch (_) {
      return DateFormat('dd/MM/yyyy').format(fecha);
    }
  }

  Widget _buildDayTrabajoItem(Trabajo trabajo) {
    final estado = trabajo.estado?.toLowerCase() ?? '';
    Color color = AppTheme.info;
    if (['en curso', 'en_progreso'].contains(estado)) {
      color = AppTheme.warning;
    }
    if (['completado', 'finalizado'].contains(estado)) {
      color = AppTheme.success;
    }

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrabajoDetailScreen(trabajo: trabajo),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${trabajo.tipo} · ${trabajo.cultivo}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trabajo.estado ?? 'Pendiente',
                    style: TextStyle(fontSize: 12, color: color),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.textHint, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDayMantenimientoItem(Mantenimiento m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.warning,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.descripcion,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Mantenimiento · ${m.estado}',
                  style:
                      const TextStyle(fontSize: 12, color: AppTheme.warning),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
