#!/usr/bin/env python3
"""Лише структурна перевірка: НЕ замінює Dart SDK, аналізатор або тести."""
import csv
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
required = [
    'pubspec.yaml', 'README.md', '.gitignore',
    *[f'bin/task{i}_{name}.dart' for i, name in enumerate(
        ['variables', 'functions', 'classes', 'collections', 'async'], 1)],
    'lib/models/student.dart', 'lib/models/course.dart',
    'lib/models/person.dart', 'lib/models/professor.dart',
    'lib/models/university.dart',
    'lib/utils/calculator.dart', 'lib/utils/data_processor.dart',
    'test/models_test.dart', 'test/utils_test.dart', 'test/async_test.dart',
    'assets/students.csv', 'assets/students.json',
    'docs/university_uml.png', 'docs/gpa_chart.png',
]
for path in required:
    assert (ROOT / path).is_file(), f'Немає файлу {path}'
print(f'OK: {len(required)} обов’язкових файлів присутні')

# Verify all local Dart imports lead to files in the project.
count = 0
for source in ROOT.rglob('*.dart'):
    for url in re.findall(r"\b(?:import|export)\s+'([^']+)'", source.read_text(encoding='utf-8')):
        if url.startswith('dart:') or url.startswith('package:test/'):
            continue
        if url.startswith('package:dart_basics_student/'):
            target = ROOT / 'lib' / url.removeprefix('package:dart_basics_student/')
        elif url.startswith('package:'):
            raise AssertionError(f'Незрозумілий імпорт: {url}')
        else:
            target = source.parent / url
        assert target.is_file(), f'Імпорт у {source}: {url}'
        count += 1
print(f'OK: {count} власних Dart import/export шляхів існують')

with (ROOT / 'assets/students.csv').open(encoding='utf-8', newline='') as handle:
    csv_rows = list(csv.DictReader(handle))
json_rows = json.loads((ROOT / 'assets/students.json').read_text(encoding='utf-8'))
assert len(csv_rows) == len(json_rows) == 5
for csv_row, json_row in zip(csv_rows, json_rows):
    assert csv_row['id'] == json_row['id']
    assert csv_row['firstName'] == json_row['firstName']
    assert csv_row['lastName'] == json_row['lastName']
    assert int(csv_row['enrollmentYear']) == json_row['enrollmentYear']
    assert csv_row['courses'].split('|') == json_row['enrolledCourses']
    assert set(csv_row['skills'].split('|')) == set(json_row['skills'])
    csv_grades = dict(item.split(':') for item in csv_row['grades'].split('|'))
    assert all(float(value) == json_row['grades'][key] for key, value in csv_grades.items())
print('OK: CSV та JSON відповідають одним і тим самим 5 студентам')

sample = json.loads((ROOT / 'reports/sample_statistics.json').read_text(encoding='utf-8'))
assert sample['statistics']['studentCount'] == 5
assert abs(sample['statistics']['averageGpa'] - 80.0333333333) < 0.00001
assert sample['averagesByCourse'] == {'DART101': 80.25, 'MATH101': 81.0, 'ADV201': 97.0}
print('OK: приклад статистики відповідає заздалегідь обчисленим значенням')

revision_count = int(subprocess.check_output(
    ['git', 'rev-list', '--count', 'HEAD'], cwd=ROOT, text=True).strip())
assert revision_count >= 15, f'Git-комітів лише {revision_count}'
print(f'OK: локальна Git-історія містить {revision_count} комітів')
print('НЕ перевірено: компіляція Dart, dart analyze, dart test, LCOV і фактичний console output.')
