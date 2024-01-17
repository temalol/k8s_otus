resource "yandex_container_registry" "bookinfo" {
  name      = "bookinfo"
  folder_id = "b1gehbt0k7uoou9p1vt9"
}

resource "yandex_iam_service_account" "docker-account" {
  name        = "docker-account"
  description = "docker service account"
}

resource "yandex_resourcemanager_folder_iam_member" "docker-images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = local.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.docker-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "docker-images-pusher" {
  # Сервисному аккаунту назначается роль "container-registry.images.pusher".
  folder_id = local.folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.docker-account.id}"
}