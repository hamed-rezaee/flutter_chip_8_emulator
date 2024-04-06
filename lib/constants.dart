typedef OpcodeHandler = void Function(int instruction);

const int rows = 0x20;
const int columns = 0x40;
const double scale = 0x04;

const int memorySize = 0x1000;
const int registerCount = 0x0010;

const int programStartAddress = 0x0200;
const int initialStackPointerAddress = 0x0EA0;
