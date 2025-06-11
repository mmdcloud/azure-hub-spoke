# Output the public IP addresses for connecting to VMs
output "vm1_public_ip" {
  value = azurerm_public_ip.vm1_pip.ip_address
}

output "vm2_public_ip" {
  value = azurerm_public_ip.vm2_pip.ip_address
}

output "vm3_public_ip" {
  value = azurerm_public_ip.vm3_pip.ip_address
}