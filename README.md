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

---

## Portainer LAN Access Guide (Separate Network Setup)

Concise reference for installing Portainer on an Ubuntu server and making it reachable from the local network (LAN).

### 1. Prerequisites
Ensure Docker Engine is installed and running:
```bash
sudo docker --version
sudo docker ps
```

### 2. Create a persistent data volume
```bash
sudo docker volume create portainer_data
```
This volume stores Portainer data (admin account, environment connections, users, and internal settings) so data is preserved if the container is removed and recreated, as long as the volume remains.

### 3. Run Portainer with correct network bindings
```bash
sudo docker run -d \
  --name portainer \
  --restart=always \
  -p 9443:9443 \
  -p 127.0.0.1:9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:lts
```

| Option | Purpose |
| --- | --- |
| `-d` | Run in background |
| `--name portainer` | Container name |
| `--restart=always` | Auto-restart on failure/reboot |
| `-p 9443:9443` | Expose HTTPS on all interfaces (LAN-accessible) |
| `-p 127.0.0.1:9000:9000` | Expose HTTP on localhost only |
| `-v /var/run/docker.sock:/var/run/docker.sock` | Allow Portainer to manage Docker |
| `-v portainer_data:/data` | Persist Portainer data |

**Important (common cause of LAN access issues):**
- `127.0.0.1:9443:9443` → localhost only (not reachable from other machines)
- `9443:9443` → reachable from the LAN (binds to `0.0.0.0`)

### 4. Verify the installation
```bash
sudo docker ps --filter name=portainer
sudo docker port portainer
curl -kI https://127.0.0.1:9443
```
Expected port mapping:
```text
9443/tcp -> 0.0.0.0:9443
9000/tcp -> 127.0.0.1:9000
```
An HTTP response (e.g. `200 OK`) from the `curl` check confirms Portainer is responding locally.

### 5. Access Portainer from another device on the LAN
1. Get the server IP address:
   ```bash
   hostname -I
   ```
2. Open in a browser on a device in the same network:
   ```text
   https://<SERVER_IP>:9443
   ```
   Example: `https://192.168.74.68:9443`

A browser warning for a self-signed HTTPS certificate is expected with the default setup. Proceed only if you are sure you are connecting to the correct server.

### 6. Fix: Portainer installed but not reachable over LAN
If Portainer works locally but not from other devices, the container is often bound to localhost. You can fix this without deleting Portainer data.

**Inspect current bindings and mounts:**
```bash
sudo docker inspect portainer --format '{{json .HostConfig.PortBindings}}'
sudo docker inspect portainer --format '{{json .Mounts}}'
```
A problematic binding looks like:
```json
{"9443/tcp":[{"HostIp":"127.0.0.1","HostPort":"9443"}]}
```
Confirm that `portainer_data` is mounted at `/data` and that the Docker socket is mounted.

**Back up data (recommended):**
```bash
sudo docker run --rm \
  -v portainer_data:/data:ro \
  -v /opt:/backup \
  alpine sh -c 'tar -czf /backup/portainer_backup.tar.gz -C /data .'
```

**Recreate the container (reuse the same volume):**
```bash
sudo docker stop portainer
sudo docker rm portainer

sudo docker run -d \
  --name portainer \
  --restart=always \
  -p 9443:9443 \
  -p 127.0.0.1:9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:lts
```
Reusing the original `portainer_data` volume restores the existing Portainer state while correcting LAN access.

**Caution:** Do **not** use `docker rm -v`, do **not** delete `portainer_data`, and do **not** run `docker volume prune` during this repair.