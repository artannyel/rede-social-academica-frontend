/// Representa uma falha genérica na camada de domínio.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Falha genérica para erros de servidor ou conexão.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Falha específica para credenciais de login inválidas.
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure() : super('E-mail ou senha inválidos. Por favor, tente novamente.');
}

/// Falha para quando um e-mail já está em uso durante o cadastro.
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure() : super('Este e-mail já está em uso por outra conta.');
}

/// Falha para quando a senha é considerada fraca pelo Firebase.
class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure() : super('A senha é muito fraca. Use pelo menos 6 caracteres.');
}