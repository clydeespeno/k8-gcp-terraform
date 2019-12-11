data "external" "config" {
  program = ["bash", "${path.root}/config/generate.sh"]
  query = {
    workers = var.worker_count
    workerips = join(",", local.worker_ips)
    kubernetes_hostnames = "${google_compute_address.k8_public_ip.address},${local.kubernetes_hostnames}"
    kubernetes_public_address = google_compute_address.k8_public_ip.address
    cluster = var.kube_cluster
  }
}
