import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Tiny month-to-date line graph drawn inside the Revenue card. One point per
/// day, tallest day scaled to full height, with a soft fill under the line.
class RevenueSparkline extends StatelessWidget {
  final List<double> values;

  const RevenueSparkline({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 4.h,
      width: double.infinity,
      child: CustomPaint(painter: _LineChartPainter(values)),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;

  _LineChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    // Keep the line off the very top and bottom edges so it never clips.
    const padding = 2.0;
    final usableHeight = size.height - padding * 2;
    final baseline = size.height - padding;

    final dx = values.length == 1 ? 0.0 : size.width / (values.length - 1);

    double yFor(double value) {
      if (maxValue <= 0) return baseline;
      return baseline - (value / maxValue) * usableHeight;
    }

    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(values.length == 1 ? size.width / 2 : i * dx, yFor(values[i])),
    ];

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      line.lineTo(points[i].dx, points[i].dy);
    }

    final fill = Path.from(line)
      ..lineTo(points.last.dx, baseline)
      ..lineTo(points.first.dx, baseline)
      ..close();

    canvas.drawPath(fill, Paint()..color = AppColors.chartFill);
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.chartPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      !listEquals(oldDelegate.values, values);
}
