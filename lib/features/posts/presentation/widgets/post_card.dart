import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/posts/presentation/pages/post_comments_page.dart';
import 'package:social_academic/features/posts/presentation/widgets/post_images_viewer.dart';
import 'package:social_academic/shared/helpers/color_helper.dart';
import 'package:social_academic/shared/helpers/time_ago_helper.dart';
import 'package:social_academic/shared/widgets/user_avatar.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRestore;
  final VoidCallback? onForceDelete;
  final bool isArchived;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    this.onEdit,
    this.onDelete,
    this.onRestore,
    this.onForceDelete,
    this.isArchived = false,
  });

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
            if (post.images.isNotEmpty && !isArchived) ...[
              const SizedBox(height: 12),
              PostImagesViewer(images: post.images),
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
    final currentUserId = context.read<UserNotifier>().appUser?.id;
    final isCurrentUserPost = post.user.id == currentUserId;

    // Considera editado se a diferença for maior que 5 segundos.
    final bool isEdited =
        post.updatedAt.difference(post.createdAt).inSeconds > 5;

    void navigateToProfile() {
      if (isCurrentUserPost) {
        context.push('/profile');
      } else {
        context.push('/users/${post.user.id}');
      }
    }

    return Row(
      children: [
        GestureDetector(
          onTap: navigateToProfile,
          child: UserAvatar(photoUrl: post.user.photoUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: navigateToProfile,
                      child: Text(
                        post.user.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        formatTimeAgo(post.createdAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isEdited)
                        Text(
                          ' (editado)',
                          style: textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
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
        if (!isArchived && (onEdit != null || onDelete != null))
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit!();
              } else if (value == 'delete') {
                onDelete!();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Editar'),
                ),
              ),
              if (onDelete != null)
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.archive_outlined, color: Colors.red),
                    title: Text(
                      'Arquivar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        if (isArchived)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'restore') {
                onRestore?.call();
              } else if (value == 'force_delete') {
                onForceDelete?.call();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              if (onRestore != null)
                const PopupMenuItem<String>(
                  value: 'restore',
                  child: ListTile(
                    leading: Icon(Icons.unarchive_outlined),
                    title: Text('Restaurar'),
                  ),
                ),
              if (onForceDelete != null)
                const PopupMenuItem<String>(
                  value: 'force_delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.red,
                    ),
                    title: Text(
                      'Excluir Permanentemente',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
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
        if (hasTopDivider && !isArchived) const Divider(height: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFooterButton(
              context: context,
              icon: post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
              label: post.likesCount.toString(),
              onPressed: onLike,
              isActive: post.isLiked,
              disabled: isArchived,
            ),
            _buildFooterButton(
              context: context,
              icon: Icons.comment_outlined,
              label: post.commentsCount.toString(),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (sheetContext) {
                    return DraggableScrollableSheet(
                      initialChildSize: 1,
                      expand: true,
                      minChildSize: 0.3,
                      builder: (_, scrollController) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: PostCommentsPage(
                            postId: post.id,
                            scrollController: scrollController,
                          ),
                        );
                      },
                    );
                  },
                );
              },
              disabled: isArchived,
            ),
            _buildFooterButton(
              context: context,
              icon: Icons.share_outlined,
              label: 'Compartilhar',
              onPressed: () {
                final postUrl = 'https://rede-social-academica.web.app/posts/${post.id}';
                final shareText =
                    'Confira a publicação de ${post.user.name} no Social Academic!\n\n$postUrl';
                SharePlus.instance.share(
                  ShareParams(
                    text: shareText,
                    subject: 'Publicação de ${post.user.name}',
                  ),
                );
              },
              disabled: isArchived,
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
    bool disabled = false,
  }) {
    return TextButton.icon(
      onPressed: disabled ? null : onPressed,
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
