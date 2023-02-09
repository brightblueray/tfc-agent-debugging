terraform {

  cloud {
    organization = "brightblueray"
    workspaces {
      name = "tfc-agent-debugging"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "nginx"
  ports {
    internal = 80
    external = 8000
  }
}

provider "vsphere" {
  # If you use a domain set your login like this "MyDomain\\MyUser"
  user           = "user"
  password       = "password"
  vsphere_server = "192.168.1.8"
  client_debug = true
  # If you have a self-signed cert
  allow_unverified_ssl = true
}

#### RETRIEVE DATA INFORMATION ON VCENTER ####
data "vsphere_datacenter" "dc" {
  name = "test-LAB"
}
data "vsphere_compute_cluster" "cluster" {
    name          = "TerraformPOC"
    datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_resource_pool" "pool" {
  # If you haven't resource pool, put "Resources" after cluster name
  name          = "TerraformPOC/Normal"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_host" "host" {
  name          = "xx.asc.com"
  datacenter_id = data.vsphere_datacenter.dc.id
}
# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  name          = "tfpoc-01"
  datacenter_id = data.vsphere_datacenter.dc.id
}
# Retrieve network information on vsphere. You must have already a template on vmware with network port "VM Network".
data "vsphere_network" "network" {
  name          = "TF-POC-v3073"
  datacenter_id = data.vsphere_datacenter.dc.id
}
# Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  name          = "RHEtestL9TFC"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Set vm parameters
resource "vsphere_virtual_machine" "POC-VM" {
  name             = "POC-VM"
  num_cpus         = 4
  memory           = 12288
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  firmware = data.vsphere_virtual_machine.template.firmware
  # Set network parameters
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  # Use a predefined vmware template has main disk
  disk {
   label = "disk0"
   #size = data.vsphere_virtual_machine.template.disks[0].size
   #thin_provisioned =  data.vsphere_virtual_machine.template.disks[0].thin_provisioned
   #datastore_id = data.vsphere_datastore.datastore.id
   size = "80"
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "pocvm"
        domain    = "pocvm.internal"
      }

      network_interface {}

      ipv4_gateway = ""
    }
  }
}