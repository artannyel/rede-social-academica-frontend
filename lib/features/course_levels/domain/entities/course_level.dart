/// Entidade pura que representa o nível de um curso (ex: Graduação, Pós-Graduação).
class CourseLevel {
  final String id;
  final String name;

  const CourseLevel({
    required this.id,
    required this.name,
  });
}