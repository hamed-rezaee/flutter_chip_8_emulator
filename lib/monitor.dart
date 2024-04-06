import 'package:flutter/material.dart';
import 'package:flutter_chip_8_emulator/constants.dart';

class Monitor {
  final List<bool> buffer = List.filled(rows * columns, true);

  void draw(Canvas canvas) {
    final paint = Paint();

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        canvas.drawRect(
          Rect.fromLTWH(x * scale, y * scale, scale, scale),
          paint..color = buffer[y * columns + x] ? Colors.black : Colors.white,
        );
      }
    }
  }

  setPixel(int x, int y) {
    x = x.clamp(0, columns - 1);
    y = y.clamp(0, rows - 1);

    buffer[y * columns + x] ^= true;

    return buffer[y * columns + x];
  }

  void clear() => buffer.fillRange(0, buffer.length, true);
}
