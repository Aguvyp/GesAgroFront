import 'package:intl/intl.dart';
import 'campo.dart';

/// Modelo para mostrar los detalles completos de un trabajo
/// Incluye información del campo, cliente, operarios con sus hectáreas y máquinas
class TrabajoDetalle {
  final int? id;
  final String tipo;
  final String cliente;
  final String cultivo;
  final String? observaciones;
  final String? estado;
  final bool aTerceros;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final int campoId;
  final double? haRealizadas;
  final double? porcentajeProgreso;

  // Información del campo
  final Campo? campo;

  // Información del cliente
  final ClienteInfo? clienteInfo;

  // Máquinas utilizadas
  final List<MaquinaTrabajo> maquinas;

  // Personal con sus hectáreas trabajadas
  final List<PersonalTrabajo> personal;

  // Información de cobro
  final bool cobrado;
  final double? montoCobrado;

  TrabajoDetalle({
    this.id,
    required this.tipo,
    required this.cliente,
    required this.cultivo,
    this.observaciones,
    this.estado,
    this.aTerceros = false,
    required this.fechaInicio,
    this.fechaFin,
    required this.campoId,
    this.campo,
    this.clienteInfo,
    this.maquinas = const [],
    this.personal = const [],
    this.cobrado = false,
    this.montoCobrado,
    this.haRealizadas,
    this.porcentajeProgreso,
  });

  factory TrabajoDetalle.fromJson(Map<String, dynamic> json) {
    return TrabajoDetalle(
      id: json['id'],
      tipo: json['tipo'] ?? '',
      cliente: json['cliente'] ?? '',
      cultivo: json['cultivo'] ?? '',
      observaciones: json['observaciones'],
      estado: json['estado'],
      aTerceros: _parseBoolean(json['a_terceros']),
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'])
          : DateTime.now(),
      fechaFin:
          json['fecha_fin'] != null ? DateTime.parse(json['fecha_fin']) : null,
      campoId: json['campo_id'] ?? 0,

      // Campo completo
      campo: json['campo'] is Map<String, dynamic>
          ? Campo.fromJson(json['campo'])
          : null,

      // Información del cliente
      clienteInfo: json['cliente_info'] is Map<String, dynamic>
          ? ClienteInfo.fromJson(json['cliente_info'])
          : null,

      // Máquinas
      // Máquinas
      maquinas: json['maquinas'] != null
          ? (json['maquinas'] as List)
              .where((item) => item is Map<String, dynamic>)
              .map((maq) => MaquinaTrabajo.fromJson(maq))
              .toList()
          : [],

      // Personal con hectáreas
      personal: json['personal'] != null
          ? (json['personal'] as List)
              .where((item) => item is Map<String, dynamic>)
              .map((per) => PersonalTrabajo.fromJson(per))
              .toList()
          : [],

      // Información de cobro
      cobrado: (json['cobrado'] ?? false) == true || (json['cobrado'] == 1),
      montoCobrado: () {
        final val = json['monto_cobrado'];
        if (val == null) return null;
        if (val is num) return val.toDouble();
        if (val is String) return double.tryParse(val);
        return null;
      }(),
      haRealizadas: _toDoubleSafe(json['ha_realizadas']),
      porcentajeProgreso: _toDoubleSafe(json['porcentaje_progreso']),
    );
  }

  static double? _toDoubleSafe(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool _parseBoolean(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'cliente': cliente,
      'cultivo': cultivo,
      'observaciones': observaciones,
      'estado': estado,
      'a_terceros': aTerceros,
      'fecha_inicio': DateFormat('yyyy-MM-dd').format(fechaInicio),
      'fecha_fin':
          fechaFin != null ? DateFormat('yyyy-MM-dd').format(fechaFin!) : null,
      'campo_id': campoId,
      'campo': campo?.toJson(),
      'cliente_info': clienteInfo?.toJson(),
      'maquinas': maquinas.map((maq) => maq.toJson()).toList(),
      'personal': personal.map((per) => per.toJson()).toList(),
      'cobrado': cobrado,
      'monto_cobrado': montoCobrado,
      'ha_realizadas': haRealizadas,
      'porcentaje_progreso': porcentajeProgreso,
    };
  }

  // Getters útiles
  bool get isCompleted => estado == 'Completado';
  bool get isInProgress => estado == 'En curso';
  bool get isPending => estado == 'Pendiente' || estado == null;
  bool get esTrabajoDeTercero => aTerceros;
  bool get estaCobrado => cobrado;

  int get durationDays {
    if (fechaFin == null) return 0;
    return fechaFin!.difference(fechaInicio).inDays + 1;
  }

  String get formattedDateRange {
    final start = DateFormat('dd/MM/yyyy').format(fechaInicio);
    if (fechaFin == null) {
      return 'Desde $start';
    }
    final end = DateFormat('dd/MM/yyyy').format(fechaFin!);
    return '$start - $end';
  }

  // Información del campo
  String get campoNombre => campo?.nombre ?? 'Campo no especificado';
  double get campoHectareas => campo?.superficieHa ?? 0.0;
  String get campoInfo =>
      '${campoNombre} - ${campoHectareas.toStringAsFixed(1)} ha';

  // Información del cliente
  String get clienteNombre => clienteInfo?.nombreRazonSocial ?? cliente;
  String get clienteInfoCompleta {
    if (clienteInfo != null) {
      return '${clienteInfo!.nombreRazonSocial} (${clienteInfo!.cuit})';
    }
    return cliente;
  }

