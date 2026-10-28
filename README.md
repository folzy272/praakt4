# Практична робота №4 — Основи мови Dart

**Дисципліна:** Програмування для мобільних платформ  
**Мета:** змінні й типи, функції, ООП, колекції, асинхронне програмування.  
**Dart:** 3.0.0+  
**Пакет:** `dart_basics_student` (замініть `student` на своє прізвище, якщо викладач вимагає індивідуальну назву).

## 1. Підготовка середовища

1. Встановіть **Dart SDK**: https://dart.dev/get-dart. Для Windows 10/11 у PowerShell можна використати `winget install --id=Google.DartSDK -e`.
2. За потреби встановіть VS Code і розширення **Dart**.
3. Відкрийте термінал у папці `dart_basics_student` (де лежить `pubspec.yaml`).
4. Перевірте SDK і завантажте залежності:

   ```bash
   dart --version
   dart pub get
   ```

> **Важливо:** У середовищі підготовки архіву SDK не був доступний. Після першого запуску на Windows виявлено 7 зауважень `dart analyze` (4 у демонстрації змінних, 1 зайвий імпорт, 2 іменування імпортів), які виправлено у цій версії. Залишилося повторно перевірити `dart analyze` і `dart test` на комп'ютері з Dart SDK або в GitHub Actions.

## 2. Запуск кожного завдання

Виконуйте команди **з кореня проєкту**:

| Завдання | Програма | Команда |
|---|---|---|
| 2 — Типи, null safety, калькулятор | `bin/task1_variables.dart` | `dart run bin/task1_variables.dart` |
| 2 — Функції, рекурсія, аналізатор тексту | `bin/task2_functions.dart` | `dart run bin/task2_functions.dart` |
| 3 — Студенти, викладачі, курси, CRUD | `bin/task3_classes.dart` | `dart run bin/task3_classes.dart` |
| 4 — CSV, List/Set/Map, аналітика | `bin/task4_collections.dart` | `dart run bin/task4_collections.dart` |
| 5 — Future, Stream, JSON, вимірювання часу | `bin/task5_async.dart` | `dart run bin/task5_async.dart` |

Додаткові приклади:

```bash
dart run bin/task1_variables.dart 20 / 4
dart run bin/task2_functions.dart "Мені подобається Dart. Dart — це чудово!"
dart run bin/task4_collections.dart assets/students.csv
dart run bin/benchmark.dart
```

**Калькулятор** підтримує `+`, `-`, `*`, `/`, `%`, `^`. Для `*` в командному рядку беріть оператор у лапки (`"*"`), щоб оболонка не розгорнула шаблон файлів.

У `reports/` програма 4 створює `statistics.json` та `student_report.csv`, а програма 5 — `async_students.json` і `async_summary.json`. Зразкові файли з префіксом `sample_` **розраховано незалежно за прикладом CSV**: це **не** заявлені результати запуску Dart.

## 3. Файлова структура

```text
dart_basics_student/
├── .github/workflows/dart.yml        # перевірки при push на GitHub
├── assets/
│   ├── students.csv                  # вхід для завдання 4
│   └── students.json                 # вхід для завдання 5
├── bin/
│   ├── task1_variables.dart
│   ├── task2_functions.dart
│   ├── task3_classes.dart
│   ├── task4_collections.dart
│   ├── task5_async.dart
│   └── benchmark.dart
├── lib/
│   ├── data/sample_data.dart
│   ├── models/{person,student,professor,course,university}.dart
│   └── utils/{calculator,text_analyzer,data_processor,csv_student_reader}.dart
├── test/{models_test,utils_test,async_test}.dart
├── docs/                         # UML, графік, пояснення
├── reports/                      # приклади та згенеровані звіти
├── scripts/                      # запуск і збір логів
├── pubspec.yaml
└── README.md
```

## 4. Приклад класів, ООП і бізнес-логіки

```dart
final uni = University(name: 'Мій університет');
uni.addCourse(Course(
  id: 'DART101', name: 'Основи Dart', description: 'Синтаксис',
  credits: 4, instructor: 'Викладач',
));
final student = Student(
  id: 'S01', firstName: 'Олена', lastName: 'Коваль',
  birthDate: DateTime(2004, 6, 12), enrollmentYear: 2023,
);
uni.addStudent(student);
uni.enrollStudentInCourse('S01', 'DART101');
uni.recordGrade('S01', 'DART101', 95);
print(student.gpa);                      // 95.0
print(uni.generateStatistics());
final copy = Student.fromJson(student.toJson());
```

