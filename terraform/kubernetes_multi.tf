locals {
  folder_id   = "b1gehbt0k7uoou9p1vt9"
}

resource "yandex_kubernetes_cluster" "k8s-regional" {
  name = "k8s-regional"
  network_id = yandex_vpc_network.my-regional-net.id
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
  }
  service_account_id      = yandex_iam_service_account.my-regional-account.id
  node_service_account_id = yandex_iam_service_account.my-regional-account.id
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_resourcemanager_folder_iam_member.encrypterDecrypter
  ]
  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
}

resource "yandex_vpc_network" "my-regional-net" {
  name = "my-regional-net"
}

resource "yandex_vpc_subnet" "mysubnet-a" {
  name = "mysubnet-a"
  v4_cidr_blocks = ["10.5.0.0/16"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my-regional-net.id
}

resource "yandex_vpc_subnet" "mysubnet-b" {
  name = "mysubnet-b"
  v4_cidr_blocks = ["10.6.0.0/16"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.my-regional-net.id
}

resource "yandex_vpc_subnet" "mysubnet-d" {
  name = "mysubnet-d"
  v4_cidr_blocks = ["10.7.0.0/16"]
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.my-regional-net.id
}

resource "yandex_iam_service_account" "my-regional-account" {
  name        = "regional-k8s-account"
  description = "K8S regional service account"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
  folder_id = local.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  # Сервисному аккаунту назначается роль "vpc.publicAdmin".
  folder_id = local.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = local.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  # Сервисному аккаунту назначается роль "editor".
  folder_id = local.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "logging-writer" {
  # Сервисному аккаунту назначается роль "logging.writer".
  folder_id = local.folder_id
  role      = "logging.writer"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "load-balancer" {
  # Сервисному аккаунту назначается роль "load-balancer.admin".
  folder_id = local.folder_id
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "encrypterDecrypter" {
  # Сервисному аккаунту назначается роль "kms.keys.encrypterDecrypter".
  folder_id = local.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_kms_symmetric_key" "kms-key" {
  # Ключ Yandex Key Management Service для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи.
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
}
