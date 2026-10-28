import 'package:dart_basics_student/models/university.dart';

void main() {
  print('=== University Management System Demo ===');
  runUniversityDemo();
}

void runUniversityDemo() {
  final university = University(name: 'Демо-університет');
  for (final course in [
    Course(id: 'DART101', name: 'Основи Dart',
        description: 'Основи синтаксису', credits: 4, instructor: 'Н. Ткаченко'),
    Course(id: 'MATH101', name: 'Математика',
        description: 'Дискретна математика', credits: 5, instructor: 'І. Гнатюк'),
    Course(id: 'ADV201', name: 'Поглиблений Dart',
        description: 'Асинхронні потоки', credits: 4,
        instructor: 'Н. Ткаченко', prerequisites: ['DART101']),
  ]) {
    university.addCourse(course);
  }

  university.addProfessor(Professor(
    id: 'P01', firstName: 'Наталія', lastName: 'Ткаченко',
    birthDate: DateTime(1983, 5, 12),
    department: 'Комп’ютерні науки', salary: 32500,
  ));
  university.assignProfessorToCourse('P01', 'DART101');
  university.assignProfessorToCourse('P01', 'ADV201');

  final olena = Student(
    id: 'S01', firstName: 'Олена', lastName: 'Коваль',
    birthDate: DateTime(2004, 6, 12), enrollmentYear: 2023,
    skills: {'Dart', 'Git'},
  );
  final andrii = Student(
    id: 'S02', firstName: 'Андрій', lastName: 'Мельник',
    birthDate: DateTime(2005, 2, 20), enrollmentYear: 2024,
  );
  university.addStudent(olena);
  university.addStudent(andrii);
  print('Університет: ${university.name}');
  print('Курси: ${university.courses.join(', ')}');

  university.enrollStudentInCourse('S01', 'DART101');
  university.enrollStudentInCourse('S01', 'MATH101');
  university.enrollStudentInCourse('S02', 'DART101');
  try {
    university.enrollStudentInCourse('S02', 'ADV201');
  } on StateError catch (error) {
    print('Очікувана відмова (prerequisites): $error');
  }
  university.recordGrade('S01', 'DART101', 95);
  university.recordGrade('S01', 'MATH101', 88);
  university.recordGrade('S02', 'DART101', 75);
  university.enrollStudentInCourse('S02', 'ADV201');
  university.recordGrade('S02', 'ADV201', 82);

  for (final student in university.students) {
    print('$student; складені курси: ${student.getPassedCourses()}');
  }
  print('Поліморфізм: ${university.describePeople()}');
  print('Студенти DART101: ${university.getStudentsByCourse('DART101').length}');
  print('Доступні курси S01: ${university.getAvailableCoursesForStudent('S01')}');

  final restored = Student.fromJson(olena.toJson());
  print('JSON round-trip: ${restored.fullName}, GPA=${restored.gpa}');
  print('Статистика: ${university.generateStatistics()}');

  final temporary = Student(
    id: 'TEMP', firstName: 'Тестовий', lastName: 'Студент',
    birthDate: DateTime(2002),
  );
  university.addStudent(temporary);
  print('CRUD: додано TEMP → ${university.findStudentById('TEMP') != null}');
  print('CRUD: вилучено TEMP → ${university.removeStudent('TEMP')}');
  print('Кількість студентів після CRUD: ${university.students.length}');
}
