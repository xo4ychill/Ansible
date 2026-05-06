# ======================================================================
# outputs.tf — Выходные данные всего проекта (три ВМ)
# ======================================================================

# -------------------- VPC и сеть --------------------
output "vpc_network_id" {
  description = "ID сети VPC"
  value       = module.vpc.network_id
}

output "vpc_subnet_id" {
  description = "ID подсети"
  value       = module.vpc.subnet_id
}

# -------------------- Группа безопасности --------------------
output "security_group_id" {
  description = "ID группы безопасности"
  value       = module.security.security_group_id
}

# -------------------- ClickHouse VM --------------------
output "clickhouse_external_ip" {
  description = "Публичный IP ClickHouse"
  value       = module.clickhouse.external_ip
}

output "clickhouse_internal_ip" {
  description = "Внутренний IP ClickHouse"
  value       = module.clickhouse.internal_ip
}

output "clickhouse_hostname" {
  description = "Hostname ClickHouse"
  value       = module.clickhouse.vm_hostname
}

# -------------------- Vector VM --------------------
output "vector_external_ip" {
  description = "Публичный IP Vector"
  value       = module.vector.external_ip
}

output "vector_internal_ip" {
  description = "Внутренний IP Vector"
  value       = module.vector.internal_ip
}

output "vector_hostname" {
  description = "Hostname Vector"
  value       = module.vector.vm_hostname
}

# -------------------- Lighthouse VM --------------------
output "lighthouse_external_ip" {
  description = "Публичный IP Lighthouse"
  value       = module.lighthouse.external_ip
}

output "lighthouse_internal_ip" {
  description = "Внутренний IP Lighthouse"
  value       = module.lighthouse.internal_ip
}

output "lighthouse_hostname" {
  description = "Hostname Lighthouse"
  value       = module.lighthouse.vm_hostname
}

# -------------------- Сводная информация --------------------
output "all_vms_ips" {
  description = "Словарь с IP-адресами всех ВМ"
  value = {
    clickhouse = {
      external = module.clickhouse.external_ip
      internal = module.clickhouse.internal_ip
    }
    vector = {
      external = module.vector.external_ip
      internal = module.vector.internal_ip
    }
    lighthouse = {
      external = module.lighthouse.external_ip
      internal = module.lighthouse.internal_ip
    }
  }
}