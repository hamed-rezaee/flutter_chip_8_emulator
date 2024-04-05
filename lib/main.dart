import 'package:flutter/material.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'Chip 8 Emulator',
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child:
                Text('Chip-8 Emulator', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
}
