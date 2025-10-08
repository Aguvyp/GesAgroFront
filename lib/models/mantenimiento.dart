class Mantenimiento {
  final int id;
  final int maquinaId;
  final String tipo; // 'Preventivo', 'Correctivo', 'Predictivo'
  final String descripcion;
  final DateTime fechaProgramada;
  final DateTime? fechaRealizada;
  final DateTime? fechaRealizacion; // Alias para fechaRealizada
  final String estado; // 'Programado', 'En Proceso', 'Completado', 'Cancelado'
  final double? costo;
  final String? proveedor;
  final String? tecnico;
  final String? observaciones;
  final List<String>? partesReemplazadas;

  Mantenimiento({
    required this.id,
    required this.maquinaId,
    required this.tipo,
    required this.descripcion,
    required this.fechaProgramada,
    this.fechaRealizada,
    this.fechaRealizacion,
    this.estado = 'Programado',
    this.costo,
    this.proveedor,
    this.tecnico,
    this.observaciones,
    this.partesReemplazadas,
  });

  factory Mantenimiento.fromJson(Map<String, dynamic> json) {
    return Mantenimiento(
      id: json['id'],
      maquinaId: json['maquina_id'],
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      fechaProgramada: DateTime.parse(json['fecha_programada']),
      fechaRealizada: json['fecha_realizada'] != null 
          ? DateTime.parse(json['fecha_realizada']) 
          : null,
      fechaRealizacion: json['fecha_realizacion'] != null 
          ? DateTime.parse(json['fecha_realizacion']) 
          : null,
      estado: json['estado'],
      costo: json['costo']?.toDouble(),
      proveedor: json['proveedor'],
      tecnico: json['tecnico'],
      observaciones: json['observaciones'],
      partesReemplazadas: json['partes_reemplazadas'] != null 
          ? List<String>.from(json['partes_reemplazadas']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maquina_id': maquinaId,
      'tipo': tipo,
      'descripcion': descripcion,
      'fecha_programada': fechaProgramada.toIso8601String(),
      'fecha_realizada': fechaRealizada?.toIso8601String(),
      'fecha_realizacion': fechaRealizacion?.toIso8601String(),
      'estado': estado,
      'costo': costo,
      'proveedor': proveedor,
      'tecnico': tecnico,
      'observaciones': observaciones,
      'partes_reemplazadas': partesReemplazadas,
    };
  }

  bool get estaProgramado => estado == 'Programado';
  bool get estaEnProceso => estado == 'En Proceso';
  bool get estaCompletado => estado == 'Completado';
  bool get estaCancelado => estado == 'Cancelado';
  bool get estaVencido => DateTime.now().isAfter(fechaProgramada) && estado == 'Programado';
  bool get esPreventivo => tipo == 'Preventivo';
  bool get esCorrectivo => tipo == 'Correctivo';
  bool get esPredictivo => tipo == 'Predictivo';

  Mantenimiento copyWith({
    int? id,
    int? maquinaId,
    String? tipo,
    String? descripcion,
    DateTime? fechaProgramada,
    DateTime? fechaRealizada,
    DateTime? fechaRealizacion,
    String? estado,
    double? costo,
    String? proveedor,
    String? tecnico,
    String? observaciones,
    List<String>? partesReemplazadas,
  }) {
    return Mantenimiento(
      id: id ?? this.id,
      maquinaId: maquinaId ?? this.maquinaId,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      fechaProgramada: fechaProgramada ?? this.fechaProgramada,
      fechaRealizada: fechaRealizada ?? this.fechaRealizada,
      fechaRealizacion: fechaRealizacion ?? this.fechaRealizacion,
      estado: estado ?? this.estado,
      costo: costo ?? this.costo,
      proveedor: proveedor ?? this.proveedor,
      tecnico: tecnico ?? this.tecnico,
      observaciones: observaciones ?? this.observaciones,
      partesReemplazadas: partesReemplazadas ?? this.partesReemplazadas,
    );
  }
}
