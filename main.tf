module "networking" {
  source               = "./modules/networking/"
  max_subnet           = var.max_subnet
  vpc_cidr             = local.vpc_cidr
  public_subnet_count  = var.public_subnet_count
  public_cidr          = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidr         = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_subnet_count = var.private_subnet_count
  access_ip            = var.access_ip
  security_group       = local.security_group


}
