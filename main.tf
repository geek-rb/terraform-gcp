terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.5.0"
    }
  }
}

provider "google" {

  project = "exadel2021-fin"
  region  = "us-central1"
  zone    = "us-central1-a"
}

provider "google-beta" {
  project = "exadel2021-fin"
  region  = "us-central1"
  zone    = "us-central1-a"
}
