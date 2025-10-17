import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';

/// Um widget que exibe um esqueleto de carregamento com o layout de um PostCard.
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  Widget _buildPlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white, // A cor é controlada pelo Shimmer
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final baseColor = isLight ? Colors.grey.shade200 : Colors.grey.shade800;
    final highlightColor = isLight ? Colors.grey.shade100 : Colors.grey.shade700;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ResponsiveLayout(
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  children: [
                    const CircleAvatar(backgroundColor: Colors.white, radius: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlaceholder(width: 120, height: 14),
                        const SizedBox(height: 4),
                        _buildPlaceholder(width: 80, height: 12),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Conteúdo
                _buildPlaceholder(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                _buildPlaceholder(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                _buildPlaceholder(width: 200, height: 14),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}