terraform {
  backend "s3" {
    bucket = ""
    key    = ""
    region = "us-east-1"
    endpoint = ""
    skip_credentials_validation = false
    skip_metadata_api_check     = false
  }
  required_providers {
    maas = {
      source = "canonical/maas"
      version = ">= 0.9.0"
    }
  }
}

provider "maas" {
  api_url = var.maas_api_url
  api_key = var.maas_api_key
}

resource "maas_fabric" "lab" {
  name = "lab"
}

resource "maas_vlan" "lab_infra_mgt" {
  fabric =  maas_fabric.lab.id
  vid    = 0
  name   = "untagged"
  dhcp_on = false
  mtu = 1500
}

resource "maas_subnet" "lab_infra_mgt" {
  cidr       = "10.0.22.0/24"
  fabric     = maas_fabric.lab.id
  vlan       = maas_vlan.lab_infra_mgt.vid
  name       = "lab_infra_mgt"
  allow_dns  = false
  rdns_mode  = 0
  gateway_ip = "10.0.22.253"
  dns_servers = [
    "10.0.22.253",
  ]
  # ip_ranges {
  # }
}

resource "maas_dns_domain" "lab" {
  name          = "lab"
  ttl           = 3600
  authoritative = false
  is_default    = true
}

resource "maas_machine" "k8s-m01" {
  hostname      = "k8s-m01"
  architecture  = "amd64/generic"
  domain        = "lab"
  zone          = "default"

  power_type = "webhook"
  power_parameters = jsonencode({
    power_on_uri    = "http://10.0.22.1:5000/nodes/k8s-m01/power-on"
    power_off_uri   = "http://10.0.22.1:5000/nodes/k8s-m01/power-off"
    power_query_uri = "http://10.0.22.1:5000/nodes/k8s-m01/state"
    power_on_regex  = ".*ON.*"
    power_off_regex = ".*OFF.*"
    # power_user (Power user).
    # power_pass (Power password).
    # power_token (Power token, will be used in place of power_user and power_pass).
    # power_verify_ssl (Verify SSL connections with system CA certificates). Choices: 'n' (No), 'y' (Yes) Default: 'n'.
  })
  pxe_mac_address = "6c:4b:90:b8:f2:fe"
}
