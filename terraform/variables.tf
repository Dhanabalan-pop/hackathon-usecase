variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for the network and cluster"
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "The name for the VPC network"
  type        = string
  default     = "gke-private-network"
}

variable "subnet_cidr" {
  description = "The CIDR range for the primary GKE node subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "pod_cidr" {
  description = "The CIDR range for GKE Pods (secondary range)"
  type        = string
  default     = "10.4.0.0/24"
}

variable "service_cidr" {
  description = "The CIDR range for GKE Services (secondary range)"
  type        = string
  default     = "10.8.0.0/27"
}