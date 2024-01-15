terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}




provider "yandex" {
  service_account_key_file = "/Users/artem/key.json"
  zone = "ru-central1-a"
  cloud_id = "cloud-temalol13"
  folder_id = "b1gehbt0k7uoou9p1vt9"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "yc-k8s-regional"
}