#!/bin/bash

echo "=========================================="
echo "  SOC Dashboard - Verificação de Saúde"
echo "=========================================="
echo ""

# Função para verificar serviço
check_service() {
    local service_name=$1
    local url=$2
    local expected_code=$3

    printf "%-30s" "Verificando $service_name..."

    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" -m 5 || echo "000")

    if [ "$status_code" == "$expected_code" ]; then
        echo "✓ OK ($status_code)"
        return 0
    else
        echo "✗ FALHA ($status_code)"
        return 1
    fi
}

# Verificar containers
echo "📦 Status dos Containers:"
docker-compose ps
echo ""

# Verificar serviços HTTP
echo "🌐 Verificando Endpoints:"
check_service "Elasticsearch" "http://localhost:9200" "200"
check_service "Kibana" "http://localhost:5601/api/status" "200"
check_service "Grafana" "http://localhost:3000/api/health" "200"
check_service "OpenCTI" "http://localhost:8080/graphql" "200"
check_service "MinIO" "http://localhost:9000/minio/health/live" "200"

echo ""
echo "📊 Uso de Recursos:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo ""
echo "💾 Espaço em Disco (Volumes):"
docker system df -v | grep -A 20 "Local Volumes"

echo ""
echo "=========================================="
