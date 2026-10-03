#!/usr/bin/env bash
# Run SwiftPM unit tests with coverage and print an llvm-cov report.
#
# Usage:
#   bash scripts/swift_coverage.sh            # test + text report
#   LCOV_OUT=coverage/lcov.info bash scripts/swift_coverage.sh
#                                       # also export lcov (for CI upload)
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> swift test --enable-code-coverage"
swift test --enable-code-coverage

PROFDATA=$(find .build -name 'default.profdata' -path '*codecov*' -print -quit)
BINARY=$(find .build -path '*BetterFitPackageTests.xctest/Contents/MacOS/BetterFitPackageTests' -print -quit)

if [ -z "$PROFDATA" ] || [ -z "$BINARY" ]; then
  echo "error: coverage artifacts not found (profdata/binary) under .build/" >&2
  exit 1
fi

echo ""
echo "==> llvm-cov report (Sources/ only)"
xcrun llvm-cov report \
  -instr-profile "$PROFDATA" \
  -ignore-filename-regex='\.build|/Tests/' \
  "$BINARY"

if [ -n "${LCOV_OUT:-}" ]; then
  mkdir -p "$(dirname "$LCOV_OUT")"
  xcrun llvm-cov export \
    -format=lcov \
    -instr-profile "$PROFDATA" \
    -ignore-filename-regex='\.build|/Tests/' \
    "$BINARY" > "$LCOV_OUT"
  echo ""
  echo "==> lcov written to $LCOV_OUT"
fi
