import 'course.dart';
import 'person.dart';
import 'professor.dart';
import 'student.dart';

// Повторні експорти для зручності користувачів системи.
export 'course.dart';
export 'person.dart';
export 'professor.dart';
export 'student.dart';

/// Спрощена система управління університетом із перевіркою інваріантів.
class University {
  final String name;
  final List<Student> students;
  final List<Professor> professors;
  final List<Course> courses;

  University({
    required this.name,
    List<Student>? students,
    List<Professor>? professors,
    List<Course>? courses,
  })  : students = List<Student>.of(students ?? const []),
        professors = List<Professor>.of(professors ?? const []),
        courses = List<Course>.of(courses ?? const []);

  void addStudent(Student student) {
    if (findStudentById(student.id) != null) {
      throw StateError('Студент з ID ${student.id} уже існує');
    }
    students.add(student);
  }

  bool removeStudent(String studentId) {
    final before = students.length;
    students.removeWhere((student) => student.id == studentId);
    return students.length != before;
  }

  Student? findStudentById(String id) {
    for (final student in students) {
      if (student.id == id) return student;
    }
    return null;
  }

  void addProfessor(Professor professor) {
    if (professors.any((item) => item.id == professor.id)) {
      throw StateError('Професор уже існує: ${professor.id}');
    }
    professors.add(professor);
  }

  bool removeProfessor(String id) {
    final before = professors.length;
    professors.removeWhere((item) => item.id == id);
    return professors.length != before;
  }

  void addCourse(Course course) {
    if (findCourseById(course.id) != null) {
      throw StateError('Курс уже існує: ${course.id}');
    }
    courses.add(course);
  }

  bool removeCourse(String courseId) {
    final removed = courses.removeWhere; // Зміни виконуються атомарно нижче.
    final before = courses.length;
    removed((item) => item.id == courseId);
    if (courses.length == before) return false;
    for (final student in students) {
      student.enrolledCourses.remove(courseId);
      student.grades.remove(courseId);
    }
    for (final professor in professors) {
      professor.unassignCourse(courseId);
    }
    return true;
  }

  Course? findCourseById(String id) {
    for (final course in courses) {
      if (course.id == id) return course;
    }
    return null;
  }

  void enrollStudentInCourse(String studentId, String courseId) {
    final student = findStudentById(studentId);
    final course = findCourseById(courseId);
    if (student == null) throw StateError('Невідомий студент: $studentId');
    if (course == null) throw StateError('Невідомий курс: $courseId');
    if (!course.canStudentEnroll(student)) {
      throw StateError('Не складено передумови курсу $courseId');
    }
    student.enrollInCourse(courseId);
  }

  void recordGrade(String studentId, String courseId, double grade) {
    final student = findStudentById(studentId);
    if (student == null) throw StateError('Невідомий студент: $studentId');
    if (findCourseById(courseId) == null) {
      throw StateError('Невідомий курс: $courseId');
    }
    student.addGrade(courseId, grade);
  }

  void assignProfessorToCourse(String professorId, String courseId) {
    if (findCourseById(courseId) == null) {
      throw StateError('Невідомий курс: $courseId');
    }
    for (final professor in professors) {
      if (professor.id == professorId) {
        professor.assignCourse(courseId);
        return;
      }
    }
    throw StateError('Невідомий професор: $professorId');
  }

  List<Student> getStudentsByCourse(String courseId) => students
      .where((student) => student.enrolledCourses.contains(courseId))
      .toList();

  List<Course> getAvailableCoursesForStudent(String studentId) {
    final student = findStudentById(studentId);
    if (student == null) throw StateError('Невідомий студент: $studentId');
    return courses
        .where((course) =>
            !student.enrolledCourses.contains(course.id) &&
            course.canStudentEnroll(student))
        .toList();
  }

  /// Інформація для звіту: середній GPA, кількість записаних і успішних.
  Map<String, dynamic> generateStatistics() {
    final avgGpa = students.isEmpty
        ? 0.0
        : students.map((student) => student.gpa).reduce((a, b) => a + b) /
            students.length;
    final enrollments = <String, int>{};
    final passed = <String, int>{};
    for (final course in courses) {
      enrollments[course.id] = getStudentsByCourse(course.id).length;
      passed[course.id] = students
          .where((student) => student.getPassedCourses().contains(course.id))
          .length;
    }
    return {
      'university': name,
      'studentCount': students.length,
      'professorCount': professors.length,
      'courseCount': courses.length,
      'averageGpa': avgGpa,
      'enrollmentsByCourse': enrollments,
      'passedByCourse': passed,
      'roles': <String, int>{
        'Student': students.length,
        'Professor': professors.length,
      },
    };
  }

  /// Поліморфізм: Person може бути Student або Professor.
  List<String> describePeople() {
    final people = <Person>[...students, ...professors];
    return people.map((person) => '${person.role}: ${person.fullName}').toList();
  }
}
