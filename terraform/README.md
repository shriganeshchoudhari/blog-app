Terraform AWS Bootstrap for G-Blog X

This folder bootstraps AWS resources (VPC, subnets, a CI bootstrap EC2 node with tooling). It can be extended to provision EKS, RDS, and S3 in a follow-on patch-set.

How to use:
- Update variables as needed (aws_region)
- Run: terraform init
- Run: terraform apply

Note: This is a bootstrap environment; consider isolating credentials and using a dedicated account or role.