Імпортуйте в код: `import 'package:dart_basics_student/models/university.dart';`.

- `Student` і `Professor` успадковують `Person`, а `University.describePeople()` використовує **поліморфізм**.
- Доступ до складнішого курсу дозволений лише якщо **усі prerequisite-курси вже складено** з оцінкою від **60**.
- GPA — просте середнє **100-бальних оцінок** (це не міжнародний GPA шкали 4.0).
- `enrollmentYear` і `skills` додано до базової моделі, щоб коректно виконати групування за роком вступу та множинні операції.
- Помилкові оцінки, дублікати ID, невідомі курси чи відсутні передумови спричиняють контрольовані винятки.

**UML:** [PNG](docs/university_uml.png) · [SVG](docs/university_uml.svg)  
**Візуалізація з CSV:** [графік GPA](docs/gpa_chart.png)

## 5. Перевірки якості, тести, coverage

```bash
dart format .
dart analyze
dart test --reporter expanded
```

Для реального звіту покриття LCOV:

```bash
dart pub global activate coverage
dart pub global run coverage:test_with_coverage
```

Результат: `coverage/lcov.info` (після запуску на машині з SDK). За бажанням встановіть `lcov` і побудуйте HTML-звіт командою `genhtml coverage/lcov.info --output-directory coverage/html`.

Готові скрипти **запускають програми та зберігають реальний текст термінала** у `reports/console/`:

```powershell
# Windows PowerShell з кореня проєкту
powershell -ExecutionPolicy Bypass -File scripts/run_all.ps1
```

Якщо використовуєте **Windows PowerShell 5.1**, скрипт `run_all.ps1` збережений
у UTF-8 із BOM; службові рядки скрипта — ASCII. Він також встановлює кодову
сторінку 65001 та UTF-8 кодування консолі перед виконанням Dart, щоб запобігти
спотворенню кирилиці під час передавання результатів через `Tee-Object`. Якщо PowerShell показує `ParserError` із некоректними кириличними
символами, замініть старий файл версією з цього архіву. Попередження
`1 package has newer versions incompatible with dependency constraints`
саме по собі **не є помилкою** і не заважає запуску.


```bash
# Linux/macOS
bash scripts/run_all.sh
```

Перед здачею відкрийте результати в терміналі й **зробіть власні скриншоти** запуску. Скриншоти запуску не вкладено, оскільки Dart SDK в середовищі підготовки був відсутній.

## 6. Що передавати викладачу

- URL **публічного GitHub** репозиторію з файлами та історією комітів;
- скриншоти запуску всіх 5 програм, тестів і `dart analyze`;
- `reports/statistics.json`, `reports/student_report.csv`, `reports/async_summary.json` після запуску;
- UML з `docs/university_uml.png`, графік `docs/gpa_chart.png`;
- `coverage/lcov.info` після реального вимірювання покриття, а також заміри з `bin/benchmark.dart`.

**GitHub:** архів містить локальну папку `.git` з історією комітів, але **публічний репозиторій автоматично не створено**. Створіть порожній репозиторій `dart-basics-[прізвище]` у GitHub, а потім з кореня проєкту виконайте:

```bash
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/dart-basics-YOUR_SURNAME.git
git push -u origin main
```

Замініть `YOUR_USERNAME` і `YOUR_SURNAME` на власні значення. Якщо GitHub уже має `origin`, замість `git remote add origin ...` використайте `git remote set-url origin ...`. Облікові дані та публічний GitHub доступ — під контролем власника репозиторію.

## 7. Додаткова документація

- [Звіт про виконання](docs/REPORT.md) — відповідність кожному завданню та розрахунки;
- [Підготовка до захисту](docs/DEFENSE.md) — пояснення ключових рішень;
- [Контрольний список](docs/SUBMISSION_CHECKLIST.md) — що перевірити перед здачею.

## 8. Джерела інструментів

- Dart SDK: https://dart.dev/get-dart
- CLI: https://dart.dev/tools/dart-tool
- Пакет тестів: https://dart.dev/tools/dart-test
- Пакет покриття: https://pub.dev/packages/coverage

Уся прикладна логіка проєкту розміщена у власних файлах `lib/` та `bin/`, без копіювання готової реалізації з інтернету.
