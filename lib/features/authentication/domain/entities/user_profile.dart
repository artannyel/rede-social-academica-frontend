import 'package:social_academic/app/core/domain/entities/paginated_response.dart';
import 'package:social_academic/features/authentication/domain/entities/user.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';

class UserProfile {
  final User user;
  final PaginatedResponse<Post> posts;

  UserProfile({
    required this.user,
    required this.posts,
  });
}