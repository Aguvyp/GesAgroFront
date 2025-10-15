class CampoCliente {
  final int? id;
  final int idCampo;
  final int idCliente;
  final DateTime? fechaAsignacion;
  final String? observaciones;
  final bool activo;

  CampoCliente({
    this.id,
    required this.idCampo,
    required this.idCliente,
    this.fechaAsignacion,
    this.observaciones,
    this.activo = true,
  });

  factory CampoCliente.fromJson(Map<String, dynamic> json) {
    return CampoCliente(
      id: json['id'],
      idCampo: json['id_campo'] ?? json['campo_id'],
      idCliente: json['id_cliente'] ?? json['cliente_id'],
      fechaAsignacion: json['fecha_asignacion'] != null 
          ? DateTime.parse(json['fecha_asignacion'])
          : null,
      observaciones: json['observaciones'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_campo': idCampo,
      'id_cliente': idCliente,
      'fecha_asignacion': fechaAsignacion?.toIso8601String(),
      'observaciones': observaciones,
      'activo': activo,
    };
  }

  CampoCliente copyWith({
    int? id,
    int? idCampo,
    int? idCliente,
    DateTime? fechaAsignacion,
    String? observaciones,
    bool? activo,
  }) {
    return CampoCliente(
      id: id ?? this.id,
      idCampo: idCampo ?? this.idCampo,
      idCliente: idCliente ?? this.idCliente,
      fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
      observaciones: observaciones ?? this.observaciones,
      activo: activo ?? this.activo,
    );
  }

  @override
  String toString() {
    return 'CampoCliente(id: $id, idCampo: $idCampo, idCliente: $idCliente, activo: $activo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CampoCliente && 
           other.idCampo == idCampo && 
           other.idCliente == idCliente;
  }

  @override
  int get hashCode => Object.hash(idCampo, idCliente);
}
