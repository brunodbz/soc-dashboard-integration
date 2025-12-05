# SOC Dashboard Codebase Analysis

## Stack Overview
- **Container orchestration**: `docker-compose.yml` defines Elasticsearch/Kibana SIEM core, OpenCTI with Redis/MinIO/RabbitMQ, Grafana dashboards, and Logstash pipeline services with healthchecks, persistent volumes, and default credentials sourced from environment variables.【F:docker-compose.yml†L4-L264】
- **Configuration assets**: Elastic Stack and Kibana tunables live under `config/` and `kibana/`, Grafana datasources/dashboards in `grafana/`, and operational scripts in `scripts/`.

## Service Definitions
- **Elasticsearch & Kibana**: Single-node Elasticsearch with security enabled and mounted config, plus Kibana configured for secured access and external config file mounts for persistence and custom settings.【F:docker-compose.yml†L5-L53】【F:kibana/kibana.yml†L1-L13】
- **OpenCTI stack**: OpenCTI platform backed by Redis, MinIO, RabbitMQ, and Elasticsearch with explicit port mappings, dependency health checks, and restart policies to ensure availability.【F:docker-compose.yml†L55-L150】
- **Threat intelligence connectors**: Dedicated OpenCTI worker plus Tenable and CVE connectors that authenticate with the OpenCTI API and poll data on configurable intervals.【F:docker-compose.yml†L152-L207】
- **Visualization**: Grafana container pre-provisioned with Elastic datasource credentials and dashboard import paths, including default plugin setup and embedding enabled.【F:docker-compose.yml†L208-L230】【F:grafana/provisioning/datasources/elasticsearch.yml†L1-L20】【F:grafana/provisioning/dashboards/soc-dashboards.yml†L1-L13】
- **Data pipeline**: Logstash service accepts Defender events over HTTP, enriches data with metadata and GeoIP, and forwards to Elasticsearch using environment-provided credentials.【F:docker-compose.yml†L232-L251】【F:config/logstash.conf†L1-L46】

## Configuration Highlights
- **Elasticsearch settings**: Custom cluster name, open network binding for container access, and disabled SSL transport with monitoring collection enabled.【F:config/elasticsearch.yml†L1-L11】
- **Kibana security**: Explicit encryption key for saved objects and alerting support enabled to allow secure alert management.【F:kibana/kibana.yml†L5-L13】
- **Grafana dashboards**: Prebuilt “SOC - Alertas Críticos e Alta Severidade” dashboard tracks critical/high alerts using Elasticsearch queries and threshold-based visualization defaults.【F:grafana/dashboards/soc-critical-alerts.json†L1-L36】

## Automation Scripts
- **Installation**: `scripts/install.sh` verifies Docker/Compose, prepares `.env`, pulls images, starts services, and provides service URLs and credentials guidance.【F:scripts/install.sh†L1-L78】
- **Updates & maintenance**: `scripts/update.sh` stops the stack, prompts for backups, pulls refreshed images, restarts services, and prunes unused images.【F:scripts/update.sh†L1-L48】
- **Backups**: `scripts/backup.sh` stops containers, snapshots volumes for core services (Elastic, Kibana, Grafana, MinIO, Redis), copies key configs, and restarts the stack.【F:scripts/backup.sh†L1-L47】
- **Health checks**: `scripts/health_check.sh` inspects container status, checks HTTP endpoints for all services, and reports resource usage and volume footprint.【F:scripts/health_check.sh†L1-L49】
- **Windows support**: `scripts/install.bat` mirrors the install flow for Windows users with Docker Desktop, `.env` preparation, image pulls, and container startup instructions.【F:scripts/install.bat†L1-L63】

## Integration Automation
- `scripts/configure_integrations.py` automates Kibana Fleet policies for Microsoft Defender and Tenable using API calls authenticated with Elastic credentials, waits for Kibana availability, and prints follow-up steps for manual verification and alert configuration.【F:scripts/configure_integrations.py†L1-L209】

## Observations
- All services ship with default passwords placeholder values; `.env` configuration is critical before deployment to secure credentials.
- Health checks and restart policies across containers aim to keep dependencies orderly, but production deployments should consider enabling TLS and tightening network exposure as noted in `README.md` guidance.
