#!/bin/sh

set -e

. /seedGitlab/runner.env


echo "--- Runner Init Skript gestartet ---"


# 1. Prüfen, ob die Konfiguration existiert
if [ -f /etc/gitlab-runner/config.toml ]; then
  echo "Konfigurationsdatei existiert. Starte Runner."
else
  echo "Konfigurationsdatei nicht gefunden. Registriere Runner..."
  
  # 2. Registrierung
  if [ -z "${RUNNER_TOKEN}" ]; then
    echo "FEHLER: RUNNER_TOKEN ist nicht gesetzt. Registrierung nicht möglich."
    exit 1
  fi
  
  # Führe den Registrierungsbefehl aus
  # ...
  gitlab-runner register \
    --non-interactive \
    --url "${CI_SERVER_URL}" \
    --registration-token "${RUNNER_TOKEN}" \
    --executor "${RUNNER_EXECUTOR}" \
    --docker-image "${DOCKER_IMAGE}" \
    --description "${RUNNER_DESCRIPTION}" \
    --tag-list "${RUNNER_TAG_LIST}" \
    --run-untagged="${RUNNER_RUN_UNTAGGED}" \
    --locked="${RUNNER_LOCKED}"
    
  echo "Runner erfolgreich registriert."
  
fi # Fehler 2 (Logik): Das 'fi' muss hier stehen, um den Registrierungsblock korrekt abzuschließen

# 3. Den Runner im Vordergrund starten
echo "Starte gitlab-runner run..."
exec gitlab-runner run --user=root --working-directory=/home/gitlab-runner