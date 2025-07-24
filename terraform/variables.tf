variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "taskflow"
}

variable "vnet_address_space" {
  description = "Address space for Virtual Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_prefixes" {
  description = "Address prefixes for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "public_subnet_prefixes" {
  description = "Address prefixes for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24"]
}

variable "db_sku_name" {
  description = "PostgreSQL Flexible Server SKU name"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "taskflow"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "Flask secret key"
  type        = string
  sensitive   = true
}

variable "app_cpu" {
  description = "CPU units for the app (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "app_memory" {
  description = "Memory for the app in MiB"
  type        = number
  default     = 512
}

variable "app_desired_count" {
  description = "Desired number of app instances"
  type        = number
  default     = 1
}

variable "mongodb_uri" {
  description = "MongoDB Atlas connection string"
  type        = string
  sensitive   = true
} 