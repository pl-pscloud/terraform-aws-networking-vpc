output "public_subnets_ids" {
  value = aws_subnet.public
}

output "private_subnets_ids" {
  value = aws_subnet.private
}

output "sec_gr_webserver" {
  value = aws_security_group.tf_sec_gr_webserver.id
}

output "sec_gr_elb" {
  value = aws_security_group.tf_sec_gr_elb.id
}

output "sec_gr_rds" {
  value = aws_security_group.tf_sec_gr_rds.id
}
output "sec_nfs_rds" {
  value = aws_security_group.tf_sec_gr_nfs.id
}

output "rds_subnet_group" {
  value = aws_db_subnet_group.tf_rds_subnet_group.id
}

output "vpc_id" {
  value = aws_vpc.tf_vpc_01.id
}
