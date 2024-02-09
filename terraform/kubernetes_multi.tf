resource "yandex_kubernetes_cluster" "k8s-regional" {
  name = "k8s-regional"
  network_id = yandex_vpc_network.my-regional-net.id
  folder_id = var.yc_folder
  master {
    version = "1.28"
    public_ip = true


    maintenance_policy {
      auto_upgrade = false
    }
    
    regional {
      region = "ru-central1"
      location {
        zone      = yandex_vpc_subnet.mysubnet-a.zone
        subnet_id = yandex_vpc_subnet.mysubnet-a.id
      }
      location {
        zone      = yandex_vpc_subnet.mysubnet-b.zone
        subnet_id = yandex_vpc_subnet.mysubnet-b.id
      }
      location {
        zone      = yandex_vpc_subnet.mysubnet-d.zone
        subnet_id = yandex_vpc_subnet.mysubnet-d.id
      }
    }

    master_logging {
      enabled                    = true
      log_group_id               = yandex_logging_group.logging-group.id
      kube_apiserver_enabled     = true
      cluster_autoscaler_enabled = true
      events_enabled             = true
      audit_enabled              = true
    }

  }

 
  service_account_id      = yandex_iam_service_account.my-regional-account.id
  node_service_account_id = yandex_iam_service_account.my-regional-account.id
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_resourcemanager_folder_iam_member.encrypterDecrypter
  ]
}

resource "yandex_vpc_network" "my-regional-net" {
  name = "my-regional-net"
  folder_id = var.yc_folder
}

resource "yandex_vpc_subnet" "mysubnet-a" {
  name = "mysubnet-a"
  folder_id = var.yc_folder
  v4_cidr_blocks = ["10.5.0.0/16"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my-regional-net.id
}

resource "yandex_vpc_subnet" "mysubnet-b" {
  name = "mysubnet-b"
  folder_id = var.yc_folder
  v4_cidr_blocks = ["10.6.0.0/16"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.my-regional-net.id
}

resource "yandex_vpc_subnet" "mysubnet-d" {
  name = "mysubnet-d"
  folder_id = var.yc_folder
  v4_cidr_blocks = ["10.7.0.0/16"]
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.my-regional-net.id
}

resource "yandex_iam_service_account" "my-regional-account" {
  name        = "regional-k8s-account"
  description = "K8S regional service account"
  folder_id = var.yc_folder
}

resource "yandex_iam_service_account" "bucket" {
  name        = "bucket"
  description = "s3 bucket service account"
  folder_id = var.yc_folder
}

resource "yandex_iam_service_account" "fluentbit" {
  name        = "bucket"
  description = "s3 bucket service account"
  folder_id = var.yc_folder
}


resource "yandex_resourcemanager_folder_iam_member" "monitoring-editor" {
  # Сервисному аккаунту назначается роль "monitoring.editor".
  folder_id = var.yc_folder
  role      = "monitoring.editor"
  member    = "serviceAccount:${yandex_iam_service_account.fluentbit.id}"
}


resource "yandex_resourcemanager_folder_iam_member" "logging-writer-fluentbit" {
  # Сервисному аккаунту назначается роль "logging.writer".
  folder_id = var.yc_folder
  role      = "logging.writer"
  member    = "serviceAccount:${yandex_iam_service_account.fluentbit.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "storage-editor" {
  # Сервисному аккаунту назначается роль "storage.editor".
  folder_id = var.yc_folder
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.bucket.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
  folder_id = var.yc_folder
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  # Сервисному аккаунту назначается роль "vpc.publicAdmin".
  folder_id = var.yc_folder
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.yc_folder
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  # Сервисному аккаунту назначается роль "editor".
  folder_id = var.yc_folder
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "logging-writer" {
  # Сервисному аккаунту назначается роль "logging.writer".
  folder_id = var.yc_folder
  role      = "logging.writer"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "load-balancer" {
  # Сервисному аккаунту назначается роль "load-balancer.admin".
  folder_id = var.yc_folder
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "encrypterDecrypter" {
  # Сервисному аккаунту назначается роль "kms.keys.encrypterDecrypter".
  folder_id = var.yc_folder
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_logging_group" "logging-group-k8s" {
  description = "Cloud Logging group k8s"
  name        = "cluster"
  retention_period = "24h"
  folder_id   = var.yc_folder
}

resource "yandex_logging_group" "logging-group-application" {
  description = "Cloud Logging group applicaton"
  name        = "applicaton"
  retention_period = "72h"
  folder_id   = var.yc_folder
}