resource "yandex_kubernetes_cluster" "zonal_cluster_resource_name" {
  name        = "k8s-terraform"

  network_id = "enpb191f9a7208esmmk8"

  master {
    version = "1.28"
    zonal {
      zone      = "ru-central1-a"
      subnet_id = "e9bgdts6faavfalg1tk6"
    }

    public_ip = true

    security_group_ids = ["enpbn28j9h6kjk6u2c9r"]

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "15:00"
        duration   = "3h"
      }
    }
    
    master_logging {
      enabled = false
      kube_apiserver_enabled = true
      cluster_autoscaler_enabled = true
      events_enabled = true
      audit_enabled = true
    }
  }

  service_account_id      = "ajenntqg7uev7o0n1cm4"
  node_service_account_id = "ajenntqg7uev7o0n1cm4"

  release_channel = "RAPID"

}
