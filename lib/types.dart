class Uint8 {
  int get value => _value;

  void set(int value) {
    if (_value < 0 || _value > 0xff) {
      throw Exception("Uint8 overflow");
    }

    _value = value;
  }

  int _value = 0;
}

class Uint16 {
  int get value => _value;

  void set(int value) {
    if (_value < 0 || _value > 0xffff) {
      throw Exception("Uint16 overflow");
    }

    _value = value;
  }

  int _value = 0;
}

class Uint32 {
  int get value => _value;

  void set(int value) {
    if (_value < 0 || _value > 0xffffffff) {
      throw Exception("Uint32 overflow");
    }

    _value = value;
  }

  int _value = 0;
}

class Uint64 {
  int get value => _value;

  void set(int value) {
    if (_value < 0 || _value > 0xffffffffffffffff) {
      throw Exception("Uint64 overflow");
    }

    _value = value;
  }

  int _value = 0;
}
