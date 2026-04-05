@echo off
title WFRunner

echo.
echo  ====================================
echo   WFRunner — Nextflow / Streamflow
echo  ====================================
echo.

docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running. Please start Docker Desktop and retry.
    pause
    exit /b 1
)

echo [1/2] Pulling latest image from GitHub...
docker compose pull
if errorlevel 1 (
    echo [WARN] Pull failed. Trying with local image if available...
)

echo.
echo [2/2] Starting WFRunner...
echo.
echo  GUI  ^>  http://localhost:8082
echo.

docker rm -f wfrunner >nul 2>&1
docker run --rm --name wfrunner --privileged --cgroupns=host -p 8082:8082 ghcr.io/fairflow-bioinformaticsframework/wfrunner:latest
