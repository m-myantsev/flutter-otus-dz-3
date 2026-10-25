// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final typeId = 0;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return Recipe(
      id: (fields[0] as num).toInt(),
      name: fields[1] as String,
      duration: (fields[2] as num).toInt(),
      photo: fields[3] as String,
      ingredients: fields[4] == null ? const [] : (fields[4] as List).cast<RecipeIngredient>(),
      steps: fields[5] == null ? const [] : (fields[5] as List).cast<RecipeStep>(),
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.photo)
      ..writeByte(4)
      ..write(obj.ingredients)
      ..writeByte(5)
      ..write(obj.steps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RecipeAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class RecipeIngredientAdapter extends TypeAdapter<RecipeIngredient> {
  @override
  final typeId = 1;

  @override
  RecipeIngredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return RecipeIngredient(count: (fields[0] as num).toDouble(), ingredient: fields[1] as Ingredient);
  }

  @override
  void write(BinaryWriter writer, RecipeIngredient obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.count)
      ..writeByte(1)
      ..write(obj.ingredient);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeIngredientAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class IngredientAdapter extends TypeAdapter<Ingredient> {
  @override
  final typeId = 2;

  @override
  Ingredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return Ingredient(id: (fields[0] as num).toInt(), name: fields[1] as String, measureUnit: fields[2] as MeasureUnit);
  }

  @override
  void write(BinaryWriter writer, Ingredient obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.measureUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class MeasureUnitAdapter extends TypeAdapter<MeasureUnit> {
  @override
  final typeId = 3;

  @override
  MeasureUnit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return MeasureUnit(
      id: (fields[0] as num).toInt(),
      one: fields[1] as String,
      few: fields[2] as String,
      many: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MeasureUnit obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.one)
      ..writeByte(2)
      ..write(obj.few)
      ..writeByte(3)
      ..write(obj.many);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasureUnitAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class RecipeStepAdapter extends TypeAdapter<RecipeStep> {
  @override
  final typeId = 4;

  @override
  RecipeStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return RecipeStep(name: fields[0] as String, duration: (fields[1] as num).toInt());
  }

  @override
  void write(BinaryWriter writer, RecipeStep obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeStepAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class CommentAdapter extends TypeAdapter<Comment> {
  @override
  final typeId = 5;

  @override
  Comment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return Comment(
      author: fields[0] as String,
      text: fields[1] as String,
      date: fields[2] as DateTime,
      avatar: fields[3] == null ? '' : fields[3] as String,
      photo: fields[4] == null ? '' : fields[4] as String,
      isOwn: fields[5] == null ? false : fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Comment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.author)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.avatar)
      ..writeByte(4)
      ..write(obj.photo)
      ..writeByte(5)
      ..write(obj.isOwn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CommentAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class RecipeImageAdapter extends TypeAdapter<RecipeImage> {
  @override
  final typeId = 6;

  @override
  RecipeImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return RecipeImage(
      bytes: fields[0] as Uint8List,
      objects: fields[1] == null ? const [] : (fields[1] as List).cast<DetectedObject>(),
    );
  }

  @override
  void write(BinaryWriter writer, RecipeImage obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.bytes)
      ..writeByte(1)
      ..write(obj.objects);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeImageAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class DetectedObjectAdapter extends TypeAdapter<DetectedObject> {
  @override
  final typeId = 7;

  @override
  DetectedObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return DetectedObject(
      label: fields[0] as String,
      score: (fields[1] as num).toDouble(),
      box: fields[2] as DetectionBox,
    );
  }

  @override
  void write(BinaryWriter writer, DetectedObject obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.box);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectedObjectAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class DetectionBoxAdapter extends TypeAdapter<DetectionBox> {
  @override
  final typeId = 8;

  @override
  DetectionBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return DetectionBox(
      left: (fields[0] as num).toDouble(),
      top: (fields[1] as num).toDouble(),
      right: (fields[2] as num).toDouble(),
      bottom: (fields[3] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, DetectionBox obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.left)
      ..writeByte(1)
      ..write(obj.top)
      ..writeByte(2)
      ..write(obj.right)
      ..writeByte(3)
      ..write(obj.bottom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionBoxAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
