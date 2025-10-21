import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? youtubeUrl;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    this.youtubeUrl,
  });

  @override
  List<Object?> get props => [id, title, description, youtubeUrl];
}