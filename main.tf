provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "projectp2" {
  name     = "Projectp2"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "projectp2-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.projectp2.location
  resource_group_name = azurerm_resource_group.projectp2.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "projectp2-subnet"
  resource_group_name  = azurerm_resource_group.projectp2.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "mysqlDelegation"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "ajay1"
  resource_group_name = azurerm_resource_group.projectp2.name
  location            = azurerm_resource_group.projectp2.location
   zone                = "1"  # Add availability zone
  sku_name            = "GP_Standard_D2ds_v4"
  administrator_login = "admin143"
  administrator_password = "yourpassword123!"  # Replace with a secure password

  storage {
    size_gb = 32
  }

  version = "8.0.21"
  
  delegated_subnet_id = azurerm_subnet.subnet.id
}

resource "azurerm_container_registry" "acr" {
  name                = "p2reg1"
  resource_group_name = azurerm_resource_group.projectp2.name
  location            = azurerm_resource_group.projectp2.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "myp2cluster"
  location            = azurerm_resource_group.projectp2.location
  resource_group_name = azurerm_resource_group.projectp2.name
  dns_prefix          = "projectp2aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }
}

resource "azurerm_static_site" "frontend" {
  name                = "frony"
  resource_group_name = azurerm_resource_group.projectp2.name
  location            = azurerm_resource_group.projectp2.location
  sku_size            = "Free"
 
  identity {
    type = "SystemAssigned"
  }
}

output "resource_group_name" {
  value = azurerm_resource_group.projectp2.name
}

output "mysql_flexible_server_name" {
  value = azurerm_mysql_flexible_server.mysql.name
}

output "container_registry_name" {
  value = azurerm_container_registry.acr.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnet_name" {
  value = azurerm_subnet.subnet.name
}