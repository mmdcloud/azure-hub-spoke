# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "vnet-peering-vms-example-rg"
  location = "East US"

}

module "vnet1" {
  source              = "./modules/vnet"
  vnet_name           = "vnet1"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnets = [
    {
      name             = "default"
      address_prefixes = ["10.1.1.0/24"]
    }
  ]
}

module "vnet2" {
  source              = "./modules/vnet"
  vnet_name           = "vnet2"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnets = [
    {
      name             = "default"
      address_prefixes = ["10.2.1.0/24"]
    }
  ]
}

module "vnet3" {
  source              = "./modules/vnet"
  vnet_name           = "vnet3"
  address_space       = ["10.3.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnets = [
    {
      name             = "default"
      address_prefixes = ["10.3.1.0/24"]
    }
  ]
}

module "nsg" {
  source              = "./modules/nsg"
  name                = "allow-rdp-ssh-icmp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rules = [
    {
      name                       = "allow-rdp"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow-ssh"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow-icmp"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Icmp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
  network_interface_ids = [
    azurerm_network_interface.vm1_nic.id,
    azurerm_network_interface.vm2_nic.id,
    azurerm_network_interface.vm3_nic.id
  ]
}

# Create public IPs for VMs
resource "azurerm_public_ip" "vm1_pip" {
  name                = "vm1-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "vm2_pip" {
  name                = "vm2-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "vm3_pip" {
  name                = "vm3-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create network interfaces for VMs
resource "azurerm_network_interface" "vm1_nic" {
  name                = "vm1-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet1.subnets[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1_pip.id
  }
}

resource "azurerm_network_interface" "vm2_nic" {
  name                = "vm2-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet2.subnets[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm2_pip.id
  }
}

resource "azurerm_network_interface" "vm3_nic" {
  name                = "vm3-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet3.subnets[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm3_pip.id
  }
}

# Create VMs
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.vm1_nic.id,
  ]

  admin_password = "Demo12345!"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "vm2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.vm2_nic.id,
  ]
  admin_password = "Demo12345!"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "vm3" {
  name                = "vm3"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.vm3_nic.id,
  ]

  admin_password = "Demo12345!"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# VNet Peering Connections (full mesh)
module "peering_connections" {
  source              = "./modules/vnet_peering"
  resource_group_name = azurerm_resource_group.rg.name
  connections = [
    {
      name                         = "vnet1-to-vnet2"
      virtual_network_name         = module.vnet1.name
      remote_virtual_network_id    = module.vnet2.id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
    },
    {
      name                         = "vnet2-to-vnet1"
      virtual_network_name         = module.vnet2.name
      remote_virtual_network_id    = module.vnet1.id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
    },
    {
      name                         = "vnet1-to-vnet3"
      virtual_network_name         = module.vnet1.name
      remote_virtual_network_id    = module.vnet3.id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
    },
    {
      name                         = "vnet3-to-vnet1"
      virtual_network_name         = module.vnet3.name
      remote_virtual_network_id    = module.vnet1.id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
    },
    {
      name                         = "vnet2-to-vnet3"
      virtual_network_name         = module.vnet2.name
      remote_virtual_network_id    = module.vnet3.id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
    },
    {
      name                         = "vnet3-to-vnet2"
      virtual_network_name         = module.vnet3.name
      remote_virtual_network_id    = module.vnet2.id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
    }
  ]
}
