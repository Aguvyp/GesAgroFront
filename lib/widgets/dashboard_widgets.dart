import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherWidget extends StatefulWidget {
  final String location;
  const WeatherWidget({Key? key, this.location = 'Mi ubicación'})
      : super(key: key);

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  bool _isExpanded = false;
  final WeatherService _weatherService = WeatherService();
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
      final data = await _weatherService.getForecast();
      if (mounted) {
        setState(() {
          _weatherData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
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
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
        border: hasAlert
            ? Border.all(color: Colors.orange.shade700, width: 2)
            : null,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Icon(
                    WeatherService.getWeatherIcon(actual.descripcion),
                    color: Colors.orange[400],
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${actual.temperatura.round()}°C',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (hasAlert) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange[700],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        size: 10, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Alerta Pulverización',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${actual.descripcion} | Viento: ${actual.viento} km/h | Hum: ${actual.humedad}%',
                          style:
                              TextStyle(fontSize: 10, color: Colors.blue[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isExpanded ? '⌃' : 'Ver pronóstico 5 días 〉',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                    ),
                  ),
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
                  return _buildForecastItem(
                    forecast.dia.toUpperCase(),
                    WeatherService.getWeatherIcon(forecast.clima),
                    '${forecast.max.round()}°',
                    '${forecast.min.round()}°',
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForecastItem(
      String day, IconData icon, String maxTemp, String minTemp) {
    return Column(
      children: [
        Text(day,
            style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Icon(icon, size: 20, color: Colors.blue[400]),
        const SizedBox(height: 4),
        Text(maxTemp,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(minTemp, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ],
    );
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
