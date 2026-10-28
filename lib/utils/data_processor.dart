import '../models/university.dart';
import 'text_analyzer.dart';

/// Списки, множини, словники та комплексна аналітика університету.
class DataProcessor {
  static List<int> filterEvenNumbers(List<int> numbers) =>
      numbers.where((number) => number.isEven).toList();

  static Map<String, int> countWords(String text) =>
      TextAnalyzer.analyze(text).wordFrequencies;

  static List<Map<String, dynamic>> sortStudentsByGPA(List<Student> students) {
    final sorted = List<Student>.of(students)
      ..sort((a, b) {
        final comparison = b.gpa.compareTo(a.gpa);
        return comparison != 0 ? comparison : a.id.compareTo(b.id);
      });
    return [
      for (final student in sorted)
        {'id': student.id, 'name': student.fullName, 'gpa': student.gpa},
    ];
  }

  static Set<String> getUniqueSkills(List<Student> students) => {
        for (final student in students) ...student.skills,
      };

  static Set<String> findCommonCourses(List<Student> students) {
    if (students.isEmpty) return <String>{};
    final common = students.first.enrolledCourses.toSet();
    for (final student in students.skip(1)) {
      common.retainAll(student.enrolledCourses);
    }
    return common;
  }

  /// Групування за роком ВСТУПУ (додаткове поле Student.enrollmentYear).
  static Map<String, List<Student>> groupStudentsByYear(List<Student> students) {
    final groups = <String, List<Student>>{};
    for (final student in students) {
      groups.putIfAbsent(student.enrollmentYear.toString(), () => <Student>[])
          .add(student);
    }
    return groups;
  }

  static Map<String, double> calculateAverageGradesByCourse(
    List<Student> students,
  ) {
    final sums = <String, double>{};
    final counts = <String, int>{};
    for (final student in students) {
      for (final grade in student.grades.entries) {
        sums.update(grade.key, (value) => value + grade.value,
            ifAbsent: () => grade.value);
        counts.update(grade.key, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    return {
      for (final courseId in sums.keys) courseId: sums[courseId]! / counts[courseId]!,
    };
  }

  /// По одному рядку на студента; відсортовано за зменшенням GPA.
  static List<Map<String, dynamic>> generateReport(University university) {
    final sorted = List<Student>.of(university.students)
      ..sort((a, b) {
        final gradeOrder = b.gpa.compareTo(a.gpa);
        return gradeOrder != 0 ? gradeOrder : a.id.compareTo(b.id);
      });
    return [
      for (final student in sorted)
        {
          'studentId': student.id,
          'fullName': student.fullName,
          'enrollmentYear': student.enrollmentYear,
          'gpa': student.gpa,
          'courseCount': student.enrolledCourses.length,
          'passedCount': student.getPassedCourses().length,
          'skills': student.skills.toList()..sort(),
        },
    ];
  }
}
