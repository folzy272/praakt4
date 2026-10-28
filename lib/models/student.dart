import 'person.dart';

/// Студент: навчальні курси, бали, набуті навички та рік вступу.
class Student extends Person {
  final List<String> enrolledCourses;
  final Map<String, double> grades;
  final Set<String> skills;
  final int enrollmentYear;

  Student({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.birthDate,
    List<String>? enrolledCourses,
    Map<String, double>? grades,
    Set<String>? skills,
    int? enrollmentYear,
  })  : enrolledCourses = List<String>.of(enrolledCourses ?? const []),
        grades = Map<String, double>.of(grades ?? const {}),
        skills = Set<String>.of(skills ?? const {}),
        enrollmentYear = enrollmentYear ?? DateTime.now().year {
    if (this.enrollmentYear < 1900) {
      throw ArgumentError.value(this.enrollmentYear, 'enrollmentYear');
    }
    for (final entry in this.grades.entries) {
      _validateGrade(entry.value);
      if (!this.enrolledCourses.contains(entry.key)) {
        throw ArgumentError('Оцінка для незаписаного курсу: ${entry.key}');
      }
    }
  }

  @override
  String get role => 'Student';

  /// Середній бал за 100-бальною шкалою (0, якщо оцінок немає).
  double get gpa => grades.isEmpty
      ? 0.0
      : grades.values.reduce((a, b) => a + b) / grades.length;

  void enrollInCourse(String courseId) {
    if (courseId.trim().isEmpty) throw ArgumentError('Порожній ID курсу');
    if (!enrolledCourses.contains(courseId)) enrolledCourses.add(courseId);
  }

  void addGrade(String courseId, double grade) {
    _validateGrade(grade);
    if (!enrolledCourses.contains(courseId)) {
      throw StateError('Студент не записаний на курс $courseId');
    }
    grades[courseId] = grade;
  }

  static void _validateGrade(double grade) {
    if (!grade.isFinite || grade < 0 || grade > 100) {
      throw ArgumentError.value(grade, 'grade', 'Оцінка від 0 до 100');
    }
  }

  List<String> getPassedCourses() => [
        for (final entry in grades.entries)
          if (entry.value >= 60) entry.key,
      ];

  @override
  String toString() =>
      'Student($id, $fullName, рік вступу: $enrollmentYear, GPA: ${gpa.toStringAsFixed(1)})';

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': birthDate.toIso8601String(),
        'enrollmentYear': enrollmentYear,
        'enrolledCourses': enrolledCourses.toList(),
        'grades': Map<String, double>.of(grades),
        'skills': skills.toList()..sort(),
      };

  factory Student.fromJson(Map<String, dynamic> json) {
    final gradesJson = Map<String, dynamic>.from(json['grades'] as Map? ?? {});
    return Student(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      enrollmentYear: (json['enrollmentYear'] as num?)?.toInt(),
      enrolledCourses: (json['enrolledCourses'] as List<dynamic>? ?? [])
          .map((value) => value as String)
          .toList(),
      grades: gradesJson.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      skills: (json['skills'] as List<dynamic>? ?? [])
          .map((value) => value as String)
          .toSet(),
    );
  }
}
