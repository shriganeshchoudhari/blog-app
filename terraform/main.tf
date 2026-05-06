provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "gblog_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "gblog-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.gblog_vpc.id
  tags = { Name = "gblog-igw" }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.gblog_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = { Name = "gblog-public-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.gblog_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = { Name = "gblog-public-b" }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.gblog_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"
  tags = { Name = "gblog-private-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.gblog_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws_region}b"
  tags = { Name = "gblog-private-b" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.gblog_vpc.id
  tags = { Name = "gblog-public-rt" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id               = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "pub_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "pub_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# NAT Gateway for Private Subnets
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "gblog-nat-eip" }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id
  tags          = { Name = "gblog-nat" }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.gblog_vpc.id
  tags   = { Name = "gblog-private-rt" }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "pri_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "pri_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "ci_sg" {
  name   = "gblog-ci-sg"
  vpc_id = aws_vpc.gblog_vpc.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Jenkins/CI port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SonarQube port"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "gblog-ci-sg" }
}

resource "aws_security_group" "eks_sg" {
  name   = "gblog-eks-sg"
  vpc_id = aws_vpc.gblog_vpc.id
  
  ingress {
    description = "Allow all from self"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Allow CI to EKS API"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ci_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "gblog-eks-sg" }
}

resource "aws_security_group" "rds_sg" {
  name   = "gblog-rds-sg"
  vpc_id = aws_vpc.gblog_vpc.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_sg.id]
  }
  tags = { Name = "gblog-rds-sg" }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical Ubuntu
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "gblog-key"
  public_key = file("${path.module}/terra-key.pub")
}

resource "aws_instance" "ci" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.ci_instance_type
  key_name      = aws_key_pair.deployer.key_name
  subnet_id = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.ci_sg.id]
  user_data_base64 = base64encode(file("${path.module}/scripts/bootstrap-aws-tools.sh"))
  iam_instance_profile = aws_iam_instance_profile.ci_profile.name
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }
  tags = { Name = "gblog-ci" }
}

# IAM Role for CI Instance
resource "aws_iam_role" "ci_role" {
  name = "gblog-ci-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ci_admin" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.ci_role.name
}

resource "aws_iam_instance_profile" "ci_profile" {
  name = "gblog-ci-profile"
  role = aws_iam_role.ci_role.name
}

# EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "gblog-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_group_ids = [aws_security_group.eks_sg.id]
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# EKS Node Group
resource "aws_iam_role" "eks_nodes" {
  name = "gblog-eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_launch_template" "eks_nodes" {
  name_prefix   = "gblog-eks-nodes-"
  instance_type = "m7i-flex.large"

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "gblog-eks-node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "gblog-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_policy,
  ]
}

# RDS Instance
resource "aws_db_subnet_group" "main" {
  name       = "gblog-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro"
  db_name              = "gblog"
  username             = "gbloguser"
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true
}

# IAM User for Jenkins
resource "aws_iam_user" "jenkins_user" {
  name = "jenkins-user"
  tags = { Name = "jenkins-user" }
}

resource "aws_iam_access_key" "jenkins_key" {
  user = aws_iam_user.jenkins_user.name
}

resource "aws_iam_user_policy_attachment" "jenkins_admin" {
  user       = aws_iam_user.jenkins_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
