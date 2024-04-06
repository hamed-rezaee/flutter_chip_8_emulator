import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_chip_8_emulator/constants.dart';
import 'package:flutter_chip_8_emulator/keyboard.dart';
import 'package:flutter_chip_8_emulator/monitor.dart';

class Chip8 {
  Chip8({required this.monitor, required this.keyboard, this.speed = 10});

  final Monitor monitor;
  final Keyboard keyboard;
  final double speed;

  int _pc = programStartAddress;
  int _ir = 0x0000;

  final Uint8List _memory = Uint8List(memorySize);
  final Uint8List _v = Uint8List(registerCount);
  final List<int> _stack = [];

  int _delayTimer = 0;
  int _soundTimer = 0;
  bool _isPaused = false;

  void step(int instruction) {
    _pc += 2;

    final int x = (instruction & 0x0F00) >> 8;
    final int y = (instruction & 0x00F0) >> 4;

    switch (instruction & 0xF000) {
      case 0x0000:
        switch (instruction) {
          case 0x00E0:
            monitor.clear();
            break;
          case 0x00EE:
            _pc = _stack.removeLast();
            break;
        }
        break;
      case 0x1000:
        _pc = instruction & 0x0FFF;
        break;
      case 0x2000:
        _stack.add(_pc);
        _pc = instruction & 0x0FFF;
        break;
      case 0x3000:
        if (_v[x] == (instruction & 0x00FF)) {
          _pc += 2;
        }
        break;
      case 0x4000:
        if (_v[x] != (instruction & 0x00FF)) {
          _pc += 2;
        }
        break;
      case 0x5000:
        if (_v[x] == _v[y]) {
          _pc += 2;
        }
        break;
      case 0x6000:
        _v[x] = (instruction & 0x00FF);
        break;
      case 0x7000:
        _v[x] += (instruction & 0x00FF);
        break;
      case 0x8000:
        switch (instruction & 0x000F) {
          case 0x0000:
            _v[x] = _v[y];
            break;
          case 0x0001:
            _v[x] |= _v[y];
            break;
          case 0x0002:
            _v[x] &= _v[y];
            break;
          case 0x0003:
            _v[x] ^= _v[y];
            break;
          case 0x0004:
            final int sum = _v[x] + _v[y];
            _v[0xF] = sum > 0xFF ? 1 : 0;
            _v[x] = sum & 0xFF;
            break;
          case 0x0005:
            _v[0xF] = _v[x] > _v[y] ? 1 : 0;
            _v[x] -= _v[y];
            break;
          case 0x0006:
            _v[0xF] = _v[x] & 0x1;
            _v[x] = _v[x] >> 1;
            break;
          case 0x0007:
            _v[0xF] = _v[y] > _v[x] ? 1 : 0;
            _v[x] = _v[y] - _v[x];
            break;
          case 0x000E:
            _v[0xF] = _v[x] & 0x80;
            _v[x] <<= 1;
            break;

          default:
            throw Exception('BAD OPCODE');
        }
        break;
      case 0x9000:
        if (_v[x] != _v[y]) {
          _pc += 2;
        }
        break;
      case 0xA000:
        _ir = instruction & 0x0FFF;
        break;
      case 0xB000:
        _pc = (instruction & 0x0FFF) + _v[0];
        break;
      case 0xC000:
        _v[x] = (Random().nextInt(0xFF) & (instruction & 0xFF));
        break;
      case 0xD000:
        int width = 8;
        int height = instruction & 0x000F;

        _v[0xF] = 0;

        for (int row = 0; row < height; row++) {
          int spriteByte = _memory[_ir + row];

          for (int column = 0; column < width; column++) {
            if ((spriteByte & 0x80) > 0) {
              if (monitor.setPixel(_v[x] + column, _v[y] + row)) {
                _v[0xF] = 1;
              }
            }

            spriteByte <<= 1;
          }
        }
        break;
      case 0xE000:
        switch (instruction & 0x00FF) {
          case 0x009E:
            if (keyboard.isKeyPressed(_v[x])) {
              _pc += 2;
            }
            break;
          case 0x00A1:
            if (!keyboard.isKeyPressed(_v[x])) {
              _pc += 2;
            }
            break;

          default:
            throw Exception('BAD OPCODE');
        }
        break;
      case 0xF000:
        switch (instruction & 0x00FF) {
          case 0x0007:
            _v[x] = _delayTimer;
            break;
          case 0x000A:
            _isPaused = true;

            keyboard.onKeyPress = (key) {
              _v[x] = key;
              _isPaused = false;
            };

            break;
          case 0x0015:
            _delayTimer = _v[x];
            break;
          case 0x0018:
            _soundTimer = _v[x];
            break;
          case 0x001E:
            _ir += _v[x];
            break;
          case 0x0029:
            _ir = _v[x] * 5;
            break;
          case 0x0033:
            _memory[_ir] = _v[x] ~/ 100;
            _memory[_ir + 1] = (_v[x] % 100) ~/ 10;
            _memory[_ir + 2] = _v[x] % 10;
            break;
          case 0x0055:
            for (int i = 0; i <= x; i++) {
              _memory[_ir + i] = _v[i];
            }
            break;
          case 0x0065:
            for (int i = 0; i <= x; i++) {
              _v[i] = _memory[_ir + i];
            }
            break;

          default:
            throw Exception('0xF BAD OPCODE $instruction');
        }
        break;

      default:
        throw Exception('BAD OPCODE');
    }
  }

  void cpuCycle() {
    for (int i = 0; i < speed; i++) {
      if (!_isPaused) {
        int instruction = _memory[_pc] << 8 | _memory[_pc + 1];
        step(instruction);
      }
    }

    if (!_isPaused) {
      updateTimers();
    }
  }

  void loadSpritsIntoMemory() {
    const sprites = [
      0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
      0x20, 0x60, 0x20, 0x20, 0x70, // 1
      0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
      0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
      0x90, 0x90, 0xF0, 0x10, 0x10, // 4
      0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
      0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
      0xF0, 0x10, 0x20, 0x40, 0x40, // 7
      0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
      0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
      0xF0, 0x90, 0xF0, 0x90, 0x90, // A
      0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
      0xF0, 0x80, 0x80, 0x80, 0xF0, // C
      0xE0, 0x90, 0x90, 0x90, 0xE0, // D
      0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
      0xF0, 0x80, 0xF0, 0x80, 0x80, // F
    ];

    for (int i = 0; i < sprites.length; i++) {
      _memory[i] = sprites[i];
    }
  }

  void loadProgramIntoMemory(List<int> program) {
    for (int i = 0; i < program.length; i++) {
      _memory[programStartAddress + i] = program[i];
    }
  }

  void updateTimers() {
    if (_delayTimer > 0) {
      _delayTimer--;
    }

    if (_soundTimer > 0) {
      _soundTimer--;
    }
  }
}
