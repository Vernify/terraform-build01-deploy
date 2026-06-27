# Vernify — build01 CI core host.
#
# Provisions the build01 Ubuntu 24.04 VM for HashiCorp Jenkins CI controller.
# Runs IN the `build01` TFC workspace (created by terraform-workspaces-deploy).
# Consumes the org-neutral terraform-proxmox-vm module; this repo holds only
# Vernify's concrete values.

terraform {
  required_version = ">= 1.15.6"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }

  # Cloud backend commented out for local testing; uncomment when running in TFC.
  # cloud {
  #   organization = "Vernify"
  #   workspaces {
  #     name = "build01"
  #   }
  # }
}

provider "proxmox" {
  # Telmate/proxmox provider — using username/password auth
  pm_api_url      = var.proxmox_api_url
  pm_user         = var.proxmox_user
  pm_password     = var.proxmox_password
  pm_tls_insecure = true
}

module "build01" {
  # Testing: local path (both repos in same workspace).
  # Once validated, commit feat branches and tag v0.1.0 on GitHub, then switch to:
  #   source = "git::https://github.com/iac-foundry/terraform-proxmox-vm.git?ref=v0.1.0"
  source = "../../iac-foundry/terraform-proxmox-vm"

  vm_name         = var.vm_name
  node            = var.proxmox_node
  template_name   = var.template_name
  cores           = var.vm_cores
  memory          = var.vm_memory
  disk_size       = var.disk_size
  datastore_id    = var.proxmox_datastore
  network_bridge  = var.network_bridge
  ci_user         = var.ci_user
  ssh_public_keys = var.ssh_public_keys
  ip_config = {
    ipv4_address = var.ipv4_address
    ipv4_gateway = var.ipv4_gateway
  }
  search_domain = var.search_domain
  tags          = var.tags
  ci_password   = var.ci_password
}
