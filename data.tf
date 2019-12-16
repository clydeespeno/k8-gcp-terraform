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
    pod_cidrs = join(",", local.pod_cidrs)
  }
}

data "external" "generate_init" {
  program = ["bash", "${path.root}/runners/generate_init.sh"]
  query = {
    kubernetes_public_address = google_compute_address.k8_public_ip.address
    cluster = var.kube_cluster
  }
}
