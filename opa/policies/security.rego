package security

default allow = true

# Privileged containers are forbidden
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.privileged == true
  msg = {"reason": "privileged containers are forbidden", "container": container.name}
}

# Containers must run as non-root
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.runAsNonRoot != true
  msg = {"reason": "container must run as non-root", "container": container.name}
}

# Root filesystem must be read-only
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.readOnlyRootFilesystem != true
  msg = {"reason": "root filesystem must be read-only", "container": container.name}
}

# Privilege escalation must be disabled
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.allowPrivilegeEscalation != false
  msg = {"reason": "privilege escalation must be disabled", "container": container.name}
}

# Containers must drop ALL capabilities and add only necessary ones
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.securityContext.capabilities.drop[_] == "ALL"
  msg = {"reason": "container must drop ALL capabilities", "container": container.name}
}
