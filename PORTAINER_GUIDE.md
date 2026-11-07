# PORTAINER_GUIDE.md — Portainer CE (Ubuntu, Phase 1: install only)

> **Scope:** Deploy and verify Portainer Community Edition only. **No integrations** (no Traefik/Jenkins/Ansible/Odoo/CI links) in this phase.  
> **Security:** Bind to `127.0.0.1` (local-only) by default. **Do not expose Portainer directly to the internet.** Portainer mounts `/var/run/docker.sock` (high privilege) — restrict access.

## Pre-check (preserve existing install/data)
```bash
docker volume ls | grep portainer_data || true
docker ps -a --filter name=portainer
ss -tlnp | grep -E ':(9000|9443)\s' || true
```
**If Portainer is already installed and running:** do **not** recreate it and do **not** delete `portainer_data`. Record status in `INSTALLATION_REPORT.md`.

## Install / run (only if not already present)
```bash
docker volume create portainer_data

docker run -d \
  --name portainer \
  --restart=always \
  -p 127.0.0.1:9000:9000 \
  -p 127.0.0.1:9443:9443 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:lts
```

## Access (local-only default)
- **HTTPS UI:** `https://localhost:9443` (on the server) — complete first-time admin setup over a trusted path.
- **Remote (controlled):** use an SSH tunnel, e.g. `ssh -L 9443:127.0.0.1:9443 user@server`, then open `https://localhost:9443` locally. Alternatively use a VPN/firewall-restricted path. **Later (Phase 2, gated, explicit request):** place behind Traefik with TLS/auth — do not publish container ports directly to the public internet.

## Verify
```bash
docker ps --filter name=portainer
docker inspect --format '{{.HostConfig.RestartPolicy.Name}}' portainer
docker volume ls --filter name=portainer_data
docker logs --tail=50 portainer
```
Confirm the UI is reachable as configured and access is restricted.

## Persistence / restart check
- `--restart=always` and the `portainer_data` volume keep configuration across container restarts.
- After a controlled restart (if appropriate): `docker restart portainer` (or host reboot in a maintenance window) and confirm settings/users remain and the UI works. Record **actual** results; do not disrupt production.

## Safety
- Never delete `portainer_data` or recreate Portainer unless explicitly intended and backed up.
- Do not expose `9000/9443` or the Docker socket to the internet.