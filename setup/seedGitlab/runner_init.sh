#!/bin/sh
set -e

# Load defaults if they exist
if [ -f /seedGitlab/runner.env ]; then
  . /seedGitlab/runner.env
fi

echo "--- Runner Init Skript gestartet ---"

# -------------------------------------------------------------
# STEP 0: HANDLE DYNAMIC TOKEN FILES
# -------------------------------------------------------------
# Allow passing a specific file path via env var, or default to standard
TARGET_TOKEN_FILE="${TOKEN_FILE:-/seedGitlab/runner_token}"

# Only attempt to read file if we don't already have a token in ENV
if [ -z "${RUNNER_TOKEN}" ]; then
  echo "RUNNER_TOKEN variable is empty. Checking for file: ${TARGET_TOKEN_FILE}"

  # 1. Wait loop: Wait for Ansible to create the file
  MAX_RETRIES=30
  COUNT=0
  while [ ! -f "${TARGET_TOKEN_FILE}" ]; do
    if [ "$COUNT" -ge "$MAX_RETRIES" ]; then
      echo "TIMEOUT: Token file ${TARGET_TOKEN_FILE} did not appear after 60 seconds."
      exit 1
    fi
    echo "Waiting for token file at ${TARGET_TOKEN_FILE}..."
    sleep 2
    COUNT=$((COUNT+1))
  done

  # 2. Read the file content into the variable
  RUNNER_TOKEN=$(cat "${TARGET_TOKEN_FILE}" | tr -d '\n' | tr -d '\r')
  echo "Token found and loaded from file."
fi

# -------------------------------------------------------------
# STEP 1: CONFIG CHECK & REGISTRATION
# -------------------------------------------------------------
if [ -f /etc/gitlab-runner/config.toml ] && grep -q "token" /etc/gitlab-runner/config.toml; then
  echo "Konfigurationsdatei existiert und enthält Token. Starte Runner."
else
  echo "Konfigurationsdatei nicht gefunden oder leer. Registriere Runner..."

  if [ -z "${RUNNER_TOKEN}" ]; then
    echo "FEHLER: RUNNER_TOKEN konnte nicht gefunden werden (Weder ENV noch Datei)."
    exit 1
  fi

  # Register
  gitlab-runner register \
    --non-interactive \
    --url "${CI_SERVER_URL}" \
    --registration-token "${RUNNER_TOKEN}" \
    --executor "${RUNNER_EXECUTOR}" \
    --docker-image "${DOCKER_IMAGE}" \
    --description "${RUNNER_DESCRIPTION}" \
    --tag-list "${RUNNER_TAG_LIST}" \
    --run-untagged="${RUNNER_RUN_UNTAGGED}" \
    --locked="${RUNNER_LOCKED}" \
    --docker-network-mode "setup_backend"

  echo "Runner erfolgreich registriert."
fi

# -------------------------------------------------------------
# STEP 2: START RUNNER
# -------------------------------------------------------------
echo "Starte gitlab-runner run..."
exec gitlab-runner run --user=root --working-directory=/home/gitlab-runner