import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// One named series plotted on the chart.
class ChartSeries {
  final String label;
  final Color color;
  final List<double> values;

  /// Fills the area under the line down to the baseline.
  final bool fillArea;

  const ChartSeries({
    required this.label,
    required this.color,
    required this.values,
    this.fillArea = false,
  });
}

/// Multi series line chart with a shared y axis, dashed gridlines and a
/// legend. Sized by its parent.
class PerformanceLineChart extends StatelessWidget {
  final List<ChartSeries> series;
  final List<String> xLabels;

  /// Gridline values, low to high - the last one is the top of the plot.
  final List<double> yTicks;

  /// Formats a y tick into its axis label.
  final String Function(double) yLabelBuilder;

  const PerformanceLineChart({
    super.key,
    required this.series,
    required this.xLabels,
    required this.yTicks,
    required this.yLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
      fontSize: 11.sp,
      color: AppColors.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 5.w,
          runSpacing: 0.6.h,
          children: [
            for (final s in series)
              _LegendEntry(label: s.label, color: s.color),
          ],
        ),
        SizedBox(height: 2.h),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _LineChartPainter(
                series: series,
                xLabels: xLabels,
                yTicks: yTicks,
                yLabelBuilder: yLabelBuilder,
                labelStyle: labelStyle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendEntry({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4.w,
          height: 0.35.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.w),
          ),
        ),
        SizedBox(width: 1.5.w),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ChartSeries> series;
  final List<String> xLabels;
  final List<double> yTicks;
  final String Function(double) yLabelBuilder;
  final TextStyle labelStyle;

  _LineChartPainter({
    required this.series,
    required this.xLabels,
    required this.yTicks,
    required this.yLabelBuilder,
    required this.labelStyle,
  });

  static const _markerRadius = 3.5;
  static const _lineWidth = 2.0;
  static const _dashWidth = 4.0;
  static const _dashGap = 4.0;

  TextPainter _textPainter(String text) {
    return TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty || yTicks.isEmpty) return;

    final minY = yTicks.first;
    final maxY = yTicks.last;
    if (maxY <= minY) return;

    // Reserve room for the axis labels around the plot area.
    var yLabelWidth = 0.0;
    for (final tick in yTicks) {
      final painter = _textPainter(yLabelBuilder(tick));
      yLabelWidth = yLabelWidth < painter.width ? painter.width : yLabelWidth;
    }
    final xLabelHeight = xLabels.isEmpty
        ? 0.0
        : _textPainter(xLabels.first).height;

    final left = yLabelWidth + 8;
    final bottom = size.height - (xLabelHeight + 8);
    final plot = Rect.fromLTRB(left, 0, size.width, bottom);
    if (plot.width <= 0 || plot.height <= 0) return;

    double dx(int index, int count) => count <= 1
        ? plot.center.dx
        : plot.left + plot.width * index / (count - 1);
    double dy(double value) =>
        plot.bottom - plot.height * (value - minY) / (maxY - minY);

    _paintGrid(canvas, plot, dy);
    _paintXLabels(canvas, plot, dx, bottom);

    for (final s in series) {
      _paintSeries(canvas, plot, s, dx, dy);
    }
  }

  void _paintGrid(Canvas canvas, Rect plot, double Function(double) dy) {
    final gridPaint = Paint()
      ..color = AppColors.chartGrid
      ..strokeWidth = 1;

    for (final tick in yTicks) {
      final y = dy(tick);
      var x = plot.left;
      while (x < plot.right) {
        final end = (x + _dashWidth).clamp(plot.left, plot.right);
        canvas.drawLine(Offset(x, y), Offset(end, y), gridPaint);
        x += _dashWidth + _dashGap;
      }

      final painter = _textPainter(yLabelBuilder(tick));
      painter.paint(
        canvas,
        Offset(plot.left - 8 - painter.width, y - painter.height / 2),
      );
    }
  }

  void _paintXLabels(
    Canvas canvas,
    Rect plot,
    double Function(int, int) dx,
    double bottom,
  ) {
    for (var i = 0; i < xLabels.length; i++) {
      final painter = _textPainter(xLabels[i]);
      final x = (dx(i, xLabels.length) - painter.width / 2).clamp(
        0.0,
        plot.right - painter.width,
      );
      painter.paint(canvas, Offset(x, bottom + 8));
    }
  }

  void _paintSeries(
    Canvas canvas,
    Rect plot,
    ChartSeries s,
    double Function(int, int) dx,
    double Function(double) dy,
  ) {
    if (s.values.isEmpty) return;

    final points = [
      for (var i = 0; i < s.values.length; i++)
        Offset(dx(i, s.values.length), dy(s.values[i])),
    ];

    if (s.fillArea) {
      final area = Path()..moveTo(points.first.dx, plot.bottom);
      for (final point in points) {
        area.lineTo(point.dx, point.dy);
      }
      area
        ..lineTo(points.last.dx, plot.bottom)
        ..close();
      canvas.drawPath(area, Paint()..color = AppColors.chartFill);
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = s.color
        ..strokeWidth = _lineWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    // Markers are drawn as filled surface discs ringed in the series colour so
    // overlapping series stay readable.
    final fillPaint = Paint()..color = AppColors.background;
    final ringPaint = Paint()
      ..color = s.color
      ..strokeWidth = _lineWidth
      ..style = PaintingStyle.stroke;
    for (final point in points) {
      canvas.drawCircle(point, _markerRadius, fillPaint);
      canvas.drawCircle(point, _markerRadius, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.series != series ||
        oldDelegate.xLabels != xLabels ||
        oldDelegate.yTicks != yTicks ||
        oldDelegate.labelStyle != labelStyle;
  }
}
