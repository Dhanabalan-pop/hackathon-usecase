# backend-setup.tf

resource "google_project_service_identity" "gcs_service_account" {
  provider = google-beta # Required for some IAM roles
  project  = var.project_id
  service  = "storage.googleapis.com"
}

resource "google_storage_bucket" "terraform_state_bucket" {
  name          = "terraform-gke-state-bucket-4890123" # ⬅️ CHANGE TO A GLOBALLY UNIQUE NAME
  location      = "US-CENTRAL1"
  force_destroy = false
  
  # Highly recommended for security and integrity
  uniform_bucket_level_access = true 

  # State Locking/Consistency: GCS provides strong read-after-write 
  # consistency and conditional update primitives, which Terraform utilizes
  # for effective state locking.

  versioning {
    enabled = true # Crucial for state rollback
  }
}