class Mantenimiento {
  final int? id;
  final int idMaquina;
  final DateTime fecha;
  final String descripcion;
  final String estado; // 'Completado', 'Pendiente', 'Atrasado'
  final double? costoTotal;

  Mantenimiento({
    this.id,
    required this.idMaquina,
    required this.fecha,
    required this.descripcion,
    this.estado = 'Pendiente',
    this.costoTotal,
  });

  factory Mantenimiento.fromJson(Map<String, dynamic> json) {
    return Mantenimiento(
      id: json['id'],
      idMaquina: json['id_maquina'],
      fecha: DateTime.parse(json['fecha']),
      descripcion: json['descripcion'],
      estado: json['estado'] ?? 'Pendiente',
      costoTotal: json['costo_total']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_maquina': idMaquina,
      'fecha': fecha.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
      'descripcion': descripcion,
      'estado': estado,
      'costo_total': costoTotal,
    };
  }

  bool get estaCompletado => estado == 'Completado';
  bool get estaPendiente => estado == 'Pendiente';
  bool get estaAtrasado => estado == 'Atrasado';

  Mantenimiento copyWith({
    int? id,
    int? idMaquina,
    DateTime? fecha,
    String? descripcion,
    String? estado,
    double? costoTotal,
  }) {
    return Mantenimiento(
      id: id ?? this.id,
      idMaquina: idMaquina ?? this.idMaquina,
      fecha: fecha ?? this.fecha,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      costoTotal: costoTotal ?? this.costoTotal,
    );
  }
}
