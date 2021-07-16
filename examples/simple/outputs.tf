output "subnet_ids" {
  value = module.public-subnet.subnet_ids
}

output "subnet_cidrs" {
  value = module.public-subnet.subnet_cidrs
}

output "route_tables_ids" {
  value = module.public-subnet.route_tables_ids
}

output "nat_gateway_ids" {
  value = module.public-subnet.nat_gateway_ids
}

output "availability_zones" {
  value = module.public-subnet.availability_zones
}