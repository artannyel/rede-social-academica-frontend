import 'package:social_academic/features/authentication/data/models/user_model.dart';
import 'package:social_academic/features/authentication/domain/entities/user_rating.dart';

class UserRatingModel extends UserRating {
  const UserRatingModel({
    required super.id,
    required super.rate,
    super.message,
    required super.createdAt,
    required super.updatedAt,
    UserModel? super.ratedUser,
    UserModel? super.evaluatingUser,
  });

  factory UserRatingModel.fromJson(Map<String, dynamic> json) {
    return UserRatingModel(
      id: json['id'],
      rate: json['rate'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
      ratedUser: json['rated_user'] != null
          ? UserModel.fromJson(json['rated_user'])
          : null,
      evaluatingUser: json['evaluating_user'] != null
          ? UserModel.fromJson(json['evaluating_user'])
          : null,
    );
  }

  UserRating toEntity() {
    return UserRating(
      id: id,
      rate: rate,
      message: message,
      createdAt: createdAt,
      updatedAt: updatedAt,
      ratedUser: ratedUser,
      evaluatingUser: evaluatingUser,
    );
  }
}