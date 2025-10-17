import 'package:social_academic/app/core/data/models/paginated_response.dart';
import 'package:social_academic/features/authentication/data/models/user_model.dart';
import 'package:social_academic/features/authentication/domain/entities/user_profile.dart';
import 'package:social_academic/features/posts/data/models/post_model.dart';

class UserProfileModel {
  UserProfileModel({
    required this.user,
    required this.posts,
  });
  final UserModel user;
  final PaginatedResponse<PostModel> posts;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      user: UserModel.fromJson(json['user']),
      posts: PaginatedResponse.fromJson(
        json['posts'],
        PostModel.fromJson,
      ),
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      user: user, // UserModel é um subtipo de User, então a atribuição é válida.
      posts: posts.toEntity(),
    );
  }
}