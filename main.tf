provider "aws" {
  region = "ap-south-1"  # Change this to your desired AWS region
}

# EC2 Instance
resource "aws_instance" "my-demo-instance" {
  ami           = "ami-09298640a92b2d12c"  # Change this to your desired AMI ID
  instance_type = "t2.micro"
  key_name      = "rdswith_ec2"  # Change this to your key pair name
  subnet_id     = aws_subnet.demo-subnet.id
  tags = {
    Name = "my-demo-instance"
    
  }

}

  //Create VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.10.0.0/16"
}

//Create Subnet

resource "aws_subnet" "demo-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "demo-subnet"
  }
}

# RDS Instance
resource "aws_db_instance" "example_rds_instance" {
  identifier            = "example-rds-instance"
  allocated_storage     = 20
  storage_type          = "gp3"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.m5d.large"
  username              = "admin"
  password              = "admin123"  # Replace with your desired password
  publicly_accessible   = false  # Adjust this as per your requirements
  skip_final_snapshot   = true

  tags = {
    Name = "example-rds-instance"
  }


}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow inbound traffic to RDS instance"
  vpc_id      = aws_vpc.my-vpc.id  # Change this to your VPC ID

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust this as per your requirements
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Associate RDS security group with EC2 instance
resource "aws_security_group_rule" "allow_rds" {
  type        = "ingress"
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  security_group_id = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.rds_sg.id # Assuming only one security group attached to the EC2 instance
}