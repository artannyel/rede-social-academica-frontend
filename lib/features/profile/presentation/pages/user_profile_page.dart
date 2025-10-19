import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/courses/domain/entities/course.dart';
import 'package:social_academic/features/posts/presentation/widgets/post_card.dart';
import 'package:social_academic/features/posts/presentation/widgets/post_card_skeleton.dart';
import 'package:social_academic/features/profile/presentation/providers/user_ratings_change_notifier.dart';
import 'package:social_academic/features/profile/presentation/providers/user_profile_change_notifier.dart';
import 'package:social_academic/shared/widgets/app_snackbar.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:social_academic/shared/helpers/time_ago_helper.dart';
import 'package:social_academic/shared/widgets/user_avatar.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProfileChangeNotifier(
        context.read(),
        context.read(),
        context.read(),
        userId,
      ),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) =>
                UserRatingsChangeNotifier(context.read(), userId),
          ),
        ],
        child: _UserProfileView(userId: userId),
      ),
    );
  }
}

class _UserProfileView extends StatefulWidget {
  final String userId;
  const _UserProfileView({required this.userId});

  @override
  State<_UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<_UserProfileView>
    with SingleTickerProviderStateMixin {
  final _postsScrollController = ScrollController();
  final _ratingsScrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileChangeNotifier>().fetchInitialProfile();
      context.read<UserRatingsChangeNotifier>().fetchInitialRatings();
    });

    _postsScrollController.addListener(() {
      if (_postsScrollController.position.pixels >=
          _postsScrollController.position.maxScrollExtent - 200) {
        context.read<UserProfileChangeNotifier>().fetchMorePosts();
      }
    });

    _ratingsScrollController.addListener(() {
      if (_ratingsScrollController.position.pixels >=
          _ratingsScrollController.position.maxScrollExtent - 200) {
        context.read<UserRatingsChangeNotifier>().fetchMoreRatings();
      }
    });
  }

  @override
  void dispose() {
    _postsScrollController.dispose();
    _ratingsScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showRatingDialog(
    BuildContext pageContext,
    UserProfileChangeNotifier notifier,
  ) {
    int rating = notifier.userProfile?.currentUserRating?.rate ?? 0;
    final messageController = TextEditingController(
      text: notifier.userProfile?.currentUserRating?.message ?? '',
    );
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: pageContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                notifier.userProfile?.currentUserRating != null
                    ? 'Editar Avaliação'
                    : 'Avaliar Usuário',
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Selecione sua nota:'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () {
                              setDialogState(() => rating = index + 1);
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: messageController,
                        decoration: const InputDecoration(
                          labelText: 'Mensagem (Opcional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: rating == 0 || isSubmitting
                      ? null
                      : () async {
                          setDialogState(() => isSubmitting = true);
                          final success = await notifier.submitRating(
                            rate: rating,
                            message: messageController.text,
                          );
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                            showAppSnackBar(
                              pageContext,
                              message: success
                                  ? 'Avaliação enviada com sucesso!'
                                  : (notifier.errorMessage ??
                                        'Falha ao enviar avaliação.'),
                              type: success
                                  ? SnackBarType.success
                                  : SnackBarType.error,
                            );
                            // Recarrega o perfil para atualizar a média e a avaliação do usuário atual
                            if (success) notifier.fetchInitialProfile();
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRatingDisplay(
    BuildContext context,
    double? avgRate,
    int? count,
  ) {
    // Não mostra nada se não houver avaliações
    if (avgRate == null || count == null || count == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(
          avgRate.toStringAsFixed(1), // Formata para uma casa decimal
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          '($count ${count == 1 ? "avaliação" : "avaliações"})',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<UserProfileChangeNotifier>(
          builder: (context, notifier, _) {
            return Text(notifier.user?.name ?? 'Perfil');
          },
        ),
      ),
      body: Consumer<UserProfileChangeNotifier>(
        builder: (context, notifier, child) {
          // Mostra o loader se o usuário for nulo E o estado não for de erro.
          // Isso cobre tanto o estado 'idle' inicial quanto o 'loading'.
          if (notifier.user == null &&
              notifier.state != UserProfileState.error) {
            return const Center(child: CircularProgressIndicator());
          }

          // Mostra o erro apenas se o usuário for nulo E o estado for de erro.
          if (notifier.user == null &&
              notifier.state == UserProfileState.error) {
            return Center(
              child: Text(
                notifier.errorMessage ?? 'Não foi possível carregar o perfil.',
              ),
            );
          }

          final user = notifier.user!;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
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
                          const SizedBox(height: 16),
                          _buildRatingDisplay(
                            context,
                            user.receivedRatingsAvgRate,
                            user.receivedRatingsCount,
                          ),
                          const SizedBox(height: 16),
                          Consumer<UserProfileChangeNotifier>(
                            builder: (context, notifier, _) {
                              final hasRated =
                                  notifier.userProfile?.currentUserRating !=
                                  null;
                              return OutlinedButton.icon(
                                onPressed: () {
                                  _showRatingDialog(context, notifier);
                                },
                                icon: Icon(
                                  hasRated ? Icons.star : Icons.star_outline,
                                ),
                                label: Text(
                                  hasRated
                                      ? 'Editar Avaliação'
                                      : 'Avaliar Usuário',
                                ),
                              );
                            },
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
                        Tab(text: 'Publicações'),
                        Tab(text: 'Avaliações'),
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
                _buildPostsSection(context, notifier),
                _buildRatingsSection(context),
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
        Text('Cursos', style: Theme.of(context).textTheme.titleLarge),
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

  Widget _buildPostsSection(
    BuildContext context,
    UserProfileChangeNotifier notifier,
  ) {
    // Mostra o skeleton se estiver carregando os posts pela primeira vez
    if (notifier.state == UserProfileState.loading && notifier.posts.isEmpty) {
      return ListView.builder(
        itemBuilder: (context, index) => const PostCardSkeleton(),
        itemCount: 3,
      );
    }

    if (notifier.posts.isEmpty) {
      return const Center(
        child: Text('Este usuário ainda não fez nenhuma publicação.'),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        controller: _postsScrollController,
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
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: notifier.posts.length + (notifier.hasMorePages ? 1 : 0),
      ),
    );
  }

  Widget _buildRatingsSection(BuildContext context) {
    return Consumer<UserRatingsChangeNotifier>(
      builder: (context, notifier, _) {
        if (notifier.state == UserRatingsState.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (notifier.state == UserRatingsState.error) {
          return Center(
            child: Text(
              notifier.errorMessage ?? 'Erro ao carregar avaliações.',
            ),
          );
        }
        if (notifier.ratings.isEmpty) {
          return const Center(
            child: Text('Este usuário ainda não recebeu avaliações.'),
          );
        }

        return AnimationLimiter(
          child: ListView.builder(
            controller: _ratingsScrollController,
            itemCount:
                notifier.ratings.length + (notifier.hasMorePages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == notifier.ratings.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final rating = notifier.ratings[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: ResponsiveLayout(
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  UserAvatar(
                                    photoUrl: rating.evaluatingUser?.photoUrl,
                                    radius: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      rating.evaluatingUser?.name ??
                                          'Usuário Anônimo',
                                      style:
                                          Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < rating.rate
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (rating.message != null &&
                                  rating.message!.isNotEmpty)
                                const Divider(height: 24),
                              if (rating.message != null &&
                                  rating.message!.isNotEmpty) ...[
                                Text(rating.message!),
                              ],
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  formatTimeAgo(rating.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
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
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}
