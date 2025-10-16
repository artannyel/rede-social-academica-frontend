/// Um modelo genérico para representar a resposta paginada padrão do Laravel.
class PaginatedResponse<T> {
  final int currentPage;
  final List<T> data;
  final int lastPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PaginatedResponse({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  /// Cria uma instância de [PaginatedResponse] a partir de um JSON.
  /// Requer uma função `fromJsonT` para converter cada item na lista `data`.
  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    final dataList = json['data'] as List;
    return PaginatedResponse<T>(
      currentPage: json['current_page'],
      data: dataList.map((item) => fromJsonT(item as Map<String, dynamic>)).toList(),
      lastPage: json['last_page'],
      total: json['total'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }
}