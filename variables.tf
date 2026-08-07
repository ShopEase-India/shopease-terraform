variable "aws_region" {
  description = "where aws resources will be created"
  type        = string
  default     = "ap-south-2"
}
variable "environment" {
  description = "Deployment Environment"
  type        = string
  default     = "dev"
}
variable "vpc_cidr" {
  description = "vpc cidr range"
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_subnet_1_cidr" {
  description = "public subnet 1 cidr range"
  type        = string
  default     = "10.0.1.0/24"
}
variable "public_subnet_2_cidr" {
  description = "public subnet 2 cidr range"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_1_az" {
  description = "subnet 1 availability zone"
  type        = string
  default     = "ap-south-2a"
}
variable "subnet_2_az" {
  description = "subnet 2 availability zone"
  type        = string
  default     = "ap-south-2b"
}
