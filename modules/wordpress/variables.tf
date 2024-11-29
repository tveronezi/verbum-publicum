variable "wordpress_namespace" {
  description = "The namespace to install wordpress"
  type        = string
}

variable "wordpress_mariadb_root_user" {
  description = "The MariaDB root user"
  type        = string
  default     = "root"
}

variable "wordpress_mariadb_root_password" {
  description = "The MariaDB root password"
  type        = string
  sensitive   = true
}

variable "wordpress_mariadb_user" {
  description = "The MariaDB user"
  type        = string
  default     = "bn_wordpress"
}

variable "wordpress_mariadb_user_password" {
  description = "The MariaDB user password"
  type        = string
  sensitive   = true
}

variable "wordpress_mariadb_storage" {
  description = "The size of the disk used by the MariaDB server"
  type        = string
}

variable "wordpress_password" {
  description = "wordpress password"
  type        = string
  sensitive   = true
}

variable "wordpress_username" {
  description = "wordpress"
  type        = string
}

variable "wordpress_storage" {
  description = "The size of the disk used by the wordpress server"
  type        = string
}

variable "wordpress_host" {
  description = "wordpress ingress host"
  type        = string
}

variable "cert_issuer" {
  description = "The name of the certificate issuer"
  type        = string
}

variable "wordpress_mariadb_pvc_host_path" {
  description = "The path of the persistent volume in the host machine"
  type        = string
}

variable "wordpress_pvc_host_path" {
  description = "The path of the persistent volume in the host machine"
  type        = string
}
