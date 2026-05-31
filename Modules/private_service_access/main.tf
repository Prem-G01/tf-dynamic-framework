resource "google_compute_global_address" "private_ip_address" {

  name = "google-managed-services"

  purpose = "VPC_PEERING"

  address_type = "INTERNAL"

  prefix_length = 16

  network = var.network
}

resource "google_service_networking_connection" "private_vpc_connection" {

  network = var.network

  service = "servicenetworking.googleapis.com"

  reserved_peering_ranges = [
    google_compute_global_address.private_ip_address.name
  ]

  deletion_policy = "ABANDON"
}