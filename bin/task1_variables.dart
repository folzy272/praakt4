import 'package:dart_basics_student/utils/calculator.dart';

void main(List<String> args) {
  print('=== Dart Variables & Types Demo ===');
  demonstrateNumbers();
  demonstrateStrings();
  demonstrateBooleans();
  demonstrateCollections();
  demonstrateNullSafety();

  print('\n--- Калькулятор ---');
  if (args.length == 3) {
    try {
      final a = double.parse(args[0]);
      final b = double.parse(args[2]);
      print('$a ${args[1]} $b = ${Calculator.calculate(a, b, args[1])}');
    } on FormatException {
      print('Помилка: потрібно передати два числа.');
    } on ArgumentError catch (error) {
      print('Помилка: $error');
    }
  } else {
    for (final operator in ['+', '-', '*', '/', '%', '^']) {
      print('12 $operator 5 = ${Calculator.calculate(12, 5, operator)}');
    }
    print('Власний приклад: dart run bin/task1_variables.dart 15 / 3');
  }
}

void demonstrateNumbers() {
  print('\n[1] Числа');
  int students = 25;
  double courseRating = 4.75;
  num grade = 92;
  print('int=$students, double=$courseRating, num=$grade');
  print('Сума=${students + grade}, ділення=${students / 4}, остача=${students % 4}');
  print('double→int=${courseRating.toInt()}, int→double=${students.toDouble()}');
  print('String→int=${int.parse('42')}, String→double=${double.parse('3.14')}');
}

void demonstrateStrings() {
  print('\n[2] Рядки');
  const firstName = 'Олена';
  const lastName = 'Коваль';
  final message = 'Студентка: $firstName $lastName';
  print(message);
  print('Великими: ${message.toUpperCase()}');
  print('Містить «Олена»: ${message.contains('Олена')}');
  print('Обрізання пробілів: "${'  Dart  '.trim()}"');
  print('Багаторядковий рядок:');
  print('''Перша лінія
Друга лінія''');
  print('Екранування: табуляція\tі новий рядок\nГотово');
}

void demonstrateBooleans() {
  print('\n[3] Логіка');
  const passed = true;
  const hasDebt = false;
  print('passed && !hasDebt = ${passed && !hasDebt}');
  print('passed || hasDebt = ${passed || hasDebt}');
  print('90 >= 60 = ${90 >= 60}');
  print('Оцінка: ${passed ? 'зараховано' : 'не зараховано'}');
}

void demonstrateCollections() {
  print('\n[4] Колекції');
  final subjects = <String>['Dart', 'Математика'];
  subjects.add('Алгоритми');
  final uniqueTags = <String>{'Dart', 'Git', 'Dart'};
  final marks = <String, int>{'Dart': 95, 'Математика': 88};
  marks['Алгоритми'] = 91;
  print('List (${subjects.length}): $subjects');
  print('Set (${uniqueTags.length}): $uniqueTags');
  print('Map: $marks');
  print('Відсортовані предмети: ${subjects.toList()..sort()}');
}

String greeting({required String name}) => 'Вітаю, $name!';

void demonstrateNullSafety() {
  print('\n[5] Null safety');
  String? nickname;
  print('Значення за замовчуванням: ${nickname ?? 'немає'}');
  print('Безпечний доступ: ${nickname?.length}');
  nickname = 'Лена';
  print('Після присвоєння: ${nickname.length}');
  late final String initializedLater;
  initializedLater = 'Ініціалізовано перед читанням';
  print(initializedLater);
  print(greeting(name: 'студенте'));
}
