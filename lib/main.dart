import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chip_8_emulator/chip_8.dart';
import 'package:flutter_chip_8_emulator/constants.dart';
import 'package:flutter_chip_8_emulator/keyboard.dart';
import 'package:flutter_chip_8_emulator/monitor.dart';
import 'package:flutter_chip_8_emulator/renderer.dart';

import 'helpers.dart';

void main() => runApp(const MainApp());

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final Chip8 chip8 = Chip8(monitor: Monitor(), keyboard: Keyboard());

  final fps = 60;
  late final Duration fpsInterval;
  late final DateTime startTime;
  late DateTime now;
  late DateTime then;
  late Duration elapsed;

  @override
  void initState() {
    super.initState();

    loadRomFromAssets(context, 'brick.ch8').then(
      (program) {
        fpsInterval = Duration(milliseconds: 1000 ~/ fps);
        startTime = DateTime.now();
        then = startTime;

        chip8.loadSpritsIntoMemory();
        chip8.loadProgramIntoMemory(program);

        Timer.periodic(fpsInterval, (timer) {
          now = DateTime.now();
          elapsed = now.difference(then);

          if (elapsed.inMilliseconds >= fpsInterval.inMilliseconds) {
            chip8.cpuCycle();
          }

          then = now;

          setState(() {});
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) => KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKeyboardEvent,
        child: MaterialApp(
          title: 'Chip 8 Emulator',
          home: Scaffold(
            backgroundColor: Colors.black,
            body: Padding(
              padding: const EdgeInsets.all(8),
              child: CustomPaint(
                size: const Size(rows * scale, columns * scale),
                painter: Renderer(monitor: chip8.monitor),
              ),
            ),
          ),
        ),
      );

  void _handleKeyboardEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      chip8.keyboard.onKeyDown(event);
    } else if (event is KeyUpEvent) {
      chip8.keyboard.onKeyUp(event);
    }
  }
}
