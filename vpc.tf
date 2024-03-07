resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
  project = "project-group-hera-3" #variables

}

resource "google_project_service" "container_api" {
  service = "container.googleapis.com"
  project = "project-group-hera-3" #variables
}

resource "google_compute_network" "vpc_network" {
  name                    = "project-vpc"
  project = "project-group-hera-3" #variables
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
  mtu                     = 1460
  delete_default_routes_on_create = false

  depends_on = [
    google_project_service.compute_api,
    google_project_service.container_api
  ]
  }

