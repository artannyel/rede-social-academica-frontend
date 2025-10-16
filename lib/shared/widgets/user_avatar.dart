import 'package:flutter/material.dart';

/// Um widget que exibe a foto do usuário ou um ícone padrão.
class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;

  const UserAvatar({
    super.key,
    this.photoUrl,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
      // Se não houver foto, exibe um ícone padrão.
      child: !hasPhoto
          ? Icon(
              Icons.person,
              size: radius, // Ajusta o tamanho do ícone ao raio
            )
          : null,
    );
  }
}