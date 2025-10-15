class Cliente {
  final int? id;
  final String nombre;
  final String? email;
  final String? telefono;
  final String? direccion;
  final String? cuit;
  final String? observaciones;
  final DateTime? fechaCreacion;
  final DateTime? fechaModificacion;

  Cliente({
    this.id,
    required this.nombre,
    this.email,
    this.telefono,
    this.direccion,
    this.cuit,
    this.observaciones,
    this.fechaCreacion,
    this.fechaModificacion,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      email: json['email'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      cuit: json['cuit'],
      observaciones: json['observaciones'],
      fechaCreacion: json['fecha_creacion'] != null 
          ? DateTime.parse(json['fecha_creacion'])
          : null,
      fechaModificacion: json['fecha_modificacion'] != null 
          ? DateTime.parse(json['fecha_modificacion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'cuit': cuit,
      'observaciones': observaciones,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
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