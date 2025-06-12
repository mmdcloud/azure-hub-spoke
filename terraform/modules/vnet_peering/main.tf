resource "azurerm_virtual_network_peering" "peering" {
  count = length(var.connections) 
  name                         = var.connections[count.index].name 
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.connections[count.index].virtual_network_name
  remote_virtual_network_id    = var.connections[count.index].remote_virtual_network_id
  allow_virtual_network_access = var.connections[count.index].allow_virtual_network_access
  allow_forwarded_traffic      = var.connections[count.index].allow_forwarded_traffic
}