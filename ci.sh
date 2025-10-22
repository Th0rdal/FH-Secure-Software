#!/usr/bin/env bash
set -euo pipefail

DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"

# 1) Repo aktualisieren (in CI meist optional)
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git remote get-url origin >/dev/null 2>&1; then
    git fetch --prune origin || true
    git checkout "${DEFAULT_BRANCH}" || true
    git pull --rebase --autostash origin "${DEFAULT_BRANCH}" || true
  fi
fi

echo "==> Tests werden ausgeführt …"

run_tests() {
  if [ -f "Makefile" ] && grep -qE '(^test:)|(^\.PHONY:.*test)' Makefile; then
    make test
  elif [ -f "package.json" ] && command -v jq >/dev/null 2>&1 && jq -e '.scripts.test' package.json >/dev/null 2>&1; then
    if [ -f package-lock.json ]; then npm ci; else npm install; fi
    npm test
  elif [ -f "pytest.ini" ] || { [ -d "tests" ] && ls tests/*.py >/dev/null 2>&1; }; then
    python3 -m venv .venv && source .venv/bin/activate
    pip install -U pip pytest
    [ -f requirements.txt ] && pip install -r requirements.txt || true
    pytest -q
  elif [ -f "pom.xml" ]; then
    mvn -q -B -DskipTests=false test
  elif [ -f "go.mod" ] || [ -d "./cmd" ] || [ -d "./internal" ]; then
    go test ./...
  else
    echo "Kein bekannter Testbefehl gefunden. Setze TEST_CMD."
    return 2
  fi
}

if [ "${TEST_CMD:-}" != "" ]; then
  bash -lc "$TEST_CMD"
else
  run_tests
fi
