data "vsphere_datacenter" "dc" {
  name = "Winghaven Cyber Range"
}

data "vsphere_datastore" "datastore" {
  name          = local.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = local.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = local.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = local.template_path
  datacenter_id = data.vsphere_datacenter.dc.id
}

