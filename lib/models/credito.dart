class Credito {
  final int id;
  final String entidad;
  final double montoOtorgado;
  final double tasaInteresAnual;
  final int plazoMeses;
  final DateTime fechaDesembolso;
  final String estado; // 'Activo', 'Finalizado', 'Cancelado', 'Suspendido'

  Credito({
    required this.id,
    required this.entidad,
    required this.montoOtorgado,
    required this.tasaInteresAnual,
    required this.plazoMeses,
    required this.fechaDesembolso,
    this.estado = 'Activo',
  });

  factory Credito.fromJson(Map<String, dynamic> json) {
    return Credito(
      id: json['id'],
      entidad: json['entidad'],
      montoOtorgado: json['monto_otorgado'].toDouble(),
      tasaInteresAnual: json['tasa_interes_anual'].toDouble(),
      plazoMeses: json['plazo_meses'],
      fechaDesembolso: DateTime.parse(json['fecha_desembolso']),
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entidad': entidad,
      'monto_otorgado': montoOtorgado,
      'tasa_interes_anual': tasaInteresAnual,
      'plazo_meses': plazoMeses,
      'fecha_desembolso':
          fechaDesembolso.toIso8601String().split('T')[0], // Solo fecha
      'estado': estado,
    };
  }

  // Método para crear un nuevo crédito (sin ID)
  Map<String, dynamic> toCreateJson() {
    return {
      'entidad': entidad,
      'monto_otorgado': montoOtorgado,
      'tasa_interes_anual': tasaInteresAnual,
      'plazo_meses': plazoMeses,
      'fecha_desembolso':
          fechaDesembolso.toIso8601String().split('T')[0], // Solo fecha
      'estado': estado,
    };
  }

  // Método para actualizar un crédito (solo campos modificables)
  Map<String, dynamic> toUpdateJson() {
    return {
      'entidad': entidad,
      'monto_otorgado': montoOtorgado,
      'tasa_interes_anual': tasaInteresAnual,
      'plazo_meses': plazoMeses,
      'fecha_desembolso':
          fechaDesembolso.toIso8601String().split('T')[0], // Solo fecha
      'estado': estado,
    };
  }

  bool get estaActivo => estado == 'Activo';
  bool get estaFinalizado => estado == 'Finalizado';
  bool get estaCancelado => estado == 'Cancelado';
  bool get estaSuspendido => estado == 'Suspendido';

  Credito copyWith({
    int? id,
    String? entidad,
    double? montoOtorgado,
    double? tasaInteresAnual,
    int? plazoMeses,
    DateTime? fechaDesembolso,
    String? estado,
  }) {
    return Credito(
      id: id ?? this.id,
      entidad: entidad ?? this.entidad,
      montoOtorgado: montoOtorgado ?? this.montoOtorgado,
      tasaInteresAnual: tasaInteresAnual ?? this.tasaInteresAnual,
      plazoMeses: plazoMeses ?? this.plazoMeses,
      fechaDesembolso: fechaDesembolso ?? this.fechaDesembolso,
      estado: estado ?? this.estado,
    );
  }
}

class CuotaCredito {
  final int id;
  final int idCredito;
  final int numeroCuota;
  final DateTime fechaVencimiento;
  final double montoTotal;
  final String estado; // 'Pendiente', 'Pagada', 'Vencida', 'Cancelada'

  CuotaCredito({
    required this.id,
    required this.idCredito,
    required this.numeroCuota,
    required this.fechaVencimiento,
    required this.montoTotal,
    this.estado = 'Pendiente',
  });

  factory CuotaCredito.fromJson(Map<String, dynamic> json) {
    return CuotaCredito(
      id: json['id'],
      idCredito: json['id_credito'] ?? json['credito'],
      numeroCuota: json['numero_cuota'],
      fechaVencimiento: DateTime.parse(json['fecha_vencimiento']),
      montoTotal: json['monto_total'].toDouble(),
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'credito': idCredito,
      'numero_cuota': numeroCuota,
      'fecha_vencimiento':
          fechaVencimiento.toIso8601String().split('T')[0], // Solo fecha
      'monto_total': montoTotal,
      'estado': estado,
    };
  }

  // Método para crear una nueva cuota (sin ID)
  Map<String, dynamic> toCreateJson() {
    return {
      'credito': idCredito,
      'numero_cuota': numeroCuota,
      'fecha_vencimiento':
          fechaVencimiento.toIso8601String().split('T')[0], // Solo fecha
      'monto_total': montoTotal,
      'estado': estado,
    };
  }

  // Método para actualizar una cuota (solo campos modificables)
  Map<String, dynamic> toUpdateJson() {
    return {
      'credito': idCredito,
      'numero_cuota': numeroCuota,
      'fecha_vencimiento':
          fechaVencimiento.toIso8601String().split('T')[0], // Solo fecha
      'monto_total': montoTotal,
      'estado': estado,
    };
  }

  bool get estaPagada => estado == 'Pagada';
  bool get estaVencida =>
      estado == 'Vencida' ||
      (DateTime.now().isAfter(fechaVencimiento) && estado == 'Pendiente');
  bool get estaPendiente => estado == 'Pendiente' && !estaVencida;
  bool get estaCancelada => estado == 'Cancelada';

  CuotaCredito copyWith({
    int? id,
    int? idCredito,
    int? numeroCuota,
    DateTime? fechaVencimiento,
    double? montoTotal,
    String? estado,
  }) {
    return CuotaCredito(
      id: id ?? this.id,
      idCredito: idCredito ?? this.idCredito,
      numeroCuota: numeroCuota ?? this.numeroCuota,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      montoTotal: montoTotal ?? this.montoTotal,
      estado: estado ?? this.estado,
    );
  }
}
