terraform {
  required_version = "~> 1.7"
  backend "gcs" {
    bucket = "platform-infra-tfstate-prod"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "vpc" {
  source       = "../../modules/vpc-network"
  network_name = "prod-vpc"
  region       = var.region
  subnet_name  = "prod-gke-subnet"
  subnet_cidr  = "10.1.0.0/20"
  pods_cidr    = "10.128.0.0/14"
  services_cidr = "10.1.32.0/20"
  pods_range_name = "pods-range"
  services_range_name = "services-range"
}

module "gke_cluster" {
  source               = "../../modules/gke-autopilot"
  project_id           = var.project_id
  cluster_name         = "prod-autopilot-cluster"
  region               = var.region
  vpc_id               = module.vpc.network_id
  subnet_id            = module.vpc.subnet_id
  pods_range_name      = "pods-range"
  services_range_name  = "services-range"
  master_ipv4_cidr_block = "172.16.0.0/28"
  environment          = "production"
}
