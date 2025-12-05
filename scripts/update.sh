#!/bin/bash

set -e

echo "=========================================="
echo "  SOC Dashboard - Script de Atualização"
echo "=========================================="
echo ""

echo "📦 Parando containers..."
docker-compose stop

echo ""
echo "💾 Fazendo backup dos volumes (recomendado)..."
echo "   Você pode fazer backup manual dos volumes em /var/lib/docker/volumes/"
read -p "Continuar sem backup automático? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Abortado. Faça o backup e execute novamente."
    exit 1
fi

echo ""
echo "🔄 Baixando imagens atualizadas..."
docker-compose pull

echo ""
echo "🚀 Reiniciando containers com novas versões..."
docker-compose up -d

echo ""
echo "⏳ Aguardando serviços reiniciarem..."
sleep 30

echo ""
echo "📊 Status dos containers:"
docker-compose ps

echo ""
echo "🧹 Removendo imagens antigas não utilizadas..."
docker image prune -f

echo ""
echo "=========================================="
echo "  ✅ Atualização concluída!"
echo "=========================================="
echo ""
echo "Logs em tempo real: docker-compose logs -f"
