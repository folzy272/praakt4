import 'student.dart';

/// Курс з перевіркою попередньо успішно складених дисциплін.
class Course {
  final String id;
  final String name;
  final String description;
  final int credits;
  final String instructor;
  final List<String> prerequisites;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.credits,
    required this.instructor,
    List<String>? prerequisites,
  }) : prerequisites = List<String>.of(prerequisites ?? const []) {
    if (credits <= 0) throw ArgumentError.value(credits, 'credits');
  }

  bool hasPrerequisites() => prerequisites.isNotEmpty;

  bool canStudentEnroll(Student student) {
    final passed = student.getPassedCourses().toSet();
    return prerequisites.every(passed.contains);
  }

  @override
  String toString() => 'Course($id — $name, $credits кредитів)';
}
