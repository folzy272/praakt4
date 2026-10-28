#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v dart >/dev/null || { echo 'Dart SDK не знайдено у PATH' >&2; exit 1; }
mkdir -p reports/console
dart --version 2>&1 | tee reports/console/sdk.txt
dart pub get
for n in 1 2 3 4 5; do
  case "$n" in
    1) file=task1_variables;; 2) file=task2_functions;;
    3) file=task3_classes;; 4) file=task4_collections;;
    5) file=task5_async;;
  esac
  dart run "bin/${file}.dart" | tee "reports/console/${file}.txt"
done
dart run bin/benchmark.dart | tee reports/console/benchmark.txt
dart analyze | tee reports/console/analyze.txt
dart test --reporter expanded | tee reports/console/tests.txt
printf 'Реальні логи збережено до reports/console/\n'
