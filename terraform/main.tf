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

  # Provisioner to install Docker and set up JFrog Artifactory
  provisioner "remote-exec" {
    inline = [
      # Wait for the instance to be ready
      "sleep 40",
      
      # Update the package list and install required certificates
      "sudo apt-get update -y",
      "sudo apt-get install -y ca-certificates curl",

      # Install Docker prerequisites
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",

      # Add Docker repository
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",

      # Install Docker
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y",

      # Create Artifactory directories and set permissions
      "mkdir -p ~/jfrog/artifactory/var/etc",
      "chmod -R 777 ~/jfrog",
      "touch ~/jfrog/artifactory/var/etc/system.yaml",
      "sudo chown -R 1030:1030 ~/jfrog/artifactory/var",

      # Run the JFrog Artifactory Docker container
      "sudo docker run --name artifactory -d -v ~/jfrog/artifactory/var:/var/opt/jfrog/artifactory -p 8081:8081 -p 8082:8082 docker.bintray.io/jfrog/artifactory-oss:latest"
    ]
  }
}
