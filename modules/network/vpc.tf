data  "aws_availability_zones" "my_availability_zones" {
  state = "available"
    filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block       =  var.my_vpc_cidr

  tags = {
    Environment = "${var.general_tag["Environment"]} - VPC"
    Owner =  "${var.general_tag["Owner"]} - VPC"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Environment = "${var.general_tag["Environment"]} - Internet gateway"
    Owner =  "${var.general_tag["Owner"]} - Internet gateway"
  }
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  count = length(var.subnet_cidr_public)
  cidr_block = element(var.subnet_cidr_public, count.index)
  availability_zone = data.aws_availability_zones.my_availability_zones.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Environment = "${var.general_tag["Environment"]} - Public subnet"
    Owner =  "${var.general_tag["Owner"]} - Public subnet"
  }
}

resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Environment = "${var.general_tag["Environment"]} - Public route table"
    Owner =  "${var.general_tag["Owner"]} - Public route table"
  }
}

resource "aws_route_table_association" "my_public_route_table_association" {
  count = length(aws_subnet.my_public_subnet[*].id)
  subnet_id      = element(aws_subnet.my_public_subnet[*].id, count.index)
  route_table_id = aws_route_table.my_public_route_table.id
}
#####

resource "aws_eip" "my_eip_for_nat_gateway" {
  count = length(var.subnet_cidr_private)
  domain = "vpc"
  tags = {
    Environment = "${var.general_tag["Environment"]} - Elastic IP for NAT"
    Owner =  "${var.general_tag["Owner"]} - Elastic IP for NAT"
  }
}

resource "aws_subnet" "my_private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  count = length(var.subnet_cidr_private)
  cidr_block = element(var.subnet_cidr_private, count.index)
  availability_zone = data.aws_availability_zones.my_availability_zones.names[count.index]

  tags = {
    Environment = "${var.general_tag["Environment"]} - Private subnet"
    Owner =  "${var.general_tag["Owner"]} - Private subnet"
  }
}

resource "aws_nat_gateway" "my_nat_gateway" {
  count = length(var.subnet_cidr_private)
  allocation_id = aws_eip.my_eip_for_nat_gateway[count.index].id
  subnet_id  = element(aws_subnet.my_public_subnet[*].id, count.index)

  tags = {
    Environment = "${var.general_tag["Environment"]} - My NAT gateway"
    Owner =  "${var.general_tag["Owner"]} - My NAT gateway"
  }
}

resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  count = length(var.subnet_cidr_private)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my_nat_gateway[count.index].id
  }

  tags = {
    Environment = "${var.general_tag["Environment"]} - Private route table"
    Owner =  "${var.general_tag["Owner"]} - Private route table"
  }
}

resource "aws_route_table_association" "my_private_route_table_association" {
  count = length(aws_subnet.my_private_subnet[*].id)
  subnet_id      = element(aws_subnet.my_private_subnet[*].id, count.index)
  route_table_id = aws_route_table.my_private_route_table[count.index].id

}


