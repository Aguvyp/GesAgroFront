import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/network/optimized_http_client.dart';

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
  final double max;
  final double min;
  final String clima;

  WeatherForecast({
    required this.dia,
    required this.max,
    required this.min,
    required this.clima,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      dia: json['dia'] as String,
      max: (json['max'] as num).toDouble(),
      min: (json['min'] as num).toDouble(),
      clima: json['clima'] as String,
    );
  }
}

class WeatherService {
  final OptimizedHttpClient _httpClient = OptimizedHttpClient.instance;

  Future<WeatherResponse> getForecast() async {
    try {
      Position position = await _determinePosition();

      final response = await _httpClient.get(
        '/api/clima/pronostico/',
        queryParameters: {
          'lat': position.latitude,
          'lon': position.longitude,
        },
      );

      if (response.statusCode == 200) {
        return WeatherResponse.fromJson(response.data);
      } else {
        throw Exception('Error al conectar con el servidor de clima');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('El GPS está desactivado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permisos denegados permanentemente.');
    }

    return await Geolocator.getCurrentPosition();
  }

  static IconData getWeatherIcon(String? description) {
    final desc = description?.toLowerCase() ?? '';
    if (desc.contains('sol') || desc.contains('despejado')) {
      return Icons.wb_sunny_rounded;
    } else if (desc.contains('nube') || desc.contains('nublado')) {
      return Icons.cloud_rounded;
    } else if (desc.contains('lluvia') ||
        desc.contains('tormenta') ||
        desc.contains('agua')) {
      return Icons.umbrella_rounded;
    } else if (desc.contains('nieve') || desc.contains('frio')) {
      return Icons.ac_unit_rounded;
    } else if (desc.contains('viento')) {
      return Icons.air_rounded;
    }
    return Icons.wb_cloudy_rounded;
  }
}
