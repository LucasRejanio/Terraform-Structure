variable "region" {
  default     = "us-east-1"
  description = "My Region"
}

variable "cidr_block" {
  default     = "192.168.0.0/16"
  description = "Ip VPC"
}

variable "cidr_block_subnet_public_a" {
  default     = "192.168.1.0/24"
  description = "Ip Subnet public A"
}

variable "cidr_block_subnet_public_b" {
  default     = "192.168.2.0/24"
  description = "Ip Subnet public B"
}

variable "cidr_block_subnet_private_a" {
  default     = "192.168.3.0/24"
  description = "Ip Subnet Private A"
}

variable "cidr_block_subnet_private_b" {
  default     = "192.168.4.0/24"
  description = "Ip Subnet Private B"
}

variable "ami_linux" {
  default     = "ami-0a887e401f7654935"
  description = "AMI-Ubuntu"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "type"
}

variable "key_name" {
  default     = "keypub"
  description = "key"
}



