import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:zcar/ui/instrument.dart';

class PointerInstrumentWidget extends StatefulWidget {
  InstrumentController controller;
  double min, max, step, startAngle, endAngle, velocity;

  PointerInstrumentWidget({
    super.key,
    required this.controller,
    required this.min,
    required this.max,
    required this.step,
    required this.startAngle,
    required this.endAngle,
    required this.velocity
  });

  @override
  State<StatefulWidget> createState() {
    return PointerInstrumentState();
  }
}

class PointerInstrumentState extends State<PointerInstrumentWidget> with SingleTickerProviderStateMixin {
  late StreamSubscription<double> valueSubscription;
  late AnimationController _animationController;
  double value = 0;

  @override
  void initState() {
    super.initState();
    valueSubscription = widget.controller.listen(valueUpdated);
    _animationController = AnimationController(
      lowerBound: 0,
      upperBound: 2 * math.pi,
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

  void valueUpdated(double value) async {
    var startRad = widget.startAngle * (math.pi / 180);
    var endRad = widget.endAngle * (math.pi / 180);
    var rad = startRad + (endRad - startRad) * value / (widget.max - widget.min);
    var diffAngle = (value - this.value) / (widget.max - widget.min) * (widget.endAngle - widget.startAngle);
    diffAngle = diffAngle.abs();
    var milli = diffAngle / widget.velocity * 1000;
    log("Value: $value Rad: $rad DiffAngle: $diffAngle Millis: $milli");
    _animationController.animateTo(rad, duration: Duration(milliseconds: milli.floor()));
    this.value = value;
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
        ),
        CustomPaint(
          painter: DivisionPainter(
              min: widget.min,
              max: widget.max,
              step: widget.step,
              startAngle: widget.startAngle,
              endAngle: widget.endAngle
          ),
          child: Container(),
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

class DivisionPainter extends CustomPainter {
  double min, max, step, startAngle, endAngle;
  
  DivisionPainter({
    required this.min,
    required this.max,
    required this.step,
    required this.startAngle,
    required this.endAngle
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    double radius = math.min(size.height, size.width) / 2;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    
    double stepAngle = (endAngle - startAngle) / ((max - min) / step);
    var paint = Paint();
    paint.color = Colors.black;
    for (var currentAngle = startAngle; currentAngle <= endAngle; currentAngle += stepAngle) {
      var currentRad = currentAngle * (math.pi / 180);
      var ax = -radius * math.sin(currentRad);
      var ay = radius * math.cos(currentRad);
      var bx = -(radius - 20) * math.sin(currentRad);
      var by = (radius - 20) * math.cos(currentRad);
      canvas.drawLine(Offset(ax, ay), Offset(bx, by), paint);
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}

class IndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double halfHeight = size.height / 2;
    double halfWidth = size.width / 2;
    var path = new Path();
    path.moveTo(-2.5, -20);
    path.lineTo(2.5, -20);
    path.lineTo(6.0, 30);
    path.lineTo(0.5, halfHeight - 8);
    path.lineTo(-0.5, halfHeight - 8);
    path.lineTo(-6.0, 30);
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