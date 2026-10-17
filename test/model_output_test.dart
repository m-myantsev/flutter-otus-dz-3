import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/models/detection_box.dart';
import 'package:recipes/vision/detection_model.dart';
import 'package:recipes/vision/model_output.dart';

const labels = ['???', 'person', 'bicycle', '???', 'cup'];

List<List<double>> boxesOf(int n) => List.generate(n, (_) => [0.1, 0.2, 0.5, 0.6]);

void main() {
  test('класс n берёт строку n + 1, рамка переводится из ymin xmin ymax xmax', () {
    final result = parseModelOutput(boxes: boxesOf(1), classes: [0], scores: [0.9], count: 1, labels: labels);
    expect(result.single.label, 'person');
    expect(result.single.score, 0.9);
    expect(result.single.box, const DetectionBox(left: 0.2, top: 0.1, right: 0.6, bottom: 0.5));
  });

  test('берёт не больше пяти объектов с вероятностью от 0.3 по убыванию', () {
    final result = parseModelOutput(
      boxes: boxesOf(10),
      classes: List.filled(10, 1),
      // Вперемешку, чтобы порядок результата задавала сортировка, а не порядок выхода модели
      scores: [0.6, 0.95, 0.1, 0.8, 0.29, 0.9, 0.3, 0.7, 0.4, 0.5],
      count: 10,
      labels: labels,
    );
    expect(result.map((o) => o.score), [0.95, 0.9, 0.8, 0.7, 0.6]);
  });

  test('вероятность ниже порога отбрасывается даже при свободных местах', () {
    final result = parseModelOutput(boxes: boxesOf(2), classes: [0, 0], scores: [0.5, 0.29], count: 2, labels: labels);
    expect(result, hasLength(1));
  });

  test('метка ??? пропускается, а не показывается', () {
    final result = parseModelOutput(boxes: boxesOf(2), classes: [2, 3], scores: [0.9, 0.8], count: 2, labels: labels);
    expect(result.single.label, 'cup');
  });

  test('вероятность ровно на пороге сохраняется, чуть ниже отбрасывается', () {
    const atThreshold = DetectionModel.minScore;
    const belowThreshold = DetectionModel.minScore - 0.0001;
    final result = parseModelOutput(
      boxes: boxesOf(2),
      classes: [0, 3],
      scores: [atThreshold, belowThreshold],
      count: 2,
      labels: labels,
    );
    expect(result.single.label, 'person');
    expect(result.single.score, atThreshold);
  });

  test('заглушки ??? и класс вне labelmap не занимают места в пятёрке', () {
    // Заглушки самые вероятные, поэтому при отборе пятёрки до фильтра меток настоящих осталось бы меньше пяти
    final result = parseModelOutput(
      boxes: boxesOf(9),
      // `2` даёт `???`, `4` выходит за конец `labels`, остальные настоящие
      classes: [2, 0, 4, 1, 2, 3, 0, 1, 3],
      scores: [0.99, 0.8, 0.98, 0.75, 0.97, 0.7, 0.65, 0.6, 0.55],
      count: 9,
      labels: labels,
    );
    expect(result.map((o) => o.label), ['person', 'bicycle', 'cup', 'person', 'bicycle']);
    expect(result.map((o) => o.score), [0.8, 0.75, 0.7, 0.65, 0.6]);
  });

  test('читает только count первых детекций', () {
    final result = parseModelOutput(
      boxes: boxesOf(3),
      classes: [0, 0, 0],
      scores: [0.9, 0.9, 0.9],
      count: 1,
      labels: labels,
    );
    expect(result, hasLength(1));
  });

  test('рамка за пределами кадра обрезается до 0..1', () {
    final result = parseModelOutput(
      boxes: [
        [-0.2, -0.1, 1.3, 1.1],
      ],
      classes: [0],
      scores: [0.9],
      count: 1,
      labels: labels,
    );
    expect(result.single.box, const DetectionBox(left: 0, top: 0, right: 1, bottom: 1));
  });
}
