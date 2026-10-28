import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_basics_student/data/sample_data.dart';
import 'package:dart_basics_student/models/student.dart';
import 'package:dart_basics_student/utils/data_processor.dart';

Future<void> main() async {
  print('=== Dart Async Programming Demo ===');
  await demonstrateFutures();
  await demonstrateStreams();
  try {
    await demonstrateFileOperations();
  } on FileSystemException catch (error) {
    stderr.writeln('Помилка файлової системи: $error');
    exitCode = 1;
  } on FormatException catch (error) {
    stderr.writeln('Помилка JSON: $error');
    exitCode = 1;
  }
}

/// Імітація API запиту. Затримка потрібна для порівняння послідовного
/// та паралельного виконання; реальне HTTP API тут не використовується.
Future<String> fetchStudentData(String studentId) async {
  await Future<void>.delayed(const Duration(milliseconds: 200));
  if (studentId == 'ERROR') throw StateError('Імітована помилка API');
  return 'Дані студента $studentId отримано';
}

Future<List<Student>> loadStudentsFromFile(String filename) async {
  final input = await File(filename).readAsString();
  final decoded = jsonDecode(input) as List<dynamic>;
  return [
    for (final item in decoded)
      Student.fromJson(Map<String, dynamic>.from(item as Map)),
  ];
}

Future<void> saveStudentsToFile(List<Student> students, String filename) async {
  final file = File(filename);
  await file.parent.create(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(students.map((s) => s.toJson()).toList())}\n');
}

Stream<Student> studentStream([List<Student>? source]) async* {
  for (final student in source ?? sampleStudents()) {
    await Future<void>.delayed(const Duration(milliseconds: 25));
    yield student;
  }
}

Future<void> demonstrateFutures() async {
  print('\n[1] Future / Future.wait / timeout / error handling');
  final ids = ['S001', 'S002', 'S003'];
  final sequentialWatch = Stopwatch()..start();
  final sequential = <String>[];
  for (final id in ids) {
    sequential.add(await fetchStudentData(id));
  }
  sequentialWatch.stop();

  final concurrentWatch = Stopwatch()..start();
  final concurrent = await Future.wait(ids.map(fetchStudentData));
  concurrentWatch.stop();
  print('Послідовно: ${sequentialWatch.elapsedMilliseconds} мс: $sequential');
  print('Паралельно: ${concurrentWatch.elapsedMilliseconds} мс: $concurrent');

  try {
    await fetchStudentData('ERROR');
  } on StateError catch (error) {
    print('Оброблена помилка: $error');
  }
  try {
    await fetchStudentData('S004').timeout(const Duration(milliseconds: 40));
  } on TimeoutException {
    print('Оброблений тайм-аут (40 мс)');
  }
}

Future<void> demonstrateStreams() async {
  print('\n[2] Stream / where / map / await for');
  var count = 0;
  await for (final item in studentStream()
      .where((student) => student.gpa >= 80)
      .map((student) => '${student.fullName}: ${student.gpa.toStringAsFixed(1)}')) {
    count++;
    print('Потік $count: $item');
  }
  final subscription = studentStream(sampleStudents().take(2).toList())
      .listen((student) => print('listen: ${student.id}'));
  await subscription.asFuture<void>();
}

Future<void> demonstrateFileOperations() async {
  print('\n[3] Асинхронні JSON-файли');
  final watch = Stopwatch()..start();
  final students = await loadStudentsFromFile('assets/students.json');
  final loadTime = watch.elapsedMicroseconds;
  final ranked = DataProcessor.sortStudentsByGPA(students);
  await saveStudentsToFile(students, 'reports/async_students.json');
  final summary = {
    'count': students.length,
    'averagesByCourse': DataProcessor.calculateAverageGradesByCourse(students),
    'rankedStudents': ranked,
  };
  const encoder = JsonEncoder.withIndent('  ');
  await File('reports/async_summary.json')
      .writeAsString('${encoder.convert(summary)}\n');
  final restored = await loadStudentsFromFile('reports/async_students.json');
  watch.stop();
  print('Зчитано: ${students.length}; повторно відкрито: ${restored.length}');
  print('Читання: $loadTime мкс; увесь read-process-write-read: '
      '${watch.elapsedMicroseconds} мкс');
  print('Збережено reports/async_students.json та reports/async_summary.json');
}
