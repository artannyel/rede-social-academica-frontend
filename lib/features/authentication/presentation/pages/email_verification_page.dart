import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/app/core/auth/auth_notifier.dart';
import 'package:social_academic/shared/widgets/app_snackbar.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with WidgetsBindingObserver {
  bool _isSendingVerification = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // O usuário pode já ter verificado o e-mail antes de chegar aqui.
    final isAlreadyVerified =
        FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isAlreadyVerified) {
      // Envia o e-mail de verificação na primeira vez que a tela é aberta.
      _sendInitialVerificationEmail();
      // Inicia o timer para checagem periódica.
      _startTimer();
    }
  }

  @override
  void dispose() {
    // É crucial cancelar o timer para evitar memory leaks.
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Quando o app volta para o primeiro plano, checa imediatamente
      // e reinicia o timer se necessário.
      _checkEmailVerified();
      _startTimer();
    } else if (state == AppLifecycleState.paused) {
      // Pausa o timer quando o app vai para segundo plano para economizar recursos.
      _timer?.cancel();
    }
  }

  void _startTimer() {
    // Garante que não haja múltiplos timers rodando.
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 5), // Aumentado para 5s para ser mais seguro
      (_) => _checkEmailVerified(),
    );
  }

  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Recarrega o estado do usuário diretamente do Firebase.
    // Isso evita notificar o GoRouter e causar um loop de redirecionamento.
    await user.reload();

    // Após o reload, verificamos o novo status.
    final isVerifiedNow =
        FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (isVerifiedNow) {
      _timer?.cancel();
      // Notifica o AuthNotifier APENAS quando a verificação for um sucesso,
      // para que o GoRouter possa navegar para a tela principal.
      if (mounted) {
        Provider.of<AuthNotifier>(
          context,
          listen: false,
        ).updateUser(); // Atualiza o usuário e notifica o GoRouter
      }
    }
  }

  Future<void> _sendInitialVerificationEmail() async {
    try {
      // Envia o e-mail sem mostrar um SnackBar, pois a própria tela já é o feedback.
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          message: 'Falha ao enviar o e-mail inicial: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_isSendingVerification) return;

    setState(() => _isSendingVerification = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        // Mostra um feedback claro de que um *novo* e-mail foi enviado.
        showAppSnackBar(
          context,
          message: 'Um novo e-mail de verificação foi enviado!',
          type: SnackBarType.info,
        );
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          message: 'Erro ao enviar e-mail: ${e.toString()}',
          type: SnackBarType.error,
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
      body: ResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Verificação de E-mail',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Text(
                'Um e-mail de verificação foi enviado para:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                userEmail,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text(
                'Por favor, verifique sua caixa de entrada e clique no link para continuar.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Reenviar E-mail'),
                onPressed:
                    _isSendingVerification ? null : _resendVerificationEmail,
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
    );
  }
}
