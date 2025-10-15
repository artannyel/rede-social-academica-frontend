import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class ImagePickerField extends StatefulWidget {
  final Function(List<XFile>) onImagesSelected;

  const ImagePickerField({super.key, required this.onImagesSelected});

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageFiles = [];

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles = pickedFiles;
      });
      widget.onImagesSelected(_imageFiles);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
    widget.onImagesSelected(_imageFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Selecionar Imagens (Opcional)'),
        ),
        const SizedBox(height: 8),
        if (_imageFiles.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imageFiles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(8),
                        // Para a web, usamos Image.network com o path (que é uma URL de blob).
                        // Para mobile, usamos Image.file.
                        child: kIsWeb
                            ? Image.network(
                                _imageFiles[index].path,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(_imageFiles[index].path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
