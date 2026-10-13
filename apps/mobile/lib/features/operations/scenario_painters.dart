import 'package:flutter/material.dart';
import '../../app/design_system.dart';

class ScenarioMapPainter extends CustomPainter {
  ScenarioMapPainter(this.plots, this.points);
  final List<Map> plots, points;
  @override
  void paint(Canvas canvas, Size size) {
    final rings = plots
        .map((p) => (p['boundary']['coordinates'][0] as List))
        .toList();
    final coords = rings
        .expand((r) => r)
        .map((p) => Offset((p[0] as num).toDouble(), (p[1] as num).toDouble()))
        .toList();
    if (coords.isEmpty) return;
    final bounds = coords.fold(
      Rect.fromPoints(coords.first, coords.first),
      (Rect b, p) => b.expandToInclude(Rect.fromPoints(p, p)),
    );
    if (bounds.width <= 0 || bounds.height <= 0) return;
    final scale =
        (size.width - 32) / bounds.width < (size.height - 32) / bounds.height
        ? (size.width - 32) / bounds.width
        : (size.height - 32) / bounds.height;
    Offset project(num lon, num lat) => Offset(
      16 + (lon - bounds.left) * scale,
      size.height - 16 - (lat - bounds.top) * scale,
    );
    for (var i = 0; i < rings.length; i++) {
      final path = Path();
      for (var j = 0; j < rings[i].length; j++) {
        final p = project(rings[i][j][0], rings[i][j][1]);
        if (j == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()..color = CommandColors.primary.withValues(alpha: .12),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = CommandColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    for (final p in points) {
      if (p['lat'] is! num || p['lon'] is! num) continue;
      final point = project(p['lon'], p['lat']);
      final color = ['falha', 'atencao'].contains(p['status'])
          ? CommandColors.error
          : p['kind'] == 'drone'
          ? CommandColors.cyan
          : CommandColors.primary;
      canvas.drawCircle(point, 5, Paint()..color = color);
      final text = TextPainter(
        text: TextSpan(
          text: p['label'],
          style: TextStyle(color: color, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, point + const Offset(6, -5));
    }
  }

  @override
  bool shouldRepaint(ScenarioMapPainter oldDelegate) => true;
}

class SeriesPainter extends CustomPainter {
  SeriesPainter(this.series);
  final List<Map> series;
  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    final path = Path();
    for (var i = 0; i < series.length; i++) {
      final x = i * size.width / (series.length - 1),
          y = size.height - (series[i]['moisture'] as num) * size.height / 100;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = CommandColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(SeriesPainter oldDelegate) => true;
}
