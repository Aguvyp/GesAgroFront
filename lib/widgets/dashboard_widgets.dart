import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/optimized_api_service.dart';
import '../models/weather.dart';
import '../themes/app_theme.dart';

// ════════════════════════════════════════════════
//  WEATHER WIDGET — Premium Edition
// ════════════════════════════════════════════════

class WeatherWidget extends ConsumerStatefulWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends ConsumerState<WeatherWidget>
    with SingleTickerProviderStateMixin {
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
      final data =
          await apiService.getWeatherForecast(pos.latitude, pos.longitude);
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
    // ── Loading state — shimmer premium ──
    if (_isLoading) {
      return Container(
        height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.surface,
              AppTheme.surfaceVariant,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Obteniendo clima...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Error state — premium ──
    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.textHint.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  color: AppTheme.textTertiary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clima no disponible',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _fetchWeather,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.refresh_rounded,
                      size: 18, color: AppTheme.primary),
                ),
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

    // ── Main weather card — premium glass design ──
    return Container(
      decoration: BoxDecoration(
        gradient: _getWeatherGradient(actual.descripcion, hasAlert),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowMd,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Column(
          children: [
            // ── Collapsed row — always visible ──
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Weather icon with glow
                      _buildWeatherIconWithGlow(actual.descripcion, 34),
                      const SizedBox(width: 14),

                      // Temperature
                      Text(
                        '${actual.temperatura.round()}°',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Description + metrics
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    actual.descripcion,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.95),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (hasAlert) ...[
                                  const SizedBox(width: 8),
                                  _buildAlertBadge(),
                                ],
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Flexible(
                                  child: _miniMetricWhite(Icons.air_rounded,
                                      '${actual.viento.round()} km/h'),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: _miniMetricWhite(
                                      Icons.water_drop_rounded,
                                      '${actual.humedad}%'),
                                ),
                                if (forecasts.isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: _miniMetricWhite(
                                        Icons.thermostat_auto_rounded,
                                        '${forecasts[0].max.round()}°/${forecasts[0].min.round()}°'),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Expand arrow
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white.withOpacity(0.8),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Expanded forecast row — glass panel ──
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: forecasts.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                    )
                  : const SizedBox.shrink(),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Gradient based on weather condition ───
  LinearGradient _getWeatherGradient(String? description, bool hasAlert) {
    final desc = description?.toLowerCase() ?? '';

    if (hasAlert) {
      return const LinearGradient(
        colors: [Color(0xFF8B6914), Color(0xFFBF8C2C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (desc.contains('sol') || desc.contains('despejado')) {
      return const LinearGradient(
        colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (desc.contains('parcial')) {
      return const LinearGradient(
        colors: [Color(0xFF5C8BC5), Color(0xFF90A4AE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (desc.contains('nube') || desc.contains('nublado')) {
      return const LinearGradient(
        colors: [Color(0xFF607D8B), Color(0xFF90A4AE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (desc.contains('lluvia') ||
        desc.contains('tormenta') ||
        desc.contains('agua')) {
      return const LinearGradient(
        colors: [Color(0xFF37474F), Color(0xFF546E7A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (desc.contains('nieve') || desc.contains('frio')) {
      return const LinearGradient(
        colors: [Color(0xFF78909C), Color(0xFFB0BEC5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    // Default — green premium
    return const LinearGradient(
      colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ─── Weather icon with glow effect ───
  Widget _buildWeatherIconWithGlow(String? description, double size) {
    final desc = description?.toLowerCase() ?? '';
    IconData iconData;
    Color glowColor;

    if (desc.contains('sol') || desc.contains('despejado')) {
      iconData = Icons.wb_sunny_rounded;
      glowColor = Colors.amber.shade300;
    } else if (desc.contains('parcial')) {
      iconData = Icons.wb_cloudy_rounded;
      glowColor = Colors.amber.shade200;
    } else if (desc.contains('nube') || desc.contains('nublado')) {
      iconData = Icons.cloud_rounded;
      glowColor = Colors.white70;
    } else if (desc.contains('lluvia') ||
        desc.contains('tormenta') ||
        desc.contains('agua')) {
      iconData = Icons.thunderstorm_rounded;
      glowColor = Colors.lightBlue.shade200;
    } else if (desc.contains('nieve') || desc.contains('frio')) {
      iconData = Icons.ac_unit_rounded;
      glowColor = Colors.cyan.shade200;
    } else if (desc.contains('viento')) {
      iconData = Icons.air_rounded;
      glowColor = Colors.white70;
    } else {
      iconData = Icons.wb_cloudy_rounded;
      glowColor = Colors.white70;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(iconData, size: size, color: Colors.white),
    );
  }

  // ─── Alert badge ───
  Widget _buildAlertBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.shade300,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 6,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 10, color: Color(0xFF5D4037)),
          SizedBox(width: 3),
          Text(
            'Alerta',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5D4037),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMetricWhite(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white.withOpacity(0.7)),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
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
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 5),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _weatherIconSmall(f.clima, 20),
              if (f.alertaPulverizacion == true)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        size: 7, color: Color(0xFF5D4037)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${f.max.round()}°',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            '${f.min.round()}°',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherIconSmall(String? description, double size) {
    final desc = description?.toLowerCase() ?? '';
    IconData iconData;

    if (desc.contains('sol') || desc.contains('despejado')) {
      iconData = Icons.wb_sunny_rounded;
    } else if (desc.contains('parcial')) {
      iconData = Icons.wb_cloudy_rounded;
    } else if (desc.contains('nube') || desc.contains('nublado')) {
      iconData = Icons.cloud_rounded;
    } else if (desc.contains('lluvia') ||
        desc.contains('tormenta') ||
        desc.contains('agua')) {
      iconData = Icons.thunderstorm_rounded;
    } else if (desc.contains('nieve') || desc.contains('frio')) {
      iconData = Icons.ac_unit_rounded;
    } else if (desc.contains('viento')) {
      iconData = Icons.air_rounded;
    } else {
      iconData = Icons.wb_cloudy_rounded;
    }

    return Icon(iconData, size: size, color: Colors.white.withOpacity(0.85));
  }

  void _showForecastDetail(WeatherForecast forecast) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusXl),
            topRight: Radius.circular(AppTheme.radiusXl),
          ),
          boxShadow: AppTheme.shadowLg,
        ),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header with gradient icon container
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: _getWeatherGradient(forecast.clima, false),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _weatherIconSmall(forecast.clima, 28),
                ),
                const SizedBox(width: 16),
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
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        forecast.clima,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Metrics grid — premium tiles
            Row(
              children: [
                _buildDetailTile('Máxima', '${forecast.max.round()}°',
                    Icons.arrow_upward_rounded, const Color(0xFFE53935)),
                const SizedBox(width: 10),
                _buildDetailTile('Mínima', '${forecast.min.round()}°',
                    Icons.arrow_downward_rounded, const Color(0xFF1976D2)),
                const SizedBox(width: 10),
                _buildDetailTile(
                    'Viento',
                    forecast.vientoMax != null
                        ? '${forecast.vientoMax!.round()}'
                        : '-',
                    Icons.air_rounded,
                    const Color(0xFF607D8B)),
                const SizedBox(width: 10),
                _buildDetailTile(
                    'Lluvia',
                    '${forecast.probabilidadPrecipitacion ?? 0}%',
                    Icons.water_drop_rounded,
                    const Color(0xFF0097A7)),
              ],
            ),

            // Alert banner
            if (forecast.alertaPulverizacion == true) ...[
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.warning.withOpacity(0.08),
                      AppTheme.warning.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.warning.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.warning_amber_rounded,
                          color: AppTheme.warning, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No apto para pulverización',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Condiciones climáticas desfavorables',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
//  PRICE TICKER WIDGET — Premium Edition
// ════════════════════════════════════════════════

class PriceTickerWidget extends StatelessWidget {
  const PriceTickerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_PriceItem> prices = [
      _PriceItem('Soja', 285.0, 'up', '🫘'),
      _PriceItem('Maíz', 165.0, 'down', '🌽'),
      _PriceItem('Trigo', 210.0, 'up', '🌾'),
      _PriceItem('Girasol', 310.0, 'neutral', '🌻'),
      _PriceItem('Sorgo', 155.0, 'up', '🌱'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header premium ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.candlestick_chart_rounded,
                    size: 14, color: AppTheme.primary),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Pizarra BCR',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'USD/Tn',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Price cards scrollable ──
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 1),
            itemCount: prices.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _buildPriceCard(prices[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(_PriceItem item) {
    Color trendColor;
    IconData trendIcon;
    Color bgAccent;

    if (item.trend == 'up') {
      trendColor = const Color(0xFF16A34A);
      trendIcon = Icons.trending_up_rounded;
      bgAccent = const Color(0xFF16A34A).withOpacity(0.04);
    } else if (item.trend == 'down') {
      trendColor = const Color(0xFFDC2626);
      trendIcon = Icons.trending_down_rounded;
      bgAccent = const Color(0xFFDC2626).withOpacity(0.04);
    } else {
      trendColor = AppTheme.textTertiary;
      trendIcon = Icons.remove_rounded;
      bgAccent = AppTheme.surfaceVariant;
    }

    return Container(
      width: 116,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        gradient: LinearGradient(
          colors: [AppTheme.surface, bgAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Crop name + emoji
          Row(
            children: [
              Text(
                item.emoji,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  item.crop,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Price + trend
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.8,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(trendIcon, size: 13, color: trendColor),
              ),
            ],
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
  final String emoji;
  _PriceItem(this.crop, this.price, this.trend, this.emoji);
}
