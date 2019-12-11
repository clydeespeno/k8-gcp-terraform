variable "controller_count" {
  type = number
  description = "number of controller instances"
  default = 3
}

variable "worker_count" {
  type = number
  description = "number of worker instances"
  default = 3
}

variable "kube_cluster" {
  type = string
  description = "the cluster name"
  default = "kubernetes"
}