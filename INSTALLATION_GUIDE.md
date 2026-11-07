# INSTALLATION_GUIDE.md â€” Docker Engine + Docker Compose + Portainer (Phase 1, Install Only)

**Project path:** `InstallingDockerDeployment/` (target: `/opt/InstallingDockerDeployment`)  
> **Scope:** Install and verify **Docker Engine + Docker Compose plugin + Portainer CE** on Ubuntu Server only. **No integrations** (no Jenkins/Ansible/Traefik/Odoo/CI).  
> **Preserve:** do not delete containers/images/volumes/networks/files; do not recreate Portainer if it already exists and works.  
> **Truth:** commands below are for the Ubuntu target; record **actual** results in `INSTALLATION_REPORT.md`. No integration phase started.

## Phase 1 â€” System check (before changes)
```bash
lsb_release -a || cat /etc/os-release
id; groups
docker --version || echo "(not installed)"
docker compose version || echo "(not installed)"
docker ps -a 2>/dev/null || true
docker volume ls 2>/dev/null || true
docker network ls 2>/dev/null || true
ss -tlnp | grep -E ':(9000|9443)\s' || true
systemctl is-active docker 2>/dev/null || true
(manual preflight: lsb_release/docker/compose/ps/volumes/networks/ports — no deletions)
```

## Phase 2 â€” Install Docker (official repo)
```bash
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
docker --version && docker compose version && docker info
# optional, security-reviewed: sudo usermod -aG docker $USER && re-login
```

## Phase 3 â€” Install Portainer (preserve existing)
```bash
# if Portainer already installed/running: SKIP creation; verify only.
docker ps -a --filter name=portainer
docker volume create portainer_data
docker run -d --name portainer --restart=always \
  -p 127.0.0.1:9000:9000 -p 127.0.0.1:9443:9443 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:lts
```
Access (local-only): `https://localhost:9443` (or SSH tunnel). **Do not expose directly to the internet.**

## Phase 4 â€” Verification (required, record actual)
```bash
cd /opt/InstallingDockerDeployment
./VERIFY_INSTALLATION.sh   # saves verify-output.txt
# manual (record output):
docker --version
docker compose version
systemctl is-active docker && systemctl is-enabled docker
docker info
docker run --rm hello-world   # non-destructive test image pull/run (acceptable if environment allows)
docker ps -a --filter name=portainer
docker volume ls --filter name=portainer_data
```
**Portainer persistence:** confirm `portainer_data` exists and restart policy is `always`. After a controlled `docker restart portainer` (only if appropriate), verify UI/config persist. Record actual results.

## Phase 5 â€” Documentation & gate
Update `INSTALLATION_REPORT.md` and `VERSION_INFO.md` with real evidence. **PASS required before any integration. Stop here (no integration phase).**

References in this folder: `DOCKER_COMMANDS.md`, `PORTAINER_GUIDE.md`, `InstallingDockerCommand.md` (Arabic).
