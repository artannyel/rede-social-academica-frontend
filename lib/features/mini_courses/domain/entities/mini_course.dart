import 'package:equatable/equatable.dart';
import 'package:social_academic/features/authentication/domain/entities/user.dart';
import 'package:social_academic/features/courses/domain/entities/course.dart';
import 'package:social_academic/features/mini_courses/domain/entities/lesson.dart';

class MiniCourse extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? photoUrl;
  final List<Course>? courses;
  final User? user;
  final bool isEnrolled;
  final bool isPublished;
  final List<Lesson>? lessons;

  const MiniCourse({
    required this.id,
    required this.title,
    required this.description,
    this.photoUrl,
    this.courses,
    this.user,
    this.isEnrolled = false,
    this.isPublished = false,
    this.lessons,
  });

  @override
  List<Object?> get props => [id, title, description, photoUrl, courses, user, isEnrolled, isPublished, lessons];

  MiniCourse copyWith({
    String? id,
    String? title,
    String? description,
    String? photoUrl,
    List<Course>? courses,
    User? user,
    bool? isEnrolled,
    bool? isPublished,
    List<Lesson>? lessons,
  }) {
    return MiniCourse(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      courses: courses ?? this.courses,
      user: user ?? this.user,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      isPublished: isPublished ?? this.isPublished,
      lessons: lessons ?? this.lessons,
    );
  }
}