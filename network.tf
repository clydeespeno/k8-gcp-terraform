resource "google_compute_network" "vpc" {
  name = "k8-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "k8-subnet"
  ip_cidr_range = "10.240.0.0/24"
  network       = google_compute_network.vpc.self_link
}

resource "google_compute_firewall" "allow_internal" {
  name = "k8-allow-internal"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.240.0.0/24", "10.200.0.0/16"]
}

resource "google_compute_firewall" "allow_external" {
  name = "k8-allow-external"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
    ports = [22, 80, 443, 6443]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "internet" {
  name = "k8-internet-access"
  network = google_compute_network.vpc.self_link

  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports = [80, 443]
  }

  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_health_check" {
  name = "allow-health-check"
  network = google_compute_network.vpc.self_link
  source_ranges = ["209.85.152.0/22", "209.85.204.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
}

resource "google_compute_address" "k8_public_ip" {
  name = "k8-public-ip"
  description = "Kubernetes public IP"
  network_tier = "STANDARD"
}

resource "google_compute_http_health_check" "kubernetes" {
  name = "kubernetes"
  description = "Kubernetes health check"
  host = "kubernetes.default.svc.cluster.local"
  request_path = "/healthz"
}

resource "google_compute_target_pool" "kubernetes" {
  name = "kubernetes-target-pool"
  health_checks = [google_compute_http_health_check.kubernetes.self_link]
  instances = [for i in google_compute_instance.controller : i.self_link]
}

resource "google_compute_forwarding_rule" "kubernetes" {
  name = "kubernetes-forwarding-rule"
  ip_address = google_compute_address.k8_public_ip.address
  target = google_compute_target_pool.kubernetes.self_link
  network_tier = "STANDARD"
}
