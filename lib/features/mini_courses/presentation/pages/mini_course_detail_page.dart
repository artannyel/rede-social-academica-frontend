import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/mini_courses/domain/entities/lesson.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/publish_mini_course.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/get_mini_course_detail.dart';
import 'package:social_academic/features/mini_courses/presentation/providers/mini_course_detail_change_notifier.dart';
import 'package:social_academic/features/mini_courses/presentation/providers/mini_course_list_change_notifier.dart';
import 'package:social_academic/shared/widgets/app_snackbar.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';
import 'package:social_academic/shared/widgets/user_avatar.dart';

class MiniCourseDetailPage extends StatelessWidget {
  final String miniCourseId;
  const MiniCourseDetailPage({super.key, required this.miniCourseId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MiniCourseDetailChangeNotifier(
        context.read<GetMiniCourseDetail>(),
        context.read<PublishMiniCourse>(),
        miniCourseId,
      )..fetchMiniCourseDetail(),
      child: const _MiniCourseDetailView(),
    );
  }
}

class _MiniCourseDetailView extends StatelessWidget {
  const _MiniCourseDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MiniCourseDetailChangeNotifier>(
        builder: (context, notifier, child) {
          if (notifier.state == MiniCourseDetailState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notifier.state == MiniCourseDetailState.error) {
            return Center(
              child: Text(notifier.errorMessage ?? 'Erro ao carregar o curso.'),
            );
          }

          if (notifier.miniCourse == null) {
            return const Center(child: Text('Curso não encontrado.'));
          }

          final miniCourse = notifier.miniCourse!;
          final textTheme = Theme.of(context).textTheme;
          final currentUserId = context.watch<UserNotifier>().appUser?.id;
          final isOwner = miniCourse.user?.id == currentUserId;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    miniCourse.title,
                    style: const TextStyle(shadows: [Shadow(blurRadius: 8)]),
                  ),
                  titlePadding: const EdgeInsets.symmetric(
                    horizontal: 72,
                    vertical: 16,
                  ),
                  background: miniCourse.photoUrl != null
                      ? Image.network(
                          miniCourse.photoUrl!,
                          fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.4),
                          colorBlendMode: BlendMode.darken,
                        )
                      : Container(color: Theme.of(context).primaryColor),
                ),
                actions: [
                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.add_box_outlined),
                      tooltip: 'Adicionar Aula',
                      onPressed: () async {
                        final newLesson = await context.push<Lesson>(
                          '/mini-courses/${miniCourse.id}/add-lesson',
                        );
                        if (newLesson != null && context.mounted) {
                          // Atualiza a UI localmente com a nova aula
                          final notifier = context
                              .read<MiniCourseDetailChangeNotifier>();
                          final currentLessons =
                              notifier.miniCourse?.lessons ?? [];
                          notifier.updateCourse(
                            notifier.miniCourse!.copyWith(
                              lessons: [...currentLessons, newLesson],
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: ResponsiveLayout(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildActionSection(context, miniCourse, isOwner),
                        const SizedBox(height: 24),
                        Text('Descrição', style: textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text(
                          miniCourse.description,
                          style: textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        if (miniCourse.user != null) ...[
                          Text('Criado por', style: textTheme.headlineSmall),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              UserAvatar(
                                photoUrl: miniCourse.user!.photoUrl,
                                radius: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                miniCourse.user!.name,
                                style: textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                        _buildLessonsSection(context, miniCourse.lessons ?? []),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLessonsSection(BuildContext context, List<Lesson> lessons) {
    if (lessons.isEmpty) {
      return const SizedBox.shrink();
    }
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aulas', style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(lesson.title),
                subtitle: Text(
                  lesson.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: lesson.youtubeUrl != null
                    ? const Icon(Icons.play_circle_outline)
                    : null,
                onTap: lesson.youtubeUrl != null
                    ?  () {
                  // TODO: Implementar navegação para a tela da aula ou abrir o vídeo
                } : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionSection(
    BuildContext context,
    MiniCourse miniCourse,
    bool isOwner,
  ) {
    if (isOwner) {
      return Center(
        child: miniCourse.isPublished
            ? const Chip(
                avatar: Icon(Icons.check_circle, color: Colors.green),
                label: Text('Publicado'),
                padding: EdgeInsets.all(12),
              )
            : ElevatedButton.icon(
                onPressed: () => _publish(context),
                icon: const Icon(Icons.publish_outlined),
                label: const Text('Publicar Curso'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
      );
    }

    // Se não for o dono, só mostra o botão de inscrição se o curso estiver publicado
    if (miniCourse.isPublished) {
      return Center(
        child: miniCourse.isEnrolled
            ? const Chip(
                avatar: Icon(Icons.check_circle, color: Colors.green),
                label: Text('Você está inscrito'),
                padding: EdgeInsets.all(12),
              )
            : ElevatedButton.icon(
                onPressed: () => _enroll(context, miniCourse),
                icon: const Icon(Icons.school_outlined),
                label: const Text('Inscrever-se no curso'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
      );
    }

    // Se não for o dono e o curso não estiver publicado, não mostra nada.
    return const SizedBox.shrink();
  }

  void _enroll(BuildContext context, MiniCourse miniCourse) async {
    final listNotifier = context.read<MiniCourseListChangeNotifier>();
    final detailNotifier = context.read<MiniCourseDetailChangeNotifier>();

    final success = await listNotifier.enrollInMiniCourse(miniCourse.id);
    if (context.mounted) {
      final message = success
          ? 'Inscrição realizada com sucesso!'
          : (listNotifier.errorMessage ?? 'Falha ao se inscrever.');
      final type = success ? SnackBarType.success : SnackBarType.error;
      showAppSnackBar(context, message: message, type: type);
      if (success) {
        detailNotifier.updateCourse(miniCourse.copyWith(isEnrolled: true));
      }
    }
  }

  void _publish(BuildContext context) async {
    final detailNotifier = context.read<MiniCourseDetailChangeNotifier>();
    final success = await detailNotifier.publishCourse();

    if (context.mounted) {
      final message = success
          ? 'Curso publicado com sucesso!'
          : (detailNotifier.errorMessage ?? 'Falha ao publicar o curso.');
      final type = success ? SnackBarType.success : SnackBarType.error;
      showAppSnackBar(context, message: message, type: type);
    }
  }
}
