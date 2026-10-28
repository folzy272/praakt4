import 'package:dart_basics_student/utils/data_processor.dart';

/// Мікробенчмарк: цифри вимірюються на машині користувача під час запуску.
void main() {
  final values = List<int>.generate(200000, (index) => index);
  final warmup = DataProcessor.filterEvenNumbers(values.take(1000).toList());
  assert(warmup.length == 500);

  final listWatch = Stopwatch()..start();
  final evensViaWhere = DataProcessor.filterEvenNumbers(values);
  listWatch.stop();

  final manualWatch = Stopwatch()..start();
  final evensViaLoop = <int>[];
  for (final value in values) {
    if (value.isEven) evensViaLoop.add(value);
  }
  manualWatch.stop();

  final left = values.take(150000).toSet();
  final right = values.skip(50000).toSet();
  final setWatch = Stopwatch()..start();
  final intersection = left.intersection(right);
  setWatch.stop();

  final text = List.filled(15000, 'Dart Flutter Dart Git').join(' ');
  final mapWatch = Stopwatch()..start();
  final words = DataProcessor.countWords(text);
  mapWatch.stop();

  if (evensViaWhere.length != evensViaLoop.length ||
      evensViaWhere.length != 100000) {
    throw StateError('Результати двох підходів фільтрації не збігаються');
  }

  print('=== Бенчмарк обробки даних ===');
  print('List.where (200000): ${listWatch.elapsedMicroseconds} мкс');
  print('Цикл for (200000): ${manualWatch.elapsedMicroseconds} мкс');
  print('Set.intersection: ${setWatch.elapsedMicroseconds} мкс; '
      'спільних: ${intersection.length}');
  print('Map частот слів: ${mapWatch.elapsedMicroseconds} мкс; '
      'різних слів: ${words.length}');
  print('Час залежить від процесора, прогріву JIT і навантаження ОС.');
}
