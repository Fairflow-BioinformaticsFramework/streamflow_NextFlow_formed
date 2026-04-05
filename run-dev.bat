@echo off
title WFRunner — Dev Build

echo.
echo  ====================================
echo   WFRunner — Local Build
echo  ====================================
echo.

docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running. Please start Docker Desktop and retry.
    pause
    exit /b 1
)

echo [1/2] Building image locally...
docker compose -f docker-compose.dev.yml build
if errorlevel 1 (
    echo [ERROR] Build failed.
    pause
    exit /b 1
)

echo.
echo [2/2] Starting WFRunner...
echo.
echo  GUI  ^>  http://localhost:8082
echo.

docker rm -f wfrunner >nul 2>&1
docker run --rm --name wfrunner --privileged --cgroupns=host -p 8082:8082 wfrunner
