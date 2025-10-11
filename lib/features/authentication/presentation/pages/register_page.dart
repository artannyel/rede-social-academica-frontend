import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:social_academic/features/authentication/presentation/provider/register_change_notifier.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleStateChange(BuildContext context, RegisterChangeNotifier notifier) {
    if (notifier.state == RegisterState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notifier.errorMessage ?? 'Erro desconhecido'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (notifier.state == RegisterState.success) {
      // Navegar para a tela principal ou de login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cadastro realizado com sucesso! Bem-vindo, ${notifier.user?.name}!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/login'); // Volta para a tela de login após o sucesso
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Consumer<RegisterChangeNotifier>(
        builder: (context, notifier, child) {
          // Escuta as mudanças de estado para mostrar SnackBars ou navegar
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStateChange(context, notifier);
          });

          if (notifier.state == RegisterState.loading) {
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
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        validator: (value) => (value?.isEmpty ?? true) ? 'Por favor, insira seu nome' : null,
                      ),
                      const SizedBox(height: 16),
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
                        validator: (value) => (value?.length ?? 0) < 6 ? 'A senha deve ter no mínimo 6 caracteres' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(onPressed: _submitForm, child: const Text('Cadastrar')),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.pop(); // Volta para a tela anterior (login)
                        },
                        child: const Text('Já tem uma conta? Faça login'),
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
      final notifier = Provider.of<RegisterChangeNotifier>(context, listen: false);
      notifier.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }
}
