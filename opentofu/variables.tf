# MAAS provider
variable "maas_api_url" {
  description = "MAAS API URL"
  type        = string
}

variable "maas_api_key" {
  description = "MAAS API key"
  type        = string
  sensitive   = true
}
