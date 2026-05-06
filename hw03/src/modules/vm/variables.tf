variable "vm_name" {
  description = "Имя виртуальной машины"
  type        = string
}

variable "vm_hostname" {
  description = "Hostname внутри ВМ"
  type        = string
}

variable "project_label" {
  description = "Метка проекта"
  type        = string
}

variable "environment_label" {
  description = "Метка окружения"
  type        = string
}

variable "subnet_id" {
  description = "ID подсети для подключения ВМ"
  type        = string
}

variable "security_group_ids" {
  description = "Список ID групп безопасности"
  type        = list(string)
}

variable "zone" {
  description = "Зона доступности"
  type        = string
}

variable "image_family" {
  description = "Семейство образа ОС"
  type        = string
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ"
  type        = string
}

variable "vm_cores" {
  description = "Количество vCPU"
  type        = number
}

variable "vm_core_fraction" {
  description = "Гарантированная доля vCPU"
  type        = number
  default     = 20
}

variable "vm_memory" {
  description = "Объём оперативной памяти (ГБ)"
  type        = number
}

variable "vm_disk_size" {
  description = "Размер загрузочного диска (ГБ)"
  type        = number
}

variable "preemptible" {
  description = "Использовать прерываемую ВМ"
  type        = bool
}

variable "vm_platform_id" {
  description = "Платформа ВМ"
  type        = string
  default     = "standard-v3"
}

variable "cloud_init_custom" {
  description = "Путь к кастомному шаблону cloud‑init"
  type        = string
  default     = null
}

variable "timezone" {
  description = "Часовой пояс"
  type        = string
  default     = "Europe/Moscow"
}

variable "user_name" {
  description = "Имя пользователя по умолчанию"
  type        = string
  default     = "yc-user"
}

variable "user_sudo" {
  description = "Права sudo для пользователя"
  type        = string
  default     = "ALL=(ALL) NOPASSWD:ALL"
}

variable "user_shell" {
  description = "Оболочка пользователя"
  type        = string
  default     = "/bin/bash"
}

variable "packages" {
  description = "Список пакетов для установки"
  type        = list(string)
  default     = ["python3", "curl", "wget", "tar", "gzip", "git", "ca-certificates", "gnupg"]
}

variable "package_update" {
  description = "Обновлять ли список пакетов перед установкой"
  type        = bool
  default     = true
}

variable "package_upgrade" {
  description = "Выполнять ли полное обновление системы"
  type        = bool
  default     = false
}
