import 'package:intl/intl.dart';

class Costo {
  final int? id;
  final double monto;
  final DateTime fecha;
  final String destinatario;
  final bool pagado;
  final String formaPago;
  final String? descripcion;
  final String? categoria;
  // Nuevos campos
  final DateTime? fechaPagoLimite; // fecha_pago_limite
  final bool esCobro; // true=cobro, false=gasto
  final String? cobrarA; // si es cobro, a quién cobrar
  final int? trabajoId; // a qué trabajo corresponde

  Costo({
    this.id,
    required this.monto,
    required this.fecha,
    required this.destinatario,
    required this.pagado,
    required this.formaPago,
    this.descripcion,
    this.categoria,
    this.fechaPagoLimite,
    this.esCobro = false,
    this.cobrarA,
    this.trabajoId,
  });

  factory Costo.fromJson(Map<String, dynamic> json) {
    // Función helper para convertir a double de forma segura
    double _toDouble(dynamic value, [double defaultValue = 0.0]) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      if (value is String) {
        if (value.isEmpty || value.trim().isEmpty) return defaultValue;
        final cleaned = value.trim().replaceAll(',', '.');
        return double.tryParse(cleaned) ?? defaultValue;
      }
      try {
        final stringValue = value.toString().trim();
        if (stringValue.isEmpty) return defaultValue;
        final cleaned = stringValue.replaceAll(',', '.');
        return double.tryParse(cleaned) ?? defaultValue;
      } catch (e) {
        return defaultValue;
      }
    }

    return Costo(
      id: json['id'],
      monto: _toDouble(json['monto'], 0.0),
      fecha: DateTime.parse(json['fecha']),
      destinatario: json['destinatario'] ?? '',
      pagado: json['pagado'] ?? false,
      formaPago: json['forma_pago'] ?? '',
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      fechaPagoLimite: json['fecha_pago_limite'] != null
          ? DateTime.tryParse(json['fecha_pago_limite'])
          : null,
      esCobro: json['es_cobro'] ?? (json['tipo'] == 'cobro'),
      cobrarA: json['cobrar_a'],
      trabajoId: json['id_trabajo'] ?? json['trabajo_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monto': monto,
      'fecha': DateFormat('yyyy-MM-dd').format(fecha),
      'destinatario': destinatario,
      'pagado': pagado,
      'forma_pago': formaPago,
      'descripcion': descripcion,
      'categoria': categoria,
      'fecha_pago_limite': fechaPagoLimite != null
          ? DateFormat('yyyy-MM-dd').format(fechaPagoLimite!)
          : null,
      'es_cobro': esCobro,
      'cobrar_a': cobrarA,
      'id_trabajo': trabajoId,
    };
  }

  Costo copyWith({
    int? id,
    double? monto,
    DateTime? fecha,
    String? destinatario,
    bool? pagado,
    String? formaPago,
    String? descripcion,
    String? categoria,
    DateTime? fechaPagoLimite,
    bool? esCobro,
    String? cobrarA,
    int? trabajoId,
  }) {
    return Costo(
      id: id ?? this.id,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      destinatario: destinatario ?? this.destinatario,
      pagado: pagado ?? this.pagado,
      formaPago: formaPago ?? this.formaPago,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      fechaPagoLimite: fechaPagoLimite ?? this.fechaPagoLimite,
      esCobro: esCobro ?? this.esCobro,
      cobrarA: cobrarA ?? this.cobrarA,
      trabajoId: trabajoId ?? this.trabajoId,
    );
  }

  String get formattedAmount {
    final formatter = NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(monto);
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }

  String get statusText => pagado ? 'Pagado' : 'Pendiente';

  bool get estaVencido {
    if (fechaPagoLimite == null) return false;
    final hoy = DateTime.now();
    return !pagado && fechaPagoLimite!.isBefore(DateTime(hoy.year, hoy.month, hoy.day).add(const Duration(days: 1)));
  }

  bool venceEnProximosDias(int dias) {
    if (fechaPagoLimite == null) return false;
    final hoy = DateTime.now();
    final limite = hoy.add(Duration(days: dias));
    return !pagado && !fechaPagoLimite!.isBefore(hoy) && !fechaPagoLimite!.isAfter(limite);
  }

  @override
  String toString() {
    return 'Costo(id: $id, monto: $monto, destinatario: $destinatario, fecha: $fecha)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Costo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
