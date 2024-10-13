
# Security group rule for JFrog Artifactory
resource "aws_security_group_rule" "artifactory_ingress" {
  count             = 2  # Create two rules
  type              = "ingress"
  from_port         = [8081, 8082][count.index]  # Set the port based on count index
  to_port           = [8081, 8082][count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "sg-0a4b86efefd9999b7"  # Replace with your security group ID

  # Optional description
  description = "Allow inbound traffic on port ${[8081, 8082][count.index]} for JFrog Artifactory"
}
