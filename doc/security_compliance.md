# Security & Compliance: G-Blog X

## 1. Shift-Left Security
We implement security at the earliest stages of the development lifecycle.

### 1.1 Static Analysis (SAST)
- **Tool**: SonarQube.
- **Enforcement**: Build fails if the "Quality Gate" is not met (e.g., > 80% coverage, 0 critical bugs).

### 1.2 Dependency Scanning (SCA)
- **Tool**: OWASP Dependency Check.
- **Enforcement**: Checks for known CVEs in Java libraries. Reports are archived in Jenkins for audit.

### 1.3 Container Scanning
- **Tool**: Trivy.
- **Enforcement**: Scans the production image for OS-level vulnerabilities. Fails the pipeline if "CRITICAL" issues are found.

## 2. Runtime Security
### 2.1 Secret Management (HashiCorp Vault)
- **Authentication**: Pods use their Kubernetes JWT to authenticate with Vault.
- **Injection**: Vault Sidecar Agent injects credentials as ephemeral environment variables.
- **Benefit**: No secrets are stored in Kubernetes Secrets or environment variables in the manifest.

### 2.2 Admission Control (OPA Gatekeeper)
We use Open Policy Agent (OPA) to enforce cluster-wide policies:
- **No Privileged Containers**: Prevents privilege escalation.
- **Image Registry Whitelist**: Ensures only images from Docker Hub/ECR are allowed.
- **Resource Limits Required**: Ensures every pod has CPU/Memory limits.

## 3. Network Security
- **mTLS**: Encrypted pod-to-pod communication (optional via Istio/Linkerd).
- **Network Policies**: Restricts egress/ingress between namespaces (e.g., only `gblog-backend` can talk to RDS).
