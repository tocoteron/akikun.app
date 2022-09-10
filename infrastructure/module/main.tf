resource "google_app_engine_application" "web_frontend" {
  project     = var.project
  location_id = var.region
}

resource "google_cloud_run_service" "web_backend" {
  name     = "web-backend"
  location = var.region

  template {}
}

data "google_iam_policy" "cloud_run_noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.web_backend.location
  project  = google_cloud_run_service.web_backend.project
  service  = google_cloud_run_service.web_backend.name

  policy_data = data.google_iam_policy.cloud_run_noauth.policy_data
}

resource "google_cloud_run_domain_mapping" "web_backend_domain" {
  location = google_cloud_run_service.web_backend.location
  name     = "api.${var.domain}"

  metadata {
    namespace = var.project
  }

  spec {
    route_name = google_cloud_run_service.web_backend.name
  }
}
