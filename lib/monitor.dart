import 'package:flutter/material.dart';
import 'package:flutter_chip_8_emulator/constants.dart';

class Monitor {
  final List<bool> buffer = List<bool>.filled(rows * columns, true);

  void draw(Canvas canvas) {
    final Paint paint = Paint();

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        canvas.drawRect(
          Rect.fromLTWH(x * scale, y * scale, scale, scale),
          paint..color = buffer[y * columns + x] ? Colors.black : Colors.white,
        );
      }
    }
  }

  bool setPixel(int x, int y) {
    final int clampedX = x.clamp(0, columns - 1);
    final int clampedY = y.clamp(0, rows - 1);

    return buffer[clampedY * columns + clampedX] ^= true;
  }

  void clear() => buffer.fillRange(0, buffer.length, true);
}
