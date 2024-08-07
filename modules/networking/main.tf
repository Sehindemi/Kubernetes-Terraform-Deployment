# networking/main.tf
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "random_integer" "random_int" {
  min = 1
  max = var.max_subnet
}

resource "random_shuffle" "random" {
  input = data.aws_availability_zones.available.names
  result_count = var.max_subnet
}

resource "aws_vpc" "mtc_k8_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "mtc_k8_vpc-${random_integer.random_int.result}"
  }
}

resource "aws_subnet" "public_subnet" {
  count = var.public_subnet_count
  vpc_id = aws_vpc.mtc_k8_vpc.id
  cidr_block = var.public_cidr[count.index]
  availability_zone = random_shuffle.random.result[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "mtc_k8_public_subnet- ${random_integer.random_int.result}"
  }
}


resource "aws_subnet" "private_subnet" {
  count = var.private_subnet_count
  vpc_id = aws_vpc.mtc_k8_vpc.id
  availability_zone = random_shuffle.random.result[count.index]
  cidr_block = var.private_cidr[count.index]
  tags = {
    Name = "mtc_k8_private_subnet- ${random_integer.random_int.result}"
  }
}

## Internet gate way for outbound traffic 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mtc_k8_vpc.id

  tags = {
    Name = "mtc_k8_igw"
  }
}

## Route table for IGW

resource "aws_route_table" "igw_rt" {
  vpc_id = aws_vpc.mtc_k8_vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "igw_rt"
  }
}

resource "aws_route_table_association" "rt_assoc" {
  count = var.public_subnet_count
  subnet_id = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.igw_rt.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow ssh "
  description = "Allow ssh traffic "
  vpc_id      = aws_vpc.mtc_k8_vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}
