import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:social_academic/features/courses/domain/entities/course.dart';
import 'package:social_academic/features/posts/presentation/widgets/post_card.dart';
import 'package:social_academic/features/posts/presentation/widgets/post_card_skeleton.dart';
import 'package:social_academic/features/profile/presentation/providers/archived_posts_change_notifier.dart';
import 'package:social_academic/features/profile/presentation/providers/my_posts_change_notifier.dart';
import 'package:social_academic/shared/widgets/app_snackbar.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';
import 'package:social_academic/shared/widgets/user_avatar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final _myPostsScrollController = ScrollController();
  final _archivedScrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyPostsChangeNotifier>().fetchInitialPosts();
      context.read<ArchivedPostsChangeNotifier>().fetchInitialPosts();
    });

    _myPostsScrollController.addListener(() {
      if (_myPostsScrollController.position.pixels >=
          _myPostsScrollController.position.maxScrollExtent - 200) {
        context.read<MyPostsChangeNotifier>().fetchMorePosts();
      }
    });

    _archivedScrollController.addListener(() {
      if (_archivedScrollController.position.pixels >=
          _archivedScrollController.position.maxScrollExtent - 200) {
        context.read<ArchivedPostsChangeNotifier>().fetchMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _myPostsScrollController.dispose();
    _archivedScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Arquivamento'),
          content: const Text(
              'Tem certeza de que deseja arquivar esta publicação? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text('Arquivar', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final notifier = context.read<MyPostsChangeNotifier>();
      final success = await notifier.deletePost(postId);
      if (context.mounted) {
        final message = success
            ? 'Publicação arquivada com sucesso.'
            : notifier.errorMessage ?? 'Falha ao arquivar a publicação.';
        final type = success ? SnackBarType.success : SnackBarType.error;
        showAppSnackBar(context, message: message, type: type);
      }
    }
  }

  Future<void> _confirmRestore(BuildContext context, String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Restaurar Publicação'),
        content: const Text('Deseja restaurar esta publicação para o seu perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final notifier = context.read<ArchivedPostsChangeNotifier>();
      final success = await notifier.restorePost(postId);
      if (context.mounted) {
        showAppSnackBar(
          context,
          message: success
              ? 'Publicação restaurada.'
              : notifier.errorMessage ?? 'Falha ao restaurar.',
          type: success ? SnackBarType.success : SnackBarType.error,
        );
        // Recarrega a lista de posts do perfil
        if (success) {
          context.read<MyPostsChangeNotifier>().fetchInitialPosts();
        }
      }
    }
  }

  Future<void> _confirmForceDelete(BuildContext context, String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Excluir Permanentemente'),
        content: const Text('Esta ação não pode ser desfeita. Deseja continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final notifier = context.read<ArchivedPostsChangeNotifier>();
      final success = await notifier.forceDeletePost(postId);
      if (context.mounted) {
        showAppSnackBar(context,
            message: success ? 'Publicação excluída.' : notifier.errorMessage ?? 'Falha ao excluir.',
            type: success ? SnackBarType.success : SnackBarType.error);
      }
    }
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

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
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
                SliverPersistentHeader(
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Minhas Publicações'),
                        Tab(text: 'Arquivados'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildMyPostsSection(context),
                _buildArchivedPostsSection(context),
              ],
            ),
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

  Widget _buildMyPostsSection(BuildContext context) {
    return Consumer<MyPostsChangeNotifier>(
      builder: (context, notifier, child) {
        // Estado de carregamento inicial
        if (notifier.state == MyPostsListState.loadingInitial) {
          return ListView.builder(
            itemCount: 3, // Mostra 3 skeletons enquanto carrega
            itemBuilder: (context, index) => const PostCardSkeleton());
        }

        // Estado de erro na busca inicial
        if (notifier.state == MyPostsListState.error &&
            notifier.posts.isEmpty) {
          return Center(
            child: Center(
              child: Text(
                notifier.errorMessage ?? 'Ocorreu um erro.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Lista vazia
        if (notifier.posts.isEmpty) {
          return const Center(child: Text('Você ainda não fez nenhuma publicação.'));
        }

        // Lista de posts
        return AnimationLimiter(
          child: ListView.builder(
              controller: _myPostsScrollController,
              itemCount: notifier.posts.length + (notifier.hasMorePages ? 1 : 0),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: PostCard(
                            post: post,
                            onLike: () => notifier.toggleLike(post.id),
                            onEdit: () => context.push(
                              '/posts/${post.id}/edit',
                              extra: post,
                            ),
                            onDelete: () => _confirmDelete(context, post.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        );
      },
    );
  }

  Widget _buildArchivedPostsSection(BuildContext context) {
    return Consumer<ArchivedPostsChangeNotifier>(
      builder: (context, notifier, child) {
        if (notifier.state == ArchivedPostsListState.loadingInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (notifier.state == ArchivedPostsListState.error &&
            notifier.posts.isEmpty) {
          return Center(
            child: Text(
              notifier.errorMessage ?? 'Ocorreu um erro.',
              textAlign: TextAlign.center,
            ),
          );
        }

        if (notifier.posts.isEmpty) {
          return const Center(child: Text('Você não tem publicações arquivadas.'));
        }

        return AnimationLimiter(
          child: ListView.builder(
            controller: _archivedScrollController,
            itemCount: notifier.posts.length + (notifier.hasMorePages ? 1 : 0),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: PostCard(
                          post: post,
                          onLike: () {}, // Não permite curtir post arquivado
                          isArchived: true,
                          onRestore: () => _confirmRestore(context, post.id),
                          onForceDelete: () => _confirmForceDelete(context, post.id),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
