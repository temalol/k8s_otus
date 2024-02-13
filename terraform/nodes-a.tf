resource "yandex_kubernetes_node_group" "group-a" {
  cluster_id  = "${yandex_kubernetes_cluster.k8s-regional.id}"
  name        = "wokernodes-a"
  description = "description"
  version     = "1.28"


  instance_template {
    platform_id = "standard-v2"
    container_runtime {
      type = "containerd"
    }

    network_interface {
      nat                = true
      subnet_ids         = ["${yandex_vpc_subnet.mysubnet-a.id}"]
    }

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 96
    }

    scheduling_policy {
      preemptible = false
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }

  maintenance_policy {
    auto_upgrade = false
    auto_repair  = false
  }
}