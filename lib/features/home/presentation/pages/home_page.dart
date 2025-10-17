import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/app/core/theme/theme_notifier.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:social_academic/features/posts/presentation/providers/post_change_notifier.dart';
import 'package:social_academic/features/posts/presentation/widgets/post_card.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostChangeNotifier>().fetchInitialPosts();
    });

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
              Provider.of<FirebaseAuth>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: Consumer<PostChangeNotifier>(
        builder: (context, notifier, child) {
          if (notifier.state == PostListState.loadingInitial) {
            return const Center(child: CircularProgressIndicator());
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
            return const Center(
              child: Text('Nenhuma publicação encontrada.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => notifier.fetchInitialPosts(),
            child: AnimationLimiter(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: notifier.posts.length +
                    (notifier.hasMorePages
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  if (index == notifier.posts.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final post = notifier.posts[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: ResponsiveLayout(
                          child: PostCard(
                            post: post,
                            onLike: () => notifier.toggleLike(post.id),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
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
