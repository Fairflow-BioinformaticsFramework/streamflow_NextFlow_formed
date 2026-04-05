#!/bin/bash
set -e

echo ""
echo " ===================================="
echo "  WFRunner — Local Build"
echo " ===================================="
echo ""

if ! docker info >/dev/null 2>&1; then
    echo "[ERROR] Docker is not running. Please start Docker and retry."
    exit 1
fi

echo "[1/2] Building image locally..."
docker compose -f docker-compose.dev.yml build

echo ""
echo "[2/2] Starting WFRunner..."
echo ""
echo "  GUI  >  http://localhost:8082"
echo ""

docker rm -f wfrunner >/dev/null 2>&1 || true
docker run --rm --name wfrunner --privileged --cgroupns=host -p 8082:8082 wfrunner
