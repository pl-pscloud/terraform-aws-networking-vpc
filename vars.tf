variable "pscloud_env" {}
variable "pscloud_company" {}
variable "pscloud_cidr_block" {}

//if set pscloud_az then will one privaye and one public subnet per available
//data "aws_availability_zones" "pscloud_az" { state = "available" }
variable "pscloud_az" { default = [] }

//if custom
variable "pscloud_private_subnets" {
  type = list(object({
    az      = string
    ip      = string
  }))
}

variable "pscloud_public_subnets" {
  type = list(object({
    az      = string
    ip      = string
  }))
}