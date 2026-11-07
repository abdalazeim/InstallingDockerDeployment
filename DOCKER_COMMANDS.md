# DOCKER_COMMANDS.md — Docker Engine & Docker Compose (Ubuntu, Phase 1 reference)

> **Scope:** Install/verify commands only. No integrations (Jenkins/Ansible/Traefik/Odoo/CI). Run on the target Ubuntu server. Record actual results in `INSTALLATION_REPORT.md`.

## System check (preserve existing containers/data)
```bash
lsb_release -a || cat /etc/os-release
id; groups
docker --version || echo "(not installed)"
docker compose version || echo "(not installed)"
docker ps -a || true
docker volume ls || true
docker network ls || true
ss -tlnp | grep -E ':(9000|9443)\s' || true
systemctl is-active docker 2>/dev/null || true
```

## Install Docker Engine + Compose plugin (official repository)
```bash
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
```

## Verify Docker
```bash
docker --version
docker compose version
docker version
docker info
systemctl is-active docker && systemctl is-enabled docker
# Non-destructive test (pulls/runs a small image) — run only if acceptable in the environment:
docker run --rm hello-world
```

## Useful checks (read-only)
```bash
docker ps
docker images
docker volume ls
docker network ls
docker compose ls
journalctl -u docker --no-pager -n 50
```

## Safety
- Do **not** run `docker system prune`, `docker volume rm`, or destructive commands unless explicitly intended and backed up.
- Adding a user to the `docker` group grants powerful access (review security): `sudo usermod -aG docker $USER` then re-login.