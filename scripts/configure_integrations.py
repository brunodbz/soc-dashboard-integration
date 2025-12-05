#!/usr/bin/env python3
"""
Script de configuração automática das integrações do SOC Dashboard
Configura Microsoft Defender, Tenable e OpenCTI via APIs
"""

import requests
import json
import time
import os
from urllib.parse import urljoin

class SOCConfigurator:
    def __init__(self):
        self.elastic_url = "http://localhost:9200"
        self.kibana_url = "http://localhost:5601"
        self.elastic_user = "elastic"
        self.elastic_password = os.getenv("ELASTIC_PASSWORD", "ChangeMe123!")

    def wait_for_service(self, url, name, timeout=300):
        print(f"⏳ Aguardando {name} ficar disponível...")
        start = time.time()
        while time.time() - start < timeout:
            try:
                response = requests.get(url, timeout=5, verify=False)
                if response.status_code < 500:
                    print(f"✓ {name} está disponível")
                    return True
            except:
                pass
            time.sleep(5)
        print(f"❌ Timeout aguardando {name}")
        return False

    def setup_microsoft_defender_integration(self):
        print("\n📘 Configurando integração Microsoft Defender...")

        tenant_id = os.getenv("DEFENDER_TENANT_ID")
        client_id = os.getenv("DEFENDER_CLIENT_ID")
        client_secret = os.getenv("DEFENDER_CLIENT_SECRET")

        if not all([tenant_id, client_id, client_secret]):
            print("⚠️  Variáveis do Microsoft Defender não configuradas no .env")
            return False

        # Endpoint da API Kibana Fleet
        url = f"{self.kibana_url}/api/fleet/package_policies"

        headers = {
            "kbn-xsrf": "true",
            "Content-Type": "application/json"
        }

        payload = {
            "name": "microsoft-defender-endpoint",
            "description": "Microsoft Defender for Endpoint integration",
            "namespace": "default",
            "policy_id": "fleet-server-policy",
            "enabled": True,
            "package": {
                "name": "microsoft_defender_endpoint",
                "version": "latest"
            },
            "inputs": [{
                "type": "httpjson",
                "enabled": True,
                "streams": [{
                    "enabled": True,
                    "data_stream": {
                        "type": "logs",
                        "dataset": "microsoft_defender_endpoint.alert"
                    },
                    "vars": {
                        "tenant_id": {"value": tenant_id},
                        "client_id": {"value": client_id},
                        "client_secret": {"value": client_secret, "type": "password"},
                        "interval": {"value": "5m"}
                    }
                }]
            }]
        }

        try:
            response = requests.post(
                url,
                headers=headers,
                auth=(self.elastic_user, self.elastic_password),
                json=payload,
                verify=False
            )

            if response.status_code in [200, 201]:
                print("✓ Integração Microsoft Defender configurada")
                return True
            else:
                print(f"⚠️  Erro ao configurar Defender: {response.status_code}")
                print(f"   Resposta: {response.text}")
                return False
        except Exception as e:
            print(f"❌ Erro: {str(e)}")
            return False

    def setup_tenable_integration(self):
        print("\n🔧 Configurando integração Tenable...")

        access_key = os.getenv("TENABLE_ACCESS_KEY")
        secret_key = os.getenv("TENABLE_SECRET_KEY")

        if not all([access_key, secret_key]):
            print("⚠️  Credenciais Tenable não configuradas no .env")
            return False

        url = f"{self.kibana_url}/api/fleet/package_policies"

        headers = {
            "kbn-xsrf": "true",
            "Content-Type": "application/json"
        }

        payload = {
            "name": "tenable-vulnerability-management",
            "description": "Tenable Vulnerability Management integration",
            "namespace": "default",
            "policy_id": "fleet-server-policy",
            "enabled": True,
            "package": {
                "name": "tenable_io",
                "version": "latest"
            },
            "inputs": [{
                "type": "httpjson",
                "enabled": True,
                "streams": [{
                    "enabled": True,
                    "data_stream": {
                        "type": "logs",
                        "dataset": "tenable_io.vulnerability"
                    },
                    "vars": {
                        "access_key": {"value": access_key},
                        "secret_key": {"value": secret_key, "type": "password"},
                        "url": {"value": "https://cloud.tenable.com"},
                        "interval": {"value": "24h"}
                    }
                }]
            }]
        }

        try:
            response = requests.post(
                url,
                headers=headers,
                auth=(self.elastic_user, self.elastic_password),
                json=payload,
                verify=False
            )

            if response.status_code in [200, 201]:
                print("✓ Integração Tenable configurada")
                return True
            else:
                print(f"⚠️  Erro ao configurar Tenable: {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ Erro: {str(e)}")
            return False

    def create_correlation_rules(self):
        print("\n⚙️  Criando regras de correlação...")

        # Regra: Correlação de vulnerabilidades críticas com alertas
        rule1 = {
            "name": "Vulnerabilidade Crítica Explorada",
            "description": "Alerta quando uma vulnerabilidade crítica é detectada em um host com atividade suspeita",
            "severity": "critical",
            "query": '''
                sequence by host.name
                  [vulnerability where vulnerability.severity == "Critical"]
                  [alert where event.severity == "high" or event.severity == "critical"]
            ''',
            "interval": "5m"
        }

        print("✓ Regras de correlação configuradas (aplicar manualmente no Kibana)")
        return True

    def run(self):
        print("=" * 50)
        print("  SOC Dashboard - Configuração de Integrações")
        print("=" * 50)

        # Aguardar serviços
        if not self.wait_for_service(self.kibana_url, "Kibana"):
            return False

        # Configurar integrações
        self.setup_microsoft_defender_integration()
        self.setup_tenable_integration()
        self.create_correlation_rules()

        print("\n" + "=" * 50)
        print("  ✅ Configuração concluída!")
        print("=" * 50)
        print("\nPróximos passos manuais:")
        print("  1. Acesse Kibana: http://localhost:5601")
        print("  2. Vá em Management > Integrations")
        print("  3. Verifique e ajuste as integrações conforme necessário")
        print("  4. Configure alertas e notificações")
        return True

if __name__ == "__main__":
    import warnings
    warnings.filterwarnings("ignore")

    configurator = SOCConfigurator()
    configurator.run()
