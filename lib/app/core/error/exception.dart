/// Exceção genérica para erros de servidor ou conexão na camada de dados.
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}