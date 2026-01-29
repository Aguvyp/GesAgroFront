import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/optimized_api_service.dart';
import '../models/weather.dart';

class WeatherWidget extends ConsumerStatefulWidget {
  final String location;
  const WeatherWidget({Key? key, this.location = 'Mi ubicación'})
      : super(key: key);

  @override
  ConsumerState<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends ConsumerState<WeatherWidget> {
  bool _isExpanded = false;
  WeatherResponse? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Primero inicializar el servicio API si no lo está
      final apiService = ref.read(apiServiceProvider);
      if (!apiService.isInitialized) {
        await apiService.initialize();
      }

      final curPosition = await _determinePosition();

      print(
          '📍 Ubicación obtenida: ${curPosition.latitude}, ${curPosition.longitude}');

      final data = await ref
          .read(apiServiceProvider)
          .getWeatherForecast(curPosition.latitude, curPosition.longitude);

      print('✅ Datos de clima recibidos del backend');

      if (mounted) {
        setState(() {
          _weatherData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ ERROR EN WEATHER WIDGET: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('Exception:')
              ? e.toString().split('Exception:')[1]
              : 'Error al obtener el clima';
          _isLoading = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 12, color: Colors.brown),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _fetchWeather,
            ),
          ],
        ),
      );
    }

    if (_weatherData == null) return const SizedBox.shrink();

    final actual = _weatherData!.actual;
    final hasAlert = actual.alertaPulverizacion;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: hasAlert
                ? Colors.orange.shade700
                : Colors.grey.withOpacity(0.1),
            width: hasAlert ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: _buildWeatherIcon(actual.descripcion, size: 40),
                      ),
                      if (hasAlert)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              actual.descripcion,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (hasAlert)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange[700],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Alerta!',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Text(
                                '${actual.temperatura.round()}°C',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                ),
                              ),
                              _buildInlineDivider(),
                              Icon(Icons.air_rounded,
                                  size: 16, color: Colors.blue[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${actual.viento} km/h',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                ),
                              ),
                              _buildInlineDivider(),
                              Icon(Icons.water_drop_outlined,
                                  size: 16, color: Colors.blue[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${actual.humedad}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.blue,
                      size: 24),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _weatherData!.pronostico.map((forecast) {
                  return _buildForecastItem(forecast);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInlineDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        '|',
        style: TextStyle(
          color: Colors.blue[300],
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  void _showForecastDetail(WeatherForecast forecast) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    getWeatherIcon(forecast.clima),
                    color: Colors.blue[600],
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        forecast.diaNombre ?? forecast.dia,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        forecast.clima,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDetailCard(
                    'Máxima',
                    '${forecast.max.round()}°C',
                    Icons.arrow_upward_rounded,
                    Colors.red[100]!,
                    Colors.red[700]!,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailCard(
                    'Mínima',
                    '${forecast.min.round()}°C',
                    Icons.arrow_downward_rounded,
                    Colors.blue[100]!,
                    Colors.blue[700]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailCard(
                    'Viento Máximo',
                    '${forecast.vientoMax ?? '--'} km/h',
                    Icons.air_rounded,
                    Colors.grey[100]!,
                    Colors.grey[700]!,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailCard(
                    'Lluvia',
                    '${forecast.probabilidadPrecipitacion ?? 0}%',
                    Icons.umbrella_rounded,
                    Colors.cyan[100]!,
                    Colors.cyan[700]!,
                  ),
                ),
              ],
            ),
            if (forecast.alertaPulverizacion == true) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Alerta de Pulverización: Las condiciones no son óptimas para aplicar fitosanitarios.',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon,
      Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: iconColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastItem(WeatherForecast forecast) {
    String displayDay = forecast.diaNombre ?? forecast.dia;
    if (displayDay.length > 3) {
      displayDay = displayDay.substring(0, 3);
    }

    return GestureDetector(
      onTap: () => _showForecastDetail(forecast),
      child: Column(
        children: [
          Text(displayDay.toUpperCase(),
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildWeatherIcon(forecast.clima, size: 22),
              if (forecast.alertaPulverizacion == true)
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${forecast.max.round()}°',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent)),
          Text('${forecast.min.round()}°',
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent)),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon(String? description, {double size = 24}) {
    final desc = description?.toLowerCase() ?? '';
    IconData iconData = Icons.wb_cloudy_rounded;
    Color iconColor = Colors.grey[400]!;

    if (desc.contains('sol') || desc.contains('despejado')) {
      iconData = Icons.wb_sunny_rounded;
      iconColor = Colors.orange[400]!;
    } else if (desc.contains('nube') || desc.contains('nublado')) {
      iconData = Icons.cloud_rounded;
      iconColor = Colors.blueGrey[300]!;
    } else if (desc.contains('lluvia') ||
        desc.contains('tormenta') ||
        desc.contains('agua')) {
      iconData = Icons.umbrella_rounded;
      iconColor = Colors.blue[400]!;
    } else if (desc.contains('nieve') || desc.contains('frio')) {
      iconData = Icons.ac_unit_rounded;
      iconColor = Colors.cyan[300]!;
    } else if (desc.contains('viento')) {
      iconData = Icons.air_rounded;
      iconColor = Colors.blue[300]!;
    }

    return Icon(iconData, size: size, color: iconColor);
  }

  IconData getWeatherIcon(String? description) {
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

class PriceTickerWidget extends StatelessWidget {
  const PriceTickerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> prices = [
      {'crop': 'Soja', 'price': '285.0', 'trend': 'up'},
      {'crop': 'Maíz', 'price': '165.0', 'trend': 'down'},
      {'crop': 'Trigo', 'price': '210.0', 'trend': 'up'},
      {'crop': 'Girasol', 'price': '310.0', 'trend': 'neutral'},
      {'crop': 'Sorgo', 'price': '155.0', 'trend': 'up'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Precios de Pizarra BCR (USD)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: prices.length,
            itemBuilder: (context, index) {
              final item = prices[index];
              return _buildPriceCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(Map<String, dynamic> item) {
    Color trendColor = Colors.grey;
    IconData trendIcon = Icons.remove;

    if (item['trend'] == 'up') {
      trendColor = Colors.green;
      trendIcon = Icons.trending_up;
    } else if (item['trend'] == 'down') {
      trendColor = Colors.red;
      trendIcon = Icons.trending_down;
    }

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item['crop'],
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Row(
            children: [
              Text(
                'U\$S ${item['price']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(trendIcon, size: 16, color: trendColor),
            ],
          ),
        ],
      ),
    );
  }
}
