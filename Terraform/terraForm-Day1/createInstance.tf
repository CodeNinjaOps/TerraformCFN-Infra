resource "aws_instance" "myFirstInstance" {
    ami = lookup(var.AWS_REGION,var.AMIS)
    instance_type = "t2.small"

    tags = {
        name = "demoInstance" 
    }

    security_groups = var.Security_Groups  
}