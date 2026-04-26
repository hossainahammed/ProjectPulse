import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class ProgressChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final bool showArrow;
  final double aspectRatio;

  const ProgressChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.showArrow = true,
    this.aspectRatio = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 30),
          AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              children: [
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxValue() * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => isDark ? const Color(0xFF1E293B) : Colors.white,
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String label = data[groupIndex]['label'] ?? data[groupIndex]['month'] ?? '';
                          final amountColor = isDark
                              ? const Color(0xFFD946EF)   // Fuchsia in dark
                              : const Color(0xFF4F46E5);  // Indigo in day
                          return BarTooltipItem(
                            '$label\n',
                            TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: '\$${rod.toY.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: amountColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < data.length) {
                              String label = data[index]['label'] ?? data[index]['month'] ?? '';
                              // Truncate long labels
                              if (label.length > 8) {
                                label = '${label.substring(0, 6)}...';
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(data.length, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data[index]['value'],
                            width: 22,
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: _getBarColors(index, isDark),
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                // Custom Painter for the Upward Arrow
                if (showArrow)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ArrowPainter(
                        color: isDark
                            ? const Color(0xFFD946EF)
                            : const Color(0xFF4F46E5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxValue() {
    if (data.isEmpty) return 100;
    double max = 0;
    for (var item in data) {
      if (item['value'] > max) max = item['value'];
    }
    return max == 0 ? 100 : max;
  }

  List<Color> _getBarColors(int index, bool isDark) {
    final int count = data.length <= 1 ? 1 : data.length - 1;
    final double t = index / count;

    if (isDark) {
      // Dark mode: Fuchsia → Deep Purple gradient
      final topColor = Color.lerp(
        const Color(0xFFD946EF), // Fuchsia
        const Color(0xFF7C3AED), // Violet
        t,
      )!;
      final bottomColor = topColor.withOpacity(0.55);
      return [bottomColor, topColor];
    } else {
      // Day mode: Indigo → Violet gradient
      final topColor = Color.lerp(
        const Color(0xFF4F46E5), // Indigo
        const Color(0xFF8B5CF6), // Purple
        t,
      )!;
      final bottomColor = topColor.withOpacity(0.45);
      return [bottomColor, topColor];
    }
  }
}

class ArrowPainter extends CustomPainter {
  final Color color;

  ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    // Start from bottom left (with some padding)
    double startX = size.width * 0.1;
    double startY = size.height * 0.8;
    // End at top right (with some padding)
    double endX = size.width * 0.95;
    double endY = size.height * 0.1;

    path.moveTo(startX, startY);
    // Quadratic bezier curve for the upward sweep
    path.quadraticBezierTo(
      size.width * 0.5, // control point X
      size.height * 0.7, // control point Y
      endX,
      endY,
    );

    // Draw shadow
    canvas.save();
    canvas.translate(2, 4);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Draw main path
    canvas.drawPath(path, paint);

    // Draw Arrowhead
    final arrowHeadSize = 12.0;
    // Calculate angle at the end of the curve
    // For quadratic bezier: tangent at end is 2*(1-t)*(P1-P0) + 2*t*(P2-P1) where t=1
    // Tangent = 2*(P2-P1)
    double p1x = size.width * 0.5;
    double p1y = size.height * 0.7;
    double dx = endX - p1x;
    double dy = endY - p1y;
    double angle = math.atan2(dy, dx);

    final arrowPath = Path();
    arrowPath.moveTo(endX, endY);
    arrowPath.lineTo(
      endX - arrowHeadSize * math.cos(angle - math.pi / 6),
      endY - arrowHeadSize * math.sin(angle - math.pi / 6),
    );
    arrowPath.lineTo(
      endX - arrowHeadSize * math.cos(angle + math.pi / 6),
      endY - arrowHeadSize * math.sin(angle + math.pi / 6),
    );
    arrowPath.close();

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
