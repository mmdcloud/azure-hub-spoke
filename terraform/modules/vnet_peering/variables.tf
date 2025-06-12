variable "connections" {
  type = list(object({
    name                = string
    virtual_network_name = string
    remote_virtual_network_id = string
    allow_virtual_network_access = bool
    allow_forwarded_traffic = bool
  }))
}
variable "resource_group_name" {
  type = string  
}