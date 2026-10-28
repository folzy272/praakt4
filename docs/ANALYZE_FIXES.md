# Усунення помилок першого запуску на Windows

У Windows PowerShell 5.1 при першому запуску скрипта `scripts/run_all.ps1` програми виконувалися, але `dart analyze` повідомляв `7 issues found`.

## Виправлення, внесені до коду

| Повідомлення аналізатора | Файл | Зміна |
|---|---|---|
| `dead_code` (2 рази) | `bin/task1_variables.dart` | Логічні значення тепер обчислюються на основі даних під час виконання, а не беруться з констант `true`/`false` |
| `equal_elements_in_set` | `bin/task1_variables.dart` | Елементи множини задаються без повторів; додавання дубліката продемонстровано через `Set.add()` |
| `dead_code` (ще 1 раз) | `bin/task1_variables.dart` | Nullable-значення отримуємо через окрему функцію; це дозволяє показати реальний null-safe доступ |
| `unnecessary_import` | `lib/utils/data_processor.dart` | Прибрано зайвий імпорт `student.dart`, оскільки він експортується з `university.dart` |
| `library_prefixes` (2 рази) | `test/async_test.dart` | Назви імпортів змінено на `async_demo` і `functions_demo` |

## Некоректна кирилиця в терміналі

До початку запуску Dart скрипт `scripts/run_all.ps1` встановлює `[Console]::InputEncoding`, `[Console]::OutputEncoding`, `$OutputEncoding` і кодову сторінку Windows `65001` (UTF-8). Це необхідно насамперед для Windows PowerShell 5.1 при використанні `Tee-Object`.

## Повторна перевірка

Відкрийте **новий термінал** у корені проєкту та запустіть:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_all.ps1
```

Якщо потрібно перевірити окремо:

```powershell
dart analyze
dart test --reporter expanded
```

**Увага:** у середовищі підготовки цієї версії Dart SDK відсутній, тому результат `No issues found!` і пройдені тести не заявляються як уже перевірені. Перевірено структуру файлів, імпорти, узгодженість даних та кодування скрипта. Наведені зміни адресно усувають саме 7 зауважень із наданого скриншота.
