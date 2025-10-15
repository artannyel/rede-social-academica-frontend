import 'package:social_academic/features/posts/domain/entities/tag.dart';

class TagModel extends Tag {
  const TagModel({
    required super.id,
    required super.name,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'].toString(), // Garante que o ID seja sempre uma string
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
