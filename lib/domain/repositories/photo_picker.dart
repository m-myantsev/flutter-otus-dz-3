import 'dart:typed_data';

import 'photo_source.dart';

/// Источник фото для рецепта
abstract interface class PhotoPicker {
  /// Доступен ли [source] на текущей платформе
  bool supports(PhotoSource source);

  /// Запрашивает фото из [source] и возвращает его байты, `null` при отмене выбора
  Future<Uint8List?> pick(PhotoSource source);
}
