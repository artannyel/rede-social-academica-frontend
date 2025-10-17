import 'package:social_academic/app/core/domain/entities/paginated_response.dart'
    as domain;

/// Representa uma resposta paginada da API na camada de dados.
/// O tipo genérico `T` deve ser um modelo de dados (ex: PostModel).
class PaginatedResponse<T> extends domain.PaginatedResponse<T> {
  PaginatedResponse({
    required super.currentPage,
    required super.data,
    required super.lastPage,
    required super.total,
  });

  /// Factory para criar uma instância a partir de um JSON.
  /// Requer uma função `fromJsonT` para converter cada item da lista de dados.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataList = json['data'] as List;
    return PaginatedResponse(
      currentPage: json['current_page'],
      data: dataList.map((item) => fromJsonT(item)).toList(),
      lastPage: json['last_page'],
      total: json['total'],
    );
  }

  /// Converte este modelo de dados paginado em uma entidade de domínio paginada.
  /// Este método assume que o tipo `T` do modelo tem um método `toEntity()`.
  domain.PaginatedResponse<E> toEntity<E>() {
    // Converte cada item da lista de Model para Entity
    final entityData =
        data.map((model) => (model as dynamic).toEntity() as E).toList();

    return domain.PaginatedResponse<E>(
      currentPage: currentPage,
      data: entityData,
      lastPage: lastPage,
      total: total,
    );
  }
}