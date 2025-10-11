import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/app/core/theme/theme_notifier.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Mudar Tema',
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              // Acessa o FirebaseAuth via Provider e executa o signOut.
              // O AuthNotifier irá detectar a mudança e o GoRouter fará o redirecionamento.
              Provider.of<FirebaseAuth>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: const Center(child: Text('Bem-vindo! Login efetuado com sucesso.')),
    );
  }
}
