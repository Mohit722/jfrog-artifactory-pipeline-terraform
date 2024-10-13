# Set AWS Provider and Region
provider "aws" {
  region = "ap-south-1"
}

# Variables for EC2 instance
variable "BuildAMI" {
  description = "Build Server AMI"
  default     = "ami-0dee22c13ea7a9a67"
}

variable "BuildType" {
  description = "Build Server Type"
  default     = "t2.medium"
}

variable "BuildKey" {
  description = "Build Server Key"
  default     = "devops"
}

variable "SecurityGroupID" {
  description = "Security Group ID"
  default     = "sg-0a4b86efefd9999b7"
}

# EC2 Instance Configuration
resource "aws_instance" "example" {
  ami                    = var.BuildAMI
  instance_type          = var.BuildType
  key_name               = var.BuildKey
  vpc_security_group_ids = [var.SecurityGroupID]

  tags = {
    Name = "ArtifactoryServer"
  }

  # Connection details for SSH
  connection {
    type        = "ssh"
    user        = "ubuntu"   # Use "ec2-user" for Amazon Linux AMIs
    private_key = file("/etc/ansible/devops.pem")  # Update with your private key path
    host        = self.public_ip
  }

  # Provisioner to set up JFrog Artifactory
  provisioner "remote-exec" {
    inline = [
      # Wait for the instance to be ready
      "sleep 40",

      # Update the hostname
      "sudo hostnamectl set-hostname Artifactory",
      "sleep 7",

      # Update the package list
      "sudo apt-get update -y",

      # Install Docker and Docker Compose
      "sudo apt-get install -y docker-compose -y",

      # Create Docker Compose file
      "cat <<EOF | sudo tee /home/ubuntu/docker-compose.yml",
      "version: '3.3'",
      "services:",
      "  artifactory-service:",
      "    image: docker.bintray.io/jfrog/artifactory-oss:7.49.6",
      "    container_name: artifactory",
      "    restart: always",
      "    networks:",
      "      - ci_net",
      "    ports:",
      "      - 8081:8081",
      "      - 8082:8082",
      "    volumes:",
      "      - artifactory:/var/opt/jfrog/artifactory",
      "volumes:",
      "  artifactory:",
      "networks:",
      "  ci_net:",
      "EOF",

      # Run the JFrog Artifactory using Docker Compose
      "sudo docker-compose -f /home/ubuntu/docker-compose.yml up -d",

      # Optional: List Docker images and running containers
      "sudo docker images",
      "sudo docker ps",

      # Optional: Test the Artifactory endpoint
      "curl localhost:8081"
  ]
 }
}
# Output the Artifactory dashboard link
output "artifactory_dashboard_url" {
  value = "http://${aws_instance.example.public_ip}:8081"
  description = "URL to access the JFrog Artifactory dashboard."
}
