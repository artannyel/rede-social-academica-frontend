import 'package:flutter/material.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/shared/widgets/user_avatar.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';

class MiniCourseCard extends StatelessWidget {
  final MiniCourse miniCourse;

  const MiniCourseCard({super.key, required this.miniCourse});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ResponsiveLayout(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
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
          ],
        ),
      ),
    );
  }
}