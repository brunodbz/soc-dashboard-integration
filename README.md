# SOC Dashboard - Plataforma Integrada de Segurança

Dashboard completo para Security Operations Center (SOC) com integração de múltiplas ferramentas de segurança: Elasticsearch (SIEM), Tenable.io, Microsoft Defender e OpenCTI.

## 🎯 Características

- **SIEM Centralizado**: Elasticsearch + Kibana para correlação de eventos
- **Threat Intelligence**: OpenCTI para inteligência de ameaças
- **Gestão de Vulnerabilidades**: Integração com Tenable.io
- **Proteção de Endpoints**: Microsoft Defender for Endpoint
- **Visualização Avançada**: Grafana com dashboards customizados
- **Correlação Automática**: Eventos críticos e de alta severidade
- **Containerizado**: 100% Docker para fácil instalação e atualização

## 📋 Requisitos

### Hardware Mínimo
- **CPU**: 4 cores
- **RAM**: 16 GB
- **Disco**: 100 GB SSD

### Hardware Recomendado
- **CPU**: 8+ cores
- **RAM**: 32 GB
- **Disco**: 500 GB SSD

### Software
- Docker Engine 24.0+ ou Docker Desktop
- Docker Compose 2.0+
- 10 GB de espaço livre para imagens

### Credenciais Necessárias
- **Tenable.io**: Access Key + Secret Key ([obter aqui](https://cloud.tenable.com))
- **Microsoft Defender**: Tenant ID, Client ID, Client Secret (Azure AD)
- **Acesso de rede**: Portas 3000, 5601, 8080, 9000, 9001, 9200, 15672

## 🚀 Instalação Rápida

### Linux / macOS

```bash
# 1. Extrair o arquivo ZIP
unzip soc-dashboard-integration.zip
cd soc-dashboard-integration

# 2. Configurar variáveis de ambiente
cp .env.example .env
nano .env  # ou vim, code, etc

# 3. Executar instalação
chmod +x scripts/install.sh
./scripts/install.sh
```

### Windows

```powershell
# 1. Extrair o arquivo ZIP
# 2. Abrir PowerShell como Administrador
cd soc-dashboard-integration

# 3. Configurar variáveis de ambiente
copy .env.example .env
notepad .env

# 4. Executar instalação
scripts\install.bat
```

## ⚙️ Configuração

### 1. Editar Arquivo .env

Abra o arquivo `.env` e configure as seguintes variáveis:

```bash
# Elasticsearch (SIEM)
ELASTIC_PASSWORD=SuaSenhaForte123!

# OpenCTI
OPENCTI_ADMIN_EMAIL=admin@soc.local
OPENCTI_ADMIN_PASSWORD=SuaSenhaForte123!
OPENCTI_ADMIN_TOKEN=token-unico-de-32-caracteres-aqui

# Tenable.io
TENABLE_ACCESS_KEY=sua-access-key-aqui
TENABLE_SECRET_KEY=sua-secret-key-aqui

# Microsoft Defender
DEFENDER_TENANT_ID=seu-tenant-id
DEFENDER_CLIENT_ID=seu-client-id  
DEFENDER_CLIENT_SECRET=seu-client-secret

# Grafana
GRAFANA_USER=admin
GRAFANA_PASSWORD=SuaSenhaForte123!
```

### 2. Obter Credenciais

#### Tenable.io
1. Acesse [https://cloud.tenable.com](https://cloud.tenable.com)
2. Vá em **Settings → My Account → API Keys**
3. Clique em **Generate** e copie Access Key + Secret Key
4. Cole no arquivo `.env`

#### Microsoft Defender
1. Acesse [Azure Portal](https://portal.azure.com)
2. Vá em **Azure Active Directory → App registrations → New registration**
3. Nome: "SOC-Dashboard", tipo: Web, URI: http://localhost
4. Em **Certificates & secrets**, crie um novo Client Secret
5. Em **API permissions**, adicione:
   - Microsoft Graph: `SecurityEvents.Read.All`
   - WindowsDefenderATP: `Alert.Read.All`, `Machine.Read.All`, `Vulnerability.Read.All`
6. Clique em **Grant admin consent**
7. Copie Tenant ID, Client ID e Client Secret para o `.env`

### 3. Configurar Integrações no Kibana

Após a instalação, acesse http://localhost:5601

```bash
# Login
Usuário: elastic
Senha: (valor de ELASTIC_PASSWORD no .env)
```

#### Microsoft Defender Integration
1. Menu lateral → **Management → Integrations**
2. Busque "Microsoft Defender for Endpoint"
3. Clique em **Add Microsoft Defender for Endpoint**
4. Configure:
   - **Tenant ID**: seu tenant ID
   - **Client ID**: seu client ID
   - **Client Secret**: seu client secret
   - **Interval**: 5m (recomendado)
5. Clique em **Save integration**

#### Tenable Integration
1. Em **Management → Integrations**
2. Busque "Tenable.io"
3. Clique em **Add Tenable.io**
4. Configure:
   - **Access Key**: sua access key
   - **Secret Key**: sua secret key
   - **URL**: https://cloud.tenable.com
   - **Interval**: 24h
5. Clique em **Save integration**

#### OpenCTI Integration
1. Em **Management → Integrations**
2. Busque "OpenCTI"
3. Configure:
   - **URL**: http://opencti:8080
   - **Token**: (valor de OPENCTI_ADMIN_TOKEN no .env)
4. Salve a integração

### 4. Configurar OpenCTI

Acesse http://localhost:8080

```bash
# Login
Email: (valor de OPENCTI_ADMIN_EMAIL no .env)
Senha: (valor de OPENCTI_ADMIN_PASSWORD no .env)
```

#### Verificar Conectores
1. Menu superior → **Data → Connectors**
2. Verifique se os conectores estão ativos:
   - ✅ Tenable Vulnerability Management
   - ✅ CVE
3. Se inativos, verifique os logs: `docker-compose logs connector-tenable`

### 5. Acessar Grafana

Acesse http://localhost:3000

```bash
# Login
Usuário: (valor de GRAFANA_USER no .env)
Senha: (valor de GRAFANA_PASSWORD no .env)
```

O dashboard **"SOC - Alertas Críticos e Alta Severidade"** estará disponível em:
- Menu lateral → **Dashboards → SOC**

## 📊 Dashboards Disponíveis

### Kibana (SIEM)
- **Security → Dashboards**: Dashboards de segurança pré-configurados
- **Security → Alerts**: Alertas em tempo real
- **Security → Timelines**: Investigações de incidentes

### Grafana
- **SOC - Alertas Críticos**: Visão consolidada de eventos críticos
  - Contadores de alertas por severidade
  - Distribuição por fonte (Defender, Tenable, OpenCTI)
  - Top 10 hosts em risco
  - Timeline de eventos
  - Tabelas de vulnerabilidades críticas

### OpenCTI
- **Dashboard**: Visão geral de threat intelligence
- **Analysis**: Análise de indicadores e observáveis
- **Data**: CVEs, vulnerabilidades e ameaças

## 🔄 Atualização

### Atualizar Todas as Imagens

```bash
# Linux/macOS
./scripts/update.sh

# Windows
scripts\update.bat
```

### Atualizar Componente Específico

```bash
docker-compose pull [nome-servico]
docker-compose up -d [nome-servico]

# Exemplos:
docker-compose pull elasticsearch
docker-compose up -d elasticsearch

docker-compose pull grafana
docker-compose up -d grafana
```

## 💾 Backup e Restore

### Fazer Backup

```bash
# Linux/macOS
./scripts/backup.sh

# Será criado em: ./backups/YYYYMMDD_HHMMSS/
```

### Restaurar Backup

```bash
# Parar containers
docker-compose down

# Restaurar volumes (substitua BACKUP_DIR pelo caminho do backup)
BACKUP_DIR=./backups/20250126_103000

docker run --rm -v soc-dashboard-integration_elastic-data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar xzf /backup/elastic-data.tar.gz -C /data
docker run --rm -v soc-dashboard-integration_kibana-data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar xzf /backup/kibana-data.tar.gz -C /data
docker run --rm -v soc-dashboard-integration_grafana-data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar xzf /backup/grafana-data.tar.gz -C /data

# Reiniciar
docker-compose up -d
```

## 🔍 Troubleshooting

### Verificar Saúde dos Serviços

```bash
./scripts/health_check.sh
```

### Ver Logs

```bash
# Todos os serviços
docker-compose logs -f

# Serviço específico
docker-compose logs -f elasticsearch
docker-compose logs -f kibana
docker-compose logs -f opencti
docker-compose logs -f connector-tenable
```

### Problemas Comuns

#### Elasticsearch não inicia
```bash
# Aumentar vm.max_map_count (Linux)
sudo sysctl -w vm.max_map_count=262144

# Tornar permanente
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

#### Containers consumindo muita memória
```bash
# Editar docker-compose.yml e adicionar limites:
services:
  elasticsearch:
    deploy:
      resources:
        limits:
          memory: 4G
```

#### Porta já em uso
```bash
# Verificar o que está usando a porta
sudo lsof -i :5601  # Exemplo para Kibana

# Parar o serviço conflitante ou mudar a porta no docker-compose.yml
```

#### OpenCTI não conecta ao Elasticsearch
```bash
# Verificar credenciais no .env
# Verificar logs
docker-compose logs opencti

# Reiniciar OpenCTI
docker-compose restart opencti
```

## 📁 Estrutura do Projeto

```
soc-dashboard-integration/
├── docker-compose.yml          # Orquestração de containers
├── .env.example                # Exemplo de variáveis de ambiente
├── .env                        # Suas configurações (criar)
├── config/
│   ├── elasticsearch.yml       # Config Elasticsearch
│   └── logstash.conf          # Pipeline Logstash
├── kibana/
│   └── kibana.yml             # Config Kibana
├── grafana/
│   ├── provisioning/          # Datasources e dashboards
│   │   ├── datasources/
│   │   └── dashboards/
│   └── dashboards/            # JSON dos dashboards
├── scripts/
│   ├── install.sh             # Instalação (Linux/Mac)
│   ├── install.bat            # Instalação (Windows)
│   ├── update.sh              # Atualização
│   ├── backup.sh              # Backup
│   ├── health_check.sh        # Verificação de saúde
│   └── configure_integrations.py  # Config automática
└── README.md                  # Esta documentação
```

## 🔒 Segurança

### Recomendações

1. **Altere TODAS as senhas padrão** no arquivo `.env`
2. **Use senhas fortes** (mínimo 16 caracteres, letras, números e símbolos)
3. **Não exponha portas na internet** sem firewall/VPN
4. **Habilite HTTPS** para produção (use nginx como proxy reverso)
5. **Faça backups regulares** (diários recomendado)
6. **Mantenha as imagens atualizadas** (semanal/mensal)
7. **Restrinja acesso à rede Docker** aos IPs necessários

### Habilitar HTTPS (Produção)

Para produção, utilize um proxy reverso com SSL:

```bash
# Exemplo com nginx
# Adicione ao docker-compose.yml:

nginx:
  image: nginx:alpine
  ports:
    - "443:443"
    - "80:80"
  volumes:
    - ./nginx/nginx.conf:/etc/nginx/nginx.conf
    - ./certs:/etc/nginx/certs
```

## 📞 Suporte

### Documentação Oficial
- **Elastic Stack**: https://www.elastic.co/guide/
- **OpenCTI**: https://docs.opencti.io/
- **Grafana**: https://grafana.com/docs/
- **Tenable**: https://developer.tenable.com/
- **Microsoft Defender**: https://learn.microsoft.com/en-us/defender-endpoint/

### Logs e Debug
```bash
# Modo debug (mais verboso)
docker-compose up

# Ver logs de um container específico
docker-compose logs -f [container_name]

# Executar comando dentro de um container
docker-compose exec elasticsearch bash
```

## 🎓 Consultas Úteis (KQL)

### Kibana - Alertas Críticos Últimas 24h
```kql
event.severity: ("Critical" OR "High") 
AND @timestamp >= now-24h
```

### Vulnerabilidades Críticas por Host
```kql
vulnerability.severity: "Critical" 
AND event.module: "tenable"
| stats count by host.name, vulnerability.id
```

### Correlação IOCs com Detecções
```kql
threat.indicator.type: * 
AND event.dataset: "microsoft_defender_endpoint.alert"
```

### Top 10 Alertas por Tipo
```kql
event.severity: ("High" OR "Critical")
| stats count by event.action
| sort count desc
| limit 10
```

## 📊 Métricas de Desempenho

### Capacidade Estimada
- **Eventos/dia**: até 1 milhão (com hardware recomendado)
- **Retenção**: 90 dias (ajustável em Elasticsearch ILM)
- **Latência de alertas**: < 5 minutos
- **Dashboards**: atualização a cada 30 segundos

### Otimização
```bash
# Elasticsearch - Ajustar heap size
# Editar docker-compose.yml:
ES_JAVA_OPTS=-Xms4g -Xmx4g  # 50% da RAM disponível

# Kibana - Limpar cache
docker-compose exec kibana bash
curl -X POST "localhost:5601/api/console/proxy?path=_cache/clear&method=POST"
```

## 📝 Licenças

- **Elasticsearch**: Elastic License 2.0
- **Kibana**: Elastic License 2.0
- **Grafana**: AGPL-3.0
- **OpenCTI**: AGPL-3.0
- Este projeto: MIT License

## 🤝 Contribuindo

Contribuições são bem-vindas! Para melhorias:

1. Faça um fork do projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📜 Changelog

### v1.0.0 (2025-11-26)
- ✅ Integração completa Elasticsearch + Kibana
- ✅ OpenCTI com conectores Tenable e CVE
- ✅ Microsoft Defender integration
- ✅ Grafana dashboards customizados
- ✅ Scripts de instalação e atualização
- ✅ Backup automatizado
- ✅ Health check system

---

**Desenvolvido para SOC Teams** | Dashboard Integrado de Segurança
