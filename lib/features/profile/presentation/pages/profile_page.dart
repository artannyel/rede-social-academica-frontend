import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:social_academic/features/courses/domain/entities/course.dart';
import 'package:social_academic/shared/widgets/user_avatar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
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
          );
        },
      ),
    );
  }

  Widget _buildCoursesSection(BuildContext context, List<Course> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meus Cursos',
          style: Theme.of(context).textTheme.titleLarge,
        ),
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
}