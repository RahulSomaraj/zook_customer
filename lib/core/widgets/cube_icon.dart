import 'package:flutter/material.dart';

/// A Feather-style isometric 3D "box" cube, drawn as a vector so it matches
/// the design exactly (Material's built-in set has no clean isometric cube).
class CubeIcon extends StatelessWidget {
  final Color color;
  final double size;
  const CubeIcon({super.key, required this.color, this.size = 15});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CubePainter(color)),
    );
  }
}

class _CubePainter extends CustomPainter {
  final Color color;
  const _CubePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 24.0;
    Offset p(double x, double y) => Offset(x * s, y * s);

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final Offset top = p(12, 2.5);
    final Offset ur = p(20.5, 7);
    final Offset lr = p(20.5, 17);
    final Offset bottom = p(12, 21.5);
    final Offset ll = p(3.5, 17);
    final Offset ul = p(3.5, 7);
    final Offset c = p(12, 12);

    final Path hex = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(ur.dx, ur.dy)
      ..lineTo(lr.dx, lr.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(ll.dx, ll.dy)
      ..lineTo(ul.dx, ul.dy)
      ..close();
    canvas.drawPath(hex, paint);

    final Path inner = Path()
      ..moveTo(ul.dx, ul.dy)
      ..lineTo(c.dx, c.dy)
      ..lineTo(ur.dx, ur.dy)
      ..moveTo(c.dx, c.dy)
      ..lineTo(bottom.dx, bottom.dy);
    canvas.drawPath(inner, paint);
  }

  @override
  bool shouldRepaint(covariant _CubePainter oldDelegate) =>
      oldDelegate.color != color;
}
