import 'package:flutter/material.dart';

/// Um widget que centraliza seu filho e aplica uma largura máxima responsiva.
/// - Para telas com largura de até 1200px, a largura máxima é 600px.
/// - Para telas com largura maior que 1200px, a largura máxima é 900px.
class ResponsiveLayout extends StatelessWidget {
  final Widget child;

  const ResponsiveLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 1200 ? 900.0 : 600.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}