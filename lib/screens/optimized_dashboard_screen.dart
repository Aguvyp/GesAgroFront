import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/trabajo.dart';
import '../models/maquina.dart';
import '../models/personal.dart';
import '../utils/constants.dart';

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

  @override
  Widget build(BuildContext context) {
    // Datos de prueba por el momento
    final trabajosPrueba = _getTrabajosPrueba();
    final maquinasPrueba = _getMaquinasPrueba();
    final personalPrueba = _getPersonalPrueba();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // Encabezado
            // _buildHeader(),
            // const SizedBox(height: 24),

            // Lista de trabajos por estado
            _buildTrabajosSection(trabajosPrueba),
            const SizedBox(height: 24),

            // Calendario de trabajos pendientes
            _buildCalendarioTrabajos(trabajosPrueba),
            const SizedBox(height: 24),

            // Superficies de máquinas
            _buildMaquinasSection(maquinasPrueba),
            const SizedBox(height: 24),

            // Superficies y horas de operadores
            _buildPersonalSection(personalPrueba),
          ],
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
    final pendientes = trabajos.where((t) => t.estado?.toLowerCase() == 'pendiente').length;
    final enCurso = trabajos.where((t) => t.estado?.toLowerCase() == 'en curso').length;
    final completados = trabajos.where((t) => t.estado?.toLowerCase() == 'completado').length;

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
    // Filtrar solo trabajos pendientes
    final trabajosPendientes = trabajos.where((t) => t.estado == 'Pendiente').toList();
    
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
                    Text(
                      'Superficie: ${(maquina.id! * 25.5).toStringAsFixed(1)} ha',
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
                    Text(
                      'Superficie: ${(operario.id! * 18.5).toStringAsFixed(1)} ha | Horas: ${(operario.id! * 12.5).toStringAsFixed(1)}h',
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

  // Métodos de datos de prueba
  List<Trabajo> _getTrabajosPrueba() {
    final ahora = DateTime.now();
    return [
      Trabajo(
        id: 1,
        tipo: 'Siembra',
        cultivo: 'Soja',
        fechaInicio: ahora.subtract(const Duration(days: 5)),
        fechaFin: ahora.subtract(const Duration(days: 3)),
        estado: 'Completado',
        idCampo: 1,
        idPersonal: [1, 2],
        idMaquinas: [1, 2],
        cobrado: true,
        montoCobrado: 150000.0,
        observaciones: 'Siembra directa de soja en campo norte',
        cliente: 'Juan Pérez',
        esTercero: true,
      ),
      Trabajo(
        id: 2,
        tipo: 'Fumigación',
        cultivo: 'Maíz',
        fechaInicio: ahora.subtract(const Duration(days: 2)),
        fechaFin: ahora.subtract(const Duration(days: 1)),
        estado: 'En Ejecución',
        idCampo: 2,
        idPersonal: [3],
        idMaquinas: [3],
        cobrado: false,
        montoCobrado: 85000.0,
        observaciones: 'Aplicación de herbicida pre-emergente',
        cliente: null, // Trabajo propio
        esTercero: false,
      ),
      Trabajo(
        id: 3,
        tipo: 'Cosecha',
        cultivo: 'Trigo',
        fechaInicio: ahora.add(const Duration(days: 3)),
        fechaFin: ahora.add(const Duration(days: 7)),
        estado: 'Pendiente',
        idCampo: 3,
        idPersonal: [4, 5, 6],
        idMaquinas: [4, 5],
        cobrado: false,
        montoCobrado: 200000.0,
        observaciones: 'Cosecha mecanizada de trigo',
        cliente: 'Agro Norte S.A.',
        esTercero: true,
      ),
      Trabajo(
        id: 4,
        tipo: 'Preparación',
        cultivo: 'Girasol',
        fechaInicio: ahora.add(const Duration(days: 10)),
        fechaFin: ahora.add(const Duration(days: 12)),
        estado: 'Pendiente',
        idCampo: 1,
        idPersonal: [1],
        idMaquinas: [6, 7],
        cobrado: false,
        montoCobrado: 120000.0,
        observaciones: 'Labranza y preparación para girasol',
        cliente: null, // Trabajo propio
        esTercero: false,
      ),
      Trabajo(
        id: 5,
        tipo: 'Fumigación',
        cultivo: 'Soja',
        fechaInicio: ahora.add(const Duration(days: 5)),
        fechaFin: ahora.add(const Duration(days: 6)),
        estado: 'Pendiente',
        idCampo: 2,
        idPersonal: [2],
        idMaquinas: [3],
        cobrado: false,
        montoCobrado: 75000.0,
        observaciones: 'Aplicación de herbicida post-emergente',
        cliente: 'Campo Sur S.A.',
        esTercero: true,
      ),
      Trabajo(
        id: 6,
        tipo: 'Siembra',
        cultivo: 'Maíz',
        fechaInicio: ahora.add(const Duration(days: 15)),
        fechaFin: ahora.add(const Duration(days: 17)),
        estado: 'Pendiente',
        idCampo: 1,
        idPersonal: [1, 3],
        idMaquinas: [1, 2],
        cobrado: false,
        montoCobrado: 180000.0,
        observaciones: 'Siembra directa de maíz tardío',
        cliente: null, // Trabajo propio
        esTercero: false,
      ),
      Trabajo(
        id: 7,
        tipo: 'Fertilización',
        cultivo: 'Trigo',
        fechaInicio: ahora.add(const Duration(days: 8)),
        fechaFin: ahora.add(const Duration(days: 9)),
        estado: 'Pendiente',
        idCampo: 3,
        idPersonal: [4],
        idMaquinas: [3],
        cobrado: false,
        montoCobrado: 95000.0,
        observaciones: 'Aplicación de fertilizante nitrogenado',
        cliente: 'Agro Norte S.A.',
        esTercero: true,
      ),
    ];
  }

  List<Maquina> _getMaquinasPrueba() {
    return [
      Maquina(
        id: 1,
        nombre: 'Tractor John Deere',
        marca: 'John Deere',
        modelo: '6120R',
        ano: 2020,
      ),
      Maquina(
        id: 2,
        nombre: 'Sembradora',
        marca: 'Kinze',
        modelo: '3600',
        ano: 2019,
      ),
      Maquina(
        id: 3,
        nombre: 'Pulverizadora',
        marca: 'Jacto',
        modelo: 'Uniport 3030',
        ano: 2021,
      ),
      Maquina(
        id: 4,
        nombre: 'Cosechadora Claas',
        marca: 'Claas',
        modelo: 'Lexion 780',
        ano: 2018,
      ),
    ];
  }

  List<Personal> _getPersonalPrueba() {
    return [
      Personal(
        id: 1,
        nombre: 'Carlos López',
        dni: '12345678',
        telefono: '011-1234-5678',
      ),
      Personal(
        id: 2,
        nombre: 'María García',
        dni: '87654321',
        telefono: '011-8765-4321',
      ),
      Personal(
        id: 3,
        nombre: 'Roberto Silva',
        dni: '11223344',
        telefono: '011-1122-3344',
      ),
      Personal(
        id: 4,
        nombre: 'Pedro Martínez',
        dni: '55667788',
        telefono: '011-5566-7788',
      ),
    ];
  }
}