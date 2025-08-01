# Azure Configuration
azure_region = "eastus"

# Environment
environment = "production"

# Project
project_name = "taskflow"

# Network Configuration
vnet_address_space      = "10.0.0.0/16"
private_subnet_prefixes = ["10.0.1.0/24"]
public_subnet_prefixes  = ["10.0.101.0/24"]

# Database Configuration
db_sku_name = "B_Standard_B1ms"
db_username = "taskflow"
db_password = "TaskflowSecure2024!"

# Application Configuration
secret_key = "your-super-secret-key-change-this-in-production"
mongodb_uri = "mongodb+srv://aoshingbes:bWcxHfCJdXLSzOhg@taskflow.onmvorc.mongodb.net/?retryWrites=true&w=majority&appName=taskflow" 