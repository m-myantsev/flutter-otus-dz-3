import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../../domain/repositories/photo_picker.dart';
import '../../domain/repositories/photo_source.dart';
import 'photo_fit.dart';
import 'photo_limits.dart';

/// Реализация [PhotoPicker] на системных диалогах камеры и альбома из `image_picker`
class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  bool supports(PhotoSource source) => _picker.supportsImageSource(_imageSource(source));

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: _imageSource(source),
      maxWidth: PhotoLimits.maxSide,
      maxHeight: PhotoLimits.maxSide,
      imageQuality: PhotoLimits.quality,
    );
    if (file == null) return null;

    // На компьютере `image_picker` не применяет `maxWidth` и `imageQuality`, поэтому ограничения проверяются ещё раз
    return fitPhotoLimits(await file.readAsBytes());
  }

  static ImageSource _imageSource(PhotoSource source) => switch (source) {
    PhotoSource.camera => ImageSource.camera,
    PhotoSource.album => ImageSource.gallery,
  };
}
