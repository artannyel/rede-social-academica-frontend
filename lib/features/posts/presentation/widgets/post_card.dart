import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/shared/helpers/color_helper.dart';
import 'package:social_academic/features/posts/presentation/widgets/post_images_viewer.dart';
import 'package:social_academic/shared/widgets/user_avatar.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;

  const PostCard({super.key, required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            if (post.tags.isNotEmpty) ...[
              _buildTags(context),
              const SizedBox(height: 12),
            ],
            Text(
              post.publication,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              PostImagesViewer(imageUrls: post.images),
            ],
            const SizedBox(height: 8),
            _buildFooter(context, hasTopDivider: post.images.isEmpty),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        UserAvatar(photoUrl: post.user.photoUrl),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      post.user.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat(
                      'dd/MM/yyyy \'às\' HH:mm',
                    ).format(post.createdAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              // Text(
              //   DateFormat('dd/MM/yyyy \'às\' HH:mm').format(post.createdAt),
              //   style: textTheme.bodySmall?.copyWith(
              //     color: Theme.of(context).colorScheme.onSurfaceVariant,
              //   ),
              // ),
              ...post.user.courses
                      ?.map(
                        (course) => Text(
                          '${course.name} - ${course.finished ?? false ? 'Formado' : '${course.currentSemester}º Semestre'}',
                          style: textTheme.bodySmall,
                        ),
                      )
                      .toList() ??
                  [],
            ],
          ),
        ),
        // IconButton(
        //   icon: const Icon(Icons.more_vert),
        //   onPressed: () {
        //     // TODO: Implementar menu de opções do post
        //   },
        // ),
      ],
    );
  }

  Widget _buildTags(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: post.tags.map((tag) {
        // No tema claro, inverte as cores para um chip de cor sólida e texto claro.
        // No tema escuro, mantém o fundo claro para contrastar com o fundo do card.
        final chipBackgroundColor = isLight
            ? ColorHelper.fromHex(tag.textColor)
            : ColorHelper.fromHex(tag.bgColor);
        final chipTextColor = isLight
            ? ColorHelper.fromHex(tag.bgColor)
            : ColorHelper.fromHex(tag.textColor);

        return Chip(
          label: Text(
            tag.name,
            style: TextStyle(color: chipTextColor, fontWeight: FontWeight.bold),
          ),
          backgroundColor: chipBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          side: BorderSide(color: chipBackgroundColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context, {bool hasTopDivider = true}) {
    return Column(
      children: [
        if (hasTopDivider) const Divider(height: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFooterButton(
              context: context,
              icon: post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
              label: post.likesCount.toString(),
              onPressed: onLike,
              isActive: post.isLiked,
            ),
            _buildFooterButton(
              context: context,
              icon: Icons.comment_outlined,
              label: post.commentsCount.toString(),
              onPressed: () {
                context.push('/posts/${post.id}/comments');
              },
            ),
            _buildFooterButton(
              context: context,
              icon: Icons.share_outlined,
              label: 'Compartilhar',
              onPressed: () {
                // TODO: Implementar lógica de compartilhar
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        foregroundColor: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
