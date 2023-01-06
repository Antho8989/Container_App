#General Variables 
variable "customer_prefix" {
  description = "Name of the customer or client"
  default     = "test"
}
variable "rg_name" {
  description = "Prefix name for the customer or client"
  default     = "test-rg-dev"
}
variable "location" {
  description = "Azure Region location for deployment of resources"
  default     = "east us"
}
variable "environment" {
  description = "Environment tag value"
  default     = "dev"
}
variable "aca-name" {
  description = "Environment tag value"
  default     = "test-env-dev"
}

#Container App Variables
variable "container_apps" {
  type = list(object({
    name = string
    image = string
    tag = string
    containerPort = number
    ingress_enabled = bool
    min_replicas = number
    max_replicas = number
    cpu_requests = number
    mem_requests = string
  }))

  default = [ {
   image = "mcr.microsoft.com/azuredocs/containerapps-helloworld"
   name = "simple-hello-world-container"
   tag = "latest"
   containerPort = 80
   ingress_enabled = true
   min_replicas = 1
   max_replicas = 2
   cpu_requests = 0.5
   mem_requests = "1.0Gi"
  },
  {
   image = "thorstenhans/gopher"
   name = "devilgopher"
   tag = "devil"
   containerPort = 80
   ingress_enabled = true
   min_replicas = 1
   max_replicas = 2
   cpu_requests = 0.5
   mem_requests = "1.0Gi"
  }] 
}