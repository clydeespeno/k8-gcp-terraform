provider "google" {
  project = local.google_provider.project
  region = local.google_provider.region
  zone = local.google_provider.zone
}
