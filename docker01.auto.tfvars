# Vernify docker01 configuration (CI infrastructure: Docker host for build workloads)

vm_name          = "docker01"
proxmox_node     = "pve08"
vm_cores         = 4
vm_memory        = 8192
disk_size        = 40
proxmox_datastore = "pve-08-zfs"
network_bridge   = "vmbr0"
template_name    = "ubuntu-24.04-template"
ci_user          = "ubuntu"

# SSH access
ssh_public_keys = [
  "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHBONYUsAucJJGHF+ZCX/ikkvdxdm6beeqKGK/ctw1+1JqApjaAcYspGWehW7vmqkyeM+GuUm5qgi7+hHqDKAjE= wernervandermerwe@Werners-Laptop.local"
]

# Static IP for docker01
ipv4_address  = "192.168.22.52/24"
ipv4_gateway  = "192.168.22.1"
search_domain = "vernify.com"

# VM tags for Proxmox organization
tags = ["vernify", "ci", "docker"]
