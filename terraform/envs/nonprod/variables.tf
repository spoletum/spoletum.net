variable "ssh_public_key" {
  description = "The public key to use for the SSH key pair"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCV3CGG5V5iii6/KhRiFAie60f22IWTFvLoLWQztsDrVHxK68KhoxGnfIfDjI7iqj19HqaCCeCY/Sp/j/eZfpqC+/v/6xk6IQQXFZdx0LYG4Z0rsxwoBvCrxoXHcmU+tBEfoFZdKvhqBG+eoSxQOx5S1vtjENaDViln2cj4zpNpE/RkSoOLYC7aNoQwmIcr4G+yrzpCRWyCHdNAnq6qIy3EyWh/dibRrdp1F/1PH8NU12FvFgb+SmCt5CkN2MmMXNRnqW7P61PElVKwOA2jrg4JXub9o3Skd5BcCwxX7/uASvc49icp4EyC5/7wM9SeTGcvBqYFNP8kRdfXo0uPlsam8ecsXnpO0hHAkUe/67ovrt8JApEGngs+MuVWlFB/UCiWWooYLlX1CAQGNJMcyUDuT6TckxShErqPF2xRDCFoLBzH1TOYXKvNtRhw1/7CallylifbseQWq5FIUViaqcY4V8eEFxeDjDbmQA8R8vp7FN6TI1z8AlAkagXdhSFMpIM= alessandro@DESKTOP-CQI0QDA"
}

variable "image_id" {
  description = "The ID of the image to use for the server"
  type        = string
  default     = "ubuntu-22.04"
}

variable "cloud_init_file" {
  description = "The path to the cloud-init file to use for the server"
  type        = string
  default     = "cloud-config.yml"
}

variable "server_type" {
  description = "The type of server to create"
  type        = string
  default     = "cx51"
}