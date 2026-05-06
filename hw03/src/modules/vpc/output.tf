# ======================================================================
# outputs.tf — Выходные данные модуля VPC
# ======================================================================

output "network_id" {
  description = "ID созданной сети VPC"
  value       = yandex_vpc_network.network.id
}

output "network_name" {
  description = "Имя созданной сети VPC"
  value       = yandex_vpc_network.network.name
}

output "subnet_id" {
  description = "ID созданной подсети"
  value       = yandex_vpc_subnet.subnet.id
}

output "subnet_name" {
  description = "Имя созданной подсети"
  value       = yandex_vpc_subnet.subnet.name
}