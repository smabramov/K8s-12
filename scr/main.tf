terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "~>1.8.4"
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}
#создаем облачную сеть
resource "yandex_vpc_network" "k8s" {
  name = "k8s"
}

#создаем подсеть
resource "yandex_vpc_subnet" "k8s" {
  name           = "k8s-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.k8s.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

#считываем данные об образе ОС
data "yandex_compute_image" "ubuntu-2004-lts" {
  family = "ubuntu-2204-lts"
}

#создаем 1 master node
resource "yandex_compute_instance" "master" {
  name        = "master-node-${count.index}"
  platform_id = "standard-v1"
  
  count = 1

  resources {
    cores  = 2
    memory = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type = "network-hdd"
      size = 15
    }   
  }

  metadata = {
      user-data          = data.template_file.cloudinit.rendered
      serial-port-enable = 1
  }

  scheduling_policy { preemptible = true }

  network_interface { 
    subnet_id = yandex_vpc_subnet.k8s.id
    nat       = true
    ipv6      = false
  }
  allow_stopping_for_update = true
}

#создаем 4 идентичные worker node
resource "yandex_compute_instance" "worker" {
  name        = "worker-node-${count.index}"
  platform_id = "standard-v1"
  
  count = 4

  resources {
    cores  = 2
    memory = 2
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type = "network-hdd"
      size = 15
    }   
  }

  metadata = {
      user-data          = data.template_file.cloudinit.rendered
      serial-port-enable = 1
  }

  scheduling_policy { preemptible = true }

  network_interface { 
    subnet_id = yandex_vpc_subnet.k8s.id
    nat       = true
    ipv6      = false
  }
  allow_stopping_for_update = true
}

data "template_file" "cloudinit" {
 template = file("./cloud_init.yml")

  vars = {
    ssh_public_key     = var.ssh_public_key
  }
}