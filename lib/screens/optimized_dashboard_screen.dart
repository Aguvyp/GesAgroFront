import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/trabajo.dart';
import '../models/maquina.dart';
import '../models/personal.dart';
import '../utils/constants.dart';
import '../services/optimized_api_service.dart';
import '../core/logger/app_logger.dart';

class OptimizedDashboardScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateToIndex;
  
  const OptimizedDashboardScreen({
    Key? key,
    this.onNavigateToIndex,
  }) : super(key: key);

  @override
  ConsumerState<OptimizedDashboardScreen> createState() => _OptimizedDashboardScreenState();
}

class _OptimizedDashboardScreenState extends ConsumerState<OptimizedDashboardScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Estados para datos reales
  List<Trabajo> _trabajos = [];
  List<Maquina> _maquinas = [];
  List<Personal> _personal = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  final ApiService _apiService = ApiService();
  final AppLogger _logger = AppLogger.instance;

  @override
  void initState() {
    super.initState();
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
      
      // Inicializar el servicio API
      await _apiService.initialize();
      
      // Cargar datos usando los endpoints específicos del dashboard
      final results = await Future.wait([
        _apiService.getTrabajos(),
        _apiService.get('/dashboard/maquinas-superficies'),
        _apiService.get('/dashboard/personal-rendimiento'),
      ]);

      setState(() {
        _trabajos = results[0] as List<Trabajo>;
        
        // Procesar datos de máquinas desde el endpoint específico
        final maquinasResponse = results[1] as Map<String, dynamic>;
        final maquinasData = maquinasResponse['data'] as List<dynamic>;
        _maquinas = maquinasData.map((json) => Maquina.fromJson(json)).toList();
        
        // Ordenar máquinas por hectáreas (mayor a menor)
        _maquinas.sort((a, b) {
          final haA = a.superficieTotalHa ?? 0.0;
          final haB = b.superficieTotalHa ?? 0.0;
          return haB.compareTo(haA); // Orden descendente
        });
        
        // Procesar datos de personal desde el endpoint específico
        final personalResponse = results[2] as Map<String, dynamic>;
        final personalData = personalResponse['data'] as List<dynamic>;
        _personal = personalData.map((json) => Personal.fromJson(json)).toList();
        
        // Ordenar personal por hectáreas (mayor a menor)
        _personal.sort((a, b) {
          final haA = a.superficieTotalHa ?? 0.0;
          final haB = b.superficieTotalHa ?? 0.0;
          return haB.compareTo(haA); // Orden descendente
        });
        
        _isLoading = false;
      });

      _logger.info('✅ Datos del dashboard cargados: ${_trabajos.length} trabajos, ${_maquinas.length} máquinas, ${_personal.length} personal');
      
      // Mostrar datos detallados de los endpoints específicos
      _logger.info('📊 Datos de máquinas desde endpoint específico:');
      for (int i = 0; i < _maquinas.length; i++) {
        final maquina = _maquinas[i];
        _logger.info('   Máquina $i: id=${maquina.id}, nombre=${maquina.nombre}, superficieTotalHa=${maquina.superficieTotalHa}, horasTrabajadas=${maquina.horasTrabajadas}');
      }
      
      _logger.info('📊 Datos de personal desde endpoint específico:');
      for (int i = 0; i < _personal.length; i++) {
        final operario = _personal[i];
        _logger.info('   Operario $i: id=${operario.id}, nombre=${operario.nombre}, superficieTotalHa=${operario.superficieTotalHa}, horasTrabajadas=${operario.horasTrabajadas}, trabajosCompletados=${operario.trabajosCompletados}');
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

  /// Probar los nuevos endpoints específicos del dashboard
  Future<void> _testNewEndpoints() async {
    try {
      _logger.info('🧪 Probando endpoint /dashboard/maquinas-superficies...');
      
      final maquinasResponse = await _apiService.get('/dashboard/maquinas-superficies');
      _logger.info('📊 Respuesta de máquinas-superficies:');
      _logger.info('   Tipo: ${maquinasResponse.runtimeType}');
      _logger.info('   Contenido: $maquinasResponse');
      
      if (maquinasResponse is Map<String, dynamic>) {
        final data = maquinasResponse['data'];
        _logger.info('   Data field: $data');
        if (data is List) {
          _logger.info('   Cantidad de máquinas: ${data.length}');
          for (int i = 0; i < data.length; i++) {
            _logger.info('   Máquina $i: ${data[i]}');
          }
        }
      }
      
    } catch (e) {
      _logger.error('❌ Error en endpoint máquinas-superficies: $e');
    }

    try {
      _logger.info('🧪 Probando endpoint /dashboard/personal-rendimiento...');
      
      final personalResponse = await _apiService.get('/dashboard/personal-rendimiento');
      _logger.info('📊 Respuesta de personal-rendimiento:');
      _logger.info('   Tipo: ${personalResponse.runtimeType}');
      _logger.info('   Contenido: $personalResponse');
      
      if (personalResponse is Map<String, dynamic>) {
        final data = personalResponse['data'];
        _logger.info('   Data field: $data');
        if (data is List) {
          _logger.info('   Cantidad de personal: ${data.length}');
          for (int i = 0; i < data.length; i++) {
            _logger.info('   Personal $i: ${data[i]}');
          }
        }
      }
      
    } catch (e) {
      _logger.error('❌ Error en endpoint personal-rendimiento: $e');
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

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              _buildHeader(),
              const SizedBox(height: 24),

              // Lista de trabajos por estado
              _buildTrabajosSection(_trabajos),
              const SizedBox(height: 24),

              // Calendario de trabajos pendientes
              _buildCalendarioTrabajos(_trabajos),
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
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard GesAgro',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Resumen de actividades y estadísticas',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 3,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(AppConstants.primaryColor).withOpacity(0.3),
                const Color(AppConstants.primaryColor),
                const Color(AppConstants.primaryColor).withOpacity(0.3),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
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
    final pendientes = trabajos.where((t) => 
      t.estado?.toLowerCase() == 'pendiente' || 
      t.estado?.toLowerCase() == 'programado'
    ).length;
    final enCurso = trabajos.where((t) => 
      t.estado?.toLowerCase() == 'en curso' || 
      t.estado?.toLowerCase() == 'en ejecución' ||
      t.estado?.toLowerCase() == 'ejecutando'
    ).length;
    final completados = trabajos.where((t) => 
      t.estado?.toLowerCase() == 'completado' || 
      t.estado?.toLowerCase() == 'finalizado'
    ).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Pendientes',
            pendientes.toString(),
            Icons.schedule,
            const Color(AppConstants.infoColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'En Curso',
            enCurso.toString(),
            Icons.play_circle,
            const Color(AppConstants.accentColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completados',
            completados.toString(),
            Icons.check_circle,
            const Color(AppConstants.successColor),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarioTrabajos(List<Trabajo> trabajos) {
    // Filtrar trabajos pendientes/programados
    final trabajosPendientes = trabajos.where((t) => 
      t.estado?.toLowerCase() == 'pendiente' || 
      t.estado?.toLowerCase() == 'programado'
    ).toList();
    
    // Crear mapa de fechas con trabajos
    final Map<DateTime, List<Trabajo>> trabajosPorFecha = {};
    for (final trabajo in trabajosPendientes) {
      final fecha = DateTime(trabajo.fechaInicio.year, trabajo.fechaInicio.month, trabajo.fechaInicio.day);
      trabajosPorFecha[fecha] = [...(trabajosPorFecha[fecha] ?? []), trabajo];
    }

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
              'Calendario de Trabajos Pendientes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
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
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                
                // Mostrar detalles del trabajo si hay trabajos en esa fecha
                final trabajosDelDia = trabajosPorFecha[selectedDay];
                if (trabajosDelDia != null && trabajosDelDia.isNotEmpty) {
                  _mostrarDetallesTrabajos(context, trabajosDelDia, selectedDay);
                }
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return trabajosPorFecha[day] ?? [];
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red[400]),
              holidayTextStyle: TextStyle(color: Colors.red[400]),
              defaultTextStyle: const TextStyle(color: Colors.black87),
              selectedDecoration: BoxDecoration(
                color: const Color(AppConstants.primaryColor),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: const Color(AppConstants.primaryColor).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: const Color(AppConstants.primaryColor),
                shape: BoxShape.circle,
              ),
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

  void _mostrarDetallesTrabajos(BuildContext context, List<Trabajo> trabajos, DateTime fecha) {
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
                Text(
                  '${trabajos.length} trabajo${trabajos.length > 1 ? 's' : ''} programado${trabajos.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ...trabajos.map((trabajo) => _buildTrabajoCard(trabajo)).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrabajoCard(Trabajo trabajo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppConstants.primaryColor).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(AppConstants.primaryColor).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.work,
                color: const Color(AppConstants.primaryColor),
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
          if (trabajo.observaciones != null && trabajo.observaciones!.isNotEmpty) ...[
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
        ],
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
      children: maquinas.take(3).map((maquina) => 
        Container(
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
      ).toList(),
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

    return Column(
      children: personal.take(3).map((operario) => 
        Container(
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
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(AppConstants.primaryColor).withOpacity(0.1),
                child: Text(
                  operario.initials,
                  style: const TextStyle(
                    color: Color(AppConstants.primaryColor),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operario.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'DNI: ${operario.dni}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${operario.superficieTotalHa?.toStringAsFixed(1) ?? '0.0'} ha',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (operario.telefono != null && operario.telefono!.isNotEmpty)
                      Text(
                        'Tel: ${operario.telefono}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}