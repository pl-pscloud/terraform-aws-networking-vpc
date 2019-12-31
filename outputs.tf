output "pscloud_public_subnets_ids" {
  value = aws_subnet.pscloud-public
}

output "pscloud_private_subnets_ids" {
  value = aws_subnet.pscloud-private
}
output "pscloud_rds_subnet_group" {
  value = aws_db_subnet_group.tf_rds_subnet_group.id
}

output "pscloud_vpc_id" {
  value = aws_vpc.pslcoud_vpc.id
}
