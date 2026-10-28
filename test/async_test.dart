import 'dart:io';

import 'package:dart_basics_student/data/sample_data.dart';
import 'package:test/test.dart';

import '../bin/task5_async.dart' as async_demo;
import '../bin/task2_functions.dart' as functions_demo;

void main() {
  group('Функції та рекурсія', () {
    test('середнє, форматування, замикання', () {
      expect(functions_demo.calculateSum(2, 8), 10);
      expect(functions_demo.calculateAverage([2, 4, 6]), 4);
      expect(
        functions_demo.formatName(
          'Олена',
          'Коваль',
          middleName: 'Іванівна',
          uppercase: true,
        ),
        'ОЛЕНА ІВАНІВНА КОВАЛЬ',
      );
      final counter = functions_demo.makeCounter();
      expect(counter(), 1);
      expect(counter(), 2);
    });

    test('Fibonacci та factorial, у тому числі крайові значення', () {
      expect(functions_demo.fibonacci(0), 0);
      expect(functions_demo.fibonacci(10), 55);
      expect(functions_demo.factorial(0), 1);
      expect(functions_demo.factorial(5), 120);
      expect(() => functions_demo.fibonacci(-1), throwsArgumentError);
      expect(() => functions_demo.factorial(-2), throwsArgumentError);
    });
  });

  group('Async', () {
    test('Future повертає дані або контрольовану помилку', () async {
      expect(await async_demo.fetchStudentData('S001'), contains('S001'));
      await expectLater(async_demo.fetchStudentData('ERROR'), throwsStateError);
    });

    test('Stream генерує потрібну кількість студентів', () async {
      final items = await async_demo
          .studentStream(sampleStudents().take(2).toList())
          .toList();
      expect(items.length, 2);
      expect(items.first.id, 'S001');
    });

    test('JSON-файл успішно зберігається та відновлюється', () async {
      final directory = await Directory.systemTemp.createTemp('dart-basics-');
      try {
        final path = '${directory.path}/students.json';
        await async_demo.saveStudentsToFile(sampleStudents(), path);
        final restored = await async_demo.loadStudentsFromFile(path);
        expect(restored.length, 5);
        expect(restored[0].grades['DART101'], 95);
        expect(restored[2].enrollmentYear, 2023);
      } finally {
        await directory.delete(recursive: true);
      }
    });
  });
}
