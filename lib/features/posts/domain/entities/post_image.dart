/// Represents an image associated with a post.
class PostImage {
  final String id;
  final String postId;
  final String urlImage;

  const PostImage({
    required this.id,
    required this.postId,
    required this.urlImage,
  });
}