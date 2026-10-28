import 'dart:io';

import 'package:dart_basics_student/data/sample_data.dart';
import 'package:test/test.dart';

import '../bin/task5_async.dart' as asyncDemo;
import '../bin/task2_functions.dart' as functionsDemo;

void main() {
  group('Функції та рекурсія', () {
    test('середнє, форматування, замикання', () {
      expect(functionsDemo.calculateSum(2, 8), 10);
      expect(functionsDemo.calculateAverage([2, 4, 6]), 4);
      expect(functionsDemo.formatName('Олена', 'Коваль',
          middleName: 'Іванівна', uppercase: true),
          'ОЛЕНА ІВАНІВНА КОВАЛЬ');
      final counter = functionsDemo.makeCounter();
      expect(counter(), 1);
      expect(counter(), 2);
    });

    test('Fibonacci та factorial, у тому числі крайові значення', () {
      expect(functionsDemo.fibonacci(0), 0);
      expect(functionsDemo.fibonacci(10), 55);
      expect(functionsDemo.factorial(0), 1);
      expect(functionsDemo.factorial(5), 120);
      expect(() => functionsDemo.fibonacci(-1), throwsArgumentError);
      expect(() => functionsDemo.factorial(-2), throwsArgumentError);
    });
  });

  group('Async', () {
    test('Future повертає дані або контрольовану помилку', () async {
      expect(await asyncDemo.fetchStudentData('S001'), contains('S001'));
      await expectLater(asyncDemo.fetchStudentData('ERROR'), throwsStateError);
    });

    test('Stream генерує потрібну кількість студентів', () async {
      final items = await asyncDemo.studentStream(sampleStudents().take(2).toList())
          .toList();
      expect(items.length, 2);
      expect(items.first.id, 'S001');
    });

    test('JSON-файл успішно зберігається та відновлюється', () async {
      final directory = await Directory.systemTemp.createTemp('dart-basics-');
      try {
        final path = '${directory.path}/students.json';
        await asyncDemo.saveStudentsToFile(sampleStudents(), path);
        final restored = await asyncDemo.loadStudentsFromFile(path);
        expect(restored.length, 5);
        expect(restored[0].grades['DART101'], 95);
        expect(restored[2].enrollmentYear, 2023);
      } finally {
        await directory.delete(recursive: true);
      }
    });
  });
}
