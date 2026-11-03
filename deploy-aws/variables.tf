variable "aws_region" {
  description = "Region de AWS (Academy solo permite us-east-1 y us-west-2)"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo para nombres y tags"
  type        = string
  default     = "juice-shop"
}

variable "allowed_cidrs" {
  description = "IPs publicas con acceso a la app, en formato CIDR (ej. [\"1.2.3.4/32\"]). Una por integrante."
  type        = list(string)

  validation {
    condition     = length(var.allowed_cidrs) > 0 && alltrue([for c in var.allowed_cidrs : can(cidrhost(c, 0)) && c != "0.0.0.0/0"])
    error_message = "Debe haber al menos un CIDR valido y ninguno puede ser 0.0.0.0/0 (la app es vulnerable a proposito)."
  }
}

variable "instance_type" {
  description = "Tipo de instancia (Juice Shop necesita ~1 GB de RAM)"
  type        = string
  default     = "t3.small"
}

variable "juice_shop_image" {
  description = "Imagen de contenedor. Para el punto 3 se cambia por la del fork corregido."
  type        = string
  default     = "bkimminich/juice-shop:latest"
}

variable "key_name" {
  description = "Key pair existente para SSH (opcional). Si es null no se abre el puerto 22."
  type        = string
  default     = null
}
