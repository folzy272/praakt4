import 'dart:convert';
import 'dart:io';

import '../models/student.dart';

/// CSV зі стандартним екрануванням подвійних лапок, підтримкою LF/CRLF.
/// Поля courses, grades, skills містять значення через символ |.
class CsvStudentReader {
  static const headers = [
    'id', 'firstName', 'lastName', 'birthDate', 'enrollmentYear',
    'courses', 'grades', 'skills',
  ];

  static Future<List<Student>> readFile(String filename) async =>
      parse(await File(filename).readAsString(encoding: utf8));

  static List<Student> parse(String csv) {
    final rows = _parseRows(csv);
    if (rows.isEmpty) throw const FormatException('Порожній CSV');
    final header = rows.first;
    if (header.length != headers.length ||
        !List.generate(headers.length, (i) => header[i] == headers[i])
            .every((match) => match)) {
      throw const FormatException('Невідповідні заголовки CSV');
    }
    final students = <Student>[];
    for (var index = 1; index < rows.length; index++) {
      final fields = rows[index];
      if (fields.every((field) => field.trim().isEmpty)) continue;
      if (fields.length != headers.length) {
        throw FormatException('Неправильна кількість полів у рядку ${index + 1}');
      }
      final courses = _splitValues(fields[5]);
      final grades = <String, double>{};
      for (final item in _splitValues(fields[6])) {
        final colon = item.lastIndexOf(':');
        if (colon <= 0) {
          throw FormatException('Некоректна оцінка "$item", рядок ${index + 1}');
        }
        grades[item.substring(0, colon)] =
            double.parse(item.substring(colon + 1));
      }
      students.add(Student(
        id: fields[0].trim(),
        firstName: fields[1].trim(),
        lastName: fields[2].trim(),
        birthDate: DateTime.parse(fields[3].trim()),
        enrollmentYear: int.parse(fields[4].trim()),
        enrolledCourses: courses,
        grades: grades,
        skills: _splitValues(fields[7]).toSet(),
      ));
    }
    return students;
  }

  static List<String> _splitValues(String source) => source.trim().isEmpty
      ? <String>[]
      : source.split('|').map((value) => value.trim()).toList();

  /// Один прохід, включно з комами та новими рядками всередині лапок.
  static List<List<String>> _parseRows(String csv) {
    final rows = <List<String>>[];
    var row = <String>[];
    var field = StringBuffer();
    var quoted = false;
    for (var i = 0; i < csv.length; i++) {
      final char = csv[i];
      if (char == '"') {
        if (quoted && i + 1 < csv.length && csv[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = !quoted;
        }
      } else if (char == ',' && !quoted) {
        row.add(field.toString());
        field = StringBuffer();
      } else if ((char == '\n' || char == '\r') && !quoted) {
        if (char == '\r' && i + 1 < csv.length && csv[i + 1] == '\n') i++;
        row.add(field.toString());
        if (row.any((value) => value.isNotEmpty)) rows.add(row);
        row = <String>[];
        field = StringBuffer();
      } else {
        field.write(char);
      }
    }
    if (quoted) throw const FormatException('Незакриті лапки у CSV');
    row.add(field.toString());
    if (row.any((value) => value.isNotEmpty)) rows.add(row);
    return rows;
  }
}
