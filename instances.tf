resource "google_compute_instance" "controller" {
  can_ip_forward = true
  count = var.controller_count
  machine_type = "n1-standard-1"
  name = "k8-controller-${count.index}"
  tags = [
    "controller"]
  boot_disk {
    initialize_params {
      image = local.boot_image
      size = 200
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link
    network_ip = local.controller_ips[count.index]
  }

  service_account {
    scopes = [
      "compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write",
      "monitoring"]
  }

  provisioner "file" {
    source = "${path.root}/config/gen/controller"
    destination = "/config"
  }

  provisioner "file" {
    source = "${path.root}/config/scripts/controller/config"
    destination = "/etc/kubernetes/config"
  }

  provisioner "file" {
    source = "${path.root}/config/scripts/controller/bootstrap"
    destination = "/scripts/bootstrap"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod -R +x /scripts/bootstrap",
      "cd /scripts/bootstrap",
      "./run.sh"
    ]
  }
}

resource "google_compute_instance" "worker" {
  can_ip_forward = true
  count = var.controller_count
  machine_type = "n1-standard-1"
  name = "k8-worker-${count.index}"
  tags = [
    "worker"]
  boot_disk {
    initialize_params {
      image = local.boot_image
      size = 200
    }
  }
  metadata = {
    pod-cidr = local.pod_cidrs[count.index]
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link
    network_ip = local.worker_ips[count.index]
  }
  service_account {
    scopes = [
      "compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write",
      "monitoring"]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/etcd /etc/kubernetes/config"
    ]
  }

  provisioner "file" {
    source = "${path.root}/config/gen/k8-worker-${count.index}"
    destination = "/config"
  }
}
