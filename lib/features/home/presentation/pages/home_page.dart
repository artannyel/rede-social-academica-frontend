import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/app/core/theme/theme_notifier.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:social_academic/features/posts/presentation/providers/post_change_notifier.dart';
import 'package:social_academic/features/posts/presentation/widgets/post_card.dart';
import 'package:social_academic/shared/widgets/user_avatar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Busca os posts iniciais assim que a tela é construída.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostChangeNotifier>().fetchInitialPosts();
    });

    // Adiciona um listener para o scroll para implementar o "scroll infinito".
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<PostChangeNotifier>().fetchMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Consumer<UserNotifier>(
            builder: (context, userNotifier, _) {
              return GestureDetector(
                onTap: () => context.push('/profile'),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: UserAvatar(
                    photoUrl: userNotifier.appUser?.photoUrl,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Mudar Tema',
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              // Acessa o FirebaseAuth via Provider e executa o signOut.
              // O AuthNotifier irá detectar a mudança e o GoRouter fará o redirecionamento.
              Provider.of<FirebaseAuth>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: Consumer<PostChangeNotifier>(
        builder: (context, notifier, child) {
          // Estado de carregamento inicial
          if (notifier.state == PostListState.loadingInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // Estado de erro na busca inicial
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

          // Lista de posts ou lista vazia
          if (notifier.posts.isEmpty) {
            return const Center(
              child: Text('Nenhuma publicação encontrada.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => notifier.fetchInitialPosts(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: notifier.posts.length +
                  (notifier.hasMorePages ? 1 : 0), // Adiciona espaço para o loader
              itemBuilder: (context, index) {
                // Se for o último item e ainda houver páginas, mostra o loader
                if (index == notifier.posts.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                // Renderiza o card do post
                final post = notifier.posts[index];
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: PostCard(
                      post: post,
                      onLike: () => notifier.toggleLike(post.id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/posts/create');
        },
        tooltip: 'Nova Publicação',
        child: const Icon(Icons.add),
      ),
    );
  }
}
