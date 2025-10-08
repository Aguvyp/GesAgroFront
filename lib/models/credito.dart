class Credito {
  final int id;
  final int clienteId;
  final double montoTotal;
  final double montoPagado;
  final DateTime fechaInicio;
  final DateTime fechaVencimiento;
  final double tasaInteres;
  final String estado; // 'Activo', 'Pagado', 'Vencido', 'Cancelado'
  final String? observaciones;
  final List<CuotaCredito> cuotas;

  Credito({
    required this.id,
    required this.clienteId,
    required this.montoTotal,
    this.montoPagado = 0.0,
    required this.fechaInicio,
    required this.fechaVencimiento,
    this.tasaInteres = 0.0,
    this.estado = 'Activo',
    this.observaciones,
    this.cuotas = const [],
  });

  factory Credito.fromJson(Map<String, dynamic> json) {
    return Credito(
      id: json['id'],
      clienteId: json['cliente_id'],
      montoTotal: json['monto_total'].toDouble(),
      montoPagado: json['monto_pagado']?.toDouble() ?? 0.0,
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaVencimiento: DateTime.parse(json['fecha_vencimiento']),
      tasaInteres: json['tasa_interes']?.toDouble() ?? 0.0,
      estado: json['estado'],
      observaciones: json['observaciones'],
      cuotas: (json['cuotas'] as List<dynamic>?)
          ?.map((cuota) => CuotaCredito.fromJson(cuota))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'monto_total': montoTotal,
      'monto_pagado': montoPagado,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_vencimiento': fechaVencimiento.toIso8601String(),
      'tasa_interes': tasaInteres,
      'estado': estado,
      'observaciones': observaciones,
      'cuotas': cuotas.map((cuota) => cuota.toJson()).toList(),
    };
  }

  double get montoPendiente => montoTotal - montoPagado;
  bool get estaActivo => estado == 'Activo';
  bool get estaVencido => estado == 'Vencido' || (DateTime.now().isAfter(fechaVencimiento) && estado == 'Activo');
  bool get estaPagado => estado == 'Pagado';

  Credito copyWith({
    int? id,
    int? clienteId,
    double? montoTotal,
    double? montoPagado,
    DateTime? fechaInicio,
    DateTime? fechaVencimiento,
    double? tasaInteres,
    String? estado,
    String? observaciones,
    List<CuotaCredito>? cuotas,
  }) {
    return Credito(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      montoTotal: montoTotal ?? this.montoTotal,
      montoPagado: montoPagado ?? this.montoPagado,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      tasaInteres: tasaInteres ?? this.tasaInteres,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      cuotas: cuotas ?? this.cuotas,
    );
  }
}

class CuotaCredito {
  final int id;
  final int creditoId;
  final int numeroCuota;
  final double monto;
  final DateTime fechaVencimiento;
  final DateTime? fechaPago;
  final double? montoPagado;
  final String estado; // 'Pendiente', 'Pagada', 'Vencida'

  CuotaCredito({
    required this.id,
    required this.creditoId,
    required this.numeroCuota,
    required this.monto,
    required this.fechaVencimiento,
    this.fechaPago,
    this.montoPagado,
    this.estado = 'Pendiente',
  });

  factory CuotaCredito.fromJson(Map<String, dynamic> json) {
    return CuotaCredito(
      id: json['id'],
      creditoId: json['credito_id'],
      numeroCuota: json['numero_cuota'],
      monto: json['monto'].toDouble(),
      fechaVencimiento: DateTime.parse(json['fecha_vencimiento']),
      fechaPago: json['fecha_pago'] != null ? DateTime.parse(json['fecha_pago']) : null,
      montoPagado: json['monto_pagado']?.toDouble(),
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'credito_id': creditoId,
      'numero_cuota': numeroCuota,
      'monto': monto,
      'fecha_vencimiento': fechaVencimiento.toIso8601String(),
      'fecha_pago': fechaPago?.toIso8601String(),
      'monto_pagado': montoPagado,
      'estado': estado,
    };
  }

  bool get estaPagada => estado == 'Pagada';
  bool get estaVencida => estado == 'Vencida' || (DateTime.now().isAfter(fechaVencimiento) && estado == 'Pendiente');
  bool get estaPendiente => estado == 'Pendiente' && !estaVencida;
}
