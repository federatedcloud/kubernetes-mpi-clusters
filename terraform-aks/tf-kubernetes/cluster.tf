resource "azurerm_resource_group" "main" {
  name     = "tf-kubernetes"
  location = "East US"
}

## Might have to add security group
resource "azurerm_virtual_network" "main" {
  name                = "tf-kubernetes-network"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.1.0.0/24"]
}

## Required for second node pool to be in subnet
resource "azurerm_route_table" "main" {
  name                          = "main-rt"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  disable_bgp_route_propagation = false

  route {
    name           = "primary-route"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }
}

resource "azurerm_subnet_route_table_association" "main" {
  subnet_id      = azurerm_subnet.internal.id
  route_table_id = azurerm_route_table.main.id
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "tf-kubernetes"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "tf-kubernetes"
  
  default_node_pool {
    name            = "launcher"
    node_count      = 1
    os_disk_size_gb = 50
    vm_size         = "Standard_DS2_v2"
    vnet_subnet_id  = azurerm_subnet.internal.id

    node_labels = {
      "role" = "launcher"
    }
    
  }
  
  ## Look into what this means
  identity {
    type = "SystemAssigned"
  }
  
  addon_profile {
    aci_connector_linux {
      enabled = false
    }
    
    azure_policy {
      enabled = false
    }
    
    ## Look into what this means
    http_application_routing {
      enabled = false
    }
    
    kube_dashboard {
      enabled = false
    }
    
    ## Potential metrics logging?
    oms_agent {
      enabled = false
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "worker" {
  name                  = "worker"

  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  node_count            = 1
  os_disk_size_gb       = 50
  vm_size               = "Standard_DS2_v2"
  vnet_subnet_id        = azurerm_subnet.internal.id

  node_labels = {
    "role" = "worker"
  }
}
