# InstallingDockerDeployment — Docker Engine + Docker Compose + Portainer (Install Only)

**Project path:** `InstallingDockerDeployment/` (recommended target: `/opt/InstallingDockerDeployment`)

**Install only. No integrations. No Phase 2 work.**  
Installs and verifies **Docker Engine** + **Docker Compose plugin** + **Portainer CE** on Ubuntu Server. Docker Engine/Compose run natively on the host; Portainer runs as a Docker container (UI).  
Portainer binds to **`127.0.0.1`** by default (no direct internet exposure). Preserves existing data; does not recreate Portainer if it already exists. Originals preserved in [`legacy/`](legacy/).

## Install (Ubuntu target)
```bash
# Docker Engine + Compose (official repo)
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker && sudo systemctl start docker

# Portainer CE (skip if container already exists/running)
docker volume create portainer_data
docker run -d --name portainer --restart=always \
  -p 127.0.0.1:9000:9000 -p 127.0.0.1:9443:9443 \
  -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data \
  portainer/portainer-ce:lts
```

## Verify (record actual results)
```bash
docker --version && docker compose version
systemctl is-active docker && systemctl is-enabled docker
docker run --rm hello-world
docker ps -a --filter name=portainer
# or: ./VERIFY_INSTALLATION.sh  (saves verify-output.txt)
```

## Troubleshooting & Maintenance

### Restart Portainer
```bash
sudo docker restart portainer
```

### Check setup/token logs
```bash
sudo docker logs portainer 2>&1 | grep -i -E "setup|token|initial"
```

### List containers
```bash
docker ps
```

### View logs for a specific container
```bash
sudo docker logs CONTAINER_NAME 2>&1
```
Replace `CONTAINER_NAME` with the target container name or ID.

### Search Portainer logs for token-related messages
```bash
sudo docker logs portainer 2>&1 | grep -i -A 5 -B 5 "token"
```

### If you still receive a 403 error
Inspect recent Portainer logs (last 5 minutes):
```bash
sudo docker logs --since 5m portainer 2>&1 | tail -60
```

Access: `https://localhost:9443` (local/SSH tunnel only). Update [`INSTALLATION_REPORT.md`](INSTALLATION_REPORT.md) and [`VERSION_INFO.md`](VERSION_INFO.md) with real evidence. **PASS required; stop — no integrations.**

## Files
- [`INSTALLATION_GUIDE.md`](INSTALLATION_GUIDE.md), [`DOCKER_COMMANDS.md`](DOCKER_COMMANDS.md), [`PORTAINER_GUIDE.md`](PORTAINER_GUIDE.md) — full steps/checks
- [`INSTALLATION_REPORT.md`](INSTALLATION_REPORT.md) — gate (actual evidence)
- [`VERIFY_INSTALLATION.sh`](VERIFY_INSTALLATION.sh), [`VERSION_INFO.md`](VERSION_INFO.md), [`InstallingDockerCommand.md`](InstallingDockerCommand.md) (Arabic)