output "subnet_ids" {
  value       = aws_subnet.public.*.id
  description = "The Identifier of the public subnet(s)."
}

output "subnet_cidrs" {
  value       = aws_subnet.public.*.cidr_block
  description = "CIDR blocks of the created public subnet(s)."
}

output "route_tables_ids" {
  value       = aws_route_table.public.*.id
  description = "The Identifiers of the public routing table(s)."
}

output "nat_gateway_ids" {
  value       = aws_nat_gateway.public.*.id
  description = "The Identifiers of the nat gateway(s)."
}

output "availability_zones" {
  value = aws_subnet.public.*.availability_zone
}