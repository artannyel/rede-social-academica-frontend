import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/posts/domain/usecases/get_post_by_id.dart';
import 'package:social_academic/features/posts/domain/usecases/like_post.dart';
import 'package:social_academic/features/posts/presentation/providers/post_detail_change_notifier.dart';
import 'package:social_academic/features/posts/presentation/widgets/post_card.dart';
import 'package:social_academic/features/posts/presentation/widgets/post_card_skeleton.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';

class PostDetailPage extends StatelessWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PostDetailChangeNotifier(
        getPostById: context.read<GetPostById>(),
        likePost: context.read<LikePost>(),
      )..fetchPost(postId),
      child: const _PostDetailView(),
    );
  }
}

class _PostDetailView extends StatelessWidget {
  const _PostDetailView();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PostDetailChangeNotifier>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Se puder voltar na pilha de navegação, volta.
            // Senão, navega para a home (útil para deep links).
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text('Publicação'),
      ),
      body: Center(
        child: ResponsiveLayout(
          child: _buildBody(context, notifier),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PostDetailChangeNotifier notifier) {
    switch (notifier.state) {
      case PostDetailState.loading:
      case PostDetailState.initial:
        return const PostCardSkeleton();
      case PostDetailState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(notifier.errorMessage ?? 'Ocorreu um erro ao carregar a publicação.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notifier.fetchPost(context.read<PostDetailPage>().postId),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        );
      case PostDetailState.success:
        if (notifier.post == null) {
          return const Center(child: Text('Publicação não encontrada.'));
        }
        return SingleChildScrollView(
          child: PostCard(
            post: notifier.post!,
            onLike: () => notifier.toggleLike(),
          ),
        );
    }
  }
}