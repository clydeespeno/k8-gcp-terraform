data "external" "config" {
  program = ["bash", "${path.root}/config/generate.sh"]
  query = {
    workers = var.worker_count
    workerips = join(",", local.worker_ips)
    controllers = var.controller_count
    controllerips = join(",", local.controller_ips)
    kubernetes_hostnames = "${google_compute_address.k8_public_ip.address},${local.kubernetes_hostnames},${join(",", local.controller_ips)}"
    kubernetes_public_address = google_compute_address.k8_public_ip.address
    cluster = var.kube_cluster
  }
}

data "external" "generate_init" {
  program = ["bash", "${path.root}/runners/generate_init.sh"]
  query = {
    controller_count = var.controller_count
    project = local.google_provider.project
    zone = local.google_provider.zone
    gcloud_account = var.gcloud_account
    ssh_user = var.ssh_user
    ssh_key_file = var.ssh_key_file
  }
}
