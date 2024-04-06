import 'package:flutter/services.dart';

class Keyboard {
  int? keysPressed;
  Function(int)? onKeyPress;

  void onKeyDown(KeyDownEvent event) {
    int? key = _keyMap[event.logicalKey];

    if (key != null) {
      keysPressed = key;

      onKeyPress?.call(key);
    }
  }

  void onKeyUp(KeyUpEvent event) => keysPressed = null;

  bool isKeyPressed(int keyCode) => keysPressed == keyCode;
}

final Map<LogicalKeyboardKey, int> _keyMap = {
  LogicalKeyboardKey.digit1: 0x01,
  LogicalKeyboardKey.digit2: 0x02,
  LogicalKeyboardKey.digit3: 0x03,
  LogicalKeyboardKey.digit4: 0x0C,
  LogicalKeyboardKey.keyQ: 0x04,
  LogicalKeyboardKey.keyW: 0x05,
  LogicalKeyboardKey.keyE: 0x06,
  LogicalKeyboardKey.keyR: 0x0D,
  LogicalKeyboardKey.keyA: 0x07,
  LogicalKeyboardKey.keyS: 0x08,
  LogicalKeyboardKey.keyD: 0x09,
  LogicalKeyboardKey.keyF: 0x0E,
  LogicalKeyboardKey.keyZ: 0x0A,
  LogicalKeyboardKey.keyX: 0x00,
  LogicalKeyboardKey.keyC: 0x0B,
  LogicalKeyboardKey.keyV: 0x0F,
};
