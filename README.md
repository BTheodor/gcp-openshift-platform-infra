# gcp-openshift-platform-infra

A production-grade hybrid cloud platform engineering repository showcasing the infrastructure, automation, and observability stack built for a B2B SaaS client serving enterprise accounts across EMEA and North America.

## Overview
This platform was designed and operated as Lead Platform Engineer to support a high-scale environment processing 40M+ daily events. The architecture combines the agility of **GCP GKE Autopilot** with the robustness of on-premise **OpenShift** clusters, providing a secure, compliant, and highly available foundation for mission-critical microservices.

### Business Impact
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Deployment Frequency | Bi-weekly | 10+ per day | ~140x |
| Mean Time to Recovery (MTTR) | 4.2 hours | 18 minutes | 92% reduction |
| P99 Latency (Public API) | 480ms | 115ms | 76% faster |
| Availability (SLO) | 99.5% | 99.99% | "Four Nines" achieved |

## Architecture
### Hybrid Cloud Topology
```text
      +-----------------------+              +-----------------------+
      |      GCP (Public)      |              |   OpenShift (Private) |
      |                       |    VPN/IC    |                       |
      |  +-----------------+  |<------------>|  +-----------------+  |
      |  | GKE Autopilot   |  |              |  | On-Prem Cluster |  |
      |  | (SaaS Core)     |  |              |  | (Legacy/Data)   |  |
      |  +-----------------+  |              |  +-----------------+  |
      |                       |              |                       |
      |  +-----------------+  |              |  +-----------------+  |
      |  | Cloud Armor WAF |  |              |  | Oracle RAC DB   |  |
      |  +-----------------+  |              |  +-----------------+  |
      +-----------------------+              +-----------------------+
```

### DataMesh Domain Topology
```text
[ Campaign Domain ] --- (Kafka) ---> [ Analytics Domain ] --- (BigQuery) ---> [ BI Dashboard ]
        |                                     |
        +------------ (Workload Identity) ----+----> [ IAM / Security Policy ]
```

## Technology Stack
| Category | Tools |
|----------|-------|
| Orchestration | GKE Autopilot, OpenShift 4.x, Istio Service Mesh |
| IaC | Terraform 1.7, Ansible (CIS L2 Hardening) |
| CI/CD | GitHub Actions, Jenkins Declarative Pipelines, ArgoCD |
| Messaging | Kafka (Strimzi), Pub/Sub |
| Data Layer | Oracle RAC, BigQuery, Redis Sentinel, Hadoop HDFS |
| Observability | Prometheus, Grafana, ELK Stack (Logstash focus) |
| Security | OPA Gatekeeper, Cloud Armor, HashiCorp Vault |

## Infrastructure as Code
- **Terraform:** Modularized structure for GCP resources with centralized state in GCS.
- **Ansible:** Playbooks for OS-level hardening (CIS Level 2) and Java runtime optimization.

## Container Orchestration
I implemented advanced Kubernetes patterns including:
- **TopologySpreadConstraints:** Ensuring multi-zone high availability.
- **HPA on Kafka Lag:** Auto-scaling consumers based on real-time processing debt.
- **Security Contexts:** Enforcing `readOnlyRootFilesystem` and `seccompProfile`.

## CI/CD Pipeline
Full Jenkins Groovy pipeline example:
```groovy
pipeline {
    agent { label 'maven-jdk17' }
    stages {
        stage('Lint & Security Scan') {
            steps {
                sh 'mvn checkstyle:check'
                sh 'trivy fs .'
            }
        }
        stage('Build & Push') {
            steps {
                sh 'docker build -t gcr.io/client-project/campaign-service:${GIT_COMMIT} .'
                sh 'docker push gcr.io/client-project/campaign-service:${GIT_COMMIT}'
            }
        }
        stage('Deploy to Staging') {
            steps {
                sh "helm upgrade --install campaign-service ./helm/campaign-service -f ./helm/campaign-service/values-staging.yaml --set image.tag=${GIT_COMMIT}"
            }
        }
    }
}
```

## Getting Started
1. Initialize Terraform: `cd terraform/environments/prod && terraform init`
2. Run Smoke Tests: `./scripts/smoke-test.sh`
3. Check Kafka Lag: `./scripts/kafka-lag-check.sh`

## Repository Structure
- `terraform/`: Infrastructure modules and environment configs.
- `ansible/`: Configuration management and hardening.
- `helm/`: Kubernetes application manifests.
- `monitoring/`: Prometheus rules and Logstash pipelines.
- `docs/`: ADRs and operational runbooks.
- `scripts/`: Operational utility scripts.
