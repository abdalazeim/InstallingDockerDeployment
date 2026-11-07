#!/usr/bin/env bash
# VERIFY_INSTALLATION.sh — Phase 1 Docker/Compose/Portainer verification (Ubuntu). No integrations.
set -euo pipefail
cd "$(dirname "$0")"
OUT="${1:-verify-output.txt}"
exec > >(tee "$OUT") 2>&1
echo "# Phase 1 Docker/Compose/Portainer verify $(date -Is)"
echo "## docker --version"; docker --version
echo "## docker compose version"; docker compose version
echo "## docker service"; systemctl is-active docker 2>/dev/null || true; systemctl is-enabled docker 2>/dev/null || true
echo "## docker info (summary)"; docker info 2>&1 | head -40
echo "## hello-world (if acceptable)"; docker run --rm hello-world 2>&1 | head -25
echo "## portainer container"; docker ps -a --filter "name=portainer" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null || true
echo "## portainer volume"; docker volume ls --filter "name=portainer_data" 2>/dev/null || true
echo "## DONE - update INSTALLATION_REPORT.md and VERSION_INFO.md with actual evidence. PASS only if all required checks succeed. No integrations before PASS."