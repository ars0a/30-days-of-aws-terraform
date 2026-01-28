
# EC2 instance For Nginx setup
resource "aws_instance" "nginxserver" {
  ami                         = "ami-0532be01f26a3de55"  # Amazon Linux 2 AMI (us-east-1)
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public-subnet.id
  vpc_security_group_ids      = [aws_security_group.nginx-sg.id]
  associate_public_ip_address = true

user_data = <<EOF
            #!/bin/bash
            yum install -y nginx
            echo "<h1>Hello from my custom Terraform deployment</h1>" > /usr/share/nginx/html/index.html
            systemctl enable nginx
            systemctl start nginx
            EOF


  tags = {
    Name = "NginxServer"
  }
}