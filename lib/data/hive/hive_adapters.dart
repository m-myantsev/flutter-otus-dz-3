import 'dart:typed_data';

import 'package:hive_ce/hive.dart';

import '../../models/comment.dart';
import '../../models/detected_object.dart';
import '../../models/detection_box.dart';
import '../../models/ingredient.dart';
import '../../models/measure_unit.dart';
import '../../models/recipe.dart';
import '../../models/recipe_image.dart';
import '../../models/recipe_ingredient.dart';
import '../../models/recipe_step.dart';

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
