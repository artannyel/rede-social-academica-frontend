import '../../domain/entities/user.dart';

// Estende a entidade User, adicionando a lógica de serialização (fromJson/toJson).
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.firebaseUid,
  });

  // Converte um mapa (JSON) em um UserModel.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      firebaseUid: json['firebase_uid'],
    );
  }

  // Converte o UserModel em um mapa (JSON).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'firebase_uid': firebaseUid,
    };
  }
}
