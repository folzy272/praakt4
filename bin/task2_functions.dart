import 'package:dart_basics_student/utils/calculator.dart';
import 'package:dart_basics_student/utils/text_analyzer.dart';

void main(List<String> args) {
  print('=== Dart Functions Demo ===');
  testBasicFunctions();
  testAdvancedFunctions();
  testFunctionalProgramming();
  final text = args.isEmpty
      ? 'Dart — це мова програмування. Dart допомагає створювати застосунки!'
      : args.join(' ');
  print('\n--- Аналізатор тексту ---');
  final analysis = TextAnalyzer.analyze(text);
  print('Текст: $text');
  print(analysis);
  print('Частота слів: ${analysis.wordFrequencies}');
}

int calculateSum(int a, int b) => a + b;

double calculateAverage(List<double> numbers) => Calculator.average(numbers);

String formatName(
  String firstName,
  String lastName, {
  String? middleName,
  bool uppercase = false,
}) {
  final chunks = [
    firstName.trim(),
    if (middleName != null && middleName.trim().isNotEmpty) middleName.trim(),
    lastName.trim(),
  ];
  final result = chunks.join(' ');
  return uppercase ? result.toUpperCase() : result;
}

int fibonacci(int n) {
  if (n < 0) throw ArgumentError.value(n, 'n', 'n має бути >= 0');
  if (n < 2) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

int factorial(int n) {
  if (n < 0) throw ArgumentError.value(n, 'n', 'n має бути >= 0');
  if (n < 2) return 1;
  return n * factorial(n - 1);
}

/// Closure: захоплює та змінює лічильник у зовнішній області видимості.
int Function() makeCounter([int start = 0]) {
  var counter = start;
  return () => ++counter;
}

void testBasicFunctions() {
  print('\n[1] Звичайні функції');
  print('7 + 9 = ${calculateSum(7, 9)}');
  print('Середнє [80, 90, 100] = ${calculateAverage([80, 90, 100])}');
}

void testAdvancedFunctions() {
  print('\n[2] Named / optional / recursive');
  print(formatName('Олена', 'Коваль', middleName: 'Іванівна'));
  print(formatName('Марія', 'Шевченко', uppercase: true));
  print('Fibonacci(10) = ${fibonacci(10)}');
  print('5! = ${factorial(5)}');
}

void testFunctionalProgramming() {
  print('\n[3] Функціональне програмування');
  final values = <int>[1, 2, 3, 4, 5, 6];
  final doubles = values.map((value) => value * 2).toList();
  final evens = values.where((value) => value.isEven).toList();
  final sum = values.fold<int>(0, (total, value) => total + value);
  final custom = values.map((value) => value * value).where((n) => n > 10);
  print('map ×2 = $doubles, where парні = $evens, fold сума = $sum');
  print('Квадрати > 10 = ${custom.toList()}');
  final increment = makeCounter(10);
  print('Closure: ${increment()}, ${increment()}, ${increment()}');
}
