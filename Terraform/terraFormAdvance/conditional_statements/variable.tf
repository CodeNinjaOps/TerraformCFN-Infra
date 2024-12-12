variable "AWS_REGION" {
    type = string
    default = "us-east-1"
}

variable "environment" {
    description = "add the tags"
    type = string
    default = "Development"
}