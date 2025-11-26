
testfolder="$1"

echo "The argument is: $testfolder"

run_case_1() {
  apk add --no-cache python3 py3-pip
  python3 -m venv ./venv
  . ./venv/bin/activate
  pip install pytest
  cd riddle
  pytest
}

run_case_2() {
  apk add --no-cache rust cargo
  cargo test -q > /dev/null 2>&1
}

run_case_3() {
  apk add --no-cache gcc musl-dev
  gcc -o check_extension file.c check_extension.c
  ./check_extension
}

run_case_4() {
  apk add --no-cache openjdk21-jre
  apk add --no-cache openjdk21-jdk
  curl -L -o junit.jar "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-console-standalone/1.10.3/junit-platform-console-standalone-1.10.3.jar"
  cd admin-riddle-04
  javac -cp .:junit.jar *.java
  java -jar junit.jar execute --class-path . --scan-class-path
}

set +e
case "$testfolder" in
  "admin-riddle-01") run_case_1 ;;
  "admin-riddle-02") run_case_2 ;;
  "admin-riddle-03") run_case_3 ;;
  "admin-riddle-04") run_case_4 ;;
  *) echo "ERROR: testfolder must be 1..4 (got: $testfolder)"; exit 2 ;;
esac
rc=$?
set -e

if [[ "$rc" -ne 0 ]]; then
  echo "ERROR: case $testfolder failed (exit code: $rc)" >&2
  exit "$rc"
fi

echo "OK: case $testfolder succeeded"
