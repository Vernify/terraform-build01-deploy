output "build01_vm_id" {
  description = "Proxmox VM ID for build01."
  value       = module.build01.vm_id
}

output "build01_ipv4_address" {
  description = "IPv4 address assigned to build01."
  value       = module.build01.ipv4_address
}
