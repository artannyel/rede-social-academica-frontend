import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/courses/domain/entities/course.dart';
import 'package:social_academic/features/posts/presentation/widgets/post_card.dart';
import 'package:social_academic/features/profile/presentation/providers/user_profile_change_notifier.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';
import 'package:social_academic/shared/widgets/user_avatar.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          UserProfileChangeNotifier(context.read(), context.read(), userId),
      child: _UserProfileView(userId: userId),
    );
  }
}

class _UserProfileView extends StatefulWidget {
  final String userId;
  const _UserProfileView({required this.userId});

  @override
  State<_UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<_UserProfileView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileChangeNotifier>().fetchInitialProfile();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<UserProfileChangeNotifier>().fetchMorePosts();
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
          if (notifier.user == null && notifier.state != UserProfileState.error) {
            return const Center(child: CircularProgressIndicator());
          }

          // Mostra o erro apenas se o usuário for nulo E o estado for de erro.
          if (notifier.user == null && notifier.state == UserProfileState.error) {
            return Center(
              child: Text(
                notifier.errorMessage ?? 'Não foi possível carregar o perfil.',
              ),
            );
          }

          final user = notifier.user!;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
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
              SliverToBoxAdapter(
                child: ResponsiveLayout(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Publicações',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
              ),
              _buildPostsSectionSliver(context, notifier),
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

  Widget _buildPostsSectionSliver(
    BuildContext context,
    UserProfileChangeNotifier notifier,
  ) {
    if (notifier.posts.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text('Este usuário ainda não fez nenhuma publicação.'),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == notifier.posts.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final post = notifier.posts[index];
        return ResponsiveLayout(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: PostCard(
              post: post,
              onLike: () => notifier.toggleLike(post.id),
            ),
          ),
        );
      }, childCount: notifier.posts.length + (notifier.hasMorePages ? 1 : 0)),
    );
  }
}
