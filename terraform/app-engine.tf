resource "google_app_engine_application" "app_engine" {
  project     = data.google_project.main.project_id
  location_id = "europe-west2"
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "../src"
  output_path = "../build/src.zip"
}

resource "google_storage_bucket" "deployment_config" {
  project        = data.google_project.main.project_id
  name           = "deployment-config-${data.google_project.main.number}"
  location       = "europe-west2"
  requester_pays = false
  storage_class  = "STANDARD"
}

resource "google_storage_bucket_object" "source_zip" {
  source = data.archive_file.source.output_path
  bucket = google_storage_bucket.deployment_config.name
  name   = "terraform-app-engine-example/src.zip"

  depends_on = [data.archive_file.source]
}

resource "google_app_engine_standard_app_version" "application" {
  project    = data.google_project.main.project_id
  version_id = data.archive_file.source.output_md5
  service    = "default"
  runtime    = "python38"

  entrypoint {
    shell = "gunicorn -b :$PORT main:app --log-level=DEBUG"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.deployment_config.name}/${google_storage_bucket_object.source_zip.name}"
    }
  }
}