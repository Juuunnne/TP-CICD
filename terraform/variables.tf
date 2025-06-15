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
  default  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjbd8ht0GQ3IogVFFMFEJZuTIBGQ2cUJH5q9yiqt1rHdzPI3/DOeC4JM758R/O761EA1cJIsGEbDAhsUw027eD4TOr5YsmlYfNmCMOvyztp5edsazPLcfyCmF/xTuM/TAGBdIVH4FlmF0c1xwYul6wC27oxdcW2kkmwIK2BS78KxdP7h7ixPYHTvlxbFoD7w9lwPa2W1kcMczYa159lZC9pVTYi8d1i4lcQEx+wxeJeHGigcpu8sIH0YCYLI5SYKVKjwFdyegMKn7wasjiGE1eC8fukjQujTE09ZHH46gLa3G5m2C9TQw3azD326DE9BDPfGhIwzqBcNtZFuFnplt06xX0joUS3i2jvICQ6bahEbENgubUXULQMAg2L1WXl3mEwd7pTmbdLoBjqK2OvqWvVOtInLZzLun/me7ax0g7zagP9KEjahPbeVRhqcj6WKHuldMydscqQZr5kHJSQDXkTOWd9kFWyujgcJsbHbdFSJcvfDfXNc/vLrnWdcGzK+giXWVpWcY9MAeVpIb9qZnwpWIHPVeA1vV0eOZiWMvh8py9hEvq1Xi8XHsffJjqNWATquOZ/3I9UUL2cYz3+YZj4IPbgvn5Vkwy5t9gUqDrt0yhPmHpIu3dN08o0/s89me4SgbHj6JAqiqVKMB/DzOqWJW1hpt9CbVr+KRy4fr7yw== tp-cicd"
} 