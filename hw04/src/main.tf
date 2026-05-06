# ======================================================================
# main.tf — ОСНОВНАЯ КОНФИГУРАЦИЯ ИНФРАСТРУКТУРЫ
# ======================================================================

# ==================== VPC: СЕТЬ И ПОДСЕТЬ ====================
module "vpc" {
  source = "./modules/vpc"

  network_name   = var.vpc_name
  subnet_name    = var.subnet_name
  zone           = var.default_zone
  v4_cidr_blocks = var.v4_cidr_blocks
  environment    = var.environment
}

# ==================== SECURITY GROUP ====================
module "security" {
  source = "./modules/security"

  name             = "${var.vpc_name}-sg"
  description      = "Security group for ClickHouse, Vector, Lighthouse"
  network_id       = module.vpc.network_id
  environment      = var.environment
  allowed_ssh_cidr = var.allowed_ssh_cidr
  app_subnet_cidrs = var.v4_cidr_blocks
}

# ==================== ВИРТУАЛЬНЫЕ МАШИНЫ ====================
module "clickhouse" {
  source = "./modules/vm"

  vm_name            = "clickhouse-vm"
  vm_hostname        = "clickhouse"
  project_label      = "ansible"
  environment_label  = var.environment

  subnet_id          = module.vpc.subnet_id
  security_group_ids = [module.security.security_group_id]
  
  zone               = var.default_zone
  image_family       = var.image_family_rhel
  ssh_public_key     = var.ssh_public_key

  vm_cores           = var.vm_cores
  vm_memory          = var.vm_memory
  vm_disk_size       = var.vm_disk_size
  preemptible        = var.preemptible
  vm_core_fraction   = var.vm_core_fraction

  depends_on         = [module.vpc]

  # Подключаем кастомный cloud-init для CentOS 7
  # cloud_init_custom  = "cloud-init-clickhouse.tpl"
}

module "vector" {
  source = "./modules/vm"

  vm_name            = "vector-vm"
  vm_hostname        = "vector"
  project_label      = "ansible"
  environment_label  = var.environment

  subnet_id          = module.vpc.subnet_id
  security_group_ids = [module.security.security_group_id]
  
  zone               = var.default_zone
  image_family       = var.image_family_ubuntu
  ssh_public_key     = var.ssh_public_key

  vm_cores           = var.vm_cores
  vm_memory          = var.vm_memory
  vm_disk_size       = var.vm_disk_size
  preemptible        = var.preemptible
  vm_core_fraction   = var.vm_core_fraction
  depends_on         = [module.clickhouse]
}

module "lighthouse" {
  source = "./modules/vm"

  vm_name            = "lighthouse-vm"
  vm_hostname        = "lighthouse"
  project_label      = "ansible"
  environment_label  = var.environment

  subnet_id          = module.vpc.subnet_id
  security_group_ids = [module.security.security_group_id]
  
  zone               = var.default_zone
  image_family       = var.image_family_debian
  ssh_public_key     = var.ssh_public_key

  vm_cores           = var.vm_cores
  vm_memory          = var.vm_memory
  vm_disk_size       = var.vm_disk_size
  preemptible        = var.preemptible
  vm_core_fraction   = var.vm_core_fraction
  depends_on         = [module.vector]
}