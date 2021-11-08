terraform{
    required_providers {
      azurerm = {
          source = "hashicorp/azurerm"
          version = "2.25"
      }
    }
}

provider "azurerm"{
    skip_provider_registration = true
    features {
    }
}

variable "client" {
  
}

variable "secret" {
  
}

resource "azurerm_resource_group" "rg-aula-kb" {
    location = "eastus"
    name = "rg-aula-kb"
}


resource "azurerm_container_registry" "acr-aula-kb" {
  name                = "aulakb"
  resource_group_name = azurerm_resource_group.rg-aula-kb.name
  location            = azurerm_resource_group.rg-aula-kb.location
  sku                 = "Basic"
  admin_enabled       = false
 }

 resource "azurerm_kubernetes_cluster" "aks-aula-kb" {
  name                = "aks-aula-kb"
  location            = azurerm_resource_group.rg-aula-kb.location
  resource_group_name = azurerm_resource_group.rg-aula-kb.name
  dns_prefix          = "aks-aula-kb"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2s_v3"
  }

  service_principal {
    client_id = var.client
    client_secret = var.secret
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    http_application_routing {
      enabled = true
    }
  }

  tags = {
    Environment = "Production"
  }
}

 data "azuread_service_principal" "aks_principal" {
     application_id = var.client
 }

 resource "azurerm_role_assignment" "acrpull-aula-kb" {
   scope = azurerm_container_registry.acr-aula-kb.id
   role_definition_name = "AcrPull"
   principal_id = data.azuread_service_principal.aks_principal.id
   skip_service_principal_aad_check = true
 }