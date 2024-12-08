variable "AWS_ACCESS_KEY" {}

variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
  default = us-east-2
}

variable "Security_Groups" {
  type = list
  default = ["sg-001","sg-002","sg-003"]  
}

variable "AMIS" {
  type = map
  default = {
    us-east-1 = "ami-0f40c8f97004632f9"
    us-east-2 = "ami-05692172625678b4e"
    us-west-1 = "ami-0352d5a37fb4f603f"
    us-west-2 = "ami-0f40c8f97004632f9"
  }
}

variable "PRIVATE_KEY" {
    default = levelup_key
}

variable "PUBLIC_KEY" {
    default = levelup_key.pub
}

variable "INSTANCE_USERNAME" {
    default = ubuntu
}