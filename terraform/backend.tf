terraform {
  backend "gcs" {
    bucket = "ms-project-state"
    prefix = "terraform-app-engine-example/terraform/state"
  }
}