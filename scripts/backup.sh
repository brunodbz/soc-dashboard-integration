#!/bin/bash

set -e

BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"

echo "=========================================="
echo "  SOC Dashboard - Script de Backup"
echo "=========================================="
echo ""

mkdir -p "$BACKUP_DIR"

echo "📦 Criando backup dos volumes Docker..."
docker-compose stop

# Backup Elasticsearch
echo "  - Elasticsearch data..."
docker run --rm -v soc-dashboard-integration_elastic-data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar czf /backup/elastic-data.tar.gz -C /data .

# Backup Kibana
echo "  - Kibana data..."
docker run --rm -v soc-dashboard-integration_kibana-data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar czf /backup/kibana-data.tar.gz -C /data .

# Backup Grafana
echo "  - Grafana data..."
docker run --rm -v soc-dashboard-integration_grafana-data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar czf /backup/grafana-data.tar.gz -C /data .

# Backup OpenCTI (MinIO + Redis)
echo "  - MinIO data..."
docker run --rm -v soc-dashboard-integration_minio-data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar czf /backup/minio-data.tar.gz -C /data .

echo "  - Redis data..."
docker run --rm -v soc-dashboard-integration_redis-data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar czf /backup/redis-data.tar.gz -C /data .

# Backup configurações
echo "  - Arquivos de configuração..."
cp .env "$BACKUP_DIR/.env.backup"
cp docker-compose.yml "$BACKUP_DIR/docker-compose.yml.backup"

docker-compose start

echo ""
echo "✅ Backup concluído em: $BACKUP_DIR"
echo ""
echo "Arquivos criados:"
ls -lh "$BACKUP_DIR"
