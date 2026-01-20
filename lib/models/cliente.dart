class Cliente {
  final int? id;
  final String? nombre;
  final String? email;
  final String? telefono;
  final String? direccion;
  final String? cuit;
  final String? observaciones;
  final DateTime? fechaCreacion;
  final DateTime? fechaModificacion;
  final int? usuarioId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cliente({
    this.id,
    this.nombre,
    this.email,
    this.telefono,
    this.direccion,
    this.cuit,
    this.observaciones,
    this.fechaCreacion,
    this.fechaModificacion,
    this.usuarioId,
    this.createdAt,
    this.updatedAt,
  });

  /// Iniciales del nombre del cliente para el avatar
  String get initials {
    if (nombre == null || nombre!.isEmpty) return '?';
    final parts = nombre!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombre![0].toUpperCase();
  }

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as int?,
      nombre: json['nombre'] as String?,
      email: json['email'] as String?,
      telefono: json['telefono'] as String?,
      direccion: json['direccion'] as String?,
      cuit: json['cuit'] as String?,
      observaciones: json['observaciones'] as String?,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
      fechaModificacion: json['fecha_modificacion'] != null
          ? DateTime.parse(json['fecha_modificacion'] as String)
          : null,
      usuarioId: json['usuario_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (email != null) 'email': email,
      if (telefono != null) 'telefono': telefono,
      if (direccion != null) 'direccion': direccion,
      if (cuit != null) 'cuit': cuit,
      if (observaciones != null) 'observaciones': observaciones,
    };
  }

  Cliente copyWith({
    int? id,
    String? nombre,
    String? email,
    String? telefono,
    String? direccion,
    String? cuit,
    String? observaciones,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      cuit: cuit ?? this.cuit,
      observaciones: observaciones ?? this.observaciones,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
    );
  }

  @override
  String toString() {
    return 'Cliente(id: $id, nombre: $nombre, email: $email, telefono: $telefono)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cliente && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
