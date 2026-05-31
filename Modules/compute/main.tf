
resource "google_compute_instance" "vm" {

  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  labels = var.labels

  tags = var.tags

  deletion_protection = false

  boot_disk {

    initialize_params {

      image = var.os_image

      size = var.disk_size
    }
  }

  network_interface {

    subnetwork = var.subnet
  }
}
