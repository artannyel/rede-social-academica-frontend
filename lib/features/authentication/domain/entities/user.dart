// Entidade pura que representa o usuário no domínio do app.
class User {
  final String id;
  final String name;
  final String email;
  final String firebaseUid;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.firebaseUid,
  });
}
