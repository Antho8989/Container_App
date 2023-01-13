#General Variables 
variable "full_customer_name" {
  description = "Name of the customer or client"
  default     = "test"
}
variable "customer_prefix" {
  description = "Prefix name for the customer or client"
  default     = "test"
}
variable "location" {
  description = "Azure Region location for deployment of resources"
  default     = "east us"
}
variable "environment" {
  description = "Environment tag value"
  default     = "dev"
}

######################
# Container Registry #
#####################
variable "container_reg_sku" {
  description = "Type of Container Registry"
  default = "basic"
}
variable "container_reg_public_access" {
  description = "Public network access"
  default = "true"
}