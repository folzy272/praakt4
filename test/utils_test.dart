import 'dart:io';

import 'package:dart_basics_student/data/sample_data.dart';
import 'package:dart_basics_student/models/university.dart';
import 'package:dart_basics_student/utils/calculator.dart';
import 'package:dart_basics_student/utils/csv_student_reader.dart';
import 'package:dart_basics_student/utils/data_processor.dart';
import 'package:dart_basics_student/utils/text_analyzer.dart';
import 'package:test/test.dart';

void main() {
  group('Calculator', () {
    test('всі операції та середнє', () {
      expect(Calculator.calculate(8, 2, '+'), 10);
      expect(Calculator.calculate(8, 2, '-'), 6);
      expect(Calculator.calculate(8, 2, '*'), 16);
      expect(Calculator.calculate(8, 2, '/'), 4);
      expect(Calculator.calculate(8, 3, '%'), 2);
      expect(Calculator.calculate(2, 3, '^'), 8);
      expect(Calculator.average([2, 4, 6]), 4);
    });

    test('ділення на нуль, невідома операція, порожній список', () {
      expect(() => Calculator.calculate(2, 0, '/'), throwsArgumentError);
      expect(() => Calculator.calculate(2, 2, '?'), throwsArgumentError);
      expect(() => Calculator.average([]), throwsArgumentError);
    });
  });

  group('TextAnalyzer', () {
    test('підтримує українську мову, Unicode та частоти слів', () {
      final data = TextAnalyzer.analyze('Привіт, Dart! Привіт.');
      expect(data.words, 3);
      expect(data.wordFrequencies['привіт'], 2);
      expect(data.wordFrequencies['dart'], 1);
      expect(data.lines, 1);
    });

    test('порожній текст', () {
      final data = TextAnalyzer.analyze('');
      expect(data.words, 0);
      expect(data.characters, 0);
      expect(data.lines, 0);
    });
  });

  group('DataProcessor', () {
    final students = sampleStudents();

    test('filterEvenNumbers та countWords', () {
      expect(DataProcessor.filterEvenNumbers([1, 2, 4, 5]), [2, 4]);
      expect(DataProcessor.countWords('Dart dart і SQL')['dart'], 2);
    });

    test('навички, перетин курсів і групування за роком вступу', () {
      expect(DataProcessor.getUniqueSkills(students),
          containsAll(['Dart', 'Git', 'Flutter', 'Python', 'SQL']));
      expect(DataProcessor.findCommonCourses(students), isEmpty);
      final groups = DataProcessor.groupStudentsByYear(students);
      expect(groups['2023']!.length, 2);
      expect(groups['2024']!.length, 2);
      expect(groups['2025']!.length, 1);
      expect(DataProcessor.findCommonCourses([]), isEmpty);
    });

    test('рейтинг GPA, середня оцінка та звіт', () {
      final ranking = DataProcessor.sortStudentsByGPA(students);
      expect(ranking.first['id'], 'S003');
      final averages = DataProcessor.calculateAverageGradesByCourse(students);
      expect(averages['DART101'], closeTo(80.25, 0.001));
      expect(averages['MATH101'], closeTo(81, 0.001));
      final university = University(name: 'Тест', students: students);
      final report = DataProcessor.generateReport(university);
      expect(report.length, 5);
      expect(report.first['studentId'], 'S003');
    });
  });

  group('CsvStudentReader', () {
    test('читає дані CSV з локального файлу', () async {
      final students = await CsvStudentReader.readFile('assets/students.csv');
      expect(students, hasLength(5));
      expect(students[0].fullName, 'Олена Коваль');
      expect(students[2].grades['ADV201'], 97);
      expect(File('assets/students.json').existsSync(), isTrue);
    });

    test('підтримує лапки і кому всередині поля', () {
      final content = '${CsvStudentReader.headers.join(',')}\n'
          'S1,"Олена, Марія",Коваль,2004-06-12,2023,DART101,DART101:95,Dart';
      final students = CsvStudentReader.parse(content);
      expect(students.single.firstName, 'Олена, Марія');
    });

    test('перевіряє заголовок і незакриті лапки', () {
      expect(() => CsvStudentReader.parse('wrong,header\n1,2'),
          throwsFormatException);
      expect(() => CsvStudentReader.parse('"bad'), throwsFormatException);
    });
  });
}
