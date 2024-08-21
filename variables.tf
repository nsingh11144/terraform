variable "ami_id" {
  description = "AMI ID to be used for the instance"
  default     = "ami-02b49a24cfb95941c"  # Your specific AMI ID
}

variable "instance_type" {
  description = "The type of instance to create"
  default     = "t3.micro"  # Set a default value or leave it empty for user input
}

variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"  # Your specified region
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in"
  default     = "subnet-0b472c705eac4e4eb"  # Your specific subnet ID
}

variable "vpc_id" {
  description = "The ID of the VPC"
  default     = "vpc-00cd838e44c96e3df"  # Your specific VPC ID
}

variable "key_name" {
  description = "Name of the key pair to use for the instance"
  default     = "login"  # Your specific key pair name
}
