import 'dart:math' as math;

/// Калькулятор; для ділення й остачі на нуль кидає ArgumentError.
class Calculator {
  static double calculate(double a, double b, String operation) {
    switch (operation) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
      case 'x':
        return a * b;
      case '/':
        if (b == 0) throw ArgumentError('Ділення на нуль');
        return a / b;
      case '%':
        if (b == 0) throw ArgumentError('Остача від ділення на нуль');
        return a % b;
      case '^':
        return math.pow(a, b).toDouble();
      default:
        throw ArgumentError.value(operation, 'operation', 'Невідома операція');
    }
  }

  static double average(Iterable<num> numbers) {
    final values = numbers.toList();
    if (values.isEmpty) throw ArgumentError('Потрібне хоча б одне число');
    return values.fold<double>(0.0, (sum, n) => sum + n) / values.length;
  }
}
