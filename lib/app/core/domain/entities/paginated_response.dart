/// Uma entidade genérica para representar uma lista paginada de itens no domínio.
class PaginatedResponse<T> {
  final int currentPage;
  final List<T> data;
  final int lastPage;
  final int total;
  final bool hasMorePages;

  const PaginatedResponse({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.total,
  }) : hasMorePages = currentPage < lastPage;
}