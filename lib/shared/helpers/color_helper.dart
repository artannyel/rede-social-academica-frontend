import 'package:flutter/material.dart';

/// Classe auxiliar para manipulação de cores.
class ColorHelper {
  /// Converte uma string de cor hexadecimal (ex: "#RRGGBB" ou "RRGGBB") em um objeto [Color].
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}