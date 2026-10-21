terraform {
  required_version = ">= 1.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
  # Uncomment to keep state in GCS
  # backend "gcs" {
  #   bucket = "YOUR_TF_STATE_BUCKET"
  #   prefix = "portfolio"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "apis" {
  for_each           = toset(["run.googleapis.com", "artifactregistry.googleapis.com"])
  service            = each.value
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "portfolio" {
  repository_id = "portfolio"
  location      = var.region
  format        = "DOCKER"
  description   = "Container images for the portfolio site"

  cleanup_policies {
    id     = "keep-last-5"
    action = "KEEP"
    most_recent_versions {
      keep_count = 5
    }
  }

  depends_on = [google_project_service.apis]
}

resource "google_service_account" "run" {
  account_id   = "portfolio-run"
  display_name = "Portfolio Cloud Run runtime"
}

resource "google_cloud_run_v2_service" "portfolio" {
  name     = "portfolio"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.run.email

    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.portfolio.repository_id}/portfolio:${var.image_tag}"

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "128Mi"
        }
        cpu_idle = true
      }

      startup_probe {
        http_get {
          path = "/healthz"
        }
      }

      liveness_probe {
        http_get {
          path = "/healthz"
        }
      }
    }
  }

  depends_on = [google_project_service.apis]
}

# Public website: allow unauthenticated access
resource "google_cloud_run_v2_service_iam_member" "public" {
  name     = google_cloud_run_v2_service.portfolio.name
  location = google_cloud_run_v2_service.portfolio.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
