locals {
  boot_image = "ubuntu-os-cloud/ubuntu-1804-lts"
}

locals {
  kubernetes_hostnames = "10.32.0.1,127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local"
  controller_ips = [for i in range(var.controller_count) : "10.240.0.1${i}"]
  worker_ips = [for i in range(var.worker_count) : "10.240.0.2${i}"]
  pod_cidrs = [for i in range(var.worker_count) : "10.200.${i}.0/24"]
}
