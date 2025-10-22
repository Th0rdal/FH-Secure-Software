FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

# Use the *singular* env var, set interpreter path, and make Docker socket explicit
ENV PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    ANSIBLE_COLLECTIONS_PATH="/usr/share/ansible/collections:/root/.ansible/collections" \
    ANSIBLE_PYTHON_INTERPRETER=/usr/local/bin/python3 \
    DOCKER_HOST=unix:///var/run/docker.sock

# Ansible + Docker SDK + unix-socket adapter
RUN python -m pip install --upgrade pip \
 && pip install \
      "ansible-core==2.16.6" \
      "docker==6.1.3" \
      "requests==2.31.0" \
      "requests-unixsocket==0.3.0"

# Preinstall community.docker (pin a known-good version)
ARG COLL_VER="3.10.0"
RUN ansible-galaxy collection download community.docker:==${COLL_VER} -p /tmp \
 && ansible-galaxy collection install /tmp/community-docker-${COLL_VER}.tar.gz \
      -p /usr/share/ansible/collections \
 && rm -f /tmp/community-docker-${COLL_VER}.tar.gz

WORKDIR /work
CMD ["bash"]
