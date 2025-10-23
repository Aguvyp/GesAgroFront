import 'package:intl/intl.dart';

class Trabajo {
  final int? id;
  final String tipo;
  final String cultivo;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final List<int> idPersonal; // Cambiado a lista
  final List<int> idMaquinas; // Cambiado a lista
  final int idCampo;
  final String? campoNombre;
  final double? campoHa;
  final String? estado;
  final String? observaciones;
  final bool esTercero;
  final bool cobrado;
  final double? montoCobrado;
  final String? cliente;
  final bool servicioContratado;

  Trabajo({
    this.id,
    required this.tipo,
    required this.cultivo,
    required this.fechaInicio,
    this.fechaFin,
    required this.idPersonal,
    required this.idMaquinas,
    required this.idCampo,
    this.campoNombre,
    this.campoHa,
    this.estado,
    this.observaciones,
    this.esTercero = false,
    this.cobrado = false,
    this.montoCobrado,
    this.cliente,
    this.servicioContratado = false,
  });

  factory Trabajo.fromJson(Map<String, dynamic> json) {
    return Trabajo(
      id: json['id'],
      tipo: json['tipo'] ?? '',
      cultivo: json['cultivo'] ?? '',
      fechaInicio: json['fecha_inicio'] != null 
          ? DateTime.parse(json['fecha_inicio'])
          : DateTime.now(), // Valor por defecto si es null
      fechaFin: json['fecha_fin'] != null ? DateTime.parse(json['fecha_fin']) : null,
      idPersonal: json['id_personal'] != null 
          ? (json['id_personal'] is List 
              ? List<int>.from(json['id_personal'])
              : [json['id_personal'] as int])
          : [], // Si no hay id_personal, usar lista vacía
      idMaquinas: json['id_maquinas'] != null 
          ? (json['id_maquinas'] is List 
              ? List<int>.from(json['id_maquinas'])
              : [json['id_maquinas'] as int])
          : [],
      idCampo: json['campo_id'] ?? json['id_campo'] ?? 0,
      campoNombre: json['campo_nombre'],
      campoHa: json['campo_ha'] != null ? (json['campo_ha'] as num).toDouble() : null,
      estado: json['estado'],
      observaciones: json['observaciones'],
      esTercero: _parseBoolean(json['a_terceros']),
      cobrado: (json['cobrado'] ?? false) == true || (json['cobrado'] == 1),
      montoCobrado: json['monto_cobrado'] != null
          ? (json['monto_cobrado'] as num).toDouble()
          : (json['montoCobrado'] != null ? (json['montoCobrado'] as num).toDouble() : null),
      cliente: json['cliente'],
      servicioContratado: _parseBoolean(json['servicio_contratado']),
    );
  }

  // Helper method para parsear valores booleanos
  static bool _parseBoolean(dynamic value) {
    print('DEBUG: _parseBoolean recibió: $value (tipo: ${value.runtimeType})');
    if (value == null) {
      print('DEBUG: _parseBoolean retorna false (null)');
      return false;
    }
    if (value is bool) {
      print('DEBUG: _parseBoolean retorna $value (bool)');
      return value;
    }
    if (value is int) {
      bool result = value == 1;
      print('DEBUG: _parseBoolean retorna $result (int: $value)');
      return result;
    }
    if (value is String) {
      bool result = value.toLowerCase() == 'true';
      print('DEBUG: _parseBoolean retorna $result (string: $value)');
      return result;
    }
    print('DEBUG: _parseBoolean retorna false (tipo desconocido)');
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'cultivo': cultivo,
      'fecha_inicio': DateFormat('yyyy-MM-dd').format(fechaInicio),
      'fecha_fin': fechaFin != null ? DateFormat('yyyy-MM-dd').format(fechaFin!) : null,
      'id_personal': idPersonal,
      'id_maquinas': idMaquinas,
      'campo_id': idCampo,
      'campo_nombre': campoNombre,
      'campo_ha': campoHa,
      'estado': estado,
      'observaciones': observaciones,
      'a_terceros': esTercero,
      'cobrado': cobrado,
      'monto_cobrado': montoCobrado,
      'cliente': cliente,
      'servicio_contratado': servicioContratado,
    };
  }

  Trabajo copyWith({
    int? id,
    String? tipo,
    String? cultivo,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    List<int>? idPersonal,
    List<int>? idMaquinas,
    int? idCampo,
    String? estado,
    String? observaciones,
    bool? esTercero,
    bool? cobrado,
    double? montoCobrado,
    String? cliente,
    bool? servicioContratado,
  }) {
    return Trabajo(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      cultivo: cultivo ?? this.cultivo,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      idPersonal: idPersonal ?? this.idPersonal,
      idMaquinas: idMaquinas ?? this.idMaquinas,
      idCampo: idCampo ?? this.idCampo,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      esTercero: esTercero ?? this.esTercero,
      cobrado: cobrado ?? this.cobrado,
      montoCobrado: montoCobrado ?? this.montoCobrado,
      cliente: cliente ?? this.cliente,
      servicioContratado: servicioContratado ?? this.servicioContratado,
    );
  }

  bool get isCompleted => estado == 'Completado';
  bool get isInProgress => estado == 'En curso';
  bool get isPending => estado == 'Pendiente' || estado == null;

  bool get esTrabajoDeTercero => esTercero;
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
  String get campoInfo {
    if (campoNombre != null && campoHa != null) {
      return '$campoNombre - ${campoHa!.toStringAsFixed(1)} ha';
    } else if (campoNombre != null) {
      return campoNombre!;
    } else {
      return 'Campo $idCampo';
    }
  }

  @override
  String toString() {
    return 'Trabajo(id: $id, tipo: $tipo, cultivo: $cultivo, fechaInicio: $fechaInicio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Trabajo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
