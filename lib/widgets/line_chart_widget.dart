import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class LineChartWidget extends StatelessWidget {
  final List<double> prices;
  final bool isPositive;

  const LineChartWidget({
    super.key,
    required this.prices,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppTheme.gainColor : AppTheme.lossColor;
    final minY = prices.reduce((a, b) => a < b ? a : b) * 0.999;
    final maxY = prices.reduce((a, b) => a > b ? a : b) * 1.001;

    final spots = prices.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withOpacity(0.05),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 55,
              getTitlesWidget: (value, meta) => Text(
                '\$${value.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: prices.length / 4,
              getTitlesWidget: (value, meta) {
                final labels = ['9:30', '11:00', '12:30', '2:00', '4:00'];
                final idx = (value / (prices.length / 4)).round();
                if (idx < labels.length) {
                  return Text(
                    labels[idx],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '\$${spot.y.toStringAsFixed(2)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
