variable "region" {
  description = "AWS region à utiliser"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "Type d’instance EC2"
  type        = string
  default     = "t2.micro"
}

variable "aws_access_key" {
  description = "Access key AWS"
  type        = string
  default     = ""
}

variable "aws_secret_key" {
  description = "Secret key AWS"
  type        = string
  default     = ""
}

variable "aws_session_token" {
  description = "Session token AWS (si fourni)"
  type        = string
  default     = ""
}

variable "ec2_key_name" {
  description = "Nom de la clé SSH existante"
  type        = string
  default     = "lab-key"
}

