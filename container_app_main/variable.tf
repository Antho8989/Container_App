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
########Credentials
variable "SUBSCRIPTION_ID" {
  description = "Environment tag value"
  default     = "0dbb99fb-abdc-4782-905b-ace3f6e255c1"
}
variable "SP_CLIENT_ID" {
  description = "Environment tag value"
  default     = "cd987ec1-06f4-46a8-a1a9-1bf64f4a533c"
}
variable "SP_CLIENT_SECRET" {
  description = "Environment tag value"
  default     = "rdv8Q~v5mckQr4Fdv0bcpQnuzKGXSPCwV_1cwaD3"
}
variable "SP_TENANT_ID" {
  description = "Environment tag value"
  default     = "8698cc9d-7acc-4963-9c7d-bc43668f374f"
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