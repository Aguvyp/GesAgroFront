class Cliente {
  final int id;
  final String nombre;
  final String? email;
  final String? telefono;
  final String? direccion;
  final String? dni;
  final DateTime fechaRegistro;
  final bool activo;

  Cliente({
    required this.id,
    required this.nombre,
    this.email,
    this.telefono,
    this.direccion,
    this.dni,
    required this.fechaRegistro,
    this.activo = true,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      dni: json['dni'],
      fechaRegistro: DateTime.parse(json['fecha_registro']),
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'dni': dni,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'activo': activo,
    };
  }

  Cliente copyWith({
    int? id,
    String? nombre,
    String? email,
    String? telefono,
    String? direccion,
    String? dni,
    DateTime? fechaRegistro,
    bool? activo,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      dni: dni ?? this.dni,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      activo: activo ?? this.activo,
    );
  }
}
