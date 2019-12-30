resource "aws_vpc" "tf_vpc_01" {
  cidr_block              = "${var.vpc_cidr_block}.0.0/16"
  enable_dns_hostnames    = true
  enable_dns_support      = true

  tags = {
    Name                  = "${var.company}_vpc_01_${var.env}"
  }
}

resource "aws_internet_gateway" "tf_gw_01" {
  vpc_id                  = aws_vpc.tf_vpc_01.id

  tags = {
    Name                  = "${var.company}_gw_01_${var.env}"
  }
}

resource "aws_route_table" "tf_rt_01_default_public" {
  vpc_id                  = aws_vpc.tf_vpc_01.id

  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = aws_internet_gateway.tf_gw_01.id
  }

  tags = {
    Name                  = "${var.company}_rt_01_default_public_${var.env}"
  }
}

resource "aws_route_table" "tf_rt_01_default_private" {
  vpc_id                  = aws_vpc.tf_vpc_01.id

  tags = {
    Name                  = "${var.company}_rt_01_default_private_${var.env}"
  }
}

resource "aws_subnet" "private" {
  count                 = length(var.az)
  vpc_id                = aws_vpc.tf_vpc_01.id
  availability_zone     = element(var.az, count.index)
  cidr_block            = "${var.vpc_cidr_block}.1${count.index}.0/24"

  tags = {
    Name                  = "${var.company}_vpc_01_subnet_${count.index}_private_${var.env}"
  }
}

resource "aws_subnet" "public" {
  count                 = length(var.az)
  vpc_id                = aws_vpc.tf_vpc_01.id
  availability_zone     = element(var.az, count.index)
  cidr_block            = "${var.vpc_cidr_block}.${count.index}.0/24"
  map_public_ip_on_launch = "true"

    tags = {
    Name                  = "${var.company}_vpc_01_subnet_${count.index}_public_${var.env}"
  }
}

resource "aws_db_subnet_group" "tf_rds_subnet_group" {
  name                    = "${var.company}_tf_rds_subnet_group_${var.env}"
  subnet_ids              = [
    for as in aws_subnet.private:
          as.id
  ]

  tags = {
    Name = "${var.company}_rds_subnet_group_${var.env}"
  }
}

resource "aws_route_table_association" "assoc_public" {
  count                 = length(aws_subnet.public)
  subnet_id               = element(aws_subnet.public, count.index).id
  route_table_id          = aws_route_table.tf_rt_01_default_public.id
}

resource "aws_route_table_association" "assoc_private" {
  count                 = length(aws_subnet.private)
  subnet_id               = element(aws_subnet.private, count.index).id
  route_table_id          = aws_route_table.tf_rt_01_default_private.id
}

resource "aws_security_group" "tf_sec_gr_webserver" {
  name                    = "${var.company}_sec_gr_webserver"
  description             = "Terraform Security Group for webserver"

  vpc_id                  = aws_vpc.tf_vpc_01.id

  ingress {
    from_port             = 80
    to_port               = 80
    protocol              = "tcp"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  ingress {
    from_port             = 443
    to_port               = 443
    protocol              = "tcp"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  ingress {
    from_port             = 22
    to_port               = 22
    protocol              = "tcp"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  ingress {
    from_port             = 9022
    to_port               = 9022
    protocol              = "tcp"
    cidr_blocks           = ["0.0.0.0/0"]
  }

  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.company}_sec_gr_webserver_${var.env}"
  }
}

resource "aws_security_group" "tf_sec_gr_elb" {
  name                    = "${var.company}_sec_gr_elb"
  description             = "Terraform Security Group for ELB"

  vpc_id                  = aws_vpc.tf_vpc_01.id

  ingress {
    from_port             = 80
    to_port               = 80
    protocol              = "tcp"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  ingress {
    from_port             = 443
    to_port               = 443
    protocol              = "tcp"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.company}_sec_gr_elb_${var.env}"
  }
}

resource "aws_security_group" "tf_sec_gr_rds" {
  name                    = "${var.company}_sec_gr_rds"
  description             = "Terraform Security Group for RDS server"

  vpc_id                  = aws_vpc.tf_vpc_01.id

  ingress {
    from_port             = 3306
    to_port               = 3306
    protocol              = "tcp"
    security_groups       = [ aws_security_group.tf_sec_gr_webserver.id ]
    //cidr_blocks           =
  }

  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.company}_sec_gr_rds_${var.env}"
  }
}

resource "aws_security_group" "tf_sec_gr_nfs" {
  name                    = "${var.company}_sec_nfs_rds"
  description             = "Terraform Security Group for NFS server"

  vpc_id                  = aws_vpc.tf_vpc_01.id

  ingress {
    from_port             = 2049
    to_port               = 2049
    protocol              = "tcp"
    //TODO: zrobic zeby było z grupy webserver
    security_groups       = [ aws_security_group.tf_sec_gr_webserver.id ]
    //cidr_blocks           = ["0.0.0.0/0"]
  }

  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.company}_sec_gr_nfs_${var.env}"
  }
}
