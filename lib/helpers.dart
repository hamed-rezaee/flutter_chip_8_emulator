import 'dart:typed_data';

import 'package:flutter/widgets.dart';

Future<Uint8List> loadRomFromAssets(BuildContext context, String name) async {
  final AssetBundle manifestContent = DefaultAssetBundle.of(context);
  final ByteData manifestData = await manifestContent.load('roms/$name');

  return manifestData.buffer.asUint8List();
}
