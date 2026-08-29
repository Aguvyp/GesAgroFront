class TipoTrabajo {
  final int id;
  final String trabajo;

  TipoTrabajo({
    required this.id,
    required this.trabajo,
  });

  factory TipoTrabajo.fromJson(Map<String, dynamic> json) {
    return TipoTrabajo(
      id: json['id'] as int,
      trabajo: json['trabajo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trabajo': trabajo,
    };
  }

  @override
  String toString() {
    return 'TipoTrabajo(id: $id, trabajo: $trabajo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TipoTrabajo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
