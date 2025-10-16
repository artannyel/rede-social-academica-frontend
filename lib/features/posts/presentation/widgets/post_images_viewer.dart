import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Um widget que exibe as imagens de um post de forma inteligente.
/// - 1 imagem: ocupa a largura total.
/// - 2 imagens: divide a largura.
/// - 3+ imagens: mostra um grid 2x2 com um indicador de "+X" se houver mais de 4.
class PostImagesViewer extends StatelessWidget {
  final List<String> imageUrls;

  const PostImagesViewer({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (imageUrls.length == 1) {
            return _buildImage(context, imageUrls[0], 0);
          } else if (imageUrls.length == 2) {
            return Row(
              children: [
                Expanded(child: _buildImage(context, imageUrls[0], 0)),
                const SizedBox(width: 2),
                Expanded(child: _buildImage(context, imageUrls[1], 1)),
              ],
            );
          } else {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: imageUrls.length > 4 ? 4 : imageUrls.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                // Se for o último item do grid e houver mais imagens
                if (index == 3 && imageUrls.length > 4) {
                  return _buildMoreIndicator(context, index);
                }
                return _buildImage(context, imageUrls[index], index);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildImage(BuildContext context, String url, int index) {
    return GestureDetector(
      onTap: () => _showFullScreenViewer(context, index),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        // Adiciona um loader enquanto a imagem carrega
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        // Mostra um ícone de erro se a imagem falhar
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.error_outline, color: Colors.red)),
          );
        },
      ),
    );
  }

  Widget _buildMoreIndicator(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _showFullScreenViewer(context, index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(context, imageUrls[index], index),
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Text(
                '+${imageUrls.length - 4}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

/// Widget para visualização de imagens em tela cheia com um PageView.
class _FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} de ${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 50),
                  ),
                ),
              );
            },
          ),

          // Botões de navegação para a Web
          if (kIsWeb)
            Positioned(
              left: 16,
              child: AnimatedOpacity(
                opacity: _currentIndex > 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  style: _iconButtonStyle(),
                ),
              ),
            ),
          if (kIsWeb)
            Positioned(
              right: 16,
              child: AnimatedOpacity(
                opacity: _currentIndex < widget.imageUrls.length - 1 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  style: _iconButtonStyle(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  ButtonStyle _iconButtonStyle() {
    return IconButton.styleFrom(
      backgroundColor: Colors.black.withOpacity(0.4),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.all(12),
    );
  }
}