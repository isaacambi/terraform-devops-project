variable "project_name" {
  description = "Name of the project"
}

variable "environment" {
  description = "Environment name"
}

variable "instance_type" {
  description = "EC2 instance type"
}

variable "subnet_id" {
  description = "ID of the subnet to launch instance in"
}

variable "security_group_id" {
  description = "ID of the security group"
}
