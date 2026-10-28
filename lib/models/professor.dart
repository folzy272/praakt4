import 'person.dart';

/// Професор успадковує Person і реалізує власну роль та функції.
class Professor extends Person {
  final String department;
  final List<String> taughtCourses;
  final double salary;

  Professor({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.birthDate,
    required this.department,
    required this.salary,
    List<String>? taughtCourses,
  }) : taughtCourses = List<String>.of(taughtCourses ?? const []) {
    if (!salary.isFinite || salary < 0) {
      throw ArgumentError.value(salary, 'salary');
    }
  }

  @override
  String get role => 'Professor';

  void assignCourse(String courseId) {
    if (!taughtCourses.contains(courseId)) taughtCourses.add(courseId);
  }

  void unassignCourse(String courseId) => taughtCourses.remove(courseId);

  @override
  String toString() => 'Professor($id, $fullName, $department)';
}
