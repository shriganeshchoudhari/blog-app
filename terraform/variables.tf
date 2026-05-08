variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  default = "gblog-eks"
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key for Jenkins"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "GitHub Personal Access Token for Webhook automation"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub Username or Organization name"
  type        = string
}

variable "github_repository" {
  description = "GitHub Repository name"
  type        = string
  default     = "blog-app"
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
