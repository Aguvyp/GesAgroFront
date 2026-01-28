import 'package:flutter/material.dart';

class WeatherWidget extends StatefulWidget {
  final String location;
  const WeatherWidget({Key? key, this.location = 'San Justo, Santa Fe'})
      : super(key: key);

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light blue background like in image
        borderRadius: BorderRadius.circular(16),
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
                  Icon(Icons.wb_sunny_rounded,
                      color: Colors.orange[400], size: 32),
                  const SizedBox(width: 12),
                  const Text(
                    '28°C',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Ver pronóstico 5 días >',
                    style: TextStyle(
                      fontSize: 12,
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
                children: [
                  _buildForecastItem('Lun', Icons.wb_sunny_rounded, '30°'),
                  _buildForecastItem('Mar', Icons.cloud_rounded, '25°'),
                  _buildForecastItem('Mié', Icons.cloud_rounded, '24°'),
                  _buildForecastItem('Jue', Icons.wb_cloudy_rounded, '26°'),
                  _buildForecastItem('Vie', Icons.wb_sunny_rounded, '29°'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForecastItem(String day, IconData icon, String temp) {
    return Column(
      children: [
        Text(day, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Icon(icon, size: 20, color: Colors.blue[300]),
        const SizedBox(height: 4),
        Text(temp,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
