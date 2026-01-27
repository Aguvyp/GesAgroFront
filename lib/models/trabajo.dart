import 'package:intl/intl.dart';

class Trabajo {
  final int? id;
  final int?
      idTipoTrabajo; // ID del tipo de trabajo (puede ser null si solo viene el nombre)
  final String? tipoTrabajoNombre; // Nombre del tipo de trabajo para mostrar
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
    this.servicioContratado = false,
  });

  factory Trabajo.fromJson(Map<String, dynamic> json) {
    // Manejar id_tipo_trabajo: puede venir como int directamente, o necesitamos parsearlo
    // NOTA: El backend puede no enviar id_tipo_trabajo en las respuestas, solo el nombre en "tipo"
    int? idTipoTrabajo;
    if (json['id_tipo_trabajo'] != null) {
      idTipoTrabajo = json['id_tipo_trabajo'] is int
          ? json['id_tipo_trabajo']
          : int.tryParse(json['id_tipo_trabajo'].toString());
    }

    // Obtener el nombre del tipo de trabajo
    // El backend devuelve el nombre en el campo "tipo" en las respuestas
    String? tipoTrabajoNombre;
    if (json['tipo'] != null) {
      // El backend devuelve el nombre del tipo en el campo "tipo"
      tipoTrabajoNombre = json['tipo'].toString();
    } else if (json['tipo_trabajo_nombre'] != null) {
      tipoTrabajoNombre = json['tipo_trabajo_nombre'].toString();
    } else if (json['tipo_trabajo'] != null && json['tipo_trabajo'] is Map) {
      tipoTrabajoNombre = json['tipo_trabajo']?['trabajo']?.toString();
    }

    // Parse ID Campo
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

    // Parse Campo Nombre
    String? campoNombre = json['campo_nombre'];
    if (campoNombre == null && json['campo'] != null && json['campo'] is Map) {
      campoNombre = json['campo']['nombre'];
    }

    // Parse Estado to ensure consistency
    String? estado = json['estado'];

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
      estado: estado,
      observaciones: json['observaciones'],
      esTercero: _parseBoolean(json['a_terceros']),
      cobrado: (json['cobrado'] ?? false) == true || (json['cobrado'] == 1),
      montoCobrado:
          _toDoubleSafe(json['monto_cobrado'] ?? json['montoCobrado']),
      cliente: json['cliente'],
      servicioContratado: _parseBoolean(json['servicio_contratado']),
    );
  }

  // Función helper para convertir a double de forma segura
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
    try {
      final stringValue = value.toString().trim();
      if (stringValue.isEmpty) return null;
      final cleaned = stringValue.replaceAll(',', '.');
      return double.tryParse(cleaned);
    } catch (e) {
      return null;
    }
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
      'id_tipo_trabajo': idTipoTrabajo, // Solo se envía al crear/actualizar
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

  // Getter para obtener el nombre del tipo de trabajo (compatibilidad)
  String get tipo => tipoTrabajoNombre ?? 'Sin tipo';

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
    return 'Trabajo(id: $id, idTipoTrabajo: $idTipoTrabajo, tipoTrabajoNombre: $tipoTrabajoNombre, cultivo: $cultivo, fechaInicio: $fechaInicio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Trabajo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
