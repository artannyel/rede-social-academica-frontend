import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:social_academic/features/courses/domain/entities/course.dart';
import 'package:social_academic/features/posts/presentation/widgets/post_card.dart';
import 'package:social_academic/features/profile/presentation/providers/my_posts_change_notifier.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';
import 'package:social_academic/shared/widgets/user_avatar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Busca os posts do usuário assim que a tela é construída.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyPostsChangeNotifier>().fetchInitialPosts();
    });

    // Adiciona o listener para carregar mais posts ao chegar no final da página.
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<MyPostsChangeNotifier>().fetchMorePosts();
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
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar Perfil',
            onPressed: () {
              context.push('/profile/edit');
            },
          ),
        ],
      ),
      body: Consumer<UserNotifier>(
        builder: (context, userNotifier, child) {
          final user = userNotifier.appUser;

          if (userNotifier.isLoading && user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (user == null) {
            return const Center(
              child: Text('Não foi possível carregar os dados do usuário.'),
            );
          }

          // A CustomScrollView agora é o widget raiz do corpo, ocupando toda a tela.
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // O conteúdo do perfil é centralizado e constrangido dentro do Sliver.
              SliverToBoxAdapter(
                child: ResponsiveLayout(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        UserAvatar(photoUrl: user.photoUrl, radius: 60),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (user.bio != null && user.bio!.isNotEmpty)
                          Text(
                            user.bio!,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        if (user.courses != null && user.courses!.isNotEmpty)
                          _buildCoursesSection(context, user.courses!),
                      ],
                    ),
                  ),
                ),
              ),
              // Adiciona o título "Minhas Publicações" como um sliver separado
              SliverToBoxAdapter(
                child: ResponsiveLayout(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Minhas Publicações',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
              ),
              // A seção de posts também será centralizada e constrangida internamente.
              _buildMyPostsSectionSliver(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCoursesSection(BuildContext context, List<Course> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Meus Cursos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ...courses.map((course) {
          final status = course.finished ?? false
              ? 'Formado'
              : '${course.currentSemester}º Semestre';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(course.name),
              subtitle: Text(course.courseLevel?.name ?? ''),
              trailing: Text(status),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMyPostsSectionSliver(BuildContext context) {
    return Consumer<MyPostsChangeNotifier>(
      builder: (context, notifier, child) {
        // Estado de carregamento inicial
        if (notifier.state == MyPostsListState.loadingInitial) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Estado de erro na busca inicial
        if (notifier.state == MyPostsListState.error &&
            notifier.posts.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(notifier.errorMessage ?? 'Ocorreu um erro.'),
            ),
          );
        }

        // Lista vazia
        if (notifier.posts.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Text('Você ainda não fez nenhuma publicação.'),
            ),
          );
        }

        // Lista de posts
        return AnimationLimiter(
          child: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: PostCard(
                            post: post,
                            onLike: () => notifier.toggleLike(post.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount:
                  notifier.posts.length + (notifier.hasMorePages ? 1 : 0),
            ),
          ),
        );
      },
    );
  }
}
