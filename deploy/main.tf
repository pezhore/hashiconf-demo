terraform {
  required_version = ">= 0.12"
}

provider "vsphere" {
  # If you have a self-signed cert
  allow_unverified_ssl = true
}

locals {
  name                  = "nginx.cyber.range"
  hostname              = "nginx"
  domain                = "cyber.range"
  nameservers           = ["172.16.0.20", "172.16.0.19"]
  dns_suffix_list       = ["cyber.range"]
  ipaddress             = "172.16.1.45"
  netmask               = 16
  gateway               = "172.16.0.1"
  provisioning_username = "range"
  provisioning_password = "range"
  datastore             = "Range Storage 1"
  cluster               = "Turing"
  network               = "Range Management"
  template_path         = "Templates/ubuntu-server-1804-3-template"
}

resource "vault_pki_secret_backend_cert" "nginx" {
  backend     = "pki_int"
  name        = "cyber-dot-range"
  common_name = local.name
  ttl         = "26280h"

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      curl -k --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{"serial_number": "${self.serial_number}"}' $VAULT_ADDR/v1/${self.backend}/revoke;
      rm cert/nginx-public.crt;
      rm cert/nginx-ca_chain.pem;
      rm cert/nginx-private.key
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
      echo '${self.certificate}' > cert/nginx-public.crt;
      echo '${self.ca_chain}' > cert/nginx-ca_chain.pem;
      echo '${self.private_key}' > cert/nginx-private.key
    EOT
  }
}


resource "vsphere_virtual_machine" "nginx" {
  depends_on       = [vault_pki_secret_backend_cert.nginx]
  name             = local.name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      dns_server_list = local.nameservers
      dns_suffix_list = local.dns_suffix_list
      linux_options {
        host_name = local.hostname
        domain    = local.domain
      }

      network_interface {
        ipv4_address = local.ipaddress
        ipv4_netmask = local.netmask
      }

      ipv4_gateway = local.gateway
    }
  }

  provisioner "file" {
    when        = create
    source      = "cert"
    destination = "/tmp/tf"

    connection {
      type     = "ssh"
      user     = local.provisioning_username
      password = local.provisioning_password
      host     = self.default_ip_address
    }
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOT
      
      ansible-galaxy install -r requirements.yml;
      ansible-playbook -i ${self.default_ip_address}, playbook.yml --extra-vars "ansible_user=${local.provisioning_username} ansible_password=${local.provisioning_password} ansible_sudo_pass=${local.provisioning_password}"
    EOT
  }
}
