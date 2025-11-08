variable "rg_name" {}
variable "location" { default = "centralus" }
variable "subnet_id" {
  description = "ID of the subnet where the VM NIC will be created"
  type        = string
}

