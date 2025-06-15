variable "prefix" {
  type        = string
  description = "Préfixe utilisé pour nommer les ressources Azure"
  default     = "tpcicd"
}

variable "location" {
  type        = string
  description = "Région Azure où déployer l'infrastructure"
  default     = "westeurope"
}

variable "admin_username" {
  type        = string
  description = "Nom d'utilisateur administrateur pour les VMs Linux"
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "Clé publique SSH pour accéder aux VMs"
  // default  = ""  # Valeur fournie via *.tfvars ou -var command
} 