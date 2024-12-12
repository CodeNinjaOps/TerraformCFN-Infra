variable "levelup_key_path" {
    type = string 
    default = "~/.ssh/levelup_key.pub"
}

variable "VPC_ID" {
    type = string
    default = ""
}

variable "Environment" {
    type = string
    default = ""
}

variable "AWS_REGION" {
    type = string
    default = "us-east-1"
}

variable "PUBLIC_SUBNET" {
    type = list
}

variable "AMIS" {
    type = map
    default = {
        us-east-1 = ""
        us-east-2 = ""
        us-west-1 = ""
        us-west-2 = ""
    }
}

variable "INSTANCE_TYPE" {
    type = string
    default = "t2.small"
}