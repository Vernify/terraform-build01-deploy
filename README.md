# terraform-docker01-deploy

Terraform configuration for provisioning the docker01 CI infrastructure host on Proxmox.

## Overview

docker01 is a 4 vCPU / 8 GB RAM Ubuntu 24.04 VM that runs:
- Docker daemon for build workloads
- CI job containers
- Vault AppRole integration

This repository follows the [terraform-proxmox-vm](https://github.com/iac-foundry/terraform-proxmox-vm) module pattern for consistency with sec01 and agent01 deployments.

## Architecture

```
terraform-docker01-deploy/
├── main.tf           # Proxmox provider + terraform-proxmox-vm module invocation
├── variables.tf      # Input variables (Proxmox credentials, VM specs, network settings)
├── outputs.tf        # Outputs (docker01 VM ID, IP address)
├── docker01.auto.tfvars  # Default values (committed; can be overridden)
├── .gitignore        # Exclude *.tfvars (sensitive), .terraform/, etc.
└── README.md         # This file
```

## Prerequisites

1. **Proxmox host reachable** at the URL specified in `proxmox_api_url` (default: `https://pve08.vernify.com:8006/api2/json`)
2. **Proxmox credentials** (username, password) provided via `proxmox_password` variable
3. **Base template exists** in Proxmox (default template name: `ubuntu-24.04-template`, created by packer-template-proxmox)
4. **terraform-proxmox-vm module** cloned locally or referenced from GitHub
5. **SSH public key** for cloud-init user (Ubuntu user) — passed via `ssh_public_keys` variable

## Usage

### Local Testing

```bash
# Initialize Terraform
terraform init

# Plan with local module path (assumes terraform-proxmox-vm cloned to ../../iac-foundry/)
terraform plan \
  -var proxmox_password='<proxmox-password>' \
  -var 'ssh_public_keys=["ssh-rsa AAAA... user@host"]'

# Apply (provision docker01 on Proxmox)
terraform apply \
  -var proxmox_password='<proxmox-password>' \
  -var 'ssh_public_keys=["ssh-rsa AAAA... user@host"]'
```

### Cloud (Terraform Cloud / Enterprise)

1. Uncomment the `cloud` block in `main.tf`
2. Authenticate: `terraform login`
3. Create TFC workspace: `docker01`
4. Set variables in TFC:
   - `proxmox_password` (sensitive)
   - `ssh_public_keys` (list of strings)
   - Other overrides (optional)
5. Run: `terraform apply`

## Variables

### Required
- **proxmox_password** — Proxmox API password (sensitive)
- **ssh_public_keys** — List of SSH public keys for cloud-init user (empty list by default; specify to enable SSH)

### Optional (with defaults)
- **proxmox_api_url** — Proxmox API URL (default: `https://pve08.vernify.com:8006/api2/json`)
- **proxmox_user** — Proxmox user (default: `root@pam`)
- **proxmox_node** — Proxmox node name (default: `pve`)
- **proxmox_datastore** — Datastore ID (default: `Proxmox_LVM`)
- **vm_name** — VM name (default: `build01`, do not change)
- **vm_cores** — CPU cores (default: 4)
- **vm_memory** — Memory in MiB (default: 8192 = 8 GB)
- **disk_size** — Disk size in GiB (default: 40)
- **template_name** — Packer template to clone (default: `ubuntu-24.04-template`)
- **network_bridge** — VM bridge (default: `vmbr0`)
- **ipv4_address** — Static IP CIDR or 'dhcp' (default: `192.168.22.52/24`)
- **ipv4_gateway** — Gateway (default: `192.168.22.1`)
- **search_domain** — DNS search domain (default: `vernify.internal`)
- **ci_user** — cloud-init login user (default: `ubuntu`, do not change)
- **ci_password** — Password for cloud-init user (optional; SSH keys preferred)

## Outputs

- **build01_vm_id** — Proxmox VM ID (integer)
- **build01_ipv4_address** — IP address assigned to build01 (CIDR notation)

## Deployment Flow

This repository is invoked by the Phase 4 orchestration playbook (`bootstrap-container/playbooks/phase-4-orchestrate.yml`):

```yaml
- name: Terraform provision build01
  terraform:
    project_path: "/workspace/terraform-build01-deploy"
    state: present
    variables:
      proxmox_ve_password: "{{ proxmox_token }}"
      ipv4_address: "192.168.22.52/24"
      vm_cores: 4
      vm_memory: 8192
```

After provisioning:
1. Ansible waits for SSH on build01 (port 22)
2. Converges Ansible roles:
   - `blueprints.step_ca.issue_certificate` (TLS cert for Jenkins)
   - `blueprints.jenkins.container_server` (deploy Jenkins container)
   - `blueprints.jenkins_integrations.vault_auth` (wire Vault AppRole)
3. Seeds Job DSL pipelines (Packer, Terraform, Ansible jobs)

## Troubleshooting

### Terraform Plan Fails: "Module version requirement..."
- Ensure terraform-proxmox-vm is cloned to `../../iac-foundry/terraform-proxmox-vm`
- Or update `source` in `main.tf` to point to the correct path/GitHub URL

### Provisioning Timeout: "Waiting for VM to boot..."
- Check Proxmox console for cloud-init errors
- Verify template has cloud-init package installed
- Check network configuration (DHCP or static IP reachable?)

### SSH Access Fails After Provisioning
- Verify SSH public key was passed to Terraform (in `ssh_public_keys`)
- SSH as `ubuntu` user (not `root`): `ssh ubuntu@192.168.22.52`
- Check cloud-init logs on VM: `cloud-init status`

## Related Repositories

- **terraform-sec01-deploy** — Provisions sec01 (security core)
- **terraform-agent01-deploy** — Provisions agent01 (build capacity)
- **terraform-proxmox-vm** — Reusable Proxmox VM module (org-neutral)
- **terraform-workspaces-deploy** — Creates TFC workspaces for each deployment repo
- **bootstrap-container** — Orchestration playbooks (Phase 3, 4, 5)

## References

- [Terraform Proxmox Provider](https://github.com/Telmate/terraform-provider-proxmox)
- [terraform-proxmox-vm Module](https://github.com/iac-foundry/terraform-proxmox-vm)
- Vernify Phase 3-5 Architecture Design: `iac-foundry/docs/design/BLUEPRINTS_PHASE_3_5_ARCHITECTURE.md` (Section 4.2)
