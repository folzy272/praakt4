import 'package:dart_basics_student/models/university.dart';
import 'package:test/test.dart';

Student makeStudent({String id = 'S1'}) => Student(
      id: id,
      firstName: 'Олена',
      lastName: 'Коваль',
      birthDate: DateTime(2004, 6, 12),
      enrollmentYear: 2023,
      enrolledCourses: ['DART101', 'MATH101'],
      grades: {'DART101': 95, 'MATH101': 55},
      skills: {'Dart', 'Git'},
    );

Course course(String id, {List<String>? prerequisites}) => Course(
      id: id,
      name: 'Курс $id',
      description: 'Опис',
      credits: 4,
      instructor: 'Викладач',
      prerequisites: prerequisites,
    );

void main() {
  group('Student', () {
    test('fullName, GPA і складені курси (>=60)', () {
      final student = makeStudent();
      expect(student.fullName, 'Олена Коваль');
      expect(student.gpa, 75);
      expect(student.getPassedCourses(), ['DART101']);
      expect(student.role, 'Student');
    });

    test('порожні оцінки дають GPA=0; дубль запису не створюється', () {
      final student = Student(
        id: '0', firstName: 'А', lastName: 'Б',
        birthDate: DateTime(2000),
      );
      expect(student.gpa, 0);
      student.enrollInCourse('DART101');
      student.enrollInCourse('DART101');
      expect(student.enrolledCourses, ['DART101']);
    });

    test('оцінка лише для записаного курсу та від 0 до 100', () {
      final student = makeStudent();
      expect(() => student.addGrade('ADV201', 80), throwsStateError);
      expect(() => student.addGrade('DART101', 101), throwsArgumentError);
      student.addGrade('MATH101', 60);
      expect(student.getPassedCourses(), contains('MATH101'));
    });

    test('JSON roundtrip з навичками, оцінками та роком вступу', () {
      final original = makeStudent();
      final restored = Student.fromJson(original.toJson());
      expect(restored.fullName, original.fullName);
      expect(restored.enrollmentYear, 2023);
      expect(restored.skills, {'Dart', 'Git'});
      expect(restored.grades, original.grades);
    });
  });

  group('Course, Professor, University', () {
    test('передумови курсу: успішно складено, а не просто записано', () {
      final advanced = course('ADV201', prerequisites: ['DART101', 'MATH101']);
      final student = makeStudent();
      expect(advanced.hasPrerequisites(), isTrue);
      expect(advanced.canStudentEnroll(student), isFalse);
      student.addGrade('MATH101', 60);
      expect(advanced.canStudentEnroll(student), isTrue);
    });

    test('поліморфізм Person: Student і Professor', () {
      final personList = <Person>[
        makeStudent(),
        Professor(
          id: 'P1', firstName: 'Іван', lastName: 'Ткаченко',
          birthDate: DateTime(1980), department: 'ІТ', salary: 20000,
        ),
      ];
      expect(personList.map((person) => person.role).toList(),
          ['Student', 'Professor']);
    });

    test('CRUD: заборона дублікатів і пошук/видалення', () {
      final university = University(name: 'Тест');
      university.addStudent(makeStudent());
      expect(() => university.addStudent(makeStudent()), throwsStateError);
      expect(university.findStudentById('S1'), isNotNull);
      expect(university.removeStudent('S1'), isTrue);
      expect(university.removeStudent('S1'), isFalse);
      expect(university.findStudentById('S1'), isNull);
    });

    test('запис на курс, статистика, видалення курсу', () {
      final university = University(name: 'Тест');
      university.addCourse(course('DART101'));
      university.addCourse(course('ADV201', prerequisites: ['DART101']));
      final student = Student(
        id: 'S', firstName: 'Іван', lastName: 'Петренко',
        birthDate: DateTime(2005), enrollmentYear: 2024,
      );
      university.addStudent(student);
      expect(() => university.enrollStudentInCourse('S', 'ADV201'),
          throwsStateError);
      university.enrollStudentInCourse('S', 'DART101');
      university.recordGrade('S', 'DART101', 80);
      expect(university.getAvailableCoursesForStudent('S').single.id, 'ADV201');
      university.enrollStudentInCourse('S', 'ADV201');
      university.recordGrade('S', 'ADV201', 90);
      expect(university.generateStatistics()['studentCount'], 1);
      expect(university.generateStatistics()['averageGpa'], 85);
      expect(university.getStudentsByCourse('ADV201').length, 1);
      expect(university.removeCourse('ADV201'), isTrue);
      expect(student.grades.containsKey('ADV201'), isFalse);
      expect(student.enrolledCourses.contains('ADV201'), isFalse);
    });

    test('порожній університет має безпечну статистику', () {
      final stats = University(name: 'Тест').generateStatistics();
      expect(stats['studentCount'], 0);
      expect(stats['averageGpa'], 0.0);
    });
  });
}
