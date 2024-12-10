output "master_ip_address" {
  value = one(yandex_compute_instance.master[*].network_interface.0.nat_ip_address)
}

output "worker_ip_address" {
  value = yandex_compute_instance.worker[*].network_interface.0.nat_ip_address
}