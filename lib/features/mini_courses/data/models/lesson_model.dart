import 'package:social_academic/features/mini_courses/domain/entities/lesson.dart';

class LessonModel extends Lesson {
  const LessonModel({
    required super.id,
    required super.title,
    required super.description,
    super.youtubeUrl,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      youtubeUrl: json['youtube_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'youtube_url': youtubeUrl,
    };
  }

  Lesson toEntity() {
    return Lesson(
      id: id,
      title: title,
      description: description,
      youtubeUrl: youtubeUrl,
    );
  }
}