data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "azs" {
  input        = data.aws_availability_zones.available.names
  result_count = 10
}

resource "aws_subnet" "public" {
  count                   = var.subnet_count
  availability_zone       = random_shuffle.azs.result[count.index]
  cidr_block              = cidrsubnet(var.subnet_cidr, ceil(log(var.subnet_count == 1 ? var.subnet_count * 4 : var.subnet_count == 2 ? var.subnet_count * 2 : var.subnet_count, 2)), count.index)
  map_public_ip_on_launch = true
  vpc_id                  = var.vpc_id

  tags = {
    Name               = "${var.name}-${count.index + 1}"
    TerraformWorkspace = var.TFC_WORKSPACE_SLUG
  }
}

resource "aws_route_table" "public" {
  count  = var.subnet_count
  vpc_id = var.vpc_id

  tags = {
    Name               = "${var.name}-public-${count.index + 1}-${random_shuffle.azs.result[count.index]}"
    TerraformWorkspace = var.TFC_WORKSPACE_SLUG
    Type               = "public"
  }
}

resource "aws_route" "public_internet_gateway" {
  count                  = var.subnet_count
  route_table_id         = aws_route_table.public[count.index].id
  gateway_id             = var.igw_id
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.public]
}

resource "aws_route_table_association" "public" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id

  depends_on = [
    aws_subnet.public,
    aws_route_table.public,
  ]
}

resource "aws_network_acl" "public" {
  count      = var.subnet_count > 0 ? 1 : 0
  vpc_id     = var.vpc_id
  subnet_ids = aws_subnet.public.*.id

  dynamic "egress" {
    for_each = var.subnet_network_acl_egress
    content {
      action          = lookup(egress.value, "action", null)
      cidr_block      = lookup(egress.value, "cidr_block", null)
      from_port       = lookup(egress.value, "from_port", null)
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
      protocol        = lookup(egress.value, "protocol", null)
      rule_no         = lookup(egress.value, "rule_no", null)
      to_port         = lookup(egress.value, "to_port", null)
    }
  }
  dynamic "ingress" {
    for_each = var.subnet_network_acl_ingress
    content {
      action          = lookup(ingress.value, "action", null)
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      from_port       = lookup(ingress.value, "from_port", null)
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
      protocol        = lookup(ingress.value, "protocol", null)
      rule_no         = lookup(ingress.value, "rule_no", null)
      to_port         = lookup(ingress.value, "to_port", null)
    }
  }

  depends_on = [aws_subnet.public]

  tags = {
    Name               = "${var.name}-${count.index + 1}"
    TerraformWorkspace = var.TFC_WORKSPACE_SLUG
    Type               = "public"
  }
}

resource "aws_eip" "nat" {
  count = var.subnet_count > 0 && var.enable_nat_gateway ? var.subnet_count : 0
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name               = "${var.name}-nat-${count.index + 1}-${random_shuffle.azs.result[count.index]}"
    TerraformWorkspace = var.TFC_WORKSPACE_SLUG
  }
}

resource "aws_nat_gateway" "public" {
  count         = var.use_single_nat_gateway && var.subnet_count > 0 && var.enable_nat_gateway ? 1 : var.enable_nat_gateway ? var.subnet_count : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_subnet.public]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name               = "${var.name}-${count.index + 1}-${random_shuffle.azs.result[count.index]}"
    TerraformWorkspace = var.TFC_WORKSPACE_SLUG
  }
}