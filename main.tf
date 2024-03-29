resource "aws_vpc" "pslcoud-vpc" {
  cidr_block           = var.pscloud_easy_vpc == true ? "${var.pscloud_cidr_block_easy}.0.0/16" : var.pscloud_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.pscloud_company}_vpc_${var.pscloud_env}_${var.pscloud_project}"
    Project = var.pscloud_project
  }
}

resource "aws_internet_gateway" "pscloud-gw" {
  vpc_id = aws_vpc.pslcoud-vpc.id

  tags = {
    Name = "${var.pscloud_company}_gw_${var.pscloud_env}_${var.pscloud_project}"
    Project = var.pscloud_project
  }
}

resource "aws_subnet" "pscloud-private" {
  count             = length(var.pscloud_az)
  vpc_id            = aws_vpc.pslcoud-vpc.id
  availability_zone = element(var.pscloud_az, count.index)
  cidr_block        = "${var.pscloud_cidr_block_easy}.1${count.index}.0/24"

  tags = {
    Name = "${var.pscloud_company}_subnet_${count.index}_private_${var.pscloud_env}_${var.pscloud_project}_${var.pscloud_cidr_block}.${count.index}.0/24"
    Project = "Default AZs"
  }
}

resource "aws_subnet" "pscloud-public" {
  count                   = length(var.pscloud_az)
  vpc_id                  = aws_vpc.pslcoud-vpc.id
  availability_zone       = element(var.pscloud_az, count.index)
  cidr_block              = "${var.pscloud_cidr_block_easy}.${count.index}.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.pscloud_company}_subnet_${count.index}_public_${var.pscloud_env}_${var.pscloud_project}_${var.pscloud_cidr_block}.${count.index}.0/24"
    Project = "Default AZs"
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
    Name                  = "${var.pscloud_company}_rds_subnet_group_${var.pscloud_env}_${var.pscloud_project}"
  }
}

resource "aws_route_table" "pscloud-rt-public" {
  count         = (length(var.pscloud_az) > 0) ? 1 : 0

  vpc_id = aws_vpc.pslcoud-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pscloud-gw.id
  }

  tags = {
    Name = "${var.pscloud_company}_rt_public_${var.pscloud_env}_${var.pscloud_project}"
  }
}

resource "aws_route_table" "pscloud-rt-private" {
  count         = (length(var.pscloud_az) > 0) ? 1 : 0
  vpc_id        = aws_vpc.pslcoud-vpc.id

  tags = {
    Name = "${var.pscloud_company}_rt_private_${var.pscloud_env}_${var.pscloud_project}"
  }
}

resource "aws_route_table_association" "assoc-public" {
  count                   = length(var.pscloud_az)
  subnet_id               = element(aws_subnet.pscloud-public, count.index).id
  route_table_id          = aws_route_table.pscloud-rt-public[0].id
}

resource "aws_route_table_association" "assoc-private" {
  count                   = length(var.pscloud_az)
  subnet_id               = element(aws_subnet.pscloud-private, count.index).id
  route_table_id          = aws_route_table.pscloud-rt-private[0].id
}











########## SPECIAL
resource "aws_subnet" "pscloud-private-ext" {
  count                   = length(var.pscloud_private_ext_subnets)
  vpc_id                  = aws_vpc.pslcoud-vpc.id
  availability_zone       = var.pscloud_private_ext_subnets[count.index].az
  cidr_block              = var.pscloud_private_ext_subnets[count.index].ip

  tags = {
    Name = "${var.pscloud_company}_subnet_${count.index}_private_ext_${var.pscloud_env}_${var.pscloud_project}_${var.pscloud_private_ext_subnets[count.index].ip}"
    Project = var.pscloud_private_ext_subnets[count.index].project
  }
}

