resource "aws_eip" "levelup-nat" {
    vpc = true
}

resource "aws_nat_gateway" "levelup-nat-gw" {
    allocation_id = aws_eip.levelup-nat.id
    subnet_id = aws_subnet.level-up-public-1.id
    depends_on = [ aws_internet_gateway.levelup-gw ]
}

resource "aws_route_table" "levelup-private" {
    vpc_id = aws_vpc.level-up.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.levelup-nat-gw.id
    }

    tags = {
        Name = "levelup-private"
    }
}

# routing association private subnets

resource "aws_route_table_association" "levelup-private-1a" {
    subnet_id = aws_subnet.level-up-private-1.id
    route_table_id = aws_route_table.levelup-private.id
}

resource "aws_route_table_association" "levelup-private-2a" {
    subnet_id = aws_subnet.level-up-private-2.id
    route_table_id = aws_route_table.levelup-private.id
}

resource "aws_route_table_association" "levelup-private-3a" {
    subnet_id = aws_subnet.level-up-private-3.id
    route_table_id = aws_route_table.levelup-private.id
}