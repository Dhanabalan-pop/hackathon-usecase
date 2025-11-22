terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Configure the Google Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

## 1. VPC Network and Subnet with Secondary Ranges

resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false # Critical for custom IP management
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "${var.network_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id

  # GKE Secondary Range for Pods (10.4.0.0/24)
  secondary_ip_range {
    range_name    = "gke-pods-range"
    ip_cidr_range = var.pod_cidr
  }

  # GKE Secondary Range for Services (10.8.0.0/27)
  secondary_ip_range {
    range_name    = "gke-services-range"
    ip_cidr_range = var.service_cidr
  }
}

## 2. GKE Cluster Creation

resource "google_container_cluster" "private_gke_cluster" {
  name               = "${var.network_name}-cluster"
  location           = var.region
  project            = var.project_id
  initial_node_count = 1
  deletion_protection  = false

  # Use the custom VPC and Subnet
  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.gke_subnet.name
  
  # Configure IP allocation using the secondary ranges
  ip_allocation_policy {
    cluster_secondary_range_name = google_compute_subnetwork.gke_subnet.secondary_ip_range[0].range_name # gke-pods-range
    services_secondary_range_name = google_compute_subnetwork.gke_subnet.secondary_ip_range[1].range_name # gke-services-range
  }
  master_authorized_networks_config {

  cidr_blocks {
    # If you use a static egress IP (e.g., via a NAT Gateway with a static IP)
    display_name = "CI/CD Egress IP"
    cidr_block   = "106.221.200.129/32" 
  }
}
  # Make the control plane private (optional but recommended for security)
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.0/28" # The master control plane IP range (must be unique)
  }

  # Default Node Pool configuration
  remove_default_node_pool = true
  
  timeouts {
    create = "30m"
    update = "30m"
  }
}

resource "google_container_node_pool" "primary_node_pool" {
  name       = "default-node-pool"
  location   = var.region
  cluster    = google_container_cluster.private_gke_cluster.name
  node_count = 1

  node_config {
    machine_type = "e2-medium" 
    disk_size_gb = 50
    # The Pods running on these nodes will use the cluster IP ranges defined above
  }
}

## 3. Output

output "gke_cluster_name" {
  value = google_container_cluster.private_gke_cluster.name
}

output "gke_endpoint" {
  value = google_container_cluster.private_gke_cluster.endpoint
}