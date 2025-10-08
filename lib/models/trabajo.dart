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
  final String? estado;
  final String? observaciones;
  final bool esTercero;
  final bool cobrado;
  final double? montoCobrado;
  final String? cliente;

  Trabajo({
    this.id,
    required this.tipo,
    required this.cultivo,
    required this.fechaInicio,
    this.fechaFin,
    required this.idPersonal,
    required this.idMaquinas,
    required this.idCampo,
    this.estado,
    this.observaciones,
    this.esTercero = false,
    this.cobrado = false,
    this.montoCobrado,
    this.cliente,
  });

  factory Trabajo.fromJson(Map<String, dynamic> json) {
    return Trabajo(
      id: json['id'],
      tipo: json['tipo'] ?? '',
      cultivo: json['cultivo'] ?? '',
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: json['fecha_fin'] != null ? DateTime.parse(json['fecha_fin']) : null,
      idPersonal: json['id_personal'] != null 
          ? (json['id_personal'] is List 
              ? List<int>.from(json['id_personal'])
              : [json['id_personal'] as int])
          : [],
      idMaquinas: json['id_maquinas'] != null 
          ? (json['id_maquinas'] is List 
              ? List<int>.from(json['id_maquinas'])
              : [json['id_maquina'] as int])
          : [],
      idCampo: json['id_campo'] ?? 0,
      estado: json['estado'],
      observaciones: json['observaciones'],
      esTercero: (json['a_terceros'] ?? json['es_tercero'] ?? json['esTercero'] ?? false) == true
          || (json['a_terceros'] == 1)
          || (json['es_tercero'] == 1),
      cobrado: (json['cobrado'] ?? false) == true || (json['cobrado'] == 1),
      montoCobrado: json['monto_cobrado'] != null
          ? (json['monto_cobrado'] as num).toDouble()
          : (json['montoCobrado'] != null ? (json['montoCobrado'] as num).toDouble() : null),
      cliente: json['cliente'],
    );
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
      'id_campo': idCampo,
      'estado': estado,
      'observaciones': observaciones,
      'a_terceros': esTercero,
      'cobrado': cobrado,
      'monto_cobrado': montoCobrado,
      'cliente': cliente,
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
