resource "yandex_vpc_security_group" "sg" {
  name        = var.name
  description = var.description
  network_id  = var.network_id

  # SSH (только если задан CIDR)
  dynamic "ingress" {
    for_each = var.allowed_ssh_cidr != null ? [1] : []
    content {
      description    = "SSH"
      protocol       = "TCP"
      port           = 22
      v4_cidr_blocks = [var.allowed_ssh_cidr]
    }
  }

  # HTTP (публичный доступ)
  ingress {
    description    = "HTTP"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS (публичный доступ)
  ingress {
    description    = "HTTPS"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # ClickHouse (TCP 9000)
  ingress {
    description    = "ClickHouse"
    protocol       = "TCP"
    port           = 9000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # ClickHouse HTTP (TCP 8123)
  ingress {
    description    = "ClickHouse HTTP"
    protocol       = "TCP"
    port           = 8123
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Vector
  ingress {
    description    = "Vector HTTP"
    protocol       = "TCP"
    port           = 8686
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Исходящий трафик
  egress {
    description    = "Исходящий трафик разрешен весь"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  
}