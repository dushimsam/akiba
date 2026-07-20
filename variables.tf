variable "server_api_url" {
  type        = string
  description = "The target endpoint to create the VM (https://api.strettch.cloud/api/v1/computes)"
}

variable "bearer_api_key" {
  type        = string
  description = "The API secret key"
  sensitive   = true
}
