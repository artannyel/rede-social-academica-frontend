import 'package:social_academic/features/posts/domain/entities/tag.dart';

class TagModel extends Tag {
  const TagModel({
    required super.id,
    required super.name,
    required super.bgColor,
    required super.textColor,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'].toString(), // Garante que o ID seja sempre uma string
      name: json['name'],
      bgColor: json['bg_color'],
      textColor: json['text_color'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bg_color': bgColor,
    'text_color': textColor,
  };
}
