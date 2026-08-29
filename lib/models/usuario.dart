class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String rol; // 'Administrador', 'Contable', 'Operario'
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime? ultimoAcceso;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.activo = true,
    required this.fechaCreacion,
    this.ultimoAcceso,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      rol: json['rol'],
      activo: json['activo'] ?? true,
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      ultimoAcceso: json['ultimo_acceso'] != null
          ? DateTime.parse(json['ultimo_acceso'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'activo': activo,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'ultimo_acceso': ultimoAcceso?.toIso8601String(),
    };
  }

  bool get esAdministrador => rol == 'Administrador';
  bool get esContable => rol == 'Contable';
  bool get esOperario => rol == 'Operario';

  Usuario copyWith({
    int? id,
    String? nombre,
    String? email,
    String? rol,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? ultimoAcceso,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
    );
  }
}
