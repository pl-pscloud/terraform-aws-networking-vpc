variable "pscloud_env" {}
variable "pscloud_company" {}
variable "pscloud_project" { default = "Default"}
variable "pscloud_cidr_block" {}

//if set pscloud_az then will one privaye and one public subnet per available
//data "aws_availability_zones" "pscloud_az" { state = "available" }
variable "pscloud_az" { default = [] }

//if custom
variable "pscloud_private_ext_subnets" {
  type = list(object({
    az      = string
    ip      = string
    project = string
  }))
  default = []
}

variable "pscloud_public_ext_subnets" {
  type = list(object({
    az      = string
    ip      = string
    project = string
  }))
  default = []
}

variable "pscloud_nat_gw" { default = false }
variable "pscloud_nat_gw_subnet_az" { default = "" }
variable "pscloud_nat_gw_subnet_cidr" { default = "" }