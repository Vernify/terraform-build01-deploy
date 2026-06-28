output "docker01_vm_id" {
  description = "Proxmox VM ID for docker01."
  value       = module.docker01.vm_id
}

output "docker01_ipv4_address" {
  description = "IPv4 address assigned to docker01."
  value       = module.docker01.ipv4_address
}
