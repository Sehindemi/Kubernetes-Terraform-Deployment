locals {
  vpc_cidr = "10.0.0.0/16"
}

locals {
  security_group = {
    public = {
      name        = "Sg-Public"
      description = "Public Sg for vpc"
      ingress = {
        ssh = {
          from       = 22
          to         = 22
          protocol   = "tcp"
          cidr_block = var.access_ip
        }
        http = {
          from       = 80
          to         = 80
          protocol   = "tcp"
          cidr_block = var.access_ip
        }
      }
    }
    rds = {
      name        = "sg public"
      description = "sg for rds instances"
      ingress = {
        mysql = {
          from       = 3306
          to         = 3306
          protocol   = "tcp"
          cidr_block = [local.vpc_cidr]
        }
      }
    }
  }
}
