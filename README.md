# JFrog Artifactory Setup with Jenkins and Terraform

# Overview

This repository provides a complete solution for setting up JFrog Artifactory on an AWS EC2 instance using Terraform and Jenkins. JFrog Artifactory is a powerful artifact repository manager that supports various package formats. This setup provisions a `t2.medium` instance with a minimum of 4 GB of RAM, suitable for running JFrog Artifactory as a web application.


# Prerequisites

Before you begin, ensure you have the following:

- Jenkins installed on your server or local machine. If you don't have Jenkins installed, you can follow the official Jenkins installation guide [here](https://www.jenkins.io/doc/book/installing/).
- Terraform installed for provisioning the infrastructure. You can find the installation instructions [here](https://learn.hashicorp.com/tutorials/terraform/install-cli).
- AWS account with appropriate permissions to create EC2 instances and manage security groups.
- Git installed for cloning the repository.

# Required Jenkins Plugins

Before setting up your Jenkins pipeline, you need to install the following plugins in Jenkins:

1. Amazon Web Services (AWS) Credentials - For managing AWS credentials in Jenkins.
2. Artifactory - For doing configuraation in jenkins to connect to Jfrog artifactory.
3. Git Plugin - For pulling code from a Git repository.

# Steps to Install Jenkins Plugins

1. Access Jenkins Dashboard
   - Open your web browser and navigate to your Jenkins server (e.g., `http://<your-jenkins-ip>:8080`).

2. Log in to Jenkins
   - Use your admin credentials to log in.

3. Go to Manage Jenkins
   - From the Jenkins dashboard, click on Manage Jenkins on the left-hand side.

4. Manage Plugins
   - Click on Manage Plugins.

5. Install Plugins
   - Go to the Available tab.
   - In the search box, type AWS and check the box for Amazon Web Services (AWS) Credentials.
   - Type Pipeline and check the box for Pipeline.
   - Type Git Plugin and check the box for Git Plugin.
   - Install the Artifactory plugin
   - Click on Install without restart.

6. Verify Installation
   - After installation, you can go back to Manage Plugins and check under the Installed tab to verify that the plugins are installed.


# Repository Structure

'''
.
├── Jenkinsfile        # Jenkins pipeline configuration
└── terraform          # Terraform folder containing infrastructure files
    ├── main.tf       # Main Terraform configuration file
    └── security_group_rules.tf # Security group rules for inbound traffic

'''

# Getting Started

1. Clone the Repository

   To get started, clone this repository to your local machine using Git:

  
   git clone https://github.com/Mohit722/jfrog-artifactory-pipeline-terraform.git
   cd jfrog-artifactory-pipeline-terraform
 

2. Configure AWS Credentials in Jenkins

   You need to set up AWS credentials in Jenkins to allow it to provision resources in your AWS account:

   - Go to Manage Jenkins.
   - Click on Manage Credentials.
   - Select the domain (typically `(global)`).
   - Click on Add Credentials.
   - Select AWS Credentials from the Kind dropdown.
   - Enter your AWS Access Key ID and Secret Access Key.
   - Give it an ID (e.g., `aws_credentials`) and a description.
   - Click OK to save the credentials.

3. Set Up the Jenkins Pipeline

   The provided `Jenkinsfile` contains the pipeline configuration for deploying the infrastructure. Here’s how to set it up:

   - In the Jenkins dashboard, click on New Item.
   - Enter a name for your job (e.g., `JFrog Artifactory Setup`).
   - Select Pipeline and click OK.
   - In the pipeline configuration, scroll down to the Pipeline section.
   - Select Pipeline script from SCM.
   - Choose Git from the SCM dropdown.
   - Enter the repository URL: `https://github.com/Mohit722/jfrog-artifactory-pipeline-terraform.git`.
   - In the Branch Specifier, you can use `/main` if your main branch is named `main`.
   - Under Credentials, select the AWS credentials you configured earlier.
   - Click Save.

4. Modify the Terraform Configuration

   The `main.tf` file contains the configuration for creating the EC2 instance and installing JFrog Artifactory. Users can customize this file based on their requirements:

   - Change the Instance Type: Modify the `BuildType` variable in `main.tf` to use a different EC2 instance type if needed.
   - Security Group Rules: The `security_group_rules.tf` file contains inbound rules. Ensure it allows inbound traffic on ports 8081 and 8082 for accessing JFrog Artifactory.

   Example security group rule for allowing inbound traffic on port 8081:

   ```hcl
   resource "aws_security_group_rule" "allow_artifactory" {
     type              = "ingress"
     from_port        = 8081
     to_port          = 8081
     protocol         = "tcp"
     security_group_id = aws_security_group.my_security_group.id
     cidr_blocks      = ["0.0.0.0/0"] # Update as per your security requirements
   }
   ```

5. Run the Jenkins Pipeline

   - Go to your newly created Jenkins job.
   - Click on Build Now.
   - You will be prompted to choose whether to Create or Destroy the Artifactory instance. Select Create to start the provisioning process.
   - The console output will show the progress of the Terraform commands being executed.

6. Accessing JFrog Artifactory

   After the pipeline completes successfully, you can access JFrog Artifactory by navigating to:

   ```
   http://<your-public-ip>:8081
   ```

   Replace `<your-public-ip>` with the public IP address of your EC2 instance.


# Conclusion

This setup provides an efficient way to manage artifacts and binaries using JFrog Artifactory, integrated with a Jenkins CI/CD pipeline. New users are encouraged to modify the `main.tf` and `security_group_rules.tf` files to meet their project requirements.

By following these instructions, you can quickly get started with JFrog Artifactory on AWS. If you encounter any issues or have questions, please check the JFrog documentation or reach out to the community for assistance.

# Cleaning Up

To remove the resources, trigger the pipeline again and select the Destroy action. This will tear down the EC2 instance and any associated resources created by Terraform.


# Troubleshooting

If you encounter issues, check the following:
Ensure that your AWS credentials are correctly configured in Jenkins.
Verify that the security group rules allow inbound traffic on the specified ports.
Check the Jenkins console logs for errors during the pipeline execution.


# License
This project is licensed under the MIT License. See the LICENSE file for details.

