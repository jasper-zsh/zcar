import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:zcar/ui/instrument.dart';

class PointerInstrumentWidget extends StatefulWidget {
  InstrumentController controller;
  double min, max;

  PointerInstrumentWidget({
    super.key,
    required this.controller,
    required this.min,
    required this.max,
  });

  @override
  State<StatefulWidget> createState() {
    return PointerInstrumentState();
  }
}

class PointerInstrumentState extends State<PointerInstrumentWidget> with SingleTickerProviderStateMixin {
  late StreamSubscription<double> valueSubscription;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    valueSubscription = widget.controller.listen(valueUpdated);
    _animationController = AnimationController(
      vsync: this
    );
  }

  @override
  void didUpdateWidget(covariant PointerInstrumentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    valueSubscription.cancel();
    valueSubscription = widget.controller.listen(valueUpdated);
  }

  @override
  void dispose() {
    super.dispose();
    valueSubscription.cancel();
    _animationController.dispose();
  }

  void valueUpdated(double value) {
    var rad = 2 * math.pi * (value / (widget.max - widget.min)) - math.pi;
    log("Value: $value Rad: $rad");
    _animationController.animateTo(rad, duration: const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animationController.value,
              child: _buildIndicator(context)
            );
          },
        )
      ],
    );
  }
  
  Widget _buildIndicator(BuildContext context) {
    return CustomPaint(
      painter: IndicatorPainter(),
      child: Container(),
    );
  }
}

class IndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double halfHeight = size.height / 2;
    double halfWidth = size.width / 2;
    var path = new Path();
    path.moveTo(-2.5, 20);
    path.lineTo(2.5, 20);
    path.lineTo(6.0, -30);
    path.lineTo(0.5, -halfHeight + 8);
    path.lineTo(-0.5, -halfHeight + 8);
    path.lineTo(-6.0, -30);
    path.close();
    canvas.save();
    canvas.translate(halfWidth, halfHeight);

    var paint = Paint();
    paint.color = Colors.red;
    paint.style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    paint.color = Colors.black;
    canvas.drawCircle(Offset(0, 0), 6, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}