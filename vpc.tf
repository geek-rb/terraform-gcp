#########################  VPC  #################################
resource "google_compute_network" "vpc_network" {
  name                    = "vpc1"
  auto_create_subnetworks = "false"
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "subnet_1" {
  name          = "internal"
  description   = "for background services"
  ip_cidr_range = "192.168.20.0/24"
  network       = google_compute_network.vpc_network.name
}

resource "google_compute_address" "static" {
  name = "public-ip-1"
}
#########################  FW   #################################

resource "google_compute_firewall" "vpc1-fw-01" {
  allow {
    protocol = "all"
  }
  direction      = "INGRESS"
  disabled       = "false"
  name           = "vpc1-fw-allow-internal"
  network        = google_compute_network.vpc_network.name
  source_ranges  = ["192.168.20.0/24"]
} 

resource "google_compute_firewall" "vpc1-fw-02" {
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction      = "INGRESS"
  disabled       = "true"
#  enable_logging = "true"
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  name           = "vpc1-fw-allow-ssh"
  network        = google_compute_network.vpc_network.name
  source_ranges  = ["0.0.0.0/0"]
} 

resource "google_compute_firewall" "vpc1-fw-03" {
  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
  direction      = "INGRESS"
  disabled       = "false"
  name           = "vpc1-fw-allow-http"
  network        = google_compute_network.vpc_network.name
  source_ranges  = ["0.0.0.0/0"] #по хорошему - внешний айпи, протестить google_compute_address.static.address
  target_tags    = ["http-server", "backend"]
}

######################### OUTPUT ################################

output "public_ip" {
  value = google_compute_address.static.address
}
