@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo   SOC Dashboard - Script de Instalacao
echo ==========================================
echo.

REM Verificar Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo X Docker nao encontrado. Instale o Docker Desktop primeiro.
    echo   Visite: https://docs.docker.com/desktop/install/windows-install/
    pause
    exit /b 1
)

echo * Docker encontrado
echo * Docker Compose encontrado
echo.

REM Verificar .env
if not exist ".env" (
    echo ! Arquivo .env nao encontrado. Copiando de .env.example...
    copy .env.example .env
    echo.
    echo ! IMPORTANTE: Edite o arquivo .env com suas credenciais!
    echo.
    pause
)

echo Baixando imagens Docker...
docker-compose pull

echo.
echo Iniciando containers...
docker-compose up -d

echo.
echo Aguardando servicos ficarem prontos...
timeout /t 30 /nobreak >nul

echo.
echo Status dos containers:
docker-compose ps

echo.
echo ==========================================
echo   Instalacao concluida!
echo ==========================================
echo.
echo Acesse os servicos:
echo   Kibana (SIEM):          http://localhost:5601
echo   Grafana:                http://localhost:3000
echo   OpenCTI:                http://localhost:8080
echo   MinIO Console:          http://localhost:9001
echo   RabbitMQ Management:    http://localhost:15672
echo.
echo Para parar: docker-compose stop
echo Para logs: docker-compose logs -f [nome-servico]
echo ==========================================
echo.
pause
