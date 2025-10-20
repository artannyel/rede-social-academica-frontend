import 'package:equatable/equatable.dart';
import 'package:social_academic/features/courses/domain/entities/course.dart';

class MiniCourse extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? photoUrl;
  final List<Course>? courses;

  const MiniCourse({
    required this.id,
    required this.title,
    required this.description,
    this.photoUrl,
    this.courses,
  });

  @override
  List<Object?> get props => [id, title, description, photoUrl, courses];
}