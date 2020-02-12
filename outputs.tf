output "pscloud_vpc" {
  value = aws_vpc.pslcoud-vpc
}

output "pscloud_vpc_id" {
  value = aws_vpc.pslcoud-vpc.id
}

output "pscloud_public_subnets_ids" {
  value = aws_subnet.pscloud-public
}

output "pscloud_private_subnets_ids" {
  value = aws_subnet.pscloud-private
}

output "pscloud_public_ext_subnets_ids" {
  value = aws_subnet.pscloud-public-ext
}

output "pscloud_private_ext_subnets_ids" {
  value = aws_subnet.pscloud-private-ext
}

output "pscloud_rds_subnet_group" {
  value = aws_db_subnet_group.pscloud-rds-subnet-group
}
