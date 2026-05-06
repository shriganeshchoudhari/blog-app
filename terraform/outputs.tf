output "ci_public_ip" {
  value = aws_instance.ci.public_ip
}

output "jenkins_access_key_id" {
  value = aws_iam_access_key.jenkins_key.id
}

output "jenkins_secret_access_key" {
  value     = aws_iam_access_key.jenkins_key.secret
  sensitive = true
}
