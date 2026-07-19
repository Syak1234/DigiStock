import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('writes marker', () async {
    final directory = Directory(
      '/Users/sayakmishra/Sayak_Flutter_Project/product_inventory/assets/readme',
    );
    await directory.create(recursive: true);
    await File('${directory.path}/debug-marker.txt').writeAsString('ok\n');
  });
}
