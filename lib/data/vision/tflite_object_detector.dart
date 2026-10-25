import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_litert/flutter_litert.dart';

import '../../domain/entities/detected_object.dart';
import '../../domain/exceptions/object_detection_exception.dart';
import '../../domain/repositories/object_detector.dart';
import 'detection_model.dart';
import 'label_map.dart';
import 'model_run.dart';

/// Детектор EfficientDet-Lite4 на TensorFlow Lite
///
/// Модель читается и интерпретатор создаётся при первом [detect], дальше он живёт столько же, сколько детектор
class TfliteObjectDetector implements ObjectDetector {
  TfliteObjectDetector({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  /// Откуда читаются модель и метки
  final AssetBundle _bundle;

  /// Адрес общего интерпретатора в нативной памяти
  ///
  /// `null` до первого успешного создания
  int? _interpreterAddress;

  /// Строки `labelmap`
  ///
  /// Индекс строки на единицу больше номера класса
  ///
  /// Пустой список до первого успешного создания интерпретатора
  List<String> _labels = const [];

  /// Причина неудачного создания интерпретатора, повторяющаяся на каждом вызове
  ObjectDetectionException? _creationError;

  /// Завершается, когда закончился последний поставленный в очередь вызов
  Future<void> _lastCall = Future<void>.value();

  @override
  Future<List<DetectedObject>> detect(Uint8List jpeg) async {
    // Интерпретатор TFLite не потокобезопасен, поэтому вызовы из изолятов выстраиваются в очередь
    final previous = _lastCall;
    final done = Completer<void>();
    _lastCall = done.future;

    try {
      await previous;
      final address = await _ensureInterpreter();
      final labels = _labels;

      // Декодирование и инференс идут сотни миллисекунд и в UI-изоляте подвесили бы кадры
      return await Isolate.run(() => runModel(address, labels, jpeg));
    } finally {
      done.complete();
    }
  }

  /// Создаёт интерпретатор при первом вызове и дальше отдаёт адрес того же
  Future<int> _ensureInterpreter() async {
    final error = _creationError;
    if (error != null) throw error;

    final existing = _interpreterAddress;
    if (existing != null) return existing;

    // Ассеты читаются в главном изоляте, потому что `rootBundle` ходит в движок через платформенный канал
    final model = await _bundle.load(DetectionModel.modelAsset);
    final labelMap = await _bundle.loadString(DetectionModel.labelsAsset);
    final bytes = model.buffer.asUint8List(model.offsetInBytes, model.lengthInBytes);

    final int address;
    try {
      // Копирование модели в нативную память и `allocateTensors` в UI-изоляте подвешивают кадры
      address = await Isolate.run(() => _createInterpreter(bytes));
    } on ObjectDetectionException catch (error) {
      // Ошибка запоминается, чтобы повторные попытки не копировали модель снова
      _creationError = error;
      rethrow;
    }

    // Байты модели не хранятся, потому что `Model.fromBuffer` уже скопировал их в нативную память интерпретатора
    _labels = parseLabelMap(labelMap);
    return _interpreterAddress = address;
  }
}

/// Создаёт интерпретатор и возвращает его адрес, чтобы передать между изолятами
///
/// Бросает [ObjectDetectionException], если модель не читается или нативная библиотека не загрузилась
int _createInterpreter(Uint8List model) {
  final options = InterpreterOptions()..threads = 4;

  try {
    return Interpreter.fromBuffer(model, options: options).address;
  } on ArgumentError catch (error) {
    throw ObjectDetectionException('Интерпретатор TFLite не создан: $error');
  } on UnsupportedError catch (error) {
    // Пакет ищет библиотеку по нескольким путям и, не найдя, бросает `UnsupportedError`
    throw ObjectDetectionException('Интерпретатор TFLite не создан: $error');
  } finally {
    options.delete();
  }
}
