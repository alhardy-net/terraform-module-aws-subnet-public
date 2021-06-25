variable "aws_region" {
  description = "The AWS region for the resources."
  type        = string
}

variable "name" {
  description = "The prefix to use for all resource names."
  type        = string
}

variable "vpc_id" {
  description = "The Identifier of the VPC for which to create the subnet(s)."
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR block for the Subnet."
  type        = string
}

variable "igw_id" {
  description = "The Identifier of the internet gateway."
  type        = string
}

variable "subnet_count" {
  description = "The number of public subnets, each assigned a random AZ where assigned AZ will be unique when possible."
  type        = number
}

variable "subnet_network_acl_egress" {
  description = "Egress network ACL rules for public subnets"
  type        = list(map(string))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
    },
  ]
}

variable "subnet_network_acl_ingress" {
  description = "Private network ACL rules for public subnets"
  type        = list(map(string))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
    },
  ]
}

variable "enable_nat_gateway" {
  description = "If true creates a nat gateway with the public subnet."
  type        = bool
}

variable "use_single_nat_gateway" {
  description = "If true uses a single nat gateway in one AZ, otherwise deploys a nat gateway in each AZ"
  type        = bool
  default     = false
}

variable "enable_flow_log" {
  description = "Enable Subnet flow log. Logs are sent to s3 bucket."
  type        = bool
}

variable "flow_log_s3_bucket_arn" {
  type        = string
  default     = ""
  description = "S3 ARN for Subnet flow logs."
  sensitive   = true
}

variable "flow_log_traffic_type" {
  type        = string
  default     = "ALL"
  description = "Type of traffic to capture in Subnet flow logs. Valid values: ACCEPT, REJECT, ALL."
}

# Terraform Cloud
variable "TFC_WORKSPACE_SLUG" {
  type        = string
  default     = "local"
  description = "This is the full slug of the configuration used in this run. This consists of the organization name and workspace name, joined with a slash"
}