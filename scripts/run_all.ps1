$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '..')
try {
    if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
        throw 'Dart SDK не знайдено. Встановіть SDK та відкрийте новий PowerShell.'
    }
    New-Item -ItemType Directory -Force 'reports/console' | Out-Null
    dart --version 2>&1 | Tee-Object -FilePath 'reports/console/sdk.txt'
    dart pub get
    if ($LASTEXITCODE -ne 0) { throw 'Помилка dart pub get' }
    $programs = @('task1_variables', 'task2_functions', 'task3_classes', 'task4_collections', 'task5_async')
    foreach ($program in $programs) {
        dart run "bin/$program.dart" | Tee-Object -FilePath "reports/console/$program.txt"
        if ($LASTEXITCODE -ne 0) { throw "Не запустився $program" }
    }
    dart run bin/benchmark.dart | Tee-Object -FilePath 'reports/console/benchmark.txt'
    if ($LASTEXITCODE -ne 0) { throw 'Помилка бенчмарку' }
    dart analyze | Tee-Object -FilePath 'reports/console/analyze.txt'
    if ($LASTEXITCODE -ne 0) { throw 'Помилка аналізу' }
    dart test --reporter expanded | Tee-Object -FilePath 'reports/console/tests.txt'
    if ($LASTEXITCODE -ne 0) { throw 'Тести завершилися з помилкою' }
    Write-Host 'Готово: звіти й текстові логи — у reports/console/'
} finally {
    Pop-Location
}
