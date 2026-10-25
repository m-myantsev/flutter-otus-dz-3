import 'package:flutter/material.dart';

import '../../core/l10n/l10n_context.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/photo_picker.dart';
import '../state/locale_controller.dart';
import '../state/recipes_manager.dart';
import '../theme/app_colors.dart';
import '../widgets/landscape_half_width.dart';
import '../widgets/language_menu_button.dart';
import '../widgets/recipe_card.dart';
import 'add_recipe_page.dart';
import 'recipe_page.dart';

/// Экран рецептов с прокручиваемым списком карточек
///
/// Список обновляется по уведомлениям менеджера
class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key, required this.manager, required this.picker, required this.localeController});

  /// Источник рецептов
  final RecipesManager manager;

  /// Источник фото, передаётся на страницы рецепта и создания рецепта
  final PhotoPicker picker;

  /// Выбранный язык интерфейса, переключаемый меню в AppBar
  final LocaleController localeController;

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

  void _openAddRecipe() => Navigator.push(context, AddRecipePage.route(manager: widget.manager, picker: widget.picker));

  void _openRecipe(Recipe recipe) =>
      Navigator.push(context, RecipePage.route(manager: widget.manager, recipe: recipe, picker: widget.picker));

  @override
  Widget build(BuildContext context) {
    final recipes = widget.manager.recipes;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.recipesTitle),
        actions: [LanguageMenuButton(controller: widget.localeController)],
      ),
      body: Center(child: LandscapeHalfWidth(child: _buildBody(recipes))),
      floatingActionButton: FloatingActionButton(
        tooltip: context.l10n.recipesAddRecipe,
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

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            context.l10n.recipesEmpty,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.text),
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
