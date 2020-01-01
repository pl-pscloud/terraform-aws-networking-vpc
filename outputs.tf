output "pscloud_vpc" {
  value = aws_vpc.pslcoud-vpc
}

output "pscloud_public_subnets_ids" {
  value = aws_subnet.pscloud-public
}

output "pscloud_private_subnets_ids" {
  value = aws_subnet.pscloud-private
}
output "pscloud_rds_subnet_group" {
  value = aws_db_subnet_group.pslouc-rds-subnet-group
}
