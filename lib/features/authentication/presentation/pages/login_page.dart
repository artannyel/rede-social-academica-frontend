import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:social_academic/features/authentication/presentation/provider/login_change_notifier.dart';
import 'package:social_academic/shared/widgets/app_snackbar.dart';
import 'package:social_academic/shared/widgets/app_text_form_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleStateChange(BuildContext context, LoginChangeNotifier notifier) {
    if (notifier.state == LoginState.error) {
      showAppSnackBar(
        context,
        message: notifier.errorMessage ?? 'Erro desconhecido',
        type: SnackBarType.error,
      );
      notifier.resetState();
    } else if (notifier.state == LoginState.success) {
      showAppSnackBar(
        context,
        message:
            'Login realizado com sucesso! Bem-vindo de volta, ${notifier.user?.name}!',
        type: SnackBarType.success,
      );
      notifier.resetState();
      context.go('/home'); // Navega para a home após o sucesso
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LoginChangeNotifier>(
        builder: (context, notifier, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStateChange(context, notifier);
          });

          if (notifier.state == LoginState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Login',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 300),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Image.asset(
                                'assets/images/image_for_login.png',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppTextFormField(
                            controller: _emailController,
                            labelText: 'E-mail',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) => (value?.isEmpty ?? true)
                                ? 'Por favor, insira seu e-mail'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          AppTextFormField(
                            controller: _passwordController,
                            labelText: 'Senha',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            validator: (value) => (value?.isEmpty ?? true)
                                ? 'Por favor, insira sua senha'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: const Text('Entrar'),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              context.go(
                                '/register',
                              ); // Navega para a tela de cadastro
                            },
                            child: const Text(
                              'Não tem uma conta? Cadastre-se.',
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showForgotPasswordDialog(context),
                            child: const Text('Esqueci minha senha'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = Provider.of<LoginChangeNotifier>(context, listen: false);
      notifier.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final dialogEmailController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Redefinir Senha'),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Digite seu e-mail para receber o link de redefinição.',
                ),
                const SizedBox(height: 16),
                AppTextFormField(
                  controller: dialogEmailController,
                  labelText: 'E-mail',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu e-mail';
                    }
                    // Simple email validation
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Por favor, insira um e-mail válido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (dialogFormKey.currentState?.validate() ?? false) {
                  final notifier = Provider.of<LoginChangeNotifier>(
                    context,
                    listen: false,
                  );
                  final resultMessage = await notifier.sendPasswordResetEmail(
                    dialogEmailController.text,
                  );

                  Navigator.of(dialogContext).pop(); // Fecha o diálogo

                  // Mostra o resultado no SnackBar
                  showAppSnackBar(
                    context,
                    message: resultMessage,
                    type: resultMessage.contains('sucesso')
                        ? SnackBarType.success
                        : SnackBarType.error,
                  );
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
}
