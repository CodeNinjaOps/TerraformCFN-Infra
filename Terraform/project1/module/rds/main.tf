# calling vpc module to get the subnet id

module "levelup-vpc" {
    source = "../vpc"

    ENVIRONMENT = var.ENVIRONMENT
    AWS_REGION = var.AWS_REGION
}

# define subnet groups for the rds services

resource "aws_db_subnet_group" "levelup-rds-subnet-groups" {
    name = "${var.ENVIRONMENT}-levelup-db-snet"
    description = "allowed subnet for db cluster"
    subnet_ids = [ 
        "${var.VPC_PRIVATE_SUBNET_1}",
        "${var.VPC_PRIVATE_SUBNET_2}"
    ]

    tags = {
        name = "${var.ENVIRONMENT}-levelup-db-subnet"
    }
}

# define security group for rds instance

resource "aws_security_group" "levelup-rds-sg" {
    name = "${var.ENVIRONMENT}-levelup-rds-sg"
    description = "created by levelup"
    vpc_id = var.VPC_ID

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["${var.RDS_CIDR}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        name = "${var.ENVIRONMENT}-levelup-rds-sg"
    }
}

# creating the rds service

resource "aws_db_instance" "levelup-rds" {
    identifier = "${var.ENVIRONMENT}-levelup-rds"
    allocated_storage = var.LEVELUP_RDS_ALLOCATED_STORAGE
    storage_type = "gp2"
    engine = var.LEVELUP_RDS_ENGINE
    engine_version = var.LEVELUP_RDS_ENGINE_VERSION
    instance_class = var.DB_INSTANCE_CLASS
    backup_retention_period = var.BACKUP_RETENTION_PERIOD
    publicly_accessible = var.PUBLICLY_ACCESSIBLE
    username = var.LEVELUP_RDS_USERNAME
    password = var.LEVELUP_RDS_PASSWORD
    vpc_security_group_ids = [aws_security_group.levelup-rds-sg.id]
    db_subnet_group_name = aws_db_subnet_group.levelup-rds-subnet-group.name
    multi_az = "false"
}

output "rds_prod_endpoint" {
    value = aws_db_instance.levelup-rds.endpoint
}