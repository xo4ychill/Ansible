# 📦 Terraform Infrastructure

---

## 📚 Автоматически сгенерированная документация

---

## 🌳 Структура проекта

```
src
├── cloud-init-clickhouse.tpl
├── main.tf
├── modules
│   ├── security
│   │   ├── main.tf
│   │   ├── output.tf
│   │   ├── providers.tf
│   │   └── variables.tf
│   ├── vm
│   │   ├── cloud-init.tpl
│   │   ├── main.tf
│   │   ├── output.tf
│   │   ├── providers.tf
│   │   └── variables.tf
│   └── vpc
│       ├── main.tf
│       ├── output.tf
│       ├── providers.tf
│       └── variables.tf
├── output.tf
├── providers.tf
├── .terraform.lock.hcl
├── terraform.tfvars
└── variables.tf
```

---

## 📘 Пояснения к структуре

| Путь | Описание |
|------|----------|
| [src/main.tf](../src/main.tf) | Точка входа: объединяет все модули |
| [src/providers.tf](../src/providers.tf) | Настройка провайдеров и backend |
| [src/variables.tf](../src/variables.tf) | Входные переменные |
| [src/terraform.tfvars.example](../src/terraform.tfvars.example) | Значения переменных |
| [src/output.tf](../src/output.tf) | Выходные значения |
| [src/modules/](../src/modules) | Каталог всех Terraform модулей |



---

## 📖 Документация Terraform

<!-- BEGIN_TF_DOCS -->
## Требования

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | >= 0.120.0 |


## Модули

| Name | Source | Version |
|------|--------|---------|
| <a name="module_clickhouse"></a> [clickhouse](#module\_clickhouse) | ./modules/vm | n/a |
| <a name="module_lighthouse"></a> [lighthouse](#module\_lighthouse) | ./modules/vm | n/a |
| <a name="module_vector"></a> [vector](#module\_vector) | ./modules/vm | n/a |
| <a name="module_security"></a> [security](#module\_security) | ./modules/security | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |

## Описание модулей

- [security](../src/modules/security/README.md)
- [vm](../src/modules/vm/README.md)
- [vpc](../src/modules/vpc/README.md)

## Вводные данные

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_id"></a> [cloud\_id](#input\_cloud\_id) | Идентификатор облака Yandex Cloud | `string` | n/a | yes |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | Идентификатор каталога для развёртывания | `string` | n/a | yes |
| <a name="input_service_account_key_file"></a> [service\_account\_key\_file](#input\_service\_account\_key\_file) | Путь к файлу ключа сервисного аккаунта (JSON) для Terraform | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Публичный SSH-ключ | `string` | n/a | yes |
| <a name="input_allowed_ssh_cidr"></a> [allowed\_ssh\_cidr](#input\_allowed\_ssh\_cidr) | CIDR для SSH (null — запретить) | `string` | `null` | no |
| <a name="input_default_zone"></a> [default\_zone](#input\_default\_zone) | Зона доступности по умолчанию | `string` | `"ru-central1-a"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Окружение (prod/staging/dev) | `string` | `"dev"` | no |
| <a name="input_image_family_debian"></a> [image\_family\_debian](#input\_image\_family\_debian) | Семейство образа Debian | `string` | `"debian-12"` | no |
| <a name="input_image_family_rhel"></a> [image\_family\_rhel](#input\_image\_family\_rhel) | Семейство образа RHEL | `string` | `"almalinux-9"` | no |
| <a name="input_image_family_ubuntu"></a> [image\_family\_ubuntu](#input\_image\_family\_ubuntu) | Семейство образа Ubuntu | `string` | `"ubuntu-2204-lts"` | no |
| <a name="input_preemptible"></a> [preemptible](#input\_preemptible) | Использовать прерываемую ВМ | `bool` | `true` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Имя подсети | `string` | `"subnet"` | no |
| <a name="input_v4_cidr_blocks"></a> [v4\_cidr\_blocks](#input\_v4\_cidr\_blocks) | CIDR-блок подсети | `list(string)` | <pre>[<br/>  "10.10.10.0/24"<br/>]</pre> | no |
| <a name="input_vm_core_fraction"></a> [vm\_core\_fraction](#input\_vm\_core\_fraction) | Гарантированная доля vCPU (5, 20, 50, 100) | `number` | `20` | no |
| <a name="input_vm_cores"></a> [vm\_cores](#input\_vm\_cores) | Количество vCPU | `number` | `2` | no |
| <a name="input_vm_disk_size"></a> [vm\_disk\_size](#input\_vm\_disk\_size) | Размер диска (ГБ) | `number` | `15` | no |
| <a name="input_vm_memory"></a> [vm\_memory](#input\_vm\_memory) | Объём ОЗУ (ГБ) | `number` | `2` | no |
| <a name="input_vm_platform_id"></a> [vm\_platform\_id](#input\_vm\_platform\_id) | Платформа ВМ | `string` | `"standard-v3"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Имя сети VPC | `string` | `"network"` | no |

## Выходные данные

| Name | Description |
|------|-------------|
| <a name="output_all_vms_ips"></a> [all\_vms\_ips](#output\_all\_vms\_ips) | Словарь с IP-адресами всех ВМ |
| <a name="output_clickhouse_external_ip"></a> [clickhouse\_external\_ip](#output\_clickhouse\_external\_ip) | Публичный IP ClickHouse |
| <a name="output_clickhouse_hostname"></a> [clickhouse\_hostname](#output\_clickhouse\_hostname) | Hostname ClickHouse |
| <a name="output_clickhouse_internal_ip"></a> [clickhouse\_internal\_ip](#output\_clickhouse\_internal\_ip) | Внутренний IP ClickHouse |
| <a name="output_lighthouse_external_ip"></a> [lighthouse\_external\_ip](#output\_lighthouse\_external\_ip) | Публичный IP Lighthouse |
| <a name="output_lighthouse_hostname"></a> [lighthouse\_hostname](#output\_lighthouse\_hostname) | Hostname Lighthouse |
| <a name="output_lighthouse_internal_ip"></a> [lighthouse\_internal\_ip](#output\_lighthouse\_internal\_ip) | Внутренний IP Lighthouse |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID группы безопасности |
| <a name="output_vector_external_ip"></a> [vector\_external\_ip](#output\_vector\_external\_ip) | Публичный IP Vector |
| <a name="output_vector_hostname"></a> [vector\_hostname](#output\_vector\_hostname) | Hostname Vector |
| <a name="output_vector_internal_ip"></a> [vector\_internal\_ip](#output\_vector\_internal\_ip) | Внутренний IP Vector |
| <a name="output_vpc_network_id"></a> [vpc\_network\_id](#output\_vpc\_network\_id) | ID сети VPC |
| <a name="output_vpc_subnet_id"></a> [vpc\_subnet\_id](#output\_vpc\_subnet\_id) | ID подсети |
<!-- END_TF_DOCS -->
