class WeatherResponse {
  final WeatherActual actual;
  final List<WeatherForecast> pronostico;

  WeatherResponse({required this.actual, required this.pronostico});

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      actual: WeatherActual.fromJson(json['actual']),
      pronostico: (json['pronostico'] as List)
          .map((i) => WeatherForecast.fromJson(i))
          .toList(),
    );
  }
}

class WeatherActual {
  final double temperatura;
  final int humedad;
  final double viento;
  final String descripcion;
  final bool alertaPulverizacion;

  WeatherActual({
    required this.temperatura,
    required this.humedad,
    required this.viento,
    required this.descripcion,
    required this.alertaPulverizacion,
  });

  factory WeatherActual.fromJson(Map<String, dynamic> json) {
    return WeatherActual(
      temperatura: (json['temperatura'] as num).toDouble(),
      humedad: (json['humedad'] as num).toInt(),
      viento: (json['viento'] as num).toDouble(),
      descripcion: json['descripcion'] as String,
      alertaPulverizacion: json['alerta_pulverizacion'] as bool? ?? false,
    );
  }
}

class WeatherForecast {
  final String dia;
  final String? diaNombre;
  final double max;
  final double min;
  final String clima;
  final double? vientoMax;
  final int? probabilidadPrecipitacion;
  final bool? alertaPulverizacion;

  WeatherForecast({
    required this.dia,
    this.diaNombre,
    required this.max,
    required this.min,
    required this.clima,
    this.vientoMax,
    this.probabilidadPrecipitacion,
    this.alertaPulverizacion,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      dia: json['dia'] as String,
      diaNombre: json['dia_nombre'] as String?,
      max: (json['max'] as num).toDouble(),
      min: (json['min'] as num).toDouble(),
      clima: json['clima'] as String,
      vientoMax: (json['viento_max'] as num?)?.toDouble(),
      probabilidadPrecipitacion:
          (json['probabilidad_precipitacion'] as num?)?.toInt(),
      alertaPulverizacion: json['alerta_pulverizacion'] as bool?,
    );
  }
}
