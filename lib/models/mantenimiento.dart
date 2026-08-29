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
    // Función helper para convertir a double de forma segura
    double? _toDouble(dynamic value) {
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

    return Mantenimiento(
      id: json['id'],
      idMaquina: json['id_maquina'] ?? json['maquina'],
      fecha: DateTime.parse(json['fecha']),
      descripcion: json['descripcion'],
      estado: json['estado'] ?? 'Pendiente',
      costoTotal: _toDouble(json['costo_total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maquina': idMaquina,
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
