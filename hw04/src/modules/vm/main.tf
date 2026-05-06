# ======================================================================
# Модуль VM — виртуальная машина с cloud-init
# ======================================================================

data "yandex_compute_image" "os_image" {
  family = var.image_family
}

locals {
  # Параметры для шаблона
  cloud_init_vars = {
    vm_hostname     = var.vm_hostname
    ssh_public_key  = var.ssh_public_key
    timezone       = var.timezone
    user_name      = var.user_name
    user_sudo      = var.user_sudo
    user_shell     = var.user_shell
    packages       = var.packages
    package_update = var.package_update
    package_upgrade = var.package_upgrade
  }

  # Выбор шаблона: кастомный или стандартный
  cloud_init_template = var.cloud_init_custom != null ? var.cloud_init_custom : "${path.module}/cloud-init.tpl"

  # Генерация содержимого cloud-init
  cloud_init_content = templatefile(local.cloud_init_template, local.cloud_init_vars)
}

resource "yandex_compute_instance" "vm" {
  name        = var.vm_name
  hostname    = var.vm_hostname
  platform_id = var.vm_platform_id
  zone        = var.zone

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory
    core_fraction = var.vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.os_image.image_id
      size     = var.vm_disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = var.subnet_id
    nat                = true
    security_group_ids = var.security_group_ids
  }

  metadata = {
    user-data          = local.cloud_init_content
    serial-port-enable = 1
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  labels = {
    project     = var.project_label
    environment = var.environment_label
    managed_by  = "terraform"
  }
}