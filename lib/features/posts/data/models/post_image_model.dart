import 'package:social_academic/features/posts/domain/entities/post_image.dart';

class PostImageModel extends PostImage {
  const PostImageModel({
    required super.id,
    required super.postId,
    required super.urlImage,
  });

  factory PostImageModel.fromJson(Map<String, dynamic> json) {
    return PostImageModel(
      id: json['id'],
      postId: json['post_id'],
      urlImage: json['url_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'post_id': postId, 'url_image': urlImage};
  }
}