import 'package:social_academic/features/authentication/domain/entities/user.dart';

class UserRating {
  final String id;
  final int rate;
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserRating({
    required this.id,
    required this.rate,
    this.message,
    required this.createdAt,
    required this.updatedAt,
    this.ratedUser,
    this.evaluatingUser,
  });

  final User? ratedUser;
  final User? evaluatingUser;
}