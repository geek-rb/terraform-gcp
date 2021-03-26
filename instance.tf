####### TEMPLATE #######
data "google_compute_image" "app_image" {
  # ubuntu-2010-groovy-v20210323
  family  = "ubuntu-2010"
  project = "ubuntu-os-cloud"
}
variable "app_pub_key" {
  default = "sa: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDpneOnxtOUQayKehKexZAnzONYkndUiOuTQY4Aq53Wg9ZqUogqHru55jjOBMjERHOHAqJOLWllWKDyVItsBws7jWYOXVzj0pLNles/97ldJrxg3mtCpt+xt2SG1uC7EBAQW0QsCaPG/X4LQ/gXYUOsCu4wcfqbqkI7I7+tTYzvauZohNbmerAEzI2B4zZ6JQiO5v+z0zIhBhgtamaDI+cElhWSmvs4GB97VJNq/VaL874gj22EroY/ZUmgSOFulM8V+Re0LqP9NO9UTQl0n5KSZPKiZx92m6d0KA0IAM1WkMXqmse0GG96ZLsMyUz3hqpxV4SPFPKTCkUPdItpUIrF"
}

data "template_file" "nginx_host" {
  template = file("./install_nginx.sh")
}

resource "google_compute_instance_template" "template" {
  provider = google-beta
  name        = "template-app"
  description = "Template with nginx."
  tags = ["backend", "template", "nginx"]

  shielded_instance_config {
    enable_integrity_monitoring = "true"
    enable_secure_boot          = "false"
    enable_vtpm                 = "true"
  }

  labels = {
    environment = "backend"
  }
  machine_type   = "f1-micro"
  can_ip_forward = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = data.google_compute_image.app_image.self_link
    auto_delete  = true
    boot         = true
    disk_size_gb = 10
  }

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet_1.self_link
  }

  metadata = {
    sshKeys = var.app_pub_key
  }
  metadata_startup_script = data.template_file.nginx_host.rendered
  
}

####### INSTANCE GROUPS ######

resource "google_compute_autoscaler" "scalling-1" {
  provider = google-beta
  name   = "my-autoscaler-1"
  target = google_compute_instance_group_manager.igm-1.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 90

    cpu_utilization {
      target = 0.7
    }

    # metric {
    #   name                       = "compute.googleapis.com/instance/network/sent_bytes_count"
    #   filter                     = "resource.type = pubsub_subscription AND resource.label.subscription_id = our-subscription"
    #   utilizationTarget = 100000
    #   utilizationTargetType = "DELTA_PER_SECOND"
    # }
  }
}
