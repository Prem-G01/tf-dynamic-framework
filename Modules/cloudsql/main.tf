resource "google_sql_database_instance" "instance" {
  name             = var.instance_name
  region           = var.region
  database_version = var.db_version

  deletion_protection = false

  settings {
    tier      = var.tier
    disk_size = var.disk_size

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network
    }

    backup_configuration {
      enabled = true
    }
  }
}