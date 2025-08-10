import 'package:flutter/material.dart';

class GradientOutlineInputBorder extends OutlineInputBorder {
  final Gradient gradient;

  GradientOutlineInputBorder({
    required this.gradient,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(4)),
    double borderSideWidth = 1,
  }) : super(
         borderRadius: borderRadius,
         borderSide: BorderSide(
           width: borderSideWidth,
           color: Colors.transparent,
         ),
       );

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double? gapExtent,
    double? gapPercentage,
    TextDirection? textDirection,
  }) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderSide.width;

    final RRect rrect = borderRadius.toRRect(rect);
    canvas.drawRRect(rrect, paint);
  }
}
