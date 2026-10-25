/// Шаг приготовления рецепта
class RecipeStep {
  const RecipeStep({required this.name, required this.duration});

  /// Название шага
  final String name;

  /// Длительность шага в секундах
  final int duration;
}
