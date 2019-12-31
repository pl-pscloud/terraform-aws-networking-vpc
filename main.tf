resource "aws_vpc" "pslcoud_vpc" {
  cidr_block           = "${var.pscloud_cidr_block}.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.pscloud_company}_vpc_${var.pscloud_env}"
  }
}

resource "aws_internet_gateway" "pscloud-gw" {
  vpc_id = aws_vpc.pslcoud_vpc.id

  tags = {
    Name = "${var.pscloud_company}_gw_${var.pscloud_env}"
  }
}

resource "aws_route_table" "pscloud-rt-public" {
  vpc_id = aws_vpc.pslcoud_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pscloud-gw.id
  }

  tags = {
    Name = "${var.pscloud_company}_rt_public_${var.pscloud_env}"
  }
}

resource "aws_route_table" "pscloud-rt-private" {
  vpc_id = aws_vpc.pslcoud_vpc.id

  tags = {
    Name = "${var.pscloud_company}_rt_private_${var.pscloud_env}"
  }
}

resource "aws_subnet" "pscloud-private" {
  count             = length(var.pscloud_az)
  vpc_id            = aws_vpc.pslcoud_vpc.id
  availability_zone = element(var.pscloud_az, count.index)
  cidr_block        = "${var.pscloud_cidr_block}.1${count.index}.0/24"

  tags = {
    Name = "${var.pscloud_company}_subnet_${count.index}_private_${var.pscloud_env}"
  }
}

resource "aws_subnet" "pscloud-public" {
  count                   = length(var.pscloud_az)
  vpc_id                  = aws_vpc.pslcoud_vpc.id
  availability_zone       = element(var.pscloud_az, count.index)
  cidr_block              = "${var.pscloud_cidr_block}.${count.index}.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.pscloud_company}_subnet_${count.index}_public_${var.pscloud_env}"
  }
}

resource "aws_db_subnet_group" "tf_rds_subnet_group" {
  name = "${var.pscloud_company}_rds_subnet_group_${var.pscloud_env}"
  subnet_ids = [
    for as in aws_subnet.pscloud-private :
    as.id
  ]

  tags = {
    Name = "${var.pscloud_company}_rds_subnet_group_${var.pscloud_env}"
  }
}

resource "aws_route_table_association" "assoc_public" {
  count          = length(aws_subnet.pscloud-public)
  subnet_id      = element(aws_subnet.pscloud-public, count.index).id
  route_table_id = aws_route_table.pscloud-rt-public.id
}

resource "aws_route_table_association" "assoc_private" {
  count          = length(aws_subnet.pscloud-private)
  subnet_id      = element(aws_subnet.pscloud-private, count.index).id
  route_table_id = aws_route_table.pscloud-rt-private.id
}
