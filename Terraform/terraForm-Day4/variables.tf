variable "AWS_ACCESS_KEYS" {
    type = string
    default = "AKIASMSIZOF42P2VU"
}

variable "AWS_SECRET_KEYS" {}

variable "AWS_REGION" {
    type = string
    default = "us-east-2"  
}

variable "SECURITY_GROUPS" {
    type = list
    default = ["sg-001","sg-002","sg-003"] 
}

variable "AMIS" {
    type = map
    default = {
        us-east-1  = "ami-0352d5a37fb4f603f"
        us-east-2 = "ami-0f40c8f97004632f9"
    }  
}