import 'dart:convert';
import 'dart:io';

import 'package:dart_basics_student/models/university.dart';
import 'package:dart_basics_student/utils/csv_student_reader.dart';
import 'package:dart_basics_student/utils/data_processor.dart';

Future<void> main(List<String> args) async {
  print('=== Dart Collections & Data Processing Demo ===');
  demonstrateLists();
  demonstrateSets();
  demonstrateMaps();
  final csvPath = args.isEmpty ? 'assets/students.csv' : args.first;
  try {
    await demonstrateAdvancedOperations(csvPath);
  } on FileSystemException catch (error) {
    stderr.writeln('Не вдалося прочитати CSV: $error');
    exitCode = 1;
  } on FormatException catch (error) {
    stderr.writeln('Помилка формату CSV: $error');
    exitCode = 1;
  }
}

void demonstrateLists() {
  print('\n[1] List / map / where / fold / reduce');
  final numbers = <int>[9, 4, 7, 2, 6, 1];
  final ordered = numbers.toList()..sort();
  print('Початкові: $numbers; відсортовані: $ordered');
  print('Парні: ${DataProcessor.filterEvenNumbers(numbers)}');
  print('Квадрати: ${numbers.map((n) => n * n).toList()}');
  print('Сума fold: ${numbers.fold<int>(0, (sum, n) => sum + n)}');
  print('Максимум reduce: ${numbers.reduce((a, b) => a > b ? a : b)}');
}

void demonstrateSets() {
  print('\n[2] Set / union / intersection / difference');
  final a = <String>{'Dart', 'Git', 'SQL'};
  final b = <String>{'Dart', 'Flutter', 'SQL'};
  print('Об’єднання: ${a.union(b)}');
  print('Перетин: ${a.intersection(b)}');
  print('Різниця A\\B: ${a.difference(b)}');
}

void demonstrateMaps() {
  print('\n[3] Map / transformations / grouping');
  final scores = <String, int>{'Олена': 95, 'Марія': 91, 'Іван': 63};
  final adjusted = scores.map((key, value) => MapEntry(key, value + 2));
  final selected = Map<String, int>.fromEntries(
    scores.entries.where((entry) => entry.value >= 90),
  );
  print('Оцінки: $scores');
  print('Після бонусу +2: $adjusted');
  print('90+: $selected');
  print('Частотність: ${DataProcessor.countWords('Dart і Git, Dart для всіх!')}');
}

String _csvEscape(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

Future<void> demonstrateAdvancedOperations(String csvPath) async {
  print('\n[4] Читання CSV, аналіз і звіти');
  final stopwatch = Stopwatch()..start();
  final students = await CsvStudentReader.readFile(csvPath);
  stopwatch.stop();
  print('Зчитано студентів: ${students.length}, час читання: '
      '${stopwatch.elapsedMicroseconds} мкс');

  final university = University(name: 'Демо-університет');
  for (final course in [
    Course(id: 'DART101', name: 'Основи Dart',
        description: 'Основи', credits: 4, instructor: 'Н. Ткаченко'),
    Course(id: 'MATH101', name: 'Математика',
        description: 'Дискретна математика', credits: 5, instructor: 'І. Гнатюк'),
    Course(id: 'ADV201', name: 'Поглиблений Dart',
        description: 'Потоки', credits: 4, instructor: 'Н. Ткаченко',
        prerequisites: ['DART101', 'MATH101']),
  ]) {
    university.addCourse(course);
  }
  for (final student in students) {
    university.addStudent(student);
  }

  final processingWatch = Stopwatch()..start();
  final averageGrades = DataProcessor.calculateAverageGradesByCourse(students);
  final yearGroups = DataProcessor.groupStudentsByYear(students);
  final report = DataProcessor.generateReport(university);
  final skills = DataProcessor.getUniqueSkills(students).toList()..sort();
  final commonCourses = DataProcessor.findCommonCourses(students);
  final ranking = DataProcessor.sortStudentsByGPA(students);
  final statistics = university.generateStatistics();
  processingWatch.stop();

  print('Рейтинг GPA: $ranking');
  print('Унікальні навички: $skills');
  print('Курси, спільні для ВСІХ: $commonCourses');
  print('За роками вступу: '
      '${yearGroups.map((year, group) => MapEntry(year, group.length))}');
  print('Середні оцінки за курсами: $averageGrades');
  print('Статистика: $statistics');
  print('Час аналітики: ${processingWatch.elapsedMicroseconds} мкс');

  final output = Directory('reports');
  await output.create(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  final jsonResult = {
    'source': csvPath,
    'statistics': statistics,
    'averagesByCourse': averageGrades,
    'studentsByEnrollmentYear':
        yearGroups.map((year, group) => MapEntry(year, group.length)),
    'uniqueSkills': skills,
    'studentReport': report,
  };
  await File('reports/statistics.json').writeAsString('${encoder.convert(jsonResult)}\n');
  final csvOutput = <String>[
    'studentId,fullName,enrollmentYear,gpa,courseCount,passedCount,skills',
    for (final row in report)
      [
        row['studentId'].toString(),
        row['fullName'].toString(),
        row['enrollmentYear'].toString(),
        (row['gpa'] as double).toStringAsFixed(2),
        row['courseCount'].toString(),
        row['passedCount'].toString(),
        (row['skills'] as List<dynamic>).join('|'),
      ].map(_csvEscape).join(','),
  ].join('\n');
  await File('reports/student_report.csv').writeAsString('$csvOutput\n');
  print('Записано reports/statistics.json і reports/student_report.csv');
}
