# Security Group for MongoDB
resource "aws_security_group" "mongodb_sg" {
  name        = "mongodb_sg"
  description = "Security group for MongoDB"

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# MongoDB Instance
resource "aws_docdb_cluster_instance" "mongodb_instance" {
  count                  = 1
  identifier             = "mongodb-instance-${count.index}"
  instance_class         = "db.r5.large"  # Change instance class as per your requirements
  cluster_identifier     = aws_docdb_cluster.mongodb_cluster.id
  availability_zone      = "us-west-2a"  # Change availability zone as per your preference
}

# Subnet Group for MongoDB
resource "aws_docdb_subnet_group" "mongodb_subnet_group" {
  subnet_ids = ["subnet-12345678"]  # Replace with your subnet IDs
}

# MongoDB Cluster
resource "aws_docdb_cluster" "mongodb_cluster" {
  cluster_identifier            = "mongodb-cluster"
  engine                        = "docdb"
  master_username               = "admin"
  master_password               = "adminPassword"  # Change the password as per your requirements
  backup_retention_period       = 5
  preferred_backup_window       = "07:00-09:00"
  skip_final_snapshot           = true
  db_subnet_group_name          = aws_docdb_subnet_group.mongodb_subnet_group.name
  vpc_security_group_ids        = [aws_security_group.mongodb_sg.id]
  storage_encrypted             = true
}

# Key Pair for EC2 Instances
resource "aws_key_pair" "spark_key_pair" {
  key_name   = "spark-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")  # Replace with your public key path
}

# Security Group for Spark
resource "aws_security_group" "spark_sg" {
  name        = "spark_sg"
  description = "Security group for Apache Spark"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance for Spark Master
resource "aws_instance" "spark_master" {
  ami           = "ami-12345678"  # Replace with your Spark AMI
  instance_type = "m5.large"      # Change instance type as per your requirements
  key_name      = aws_key_pair.spark_key_pair.key_name
  security_groups = [aws_security_group.spark_sg.name]
  tags = {
    Name = "spark-master"
  }
}

# EC2 Instance for Spark Worker
resource "aws_instance" "spark_worker" {
  count         = 2
  ami           = "ami-12345678"  # Replace with your Spark AMI
  instance_type = "m5.large"      # Change instance type as per your requirements
  key_name      = aws_key_pair.spark_key_pair.key_name
  security_groups = [aws_security_group.spark_sg.name]
  tags = {
    Name = "spark-worker-${count.index}"
  }
}

