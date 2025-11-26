set -euo pipefail

# 1) Pin & install collection (download first, install from file to avoid Galaxy hiccups)
cat >/work/requirements.yml <<'YAML'
---
collections:
  - name: community.docker
    version: "3.10.0"
YAML

ansible-galaxy collection download community.docker:==3.10.0 -p /work
ansible-galaxy collection install /work/community-docker-3.10.0.tar.gz \
  -p /usr/share/ansible/collections

# 2) Ensure Ansible can find the collection
export ANSIBLE_COLLECTIONS_PATHS="/usr/share/ansible/collections:/root/.ansible/collections"

# 3) Dependencies for community.docker on the controller (localhost)
python3 -m pip install --upgrade pip
pip install -q --no-cache-dir docker

# 4) Optional: prove the module is visible (diagnostic)
ansible-doc -t module community.docker.docker_container_exec >/dev/null

# 5) Run the playbook
exec ansible-playbook -i localhost, /work/seed.yml
