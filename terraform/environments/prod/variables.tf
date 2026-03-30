variable "project_id" {
  description = "The GCP project ID to deploy resources into"
  type        = string
}

variable "region" {
  description = "The default GCP region for resources"
  type        = string
  default     = "europe-west1"
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "vpc_id" {
  description = "The ID of the VPC network"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "The ID of the subnetwork"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "autopilot-cluster"
}

variable "pods_range_name" {
  description = "The name of the secondary range for pods"
  type        = string
  default     = "pods-range"
}

variable "services_range_name" {
  description = "The name of the secondary range for services"
  type        = string
  default     = "services-range"
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation to use for the GKE master"
  type        = string
  default     = "172.16.0.0/28"
}
