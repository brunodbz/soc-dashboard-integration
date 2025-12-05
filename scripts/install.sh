#!/bin/bash

set -e

echo "=========================================="
echo "  SOC Dashboard - Script de Instalação"
echo "=========================================="
echo ""

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não encontrado. Por favor, instale o Docker primeiro."
    echo "   Visite: https://docs.docker.com/get-docker/"
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose não encontrado. Por favor, instale o Docker Compose."
    echo "   Visite: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✓ Docker encontrado"
echo "✓ Docker Compose encontrado"
echo ""

# Verificar se .env existe
if [ ! -f ".env" ]; then
    echo "⚠️  Arquivo .env não encontrado. Copiando de .env.example..."
    cp .env.example .env
    echo ""
    echo "⚠️  IMPORTANTE: Edite o arquivo .env com suas credenciais antes de continuar!"
    echo ""
    read -p "Pressione ENTER após configurar o .env ou Ctrl+C para sair..."
fi

echo "📦 Baixando imagens Docker (isso pode demorar alguns minutos)..."
docker-compose pull

echo ""
echo "🚀 Iniciando containers..."
docker-compose up -d

echo ""
echo "⏳ Aguardando serviços ficarem prontos..."
sleep 30

# Verificar status dos containers
echo ""
echo "📊 Status dos containers:"
docker-compose ps

echo ""
echo "=========================================="
echo "  ✅ Instalação concluída!"
echo "=========================================="
echo ""
echo "Acesse os serviços:"
echo "  🔍 Kibana (SIEM):           http://localhost:5601"
echo "  📊 Grafana:                 http://localhost:3000"
echo "  🛡️  OpenCTI:                 http://localhost:8080"
echo "  📦 MinIO Console:           http://localhost:9001"
echo "  🐰 RabbitMQ Management:     http://localhost:15672"
echo ""
echo "Credenciais padrão (verifique seu .env):"
echo "  Kibana:   elastic / (ver ELASTIC_PASSWORD no .env)"
echo "  Grafana:  admin / (ver GRAFANA_PASSWORD no .env)"
echo "  OpenCTI:  (ver OPENCTI_ADMIN_EMAIL e PASSWORD no .env)"
echo ""
echo "⚠️  Próximos passos:"
echo "  1. Configure as integrações no Kibana"
echo "  2. Configure conectores no OpenCTI"
echo "  3. Ajuste dashboards conforme necessário"
echo ""
echo "Para parar: docker-compose stop"
echo "Para logs: docker-compose logs -f [nome-servico]"
echo "=========================================="
