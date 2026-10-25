import 'package:flutter/material.dart';

import '../../domain/entities/recipe.dart';
import '../state/recipes_manager.dart';
import '../theme/app_colors.dart';
import '../widgets/landscape_half_width.dart';
import '../widgets/recipe_card.dart';
import 'add_recipe_page.dart';
import 'recipe_page.dart';

/// Экран рецептов с прокручиваемым списком карточек
///
/// Список обновляется по уведомлениям менеджера
class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key, required this.manager});

  /// Источник рецептов
  final RecipesManager manager;

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  @override
  void initState() {
    super.initState();
    widget.manager.addListener(_handleManagerChange);
  }

  @override
  void dispose() {
    widget.manager.removeListener(_handleManagerChange);
    super.dispose();
  }

  void _handleManagerChange() => setState(() {});

  void _openAddRecipe() => Navigator.push(context, AddRecipePage.route(manager: widget.manager));

  void _openRecipe(Recipe recipe) => Navigator.push(context, RecipePage.route(manager: widget.manager, recipe: recipe));

  @override
  Widget build(BuildContext context) {
    final recipes = widget.manager.recipes;
    return Scaffold(
      appBar: AppBar(title: const Text('Рецепты')),
      body: Center(child: LandscapeHalfWidth(child: _buildBody(recipes))),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddRecipe,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Список рецептов, индикатор первой загрузки или пояснение при пустом списке
  Widget _buildBody(List<Recipe> recipes) {
    if (recipes.isEmpty) {
      if (widget.manager.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Нет рецептов. Проверьте соединение с интернетом',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.text),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
      itemCount: recipes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => _openRecipe(recipes[index]),
        behavior: HitTestBehavior.opaque,
        child: RecipeCard(recipe: recipes[index]),
      ),
    );
  }
}
