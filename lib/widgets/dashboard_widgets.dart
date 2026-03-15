import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/optimized_api_service.dart';
import '../models/weather.dart';
import '../themes/app_theme.dart';

// ════════════════════════════════════════════════
//  WEATHER WIDGET
// ════════════════════════════════════════════════

class WeatherWidget extends ConsumerStatefulWidget {
  const WeatherWidget({Key? key}) : super(key: key);

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
      final apiService = ref.read(apiServiceProvider);
      if (!apiService.isInitialized) {
        await apiService.initialize();
      }
      final pos = await _determinePosition();
      final data = await apiService.getWeatherForecast(pos.latitude, pos.longitude);
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
              ? e.toString().split('Exception:')[1].trim()
              : 'Error al obtener el clima';
          _isLoading = false;
        });
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('GPS desactivado');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permisos denegados permanentemente');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    // ── Loading ──
    if (_isLoading) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primary,
            ),
          ),
        ),
      );
    }

    // ── Error ──
    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_outlined,
                color: AppTheme.textHint, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: _fetchWeather,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.refresh_rounded,
                    size: 16, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    if (_weatherData == null) return const SizedBox.shrink();

    final actual = _weatherData!.actual;
    final hasAlert = actual.alertaPulverizacion;
    final forecasts = _weatherData!.pronostico;

    // ── Main weather card ──
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14),
        border: hasAlert
            ? Border.all(color: AppTheme.warning.withOpacity(0.4), width: 1)
            : null,
      ),
      child: Column(
        children: [
          // Collapsed row — always visible
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Weather icon
                  _weatherIcon(actual.descripcion, 28),
                  const SizedBox(width: 12),
                  // Temperature
                  Text(
                    '${actual.temperatura.round()}°',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Description + metrics — wrapped in Expanded to prevent overflow
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                actual.descripcion,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasAlert) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.warning.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        size: 10, color: AppTheme.warning),
                                    SizedBox(width: 2),
                                    Text(
                                      'Alerta',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _miniMetric(Icons.air_rounded,
                                '${actual.viento.round()} km/h'),
                            const SizedBox(width: 10),
                            _miniMetric(Icons.water_drop_outlined,
                                '${actual.humedad}%'),
                            if (forecasts.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              _miniMetric(Icons.thermostat_rounded,
                                  '${forecasts[0].max.round()}°/${forecasts[0].min.round()}°'),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textHint,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded forecast row
          if (_isExpanded && forecasts.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: Row(
                children: forecasts.map((f) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _showForecastDetail(f),
                      child: _buildForecastColumn(f),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _miniMetric(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.textHint),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildForecastColumn(WeatherForecast f) {
    String day = f.diaNombre ?? f.dia;
    if (day.length > 3) day = day.substring(0, 3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        children: [
          Text(
            day.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textHint,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _weatherIcon(f.clima, 18),
              if (f.alertaPulverizacion == true)
                const Positioned(
                  top: -5,
                  right: -5,
                  child: Icon(Icons.warning_amber_rounded,
                      size: 9, color: AppTheme.warning),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${f.max.round()}°',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            '${f.min.round()}°',
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }

  void _showForecastDetail(WeatherForecast forecast) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
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
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                _weatherIcon(forecast.clima, 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${forecast.diaNombre ?? ''} ${forecast.dia}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        forecast.clima,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Metrics grid
            Row(
              children: [
                _buildDetailTile('Máxima', '${forecast.max.round()}°',
                    Icons.arrow_upward_rounded, Colors.red),
                const SizedBox(width: 10),
                _buildDetailTile('Mínima', '${forecast.min.round()}°',
                    Icons.arrow_downward_rounded, Colors.blue),
                const SizedBox(width: 10),
                _buildDetailTile(
                    'Viento',
                    forecast.vientoMax != null
                        ? '${forecast.vientoMax!.round()}'
                        : '-',
                    Icons.air_rounded,
                    Colors.blueGrey),
                const SizedBox(width: 10),
                _buildDetailTile(
                    'Lluvia',
                    '${forecast.probabilidadPrecipitacion ?? 0}%',
                    Icons.umbrella_rounded,
                    Colors.cyan),
              ],
            ),
            // Alert
            if (forecast.alertaPulverizacion == true) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppTheme.warning, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No apto para pulverización',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
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

  Widget _buildDetailTile(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherIcon(String? description, double size) {
    final desc = description?.toLowerCase() ?? '';
    IconData iconData;
    Color iconColor;

    if (desc.contains('sol') || desc.contains('despejado')) {
      iconData = Icons.wb_sunny_rounded;
      iconColor = Colors.amber.shade600;
    } else if (desc.contains('parcial')) {
      iconData = Icons.wb_cloudy_rounded;
      iconColor = Colors.amber.shade400;
    } else if (desc.contains('nube') || desc.contains('nublado')) {
      iconData = Icons.cloud_rounded;
      iconColor = Colors.blueGrey.shade300;
    } else if (desc.contains('lluvia') ||
        desc.contains('tormenta') ||
        desc.contains('agua')) {
      iconData = Icons.umbrella_rounded;
      iconColor = Colors.blue.shade400;
    } else if (desc.contains('nieve') || desc.contains('frio')) {
      iconData = Icons.ac_unit_rounded;
      iconColor = Colors.cyan.shade300;
    } else if (desc.contains('viento')) {
      iconData = Icons.air_rounded;
      iconColor = Colors.blue.shade300;
    } else {
      iconData = Icons.wb_cloudy_rounded;
      iconColor = Colors.blueGrey.shade300;
    }

    return Icon(iconData, size: size, color: iconColor);
  }
}

// ════════════════════════════════════════════════
//  PRICE TICKER WIDGET
// ════════════════════════════════════════════════

class PriceTickerWidget extends StatelessWidget {
  const PriceTickerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_PriceItem> prices = [
      _PriceItem('Soja', 285.0, 'up'),
      _PriceItem('Maíz', 165.0, 'down'),
      _PriceItem('Trigo', 210.0, 'up'),
      _PriceItem('Girasol', 310.0, 'neutral'),
      _PriceItem('Sorgo', 155.0, 'up'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.show_chart_rounded,
                size: 16, color: AppTheme.textHint),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Pizarra BCR (USD/Tn)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 68,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: prices.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => _buildPriceCard(prices[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(_PriceItem item) {
    Color trendColor = AppTheme.textHint;
    IconData trendIcon = Icons.remove_rounded;

    if (item.trend == 'up') {
      trendColor = const Color(0xFF16A34A);
      trendIcon = Icons.trending_up_rounded;
    } else if (item.trend == 'down') {
      trendColor = AppTheme.error;
      trendIcon = Icons.trending_down_rounded;
    }

    return Container(
      width: 108,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.crop,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(trendIcon, size: 14, color: trendColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '\$${item.price.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceItem {
  final String crop;
  final double price;
  final String trend;
  _PriceItem(this.crop, this.price, this.trend);
}
