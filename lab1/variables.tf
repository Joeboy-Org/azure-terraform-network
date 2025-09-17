variable "application_name" {
  description = "Name of the application"
  type        = string
  validation {
    condition     = length(var.application_name) > 0 && length(var.application_name) <= 10
    error_message = "Application name must be between 1 and 10 characters."
  }
}

variable "environment_name" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment_name)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "primary_location" {
  description = "Primary Azure region"
  type        = string
  default     = ""
}

variable "secondary_location" {
  description = "Secondary Azure region (fallback)"
  type        = string
}

variable "hub_vnets" {
  description = "Hub virtual networks configuration"
  type = map(object({
    hub_base_address_space = string
    subnets = optional(map(object({
      address_prefix = string
    })), {})
  }))
  default = {}
}

variable "spoke_vnets" {
  description = "Spoke virtual networks configuration"
  type = map(object({
    spoke_base_address_space = string
    subnets = optional(map(object({
      address_prefix = string
    })), {})
  }))
  default = {}
}

variable "hub_base_address_space" {
  description = "Base CIDR block for hub VNets"
  type        = string
  validation {
    condition     = can(cidrhost(var.hub_base_address_space, 0))
    error_message = "Hub base address space must be a valid CIDR block."
  }
}

variable "spoke_base_address_space" {
  description = "Base CIDR block for spoke VNets"
  type        = string
  validation {
    condition     = can(cidrhost(var.spoke_base_address_space, 0))
    error_message = "Spoke base address space must be a valid CIDR block."
  }
}