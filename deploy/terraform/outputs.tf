output "service_url" {
  description = "Public URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.portfolio.uri
}

output "image_repository" {
  description = "Artifact Registry path to push images to"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.portfolio.repository_id}/portfolio"
}
