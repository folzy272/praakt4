$ErrorActionPreference = 'Stop'
# Use UTF-8 for native Dart output when piped through Windows PowerShell 5.1.
# Without this, Ukrainian text can become mojibake in the terminal/logs.
$utf8 = New-Object System.Text.UTF8Encoding($false)
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8
if ($env:OS -eq 'Windows_NT') {
    & chcp.com 65001 | Out-Null
}
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location -LiteralPath $projectRoot
try {
    if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
        throw 'Dart SDK was not found in PATH. Install Dart and reopen PowerShell.'
    }

    New-Item -ItemType Directory -Path 'reports/console' -Force | Out-Null

    Write-Host '=== Checking Dart SDK ==='
    & dart --version
    if ($LASTEXITCODE -ne 0) { throw 'Checking the Dart version failed.' }

    Write-Host '=== Installing project dependencies ==='
    & dart pub get
    if ($LASTEXITCODE -ne 0) { throw 'dart pub get failed.' }

    $programs = @(
        'task1_variables',
        'task2_functions',
        'task3_classes',
        'task4_collections',
        'task5_async'
    )

    foreach ($program in $programs) {
        Write-Host "=== Running $program ==="
        & dart run "bin/$program.dart" | Tee-Object -FilePath "reports/console/$program.txt"
        if ($LASTEXITCODE -ne 0) { throw "Program $program failed." }
    }

    Write-Host '=== Running the benchmark ==='
    & dart run bin/benchmark.dart | Tee-Object -FilePath 'reports/console/benchmark.txt'
    if ($LASTEXITCODE -ne 0) { throw 'Benchmark failed.' }

    Write-Host '=== Analyzing Dart code ==='
    & dart analyze | Tee-Object -FilePath 'reports/console/analyze.txt'
    if ($LASTEXITCODE -ne 0) { throw 'dart analyze failed.' }

    Write-Host '=== Running unit tests ==='
    & dart test --reporter expanded | Tee-Object -FilePath 'reports/console/tests.txt'
    if ($LASTEXITCODE -ne 0) { throw 'dart test failed.' }

    Write-Host 'All tasks finished. Logs are in reports/console/'
}
finally {
    Pop-Location
}
