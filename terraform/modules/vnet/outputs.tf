output "name" {
  value = azurerm_virtual_network.vnet.name  
}

output "id" {
  value = azurerm_virtual_network.vnet.id  
}

output "subnets" {
  value = azurerm_subnet.vnet1_subnet[*]
}