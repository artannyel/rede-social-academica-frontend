import 'package:social_academic/features/posts/domain/entities/post_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PostImageModel extends PostImage {
  const PostImageModel({
    required super.id,
    required super.postId,
    required super.urlImage,
  });

  factory PostImageModel.fromJson(Map<String, dynamic> json) {
    final String baseUrl = dotenv.env['STORAGE_BASE_URL'] ?? '';
    final String relativeUrl = json['url_image'] ?? '';

    // Constrói a URL completa da imagem.
    final String fullUrl = relativeUrl.isNotEmpty ? '$baseUrl/$relativeUrl' : '';

    return PostImageModel(
      id: json['id'],
      postId: json['post_id'],
      urlImage: fullUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'post_id': postId, 'url_image': urlImage};
  }
}