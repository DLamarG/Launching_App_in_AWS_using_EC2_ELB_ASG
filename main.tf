provider "aws" {
  region = "us-east-2"  # Specify your AWS region
}

# Create Security Group
resource "aws_security_group" "lamar_react_sg" {
  name        = "lamar-react-sg"
  description = "Allow inbound traffic for Lamar React app"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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

# Create Ubuntu EC2 Instance
resource "aws_instance" "lamar_react_instance" {
  ami           = "ami-036841078a4b68e14"  # Replace with the correct Ubuntu AMI ID
  instance_type = "t2.micro"
  key_name      = "mariaDB_server_key"      # Replace with your key pair name

  security_groups = [aws_security_group.lamar_react_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y git
              curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
              apt install -y nodejs
              git clone https://github.com/mikhail-w/pokedex.git /home/ubuntu/react-app
              cd /home/ubuntu/react-app
              npm install
              npm run dev -- --host
              EOF

  tags = {
    Name = "LamarReactAppInstance"
  }
}

# Output EC2 instance public IP
output "lamar_public_ip" {
  value = aws_instance.lamar_react_instance.public_ip
}
