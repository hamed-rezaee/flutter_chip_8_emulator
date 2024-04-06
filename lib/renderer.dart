import 'package:flutter/material.dart';
import 'package:flutter_chip_8_emulator/monitor.dart';

class Renderer extends CustomPainter {
  Renderer({required this.monitor});

  Monitor monitor;

  @override
  void paint(Canvas canvas, Size size) {
    monitor.draw(canvas);
  }

  @override
  bool shouldRepaint(Renderer oldDelegate) => true;
}
