locals {
  name               = "example"
  aws_region         = "ap-southeast-2"
  vpc_cidr           = "10.100.0.0/16"
  public_subnet_cidr = cidrsubnet(local.vpc_cidr, 4, 0)
}

module "aws-vpc" {
  source                        = "app.terraform.io/bytebox/aws-vpc/module"
  version                       = "0.0.2"
  aws_region                    = local.aws_region
  vpc_cidr                      = local.vpc_cidr
  manage_default_security_group = false
  manage_default_network_acl    = false
  manage_default_route_table    = false
  name                          = local.name
}

module "public-subnet" {
  source                 = "../../"
  aws_region             = local.aws_region
  igw_id                 = module.aws-vpc.igw_id
  name                   = "${local.name}-public"
  enable_nat_gateway     = false
  use_single_nat_gateway = true
  subnet_count           = 2
  vpc_id                 = module.aws-vpc.vpc_id
  subnet_cidr            = local.public_subnet_cidr
}