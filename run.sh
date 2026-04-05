#!/bin/bash
set -e

echo ""
echo " ===================================="
echo "  WFRunner - Nextflow / Streamflow"
echo " ===================================="
echo ""

if ! docker info >/dev/null 2>&1; then
    echo "[ERROR] Docker is not running. Please start Docker and retry."
    exit 1
fi

echo "[1/2] Pulling latest image from GitHub..."
docker compose pull || echo "[WARN] Pull failed. Trying with local image if available..."

echo ""
echo "[2/2] Starting WFRunner..."
echo ""
echo "  GUI  >  http://localhost:8082"
echo ""

docker rm -f wfrunner >/dev/null 2>&1 || true
docker run --rm --name wfrunner --privileged --cgroupns=host -p 8082:8082 ghcr.io/fairflow-bioinformaticsframework/streamflow_nextflow_formed:latest
