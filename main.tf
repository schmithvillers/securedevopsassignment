terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  credentials = file("nice-tiger-452122-s2.json")
  project = var.project_id
  region = var.region
  zone = var.zone
}

resource "google_compute_instance" "vm_instance" {
  name = "lms-instance"
  machine_type = "e2-medium"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size = 20
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  tags = ["http-server", "https-server"]
  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    EOF
}

resource "google_compute_firewall" "allow_http" {
  name = "allow-http"
  network = "default"
  allow {
    protocol = "tcp"
    ports = ["80", "443", "4000"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["http-server"]
}