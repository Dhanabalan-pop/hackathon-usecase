# terraform/backend.tf

terraform {
  backend "gcs" {
    # 1. Bucket Name (Static)
    # This MUST match the name of the bucket you created in backend-setup.tf
    bucket = "terraform-gke-state-bucket-4890123" 
    
    # 2. Prefix/Key (Dynamic)
    # We DO NOT set the prefix here. It will be provided dynamically 
    # during 'terraform init' in GitHub Actions using -backend-config.
  }
}