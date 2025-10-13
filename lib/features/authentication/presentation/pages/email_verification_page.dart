import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/app/core/auth/auth_notifier.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isEmailVerified = false;
  bool _isSendingVerification = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // O usuário pode já ter verificado o e-mail antes de chegar aqui.
    _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!_isEmailVerified) {
      // Envia o e-mail de verificação na primeira vez que a tela é aberta.
      _sendVerificationEmail();

      // Inicia um timer para verificar o status do e-mail a cada 3 segundos.
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    // É crucial cancelar o timer para evitar memory leaks.
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    // Usamos o AuthNotifier para recarregar o estado do usuário.
    // Isso garante que o GoRouter também seja notificado da mudança.
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    await authNotifier.checkEmailVerification();
    
    final isVerifiedNow = authNotifier.user?.emailVerified ?? false;
    
    if (isVerifiedNow) {
      _timer?.cancel();
    }
  }

  Future<void> _sendVerificationEmail() async {
    if (_isSendingVerification) return;

    setState(() => _isSendingVerification = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail de verificação enviado!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar e-mail: ${e.toString()}')),
        );
      }
    } finally {
      // Adiciona um pequeno delay para evitar spam do botão.
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) setState(() => _isSendingVerification = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'seu e-mail';

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Verificação de E-mail', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                Text('Um e-mail de verificação foi enviado para:', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(userEmail, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const Text('Por favor, verifique sua caixa de entrada e clique no link para continuar.', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.email),
                  label: const Text('Reenviar E-mail'),
                  onPressed: _isSendingVerification ? null : _sendVerificationEmail,
                ),
                if (_isSendingVerification) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    // Faz logout e o redirect do GoRouter cuidará do resto
                    Provider.of<FirebaseAuth>(context, listen: false).signOut();
                  },
                  child: const Text('Fazer logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
