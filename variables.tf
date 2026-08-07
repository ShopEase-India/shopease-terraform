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
