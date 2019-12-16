resource "google_compute_instance" "controller" {
  can_ip_forward = true
  count = var.controller_count
  machine_type = "n1-standard-1"
  name = "k8-controller-${count.index}"
  tags = [
    "controller"
  ]
  boot_disk {
    initialize_params {
      image = local.boot_image
      size = 200
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link
    network_ip = local.controller_ips[count.index]
    access_config {
      network_tier = "STANDARD"
    }
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
    source = "${path.root}/config/gen/k8-controller-${count.index}"
    destination = "./config"
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.ssh_key_file)
      host = self.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "file" {
    source = "${path.root}/scripts/controller/bootstrap"
    destination = "./bootstrap"
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.ssh_key_file)
      host = self.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "remote-exec" {
    script = "${path.root}/scripts/init.sh"
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.ssh_key_file)
      host = self.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "remote-exec" {
    script = "${path.root}/scripts/run.sh"
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.ssh_key_file)
      host = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

resource "google_compute_instance" "worker" {
  can_ip_forward = true
  count = var.controller_count
  machine_type = "n1-standard-1"
  name = "k8-worker-${count.index}"
  tags = [
    "worker"
  ]

  depends_on = [google_compute_instance.controller]

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
    access_config {
      network_tier = "STANDARD"
    }
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
    source = "${path.root}/config/gen/k8-worker-${count.index}"
    destination = "./config"
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.ssh_key_file)
      host = self.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "file" {
    source = "${path.root}/scripts/worker/bootstrap"
    destination = "./bootstrap"
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.ssh_key_file)
      host = self.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "remote-exec" {
    script = "${path.root}/scripts/init.sh"
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.ssh_key_file)
      host = self.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "remote-exec" {
    script = "${path.root}/scripts/run.sh"
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.ssh_key_file)
      host = self.network_interface[0].access_config[0].nat_ip
    }
  }
}