resource "aws_subnet" "pscloud-public-ext" {
  count                   = length(var.pscloud_public_ext_subnets)
  vpc_id                  = aws_vpc.pslcoud-vpc.id
  availability_zone       = var.pscloud_public_ext_subnets[count.index].az
  cidr_block              = var.pscloud_public_ext_subnets[count.index].ip
  map_public_ip_on_launch = "true"

  tags = {
    Name                  = "${var.pscloud_company}_subnet_${count.index}_public_ext_${var.pscloud_env}_${var.pscloud_project}_${var.pscloud_private_ext_subnets[count.index].ip}"
    Project               = var.pscloud_public_ext_subnets[count.index].project
  }
}

resource "aws_route_table" "pscloud-rt-public-ext" {
  count         = (length(var.pscloud_public_ext_subnets) > 0) ? 1 : 0

  vpc_id = aws_vpc.pslcoud-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pscloud-gw.id
  }

  tags = {
    Name = "${var.pscloud_company}_rt_public_${var.pscloud_env}_${var.pscloud_project}"
  }
}

resource "aws_route_table" "pscloud-rt-private-ext" {
  count         = (length(var.pscloud_private_ext_subnets) > 0) ? 1 : 0
  vpc_id        = aws_vpc.pslcoud-vpc.id

  tags = {
    Name = "${var.pscloud_company}_rt_private_${var.pscloud_env}_${var.pscloud_project}"
  }
}


resource "aws_route_table_association" "assoc-public-ext" {
  count                   = length(var.pscloud_public_ext_subnets)
  subnet_id               = element(aws_subnet.pscloud-public-ext, count.index).id
  route_table_id          = aws_route_table.pscloud-rt-public-ext[0].id

  depends_on              = [aws_subnet.pscloud-public-ext]
}

resource "aws_route_table_association" "assoc-private-ext" {
  count                   = length(var.pscloud_private_ext_subnets)
  subnet_id               = element(aws_subnet.pscloud-private-ext, count.index).id
  route_table_id          = aws_route_table.pscloud-rt-private-ext[0].id

  depends_on              = [aws_subnet.pscloud-private-ext]
}


resource "aws_subnet" "pscloud-public-nat" {
  count                   = (var.pscloud_nat_gw == true ? 1 : 0)
  vpc_id                  = aws_vpc.pslcoud-vpc.id
  availability_zone       = var.pscloud_nat_gw_subnet_az
  cidr_block              = var.pscloud_nat_gw_subnet_cidr
  map_public_ip_on_launch = "true"

  tags = {
    Name                  = "${var.pscloud_company}_subnet_public_nat_${var.pscloud_env}_${var.pscloud_project}_${var.pscloud_nat_gw_subnet_cidr}"
    Project               = var.pscloud_project
  }
}

resource "aws_route_table" "pscloud-rt-public-nat" {
  count                   = (var.pscloud_nat_gw == true ? 1 : 0)

  vpc_id = aws_vpc.pslcoud-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pscloud-gw.id
  }

  tags = {
    Name = "${var.pscloud_company}_rt_public_nat_${var.pscloud_env}_${var.pscloud_project}"
  }
}

resource "aws_route_table_association" "assoc-public-nat" {
  count                   = (var.pscloud_nat_gw == true ? 1 : 0)
  subnet_id               = aws_subnet.pscloud-public-nat[0].id
  route_table_id          = aws_route_table.pscloud-rt-public-nat[0].id
}

resource "aws_eip" "pscloud-eip-nat-gw" {
  count = (var.pscloud_nat_gw == true ? 1 : 0)
  vpc   = true

  tags = {
    Name = "${var.pscloud_company}_eip_nat_gw_${var.pscloud_env}_${var.pscloud_project}"
  }
}

resource "aws_nat_gateway" "pscloud-nat-gw" {
  count = (var.pscloud_nat_gw == true ? 1 : 0)

  allocation_id = aws_eip.pscloud-eip-nat-gw[0].id
  subnet_id     = aws_subnet.pscloud-public-nat[0].id

  tags = {
    Name = "${var.pscloud_company}_nat_gw_${var.pscloud_env}_${var.pscloud_project}"
  }

  depends_on = [ aws_eip.pscloud-eip-nat-gw ]
}