variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  default = "gblog-eks"
}

variable "db_password" {
  description = "RDS root password"
  type        = string
  sensitive   = true
  default     = "gblogpassword123"
}

variable "ci_instance_type" {
  default = "m7i-flex.large"
}

variable "jenkins_admin_password" {
  default = "admin"
}

variable "sonar_token" {
  default = "admin"
}

variable "docker_hub_user" {
  default = "guest"
}

variable "docker_hub_token" {
  default = "guest"
  sensitive = true
}
