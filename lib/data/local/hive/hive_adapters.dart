import 'dart:typed_data';

import 'package:hive_ce/hive.dart';

import '../../../domain/entities/comment.dart';
import '../../../domain/entities/detected_object.dart';
import '../../../domain/entities/detection_box.dart';
import '../../../domain/entities/ingredient.dart';
import '../../../domain/entities/measure_unit.dart';
import '../../../domain/entities/recipe.dart';
import '../../../domain/entities/recipe_image.dart';
import '../../../domain/entities/recipe_ingredient.dart';
import '../../../domain/entities/recipe_step.dart';

@GenerateAdapters([
  AdapterSpec<Recipe>(),
  AdapterSpec<RecipeIngredient>(),
  AdapterSpec<Ingredient>(),
  AdapterSpec<MeasureUnit>(),
  AdapterSpec<RecipeStep>(),
  AdapterSpec<Comment>(),
  AdapterSpec<RecipeImage>(),
  AdapterSpec<DetectedObject>(),
  AdapterSpec<DetectionBox>(),
])
part 'hive_adapters.g.dart';
