variable "region" {
    default = "us-east-2"
}

variable "public_key_path" {
    description = "public key path"
    default = "~/.ssh/levelup_key.pub"
}

variable "instance_ami" {
    description = "ami for the aws instance"
    default = ""
}

variable "instance_type" {
    description = "instance type"
    default = "t2.small"
}

variable "environment_tag" {
    description = "environment tag"
    default = "Production"
}