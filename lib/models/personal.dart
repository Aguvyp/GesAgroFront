class Personal {
  final int? id;
  final String nombre;
  final String dni;
  final String? telefono;

  Personal({
    this.id,
    required this.nombre,
    required this.dni,
    this.telefono,
  });

  factory Personal.fromJson(Map<String, dynamic> json) {
    return Personal(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      dni: json['dni'] ?? '',
      telefono: json['telefono'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'dni': dni,
      'telefono': telefono,
    };
  }

  Personal copyWith({
    int? id,
    String? nombre,
    String? dni,
    String? telefono,
  }) {
    return Personal(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      dni: dni ?? this.dni,
      telefono: telefono ?? this.telefono,
    );
  }

  String get initials {
    final names = nombre.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  @override
  String toString() {
    return 'Personal(id: $id, nombre: $nombre, dni: $dni)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Personal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
