resource "aws_vpc" "pslcoud-vpc" {
  cidr_block           = "${var.pscloud_cidr_block}.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.pscloud_company}_vpc_${var.pscloud_env}"
    Project = var.pscloud_project
  }
}

resource "aws_internet_gateway" "pscloud-gw" {
  vpc_id = aws_vpc.pslcoud-vpc.id

  tags = {
    Name = "${var.pscloud_company}_gw_${var.pscloud_env}"
    Project = var.pscloud_project
  }
}

resource "aws_route_table" "pscloud-rt-public" {
  vpc_id = aws_vpc.pslcoud-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pscloud-gw.id
  }

  tags = {
    Name = "${var.pscloud_company}_rt_public_${var.pscloud_env}"
  }
}

resource "aws_route_table" "pscloud-rt-private" {
  vpc_id = aws_vpc.pslcoud-vpc.id

  tags = {
    Name = "${var.pscloud_company}_rt_private_${var.pscloud_env}"
  }
}

resource "aws_subnet" "pscloud-private" {
  count             = length(var.pscloud_az)
  vpc_id            = aws_vpc.pslcoud-vpc.id
  availability_zone = element(var.pscloud_az, count.index)
  cidr_block        = "${var.pscloud_cidr_block}.1${count.index}.0/24"

  tags = {
    Name = "${var.pscloud_company}_subnet_${count.index}_private_${var.pscloud_env}"
    Project = "Default AZs"
  }
}

resource "aws_subnet" "pscloud-public" {
  count                   = length(var.pscloud_az)
  vpc_id                  = aws_vpc.pslcoud-vpc.id
  availability_zone       = element(var.pscloud_az, count.index)
  cidr_block              = "${var.pscloud_cidr_block}.${count.index}.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.pscloud_company}_subnet_${count.index}_public_${var.pscloud_env}"
    Project = "Default AZs"
  }
}

resource "aws_subnet" "pscloud-private-ext" {
  count                   = length(var.pscloud_private_ext_subnets)
  vpc_id                  = aws_vpc.pslcoud-vpc.id
  availability_zone       = var.pscloud_private_ext_subnets[count.index].az
  cidr_block              = var.pscloud_private_ext_subnets[count.index].ip

  tags = {
    Name = "${var.pscloud_company}_subnet_${count.index}_private_ext_${var.pscloud_env}"
    Project = var.pscloud_private_ext_subnets[count.index].project
  }
}

resource "aws_subnet" "pscloud-public-ext" {
  count                   = length(var.pscloud_public_ext_subnets)
  vpc_id                  = aws_vpc.pslcoud-vpc.id
  availability_zone       = var.pscloud_public_ext_subnets[count.index].az
  cidr_block              = var.pscloud_public_ext_subnets[count.index].ip

  tags = {
    Name = "${var.pscloud_company}_subnet_${count.index}_public_ext_${var.pscloud_env}"
    Project = var.pscloud_public_ext_subnets[count.index].project
  }
}


resource "aws_db_subnet_group" "pscloud-rds-subnet-group" {
  count                   = length(var.pscloud_az) > 0 ? 1 : 0
  name                    = "${var.pscloud_company}_rds_subnet_group_${var.pscloud_env}"
  subnet_ids = [
    for as in aws_subnet.pscloud-private :
    as.id
  ]

  tags = {
    Name                  = "${var.pscloud_company}_rds_subnet_group_${var.pscloud_env}"
  }
}

resource "aws_route_table_association" "assoc-public" {
  count                   = length(aws_subnet.pscloud-public)
  subnet_id               = element(aws_subnet.pscloud-public, count.index).id
  route_table_id          = aws_route_table.pscloud-rt-public.id
}

resource "aws_route_table_association" "assoc-private" {
  count                   = length(aws_subnet.pscloud-private)
  subnet_id               = element(aws_subnet.pscloud-private, count.index).id
  route_table_id          = aws_route_table.pscloud-rt-private.id
}

resource "aws_route_table_association" "assoc-public-ext" {
  count                   = length(aws_subnet.pscloud-public-ext)
  subnet_id               = element(aws_subnet.pscloud-public-ext, count.index).id
  route_table_id          = aws_route_table.pscloud-rt-public.id

  depends_on = [aws_subnet.pscloud-public-ext]
}

resource "aws_route_table_association" "assoc-private-ext" {
  count                   = length(aws_subnet.pscloud-private-ext)
  subnet_id               = element(aws_subnet.pscloud-private-ext, count.index).id
  route_table_id          = aws_route_table.pscloud-rt-private.id

  depends_on = [aws_subnet.pscloud-private-ext]
}