package helm

default allow = true

deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.privileged == true
  msg = {"reason": "privileged containers are disallowed", "container": container.name}
}

deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  cs := container.securityContext
  cs.runAsNonRoot == false
  msg = {"reason": "containers must run as non-root", "container": container.name}
}
