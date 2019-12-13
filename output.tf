output "config" {
  value = data.external.config.result
}

output "runners" {
  value = data.external.generate_init.result
}

output "query" {
  value = {
    workers = var.worker_count
    workerips = join(",", local.worker_ips)
    kubernetes_hostnames = "${google_compute_address.k8_public_ip.address},${local.kubernetes_hostnames}"
  }
}
