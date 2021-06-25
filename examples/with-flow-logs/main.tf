locals {
  name               = "alhardynet"
  aws_region         = "ap-southeast-2"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = cidrsubnet(local.vpc_cidr, 4, 0)
}

resource "aws_s3_bucket" "s3_flow_log" {
  bucket        = "alhardynet-vpc-flow-logs"
  force_destroy = true
}

module "aws-vpc" {
  source                        = "app.terraform.io/bytebox/aws-vpc/module"
  version                       = "0.0.1"
  aws_region                    = local.aws_region
  vpc_cidr                      = local.vpc_cidr
  enable_vpc_flow_log            = true
  vpc_flow_log_s3_bucket_arn     = aws_s3_bucket.s3_flow_log.arn
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
  enable_nat_gateway     = true
  use_single_nat_gateway = true
  subnet_count           = 2
  vpc_id                 = module.aws-vpc.vpc_id
  enable_flow_log         = true
  flow_log_s3_bucket_arn  = aws_s3_bucket.s3_flow_log.arn
  subnet_cidr            = local.public_subnet_cidr
}