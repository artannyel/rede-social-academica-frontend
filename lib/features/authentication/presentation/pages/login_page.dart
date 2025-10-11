import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:social_academic/features/authentication/presentation/provider/login_change_notifier.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notifier.errorMessage ?? 'Erro desconhecido'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (notifier.state == LoginState.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login realizado com sucesso! Bem-vindo de volta, ${notifier.user?.name}!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/home'); // Navega para a home após o sucesso
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Consumer<LoginChangeNotifier>(
        builder: (context, notifier, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStateChange(context, notifier);
          });

          if (notifier.state == LoginState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'E-mail'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => (value?.isEmpty ?? true) ? 'Por favor, insira seu e-mail' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Senha'),
                        obscureText: true,
                        validator: (value) => (value?.isEmpty ?? true) ? 'Por favor, insira sua senha' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(onPressed: _submitForm, child: const Text('Entrar')),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.push('/register'); // Navega para a tela de cadastro
                        },
                        child: const Text('Não tem uma conta? Cadastre-se'),
                      ),
                    ],
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
}
