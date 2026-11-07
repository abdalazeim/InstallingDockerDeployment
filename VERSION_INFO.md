# VERSION_INFO.md — Docker Engine + Compose + Portainer (Phase 1)
> Update after actual execution. Do not guess.

| Component | Before | After (observed) | Notes |
|---|---|---|---|
| Ubuntu/kernel/arch | not observed | not observed | |
| Docker Engine | not observed/may exist | not observed | `docker --version` |
| Docker Compose plugin | not observed | not observed | `docker compose version` |
| containerd/buildx | — | not observed | |
| Portainer | not observed | not observed | `portainer/portainer-ce:lts`, name `portainer`, volume `portainer_data` |
| Portainer bind | — | not observed | default `127.0.0.1:9000,9443` (local-only) |
| Install method | — | not observed | official Docker apt repo + `docker run` |