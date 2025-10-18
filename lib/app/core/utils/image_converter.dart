import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:heckofaheic/heckofaheic.dart';
import 'package:path/path.dart' as p;

/// Processa uma imagem [XFile]. Se for um arquivo HEIC/HEIF, converte para JPEG.
///
/// Retorna um mapa contendo os bytes da imagem processada e o novo nome do arquivo.
Future<Map<String, dynamic>> processAndConvertImage(XFile imageFile) async {
  final imagePath = imageFile.path;
  var imageName = imageFile.name;
  Uint8List imageBytes = await imageFile.readAsBytes();

  // A conversão de HEIC só é necessária e possível em plataformas móveis.
  // Na web, os navegadores (exceto Safari) não suportam HEIC, então a conversão
  // não é viável e o upload de HEIC deve ser evitado.
  if (!kIsWeb && (p.extension(imagePath).toLowerCase() == '.heic' ||
      p.extension(imagePath).toLowerCase() == '.heif')) {
    // Converte para JPEG
    final result = await FlutterImageCompress.compressWithList(
      imageBytes,
      minHeight: 1920, // Define uma resolução máxima para otimizar o tamanho
      minWidth: 1080,
      quality: 100, // Qualidade do JPEG
      format: CompressFormat.jpeg,
    );
    imageBytes = result;
    // Altera o nome do arquivo para refletir a nova extensão
    imageName = '${p.basenameWithoutExtension(imageName)}.jpg';
  } else if (kIsWeb) {
    if (HeckOfAHeic.isHEIC(imageBytes)) {
      imageBytes = await HeckOfAHeic.convert(imageBytes);
    }
  }

  return {'bytes': imageBytes, 'name': imageName};
}
