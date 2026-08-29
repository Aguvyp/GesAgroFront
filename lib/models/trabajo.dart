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
  final int? loteId;
  final String? campoNombre;
  final double? campoHa;
  final String? loteNombre;
  final double? loteHa;
  final Map<String, dynamic>? lotePolygonGeoJson;
  final double? lotePuntoAccesoLatitud;
  final double? lotePuntoAccesoLongitud;
  final double? lotePuntoEntradaLatitud;
  final double? lotePuntoEntradaLongitud;
  final String? loteNotasAcceso;
  final String? estado;
  final String? observaciones;
  final String? indicaciones;
  final String? estadoIndicaciones;
  final DateTime? indicacionesEnviadasAt;
  final List<String> indicacionesEnviadasA;
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
    this.loteId,
    this.campoNombre,
    this.campoHa,
    this.loteNombre,
    this.loteHa,
    this.lotePolygonGeoJson,
    this.lotePuntoAccesoLatitud,
    this.lotePuntoAccesoLongitud,
    this.lotePuntoEntradaLatitud,
    this.lotePuntoEntradaLongitud,
    this.loteNotasAcceso,
    this.estado,
    this.observaciones,
    this.indicaciones,
    this.estadoIndicaciones,
    this.indicacionesEnviadasAt,
    this.indicacionesEnviadasA = const [],
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

    int? loteId;
    if (json['lote'] != null) {
      loteId = json['lote'] is int
          ? json['lote']
          : int.tryParse(json['lote'].toString());
    } else if (json['lote_id'] != null) {
      loteId = json['lote_id'] is int
          ? json['lote_id']
          : int.tryParse(json['lote_id'].toString());
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
      idPersonal: (json['id_personal'] ?? json['personal']) != null
          ? ((json['id_personal'] ?? json['personal']) is List
              ? List<int>.from(json['id_personal'] ?? json['personal'])
              : [
                  (json['id_personal'] ?? json['personal']) is int
                      ? (json['id_personal'] ?? json['personal'])
                      : int.tryParse((json['id_personal'] ?? json['personal'])
                              .toString()) ??
                          0
                ])
          : [],
      idMaquinas: (json['id_maquinas'] ?? json['maquinas']) != null
          ? ((json['id_maquinas'] ?? json['maquinas']) is List
              ? List<int>.from(json['id_maquinas'] ?? json['maquinas'])
              : [
                  (json['id_maquinas'] ?? json['maquinas']) is int
                      ? (json['id_maquinas'] ?? json['maquinas'])
                      : int.tryParse((json['id_maquinas'] ?? json['maquinas'])
                              .toString()) ??
                          0
                ])
          : [],
      idCampo: idCampo,
      loteId: loteId,
      campoNombre: campoNombre,
      campoHa: _toDoubleSafe(json['campo_ha']),
      loteNombre: json['lote_nombre']?.toString(),
      loteHa: _toDoubleSafe(json['lote_ha']),
      lotePolygonGeoJson: json['lote_polygon_geojson'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['lote_polygon_geojson'])
          : null,
      lotePuntoAccesoLatitud: _toDoubleSafe(json['lote_punto_acceso_latitud']),
      lotePuntoAccesoLongitud:
          _toDoubleSafe(json['lote_punto_acceso_longitud']),
      lotePuntoEntradaLatitud:
          _toDoubleSafe(json['lote_punto_entrada_latitud']),
      lotePuntoEntradaLongitud:
          _toDoubleSafe(json['lote_punto_entrada_longitud']),
      loteNotasAcceso: json['lote_notas_acceso']?.toString(),
      estado: json['estado'],
      observaciones: json['observaciones'],
      indicaciones: json['indicaciones']?.toString(),
      estadoIndicaciones: json['estado_indicaciones']?.toString(),
      indicacionesEnviadasAt: json['indicaciones_enviadas_at'] != null
          ? DateTime.tryParse(json['indicaciones_enviadas_at'].toString())
          : null,
      indicacionesEnviadasA: json['indicaciones_enviadas_a'] is List
          ? (json['indicaciones_enviadas_a'] as List)
              .map((value) => value.toString())
              .toList()
          : const [],
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
      'campo': idCampo,
      'lote': loteId,
      'campo_nombre': campoNombre,
      'campo_ha': campoHa,
      'lote_nombre': loteNombre,
      'lote_ha': loteHa,
      'lote_polygon_geojson': lotePolygonGeoJson,
      'lote_punto_acceso_latitud': lotePuntoAccesoLatitud,
      'lote_punto_acceso_longitud': lotePuntoAccesoLongitud,
      'lote_punto_entrada_latitud': lotePuntoEntradaLatitud,
      'lote_punto_entrada_longitud': lotePuntoEntradaLongitud,
      'lote_notas_acceso': loteNotasAcceso,
      'estado': estado,
      'observaciones': observaciones,
      'indicaciones': indicaciones,
      'estado_indicaciones': estadoIndicaciones,
      'indicaciones_enviadas_at': indicacionesEnviadasAt?.toIso8601String(),
      'indicaciones_enviadas_a': indicacionesEnviadasA,
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
    int? loteId,
    String? campoNombre,
    double? campoHa,
    String? loteNombre,
    double? loteHa,
    Map<String, dynamic>? lotePolygonGeoJson,
    double? lotePuntoAccesoLatitud,
    double? lotePuntoAccesoLongitud,
    double? lotePuntoEntradaLatitud,
    double? lotePuntoEntradaLongitud,
    String? loteNotasAcceso,
    String? estado,
    String? observaciones,
    String? indicaciones,
    String? estadoIndicaciones,
    DateTime? indicacionesEnviadasAt,
    List<String>? indicacionesEnviadasA,
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
      loteId: loteId ?? this.loteId,
      campoNombre: campoNombre ?? this.campoNombre,
      campoHa: campoHa ?? this.campoHa,
      loteNombre: loteNombre ?? this.loteNombre,
      loteHa: loteHa ?? this.loteHa,
      lotePolygonGeoJson: lotePolygonGeoJson ?? this.lotePolygonGeoJson,
      lotePuntoAccesoLatitud:
          lotePuntoAccesoLatitud ?? this.lotePuntoAccesoLatitud,
      lotePuntoAccesoLongitud:
          lotePuntoAccesoLongitud ?? this.lotePuntoAccesoLongitud,
      lotePuntoEntradaLatitud:
          lotePuntoEntradaLatitud ?? this.lotePuntoEntradaLatitud,
      lotePuntoEntradaLongitud:
          lotePuntoEntradaLongitud ?? this.lotePuntoEntradaLongitud,
      loteNotasAcceso: loteNotasAcceso ?? this.loteNotasAcceso,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      indicaciones: indicaciones ?? this.indicaciones,
      estadoIndicaciones: estadoIndicaciones ?? this.estadoIndicaciones,
      indicacionesEnviadasAt:
          indicacionesEnviadasAt ?? this.indicacionesEnviadasAt,
      indicacionesEnviadasA:
          indicacionesEnviadasA ?? this.indicacionesEnviadasA,
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

  String get loteInfo {
    if (loteNombre != null && loteNombre!.isNotEmpty) {
      if (loteHa != null && loteHa! > 0) {
        return '$loteNombre - ${loteHa!.toStringAsFixed(1)} ha';
      }
      return loteNombre!;
    }
    return 'Sin lote asignado';
  }

  bool get tieneLote => loteId != null || loteNombre != null;
  bool get tieneContornoLote => lotePolygonGeoJson != null;
  bool get tienePuntoEntrada =>
      lotePuntoEntradaLatitud != null && lotePuntoEntradaLongitud != null;
  bool get indicacionesEnviadas =>
      (estadoIndicaciones ?? '').toLowerCase().contains('enviad');
}
