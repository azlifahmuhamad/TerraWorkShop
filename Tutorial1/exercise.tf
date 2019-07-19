/*
provider
resource group
storage account
virtual network
subnet
public ip
network interface card
virtual machine
*/

locals {
  rgname = "pahtestrg"
  locationName = "Southeast Asia"
  saname = "sapahtest"
}



provider "azurerm" {
  version = "1.28.0"
}

//resouce group
resource "azurerm_resource_group" "rg-test" {
  name = local.rgname
  location = local.locationName
  
}

//storage account
resource "azurerm_storage_account" "sa" {
  name = local.saname
  resource_group_name = local.rgname
  location = local.locationName
  account_tier = "Standard"
  account_replication_type = "LRS"
  
}

//virtual network
resource "azurerm_virtual_network" "mainvnet" {
  name = "vnetpah-test"
  location = azurerm_resource_group.rg-test.location
  resource_group_name = azurerm_resource_group.rg-test.name
  address_space = ["10.0.0.0/16"]
}


//subnet
resource "azurerm_subnet" "subnet1" {
name = "subnetpah-test"
resource_group_name = azurerm_resource_group.rg-test.name
virtual_network_name = "vnetpah-test"
address_prefix = "10.0.1.0/24"

}

// public ip

resource "azurerm_public_ip" "testip" {
  name = "testpah-ip"
  location = azurerm_resource_group.rg-test.location
  resource_group_name = azurerm_resource_group.rg-test.name
  allocation_method = "Dynamic"


}

//network interface
resource "azurerm_network_interface" "nictest" {
  name = "nicpah-test"
  location = azurerm_resource_group.rg-test.location
  resource_group_name = azurerm_resource_group.rg-test.name

  ip_configuration {
    name = "ipconfig-test"
    subnet_id = azurerm_subnet.subnet1.id
    private_ip_address = "10.0.1.4"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.testip.id
  }
  
}
//virtual machine
resource "azurerm_virtual_machine" "testvm" {
  name = "vm-test"
  location = azurerm_resource_group.rg-test.location
  resource_group_name = azurerm_resource_group.rg-test.name
  network_interface_ids = [azurerm_network_interface.nictest.id]
  vm_size = "Standard_D2s_v3"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2016-Datacenter"
    version = "latest"
  }
  
  storage_os_disk {
    name = "vm1-disk1"
    caching ="ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "vm01"
    admin_username = "Azlifah"
  admin_password = "Lieya175"
  }

  os_profile_windows_config {
    provision_vm_agent = true
    enable_automatic_upgrades = false
  }

  boot_diagnostics {
    enabled = "true"
    storage_uri = join(",", azurerm_storage_account.sa.*.primary_blob_endpoint)
  }
}

