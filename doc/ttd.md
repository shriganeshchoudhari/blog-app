# Technical Design Document (TTD): G-Blog X

## 1. System Architecture
G-Blog X follows a decoupled microservices architecture with a React frontend and a Spring Boot backend, running on Amazon EKS.

### 1.1 Technology Stack
- **Runtime**: Java 21 (Temurin) / Node.js 18
- **Framework**: Spring Boot 3.3.5 / React 18
- **Database**: Amazon RDS PostgreSQL 15
- **Orchestration**: Amazon EKS (Kubernetes 1.27+)

## 2. CI/CD Pipeline Design
The platform uses a **Modular Shared Library** approach to ensure pipeline consistency and reusability.

### 2.1 The Jenkins Shared Library
- **`mavenBuild`**: Standardized Java build with unit tests.
- **`sonarScan`**: Integration with SonarQube for static analysis.
- **`trivyScan`**: Vulnerability scanning for the final Docker image.
- **`argocdSync`**: Automated GitOps synchronization.

### 2.2 Deployment Strategy (Canary)
We use **Argo Rollouts** instead of standard Kubernetes Deployments.
- **Controller**: Argo Rollout Controller.
- **Analysis**: Custom Prometheus queries monitor the error rate during rollout steps.

## 3. Data Design
- **Primary Key Strategy**: UUID v4 for all entities to ensure globally unique identifiers and easier sharding.
- **Migration**: Flyway handles versioned schema updates (V1__init.sql).

## 4. Security Architecture
### 4.1 Secret Management
- **Vault Agent Sidecar**: Injects secrets from HashiCorp Vault directly into `/vault/secrets/database`.
- **Authentication**: AppRole/Kubernetes Auth method ensures pods only access their own secrets.

### 4.2 Network Security
- **Private Nodes**: EKS nodes and RDS instances are located in private subnets.
- **NAT Gateway**: Provides controlled egress for updates and image pulls.
- **Ingress**: NGINX Ingress Controller manages SSL termination and path-based routing.

## 5. Observability Stack
- **Metrics**: Micrometer -> Prometheus -> Grafana.
- **Logs**: Promtail -> Loki -> Grafana.
- **Traces**: OpenTelemetry Java Agent -> OTel Collector -> Grafana Tempo.
