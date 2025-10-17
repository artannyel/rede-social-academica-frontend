import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/features/posts/domain/entities/post_image.dart';

class ImagePickerField extends StatefulWidget {
  /// Callback para notificar sobre as novas imagens selecionadas.
  final Function(List<XFile>) onImagesSelected;
  /// Lista de URLs de imagens já existentes no post.
  final List<PostImage>? existingImages;
  /// Callback para notificar quando uma imagem existente for removida.
  final Function(PostImage)? onRemoveExistingImage;

  const ImagePickerField({
    super.key,
    required this.onImagesSelected,
    this.existingImages,
    this.onRemoveExistingImage,
  });

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _newImageFiles = [];

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        // Adiciona as novas imagens às já selecionadas, evitando duplicatas.
        _newImageFiles.addAll(pickedFiles);
      });
      widget.onImagesSelected(_newImageFiles);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _newImageFiles.removeAt(index);
    });
    widget.onImagesSelected(_newImageFiles);
  }

  void _removeExistingImage(PostImage image) {
    // Chama o callback para que a página pai possa gerenciar o estado.
    widget.onRemoveExistingImage?.call(image);
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
        _buildImagePreviews(),
      ],
    );
  }

  Widget _buildImagePreviews() {
    final existing = widget.existingImages ?? [];
    final totalImages = existing.length + _newImageFiles.length;

    if (totalImages == 0) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalImages,
        itemBuilder: (context, index) {
          // Exibe as imagens existentes primeiro
          if (index < existing.length) {
            final image = existing[index];
            return _buildImagePreview(
              Image.network(image.urlImage, fit: BoxFit.cover),
              () => _removeExistingImage(image),
            );
          }
          // Depois exibe as novas imagens
          else {
            final imageFile = _newImageFiles[index - existing.length];
            final imageWidget = kIsWeb
                ? Image.network(imageFile.path, fit: BoxFit.cover)
                : Image.file(File(imageFile.path), fit: BoxFit.cover);
            return _buildImagePreview(
              imageWidget,
              () => _removeImage(index - existing.length),
            );
          }
        },
      ),
    );
  }

  Widget _buildImagePreview(Widget image, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
