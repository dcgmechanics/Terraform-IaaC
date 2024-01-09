# --- Provider ---

terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "=0.4.0"
    }
  }
}

provider "azurerm" {
  features {}
}


# --- Resource Group ---

resource "azurerm_resource_group" "resource_group" {
  name     = "azure-rg"
  location = "eastus2" #eg: "uksouth", "eastus2", "westus3"

}

# --- Virtual Network & Subnets ---

resource "azurerm_virtual_network" "custom_vnet" {
  name                = "azure-vnet"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = ["10.10.0.0/20"]
}


resource "azurerm_subnet" "subnet_public_1" {
  name                 = "azure-subnet-public-1"
  resource_group_name  = azurerm_resource_group.resource_group.name
  address_prefixes     = ["10.10.2.0/22"]
  virtual_network_name = azurerm_virtual_network.custom_vnet.name
}

resource "azurerm_subnet" "subnet_public_2" {
  name                 = "azure-subnet-public-2"
  resource_group_name  = azurerm_resource_group.resource_group.name
  address_prefixes     = ["10.10.4.0/22"]
  virtual_network_name = azurerm_virtual_network.custom_vnet.name
}


# --- Network Security Group ---

resource "azurerm_network_security_group" "custom_nsg" {
  name                = "azure-nsg"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_network_security_rule" "rule8080" {
  name                        = "rule-8080"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.custom_nsg.name
}

resource "azurerm_network_security_rule" "ruleSSH" {
  name                        = "rule-22"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "192.168.10.245/32" #Must be Unique or Your IP
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.custom_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg" {
  subnet_id                 = azurerm_subnet.subnet_public_1.id
  network_security_group_id = azurerm_network_security_group.custom_nsg.id
  depends_on = [
    azurerm_network_security_group.custom_nsg
  ]
}



# --- SSH Key ---

resource "azurerm_ssh_public_key" "ssh_key" {
  name                = "azure-sshkey"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  public_key          = file("~/.ssh/id_rsa.pub")
}


# --- Virtual Machine & Others

resource "azurerm_public_ip" "custom_publicip" {
  name                = "azure-public-ip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "nic" {
  name                = "azure-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "azure-ipconfig"
    subnet_id                     = azurerm_subnet.subnet_public_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.custom_publicip.id
  }
}



resource "azurerm_linux_virtual_machine" "custom_vm" {
  name                = "azure-vm"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = azurerm_ssh_public_key.ssh_key.public_key #file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "22_04-lts"
    version   = "latest"
  }
}



# --- Azure MySQL Flexible Server ---

resource "azurerm_mysql_flexible_server" "mysql_server" {
  name                   = "azure-mysql-server22"
  resource_group_name    = azurerm_resource_group.resource_group.name
  location               = azurerm_resource_group.resource_group.location
  administrator_login    = "admin"
  administrator_password = "pass123"
  backup_retention_days  = 7
  # delegated_subnet_id    = azurerm_subnet.example.id
  # private_dns_zone_id    = azurerm_private_dns_zone.example.id
  sku_name = "GP_Standard_D2ds_v4"
  # public_network_access_enabled     = true

  # depends_on = [azurerm_private_dns_zone_virtual_network_link.example]
}



# Resource-2: Azure MySQL Database / Schema


resource "azurerm_mysql_flexible_database" "webappdb" {
  name                = "azure-dbserver"
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name         = azurerm_mysql_flexible_server.mysql_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}



# Resource-3: Azure MySQL Firewall Rule - Allow access from Bastion Host Public IP

resource "azurerm_mysql_flexible_server_firewall_rule" "mysql_fw_rule" {
  name                = "azure-mysql-firewall"
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name         = azurerm_mysql_flexible_server.mysql_server.name
  start_ip_address    = azurerm_linux_virtual_machine.custom_vm.public_ip_address
  end_ip_address      = azurerm_linux_virtual_machine.custom_vm.public_ip_address
}


# --- Blob Storage ---

resource "azurerm_storage_account" "custom_storage_account" {
  name                     = "sudipstorageaccount"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "custom_blob" {
  name                  = "azure-blob"
  storage_account_name  = azurerm_storage_account.custom_storage_account.name
  container_access_type = "private"
}



# --- Azure AKS Cluster---

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "azure-cluster"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  dns_prefix          = "sudipdns"

  default_node_pool {
    name                  = "default"
    node_count            = "1"
    vm_size               = "standard_D2_V2"
    enable_auto_scaling   = false
    enable_node_public_ip = false
    vnet_subnet_id        = azurerm_subnet.subnet_public_2.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    #service_cidr      = "10.0.0.0/16"
    #docker_bridge_cidr = var.dockercidrip
    #dns_service_ip    = "10.0.0.10"
  }
}
