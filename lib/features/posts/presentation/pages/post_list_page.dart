import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/posts/presentation/providers/post_change_notifier.dart';
import 'package:social_academic/features/posts/presentation/widgets/post_card.dart';
import 'package:social_academic/features/posts/presentation/widgets/post_card_skeleton.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Garante que o contexto ainda é válido
      if (mounted) {
        final notifier = context.read<PostChangeNotifier>();
        // Só busca se a lista estiver vazia, para não recarregar ao trocar de aba
        if (notifier.posts.isEmpty) {
          notifier.fetchInitialPosts();
        }
        // Adiciona o listener para o scroll infinito
        _scrollController.addListener(_onScroll);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Garante que o contexto ainda é válido antes de ler o provider
      if (mounted) context.read<PostChangeNotifier>().fetchMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para o AutomaticKeepAliveClientMixin
    return Scaffold(
      body: Consumer<PostChangeNotifier>(
        builder: (context, notifier, child) {
          if (notifier.state == PostListState.loadingInitial) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => const PostCardSkeleton(),
            );
          }
      
          if (notifier.state == PostListState.error && notifier.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(notifier.errorMessage ?? 'Ocorreu um erro.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => notifier.fetchInitialPosts(),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }
      
          if (notifier.posts.isEmpty) {
            return const Center(child: Text('Nenhuma publicação encontrada.'));
          }
      
          return RefreshIndicator(
            onRefresh: () => notifier.fetchInitialPosts(),
            child: AnimationLimiter(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: notifier.posts.length + (notifier.hasMorePages ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == notifier.posts.length) {
                    return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()));
                  }
                  final post = notifier.posts[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(verticalOffset: 50.0, child: FadeInAnimation(child: ResponsiveLayout(child: PostCard(post: post, onLike: () => notifier.toggleLike(post.id))))),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/posts/create'),
        tooltip: 'Nova Publicação',
        child: const Icon(Icons.add),
      ),
    );
  }
}