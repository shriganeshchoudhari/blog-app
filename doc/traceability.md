# G-Blog X: Traceability Matrix

This document maps product requirements to implementation artifacts across Helm charts, ArgoCD apps, CI/CD steps, and security/compliance controls.

## 1. Map: PRD to Implementation Artifacts
- PRD sections (PRD.md) map to:
  - Helm: helm/gblog/Chart.yaml, values.yaml, templates (deployment/service/ingress/hpa/configmap)
  - CI/CD: Jenkinsfile
  - GitOps: ArgoCD app manifest: gitops/argo-apps/gblog-helm-app.yaml
  - Observability/Telemetry: Values in helm/gblog/values-prod.yaml and helm/gblog/templates/otel-collector.yaml
  - Vault integration: deployment annotations and config in helm templates; doc/security_compliance.md for policy
  - OPA policies: opa/policies/helm.rego

- TTD sections map to:
  - Deployment architecture: doc/deployment.md and doc/infrastructure.md
  - Security: doc/security_compliance.md and opa/policies/helm.rego
  - Observability: doc/ttd.md + helm/values + otel collector

## 2. Traceability Table (high level)
- Requirement: RBAC per roles
  - Implemented in: Backend API authorization logic; chart values via env/roles; OPA policies
- Requirement: GitOps-driven deployment
  - Implemented in: ArgoCD app manifest, Jenkins pipeline, Helm charts
- Requirement: Vault-based secrets
  - Implemented in: Vault integration in Helm templates; doc/security_compliance.md
- Requirement: Observability
  - Implemented in: OTEL collector deployment; helm templates; grafana/prometheus setup description
- Requirement: Progressive rollout (elite)
  - Implemented in: Proposed Argo Rollouts snippet in patch (if enabled)

## 3. Artifacts Cross-Referencing
- PRD.md <-> doc/deployment.md, doc/infrastructure.md
- TTD.md <-> helm charts (values + deployment) + infra design
- API Spec: doc/api_spec.md
- Schema Spec: doc/schema_spec.md
- Test Suite: doc/test_suite.md
- Security & Compliance: doc/security_compliance.md + opa/policies/helm.rego
- Traceability: doc/traceability.md

---
End of traceability map.
## Phase 5/Phase 6 Traceability
- **Phase 5: Security Hardening**
  - **RBAC Refactor**: `PostController.java`, `JwtRequestFilter.java`
  - **UUID Migration**: `Post.java`, `User.java`, `Comment.java`, `Tag.java`, `Category.java`, `PostRepository.java`
  - **Vault Rotation**: `VaultRotation.java`, `pom.xml`
  - **OPA Policies**: `opa/policies/security.rego`
  - **CI Gates**: `.github/workflows/ci.yml`, `.github/scripts/security_gates.sh`
- **Phase 6: Documentation Upgrades**
  - **API Specs**: `doc/api_spec.md` (Finalized JSON Schemas)
  - **Schema Specs**: `doc/schema_spec.md` (UUID DDL & Migration Plan)
  - **Implementation Plan**: `doc/implementation_plan_p5_p6.md`
