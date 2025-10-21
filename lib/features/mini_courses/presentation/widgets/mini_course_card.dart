import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/features/mini_courses/presentation/providers/mini_course_list_change_notifier.dart';
import 'package:social_academic/shared/widgets/app_snackbar.dart';
import 'package:social_academic/shared/widgets/user_avatar.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';

class MiniCourseCard extends StatelessWidget {
  final MiniCourse miniCourse;

  const MiniCourseCard({super.key, required this.miniCourse});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentUserId = context.watch<UserNotifier>().appUser?.id;
    final isOwner = miniCourse.user?.id == currentUserId;

    return ResponsiveLayout(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/mini-courses/${miniCourse.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (miniCourse.photoUrl != null)
                Image.network(
                  miniCourse.photoUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 200,
                    child: Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      miniCourse.title,
                      style: textTheme.headlineSmall,
                    ),
                    if (miniCourse.user != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          UserAvatar(photoUrl: miniCourse.user!.photoUrl, radius: 16),
                          const SizedBox(width: 8),
                          Text(miniCourse.user!.name, style: textTheme.bodyLarge),
                        ],
                      ),
                    ]
                  ], 
                ),
              ),
              // Botão de inscrição
              if (!isOwner)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: miniCourse.isEnrolled
                      ? const Chip(
                          avatar: Icon(Icons.check_circle, color: Colors.green),
                          label: Text('Inscrito'),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            final notifier = context.read<MiniCourseListChangeNotifier>();
                            final success = await notifier.enrollInMiniCourse(miniCourse.id);
                            if (context.mounted) {
                              if (success) {
                                showAppSnackBar(
                                  context,
                                  message: 'Inscrição realizada com sucesso!',
                                  type: SnackBarType.success,
                                );
                              } else {
                                showAppSnackBar(
                                  context,
                                  message: notifier.errorMessage ?? 'Falha ao se inscrever.',
                                  type: SnackBarType.error,
                                );
                              }
                            }
                          },
                          child: const Text('Inscrever-se'),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}