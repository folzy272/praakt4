import '../models/course.dart';
import '../models/student.dart';

/// Детерміновані приклади для демонстрацій; відповідають assets/students.csv.
List<Student> sampleStudents() => [
      Student(
        id: 'S001', firstName: 'Олена', lastName: 'Коваль',
        birthDate: DateTime(2004, 6, 12), enrollmentYear: 2023,
        enrolledCourses: ['DART101', 'MATH101'],
        grades: {'DART101': 95, 'MATH101': 88},
        skills: {'Dart', 'Flutter', 'Git'},
      ),
      Student(
        id: 'S002', firstName: 'Андрій', lastName: 'Мельник',
        birthDate: DateTime(2005, 2, 20), enrollmentYear: 2024,
        enrolledCourses: ['DART101', 'MATH101'],
        grades: {'DART101': 72, 'MATH101': 54},
        skills: {'Dart', 'Python'},
      ),
      Student(
        id: 'S003', firstName: 'Марія', lastName: 'Шевченко',
        birthDate: DateTime(2004, 11, 8), enrollmentYear: 2023,
        enrolledCourses: ['DART101', 'MATH101', 'ADV201'],
        grades: {'DART101': 91, 'MATH101': 93, 'ADV201': 97},
        skills: {'Flutter', 'Dart', 'SQL'},
      ),
      Student(
        id: 'S004', firstName: 'Іван', lastName: 'Петренко',
        birthDate: DateTime(2006, 7, 15), enrollmentYear: 2025,
        enrolledCourses: ['DART101'],
        grades: {'DART101': 63},
        skills: {'Git', 'Dart'},
      ),
      Student(
        id: 'S005', firstName: 'Софія', lastName: 'Бондар',
        birthDate: DateTime(2005, 1, 10), enrollmentYear: 2024,
        enrolledCourses: ['MATH101'],
        grades: {'MATH101': 89},
        skills: {'Python', 'SQL'},
      ),
    ];

List<Course> sampleCourses() => [
      Course(
        id: 'DART101', name: 'Основи Dart',
        description: 'Змінні, функції та ООП', credits: 4,
        instructor: 'Проф. Ткаченко',
      ),
      Course(
        id: 'MATH101', name: 'Дискретна математика',
        description: 'Логіка та комбінаторика', credits: 5,
        instructor: 'Проф. Гнатюк',
      ),
      Course(
        id: 'ADV201', name: 'Поглиблений Dart',
        description: 'Колекції та асинхронне програмування', credits: 4,
        instructor: 'Проф. Ткаченко',
        prerequisites: ['DART101', 'MATH101'],
      ),
    ];
