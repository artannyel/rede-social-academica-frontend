import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';

/// Um widget que exibe um esqueleto de carregamento com o layout de um CommentCard.
class CommentCardSkeleton extends StatelessWidget {
  const CommentCardSkeleton({super.key});

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
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(backgroundColor: Colors.white, radius: 16),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlaceholder(width: 100, height: 12),
                        const SizedBox(height: 4),
                        _buildPlaceholder(width: 70, height: 10),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPlaceholder(width: double.infinity, height: 12),
                const SizedBox(height: 6),
                _buildPlaceholder(width: 150, height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}