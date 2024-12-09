resource "aws_vpc" "level-up" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"

    tags = {
        name = "level-up"
    }
}
# public subnets

resource "aws_subnet" "level-up-public-1" {
    vpc_id     = aws_vpc.level-up.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-2a"

    tags = {
        Name = "level-up-public-1"
    }
}

resource "aws_subnet" "level-up-public-2" {
    vpc_id     = aws_vpc.level-up.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-2b"

    tags = {
        Name = "level-up-public-2"
    }
}

resource "aws_subnet" "level-up-public-3" {
    vpc_id     = aws_vpc.level-up.id
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-2c"

    tags = {
        Name = "level-up-public-3"
    }
}

#private subnets
resource "aws_subnet" "level-up-private-1" {
    vpc_id     = aws_vpc.level-up.id
    cidr_block = "10.0.4.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-2a"

    tags = {
        Name = "level-up-private-1"
    }
}

resource "aws_subnet" "level-up-private-2" {
    vpc_id     = aws_vpc.level-up.id
    cidr_block = "10.0.5.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "us-east-2b"

    tags = {
        Name = "level-up-private-2"
    }
}

resource "aws_subnet" "level-up-private-3" {
    vpc_id     = aws_vpc.level-up.id
    cidr_block = "10.0.6.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "us-east-2c"

    tags = {
        Name = "level-up-private-3"
    }
}

# custom internet gateways

resource "aws_internet_gateway" "levelup-gw" {
    vpc_id = aws_vpc.level-up.id

    tags = {
        Name = "levelup-gw"
    }
}

# routing tables for custom vpc 

resource "aws_route_table" "levelup-public" {
    vpc_id = aws_vpc.level-up.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.levelup-gw.id
    }

    tags = {
        Name = "levelup-public-1"
    }
}

# routing association public subnets

resource "aws_route_table_association" "levelup-public-1a" {
    subnet_id      = aws_subnet.level-up-public-1.id
    route_table_id = aws_route_table.levelup-public.id
}

resource "aws_route_table_association" "levelup-public-2a" {
    subnet_id      = aws_subnet.level-up-public-2.id
    route_table_id = aws_route_table.levelup-public.id
}

resource "aws_route_table_association" "levelup-public-3a" {
    subnet_id      = aws_subnet.level-up-public-3.id
    route_table_id = aws_route_table.levelup-public.id
}