  // Información de personal
  int get totalPersonal => personal.length;
  double get totalHectareasPersonal =>
      personal.fold(0.0, (sum, per) => sum + per.ha);
  String get personalInfo {
    if (personal.isEmpty) return 'Sin personal asignado';
    return '${personal.length} operario${personal.length > 1 ? 's' : ''} - ${totalHectareasPersonal.toStringAsFixed(1)} ha';
  }

  // Información de máquinas
  int get totalMaquinas => maquinas.length;
  String get maquinasInfo {
    if (maquinas.isEmpty) return 'Sin máquinas asignadas';
    return '${maquinas.length} máquina${maquinas.length > 1 ? 's' : ''}';
  }

  // Información del trabajo
  String get trabajoInfo {
    if (aTerceros && clienteInfo != null) {
      return 'Trabajo a terceros - ${clienteInfo!.nombreRazonSocial}';
    }
    return aTerceros ? 'Trabajo a terceros' : 'Trabajo propio';
  }

  @override
  String toString() {
    return 'TrabajoDetalle(id: $id, tipo: $tipo, cultivo: $cultivo, campo: ${campoNombre})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrabajoDetalle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Modelo para información completa del cliente
class ClienteInfo {
  final int id;
  final String nombreRazonSocial;
  final String cuit;
  final String direccion;
  final String telefono;
  final String email;

  ClienteInfo({
    required this.id,
    required this.nombreRazonSocial,
    required this.cuit,
    required this.direccion,
    required this.telefono,
    required this.email,
  });

  factory ClienteInfo.fromJson(Map<String, dynamic> json) {
    return ClienteInfo(
      id: json['id'],
      nombreRazonSocial: json['nombre_razon_social'] ?? '',
      cuit: json['cuit'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_razon_social': nombreRazonSocial,
      'cuit': cuit,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
    };
  }

  ClienteInfo copyWith({
    int? id,
    String? nombreRazonSocial,
    String? cuit,
    String? direccion,
    String? telefono,
    String? email,
  }) {
    return ClienteInfo(
      id: id ?? this.id,
      nombreRazonSocial: nombreRazonSocial ?? this.nombreRazonSocial,
      cuit: cuit ?? this.cuit,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
    );
  }

  @override
  String toString() {
    return 'ClienteInfo(id: $id, nombre: $nombreRazonSocial, cuit: $cuit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClienteInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Modelo para máquinas utilizadas en un trabajo específico
class MaquinaTrabajo {
  final int id;
  final String nombre;
  final String marca;
  final String modelo;

  MaquinaTrabajo({
    required this.id,
    required this.nombre,
    required this.marca,
    required this.modelo,
  });

  factory MaquinaTrabajo.fromJson(Map<String, dynamic> json) {
    return MaquinaTrabajo(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'marca': marca,
      'modelo': modelo,
    };
  }

  MaquinaTrabajo copyWith({
    int? id,
    String? nombre,
    String? marca,
    String? modelo,
  }) {
    return MaquinaTrabajo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
    );
  }

  @override
  String toString() {
    return 'MaquinaTrabajo(id: $id, nombre: $nombre, marca: $marca, modelo: $modelo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaquinaTrabajo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Modelo para personal con sus hectáreas trabajadas en un trabajo específico
class PersonalTrabajo {
  final int id;
  final int? idTrabajoPersonal; // ID de la relación TrabajoPersonal
  final int? idPersonal; // ID del operario (Personal)
  final String nombre;
  final String dni;
  final String? rol;
  final double ha; // Hectáreas trabajadas en este trabajo específico
  final double horas; // Horas trabajadas

  PersonalTrabajo({
    required this.id,
    this.idTrabajoPersonal,
    this.idPersonal,
    required this.nombre,
    required this.dni,
    this.rol,
    required this.ha,
    required this.horas,
  });

  factory PersonalTrabajo.fromJson(Map<String, dynamic> json) {
    return PersonalTrabajo(
      id: json['id'],
      idTrabajoPersonal:
          json['id_trabajo_personal'] ?? json['trabajo_personal_id'],
      idPersonal: json['id_personal'] ?? json['personal_id'],
      nombre: json['nombre'] ?? '',
      dni: json['dni'] ?? '',
      rol: json['rol'],
      ha: () {
        final val = json['hectareas'] ?? json['ha'];
        if (val == null) return 0.0;
        if (val is num) return val.toDouble();
        if (val is String) return double.tryParse(val) ?? 0.0;
        return 0.0;
      }(),
      horas: () {
        final val = json['horas_trabajadas'] ?? json['horas'];
        if (val == null) return 0.0;
        if (val is num) return val.toDouble();
        if (val is String) return double.tryParse(val) ?? 0.0;
        return 0.0;
      }(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_trabajo_personal': idTrabajoPersonal,
      'id_personal': idPersonal,
      'nombre': nombre,
      'dni': dni,
      'rol': rol,
      'ha': ha,
      'horas': horas,
    };
  }

  PersonalTrabajo copyWith({
    int? id,
    int? idTrabajoPersonal,
    int? idPersonal,
    String? nombre,
    String? dni,
    String? rol,
    double? ha,
    double? horas,
  }) {
    return PersonalTrabajo(
      id: id ?? this.id,
      idTrabajoPersonal: idTrabajoPersonal ?? this.idTrabajoPersonal,
      idPersonal: idPersonal ?? this.idPersonal,
      nombre: nombre ?? this.nombre,
      dni: dni ?? this.dni,
      rol: rol ?? this.rol,
      ha: ha ?? this.ha,
      horas: horas ?? this.horas,
    );
  }

  @override
  String toString() {
    return 'PersonalTrabajo(id: $id, idTrabajoPersonal: $idTrabajoPersonal, nombre: $nombre, ha: $ha, horas: $horas)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PersonalTrabajo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
