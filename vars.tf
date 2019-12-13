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

variable "ssh_user" {
  type = string
  description = "ssh user to upload scripts"
}

variable "ssh_key_file" {
  type = string
  description = "ssh user's key file"
}

variable "gcloud_account" {
  type = string
  description = "user account for gcloud"
}
