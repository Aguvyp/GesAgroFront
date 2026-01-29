import 'package:intl/intl.dart';

class Trabajo {
  final int? id;
  final int?
      idTipoTrabajo; // ID del tipo de trabajo (puede ser null si solo viene el nombre)
  final String? tipoTrabajoNombre; // Nombre del tipo de trabajo para mostrar
  final String cultivo;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final List<int> idPersonal;
  final List<int> idMaquinas;
  final int idCampo;
  final String? campoNombre;
  final double? campoHa;
  final String? estado;
  final String? observaciones;
  final bool esTercero;
  final bool cobrado;
  final double? montoCobrado;
  final String? cliente;
  final double? haRealizadas; // Hectáreas realizadas hasta el momento
  final double? porcentajeProgreso; // Porcentaje de progreso (0-100)
  final bool servicioContratado;

  Trabajo({
    this.id,
    this.idTipoTrabajo,
    this.tipoTrabajoNombre,
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
    this.haRealizadas,
    this.porcentajeProgreso,
    this.servicioContratado = false,
  });

  factory Trabajo.fromJson(Map<String, dynamic> json) {
    int? idTipoTrabajo;
    if (json['id_tipo_trabajo'] != null) {
      idTipoTrabajo = json['id_tipo_trabajo'] is int
          ? json['id_tipo_trabajo']
          : int.tryParse(json['id_tipo_trabajo'].toString());
    }

    String? tipoTrabajoNombre;
    if (json['tipo'] != null) {
      tipoTrabajoNombre = json['tipo'].toString();
    } else if (json['tipo_trabajo_nombre'] != null) {
      tipoTrabajoNombre = json['tipo_trabajo_nombre'].toString();
    } else if (json['tipo_trabajo'] != null && json['tipo_trabajo'] is Map) {
      tipoTrabajoNombre = json['tipo_trabajo']?['trabajo']?.toString();
    }

    int idCampo = 0;
    if (json['id_campo'] != null) {
      idCampo = json['id_campo'] is int
          ? json['id_campo']
          : int.tryParse(json['id_campo'].toString()) ?? 0;
    } else if (json['campo_id'] != null) {
      idCampo = json['campo_id'] is int
          ? json['campo_id']
          : int.tryParse(json['campo_id'].toString()) ?? 0;
    } else if (json['campo'] != null && json['campo'] is Map) {
      idCampo = json['campo']['id'] ?? 0;
    } else if (json['campo'] != null && json['campo'] is int) {
      idCampo = json['campo'];
    }

    String? campoNombre = json['campo_nombre'];
    if (campoNombre == null && json['campo'] != null && json['campo'] is Map) {
      campoNombre = json['campo']['nombre'];
    }

    return Trabajo(
      id: json['id'],
      idTipoTrabajo: idTipoTrabajo,
      tipoTrabajoNombre: tipoTrabajoNombre,
      cultivo: json['cultivo'] ?? '',
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'])
          : DateTime.now(),
      fechaFin:
          json['fecha_fin'] != null ? DateTime.parse(json['fecha_fin']) : null,
      idPersonal: json['id_personal'] != null
          ? (json['id_personal'] is List
              ? List<int>.from(json['id_personal'])
              : [
                  json['id_personal'] is int
                      ? json['id_personal']
                      : int.tryParse(json['id_personal'].toString()) ?? 0
                ])
          : [],
      idMaquinas: json['id_maquinas'] != null
          ? (json['id_maquinas'] is List
              ? List<int>.from(json['id_maquinas'])
              : [
                  json['id_maquinas'] is int
                      ? json['id_maquinas']
                      : int.tryParse(json['id_maquinas'].toString()) ?? 0
                ])
          : [],
      idCampo: idCampo,
      campoNombre: campoNombre,
      campoHa: _toDoubleSafe(json['campo_ha']),
      estado: json['estado'],
      observaciones: json['observaciones'],
      esTercero: _parseBoolean(json['a_terceros']),
      cobrado: (json['cobrado'] ?? false) == true || (json['cobrado'] == 1),
      montoCobrado:
          _toDoubleSafe(json['monto_cobrado'] ?? json['montoCobrado']),
      cliente: json['cliente'],
      haRealizadas: _toDoubleSafe(json['ha_realizadas']),
      porcentajeProgreso: _toDoubleSafe(json['porcentaje_progreso']),
      servicioContratado: _parseBoolean(json['servicio_contratado']),
    );
  }

  static double? _toDoubleSafe(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      if (value.isEmpty || value.trim().isEmpty) return null;
      final cleaned = value.trim().replaceAll(',', '.');
      return double.tryParse(cleaned);
    }
    return null;
  }

  static bool _parseBoolean(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_tipo_trabajo': idTipoTrabajo,
      'cultivo': cultivo,
      'fecha_inicio': DateFormat('yyyy-MM-dd').format(fechaInicio),
      'fecha_fin':
          fechaFin != null ? DateFormat('yyyy-MM-dd').format(fechaFin!) : null,
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
      'ha_realizadas': haRealizadas,
      'porcentaje_progreso': porcentajeProgreso,
      'servicio_contratado': servicioContratado,
    };
  }

  Trabajo copyWith({
    int? id,
    int? idTipoTrabajo,
    String? tipoTrabajoNombre,
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
    double? haRealizadas,
    double? porcentajeProgreso,
    bool? servicioContratado,
  }) {
    return Trabajo(
      id: id ?? this.id,
      idTipoTrabajo: idTipoTrabajo ?? this.idTipoTrabajo,
      tipoTrabajoNombre: tipoTrabajoNombre ?? this.tipoTrabajoNombre,
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
      haRealizadas: haRealizadas ?? this.haRealizadas,
      porcentajeProgreso: porcentajeProgreso ?? this.porcentajeProgreso,
      servicioContratado: servicioContratado ?? this.servicioContratado,
    );
  }

  bool get isCompleted => estado == 'Completado';
  bool get isInProgress => estado == 'En curso';
  bool get isPending => estado == 'Pendiente' || estado == null;

  String get tipo => tipoTrabajoNombre ?? 'Sin tipo';

  String get campoInfo {
    if (campoNombre != null && campoHa != null) {
      return '$campoNombre - ${campoHa!.toStringAsFixed(1)} ha';
    } else if (campoNombre != null) {
      return campoNombre!;
    } else {
      return 'Campo $idCampo';
    }
  }
}
