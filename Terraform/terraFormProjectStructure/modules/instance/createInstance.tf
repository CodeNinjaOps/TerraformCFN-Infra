# resource key pair

resource "aws_key_pair" "levelup_key" {
    key_name = "levelup_key"
    public_key = file(var.levelup_key_path)
}

resource "aws_security_group" "sg_level_22" {
    vpc_id = var.VPC_ID
    name = "allow-ssh-${var.Environment}" 
    description = "security group that allow ssh traffic"

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        name = "allow-shh"
        Environment = var.Environment 
    }    
}

resource "aws_instance" "levelup_instance" {
    ami = lookup(var.AMIS, var.AWS_REGION)
    instance_type = var.INSTANCE_TYPE

    # the vpc subnet 
    subnet_id = element(var.PUBLIC_SUBNET, 0)
    availability_zone = "${var.AWS_REGION}a"

    # the security groups
    vpc_security_group_ids = ["${aws_security_group.sg_level_22.id}"]

    # the public ssh key 
    key_name = aws_key_pair.levelup_key.key_name

    tags = {
        Name = "instance-${var.Environment}"
        Environment = var.Environment
    }
}