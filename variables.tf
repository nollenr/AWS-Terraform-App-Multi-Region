# ----------------------------------------
# TAGS
# ----------------------------------------
    # Required tags
    variable "project_name" {
      description = "Name of the project."
      type        = string
      default     = "terraform-test"
    }

    variable "environment" {
      description = "Name of the environment."
      type        = string
      default     = "dev"
    }

    variable "owner" {
      description = "Owner of the infrastructure"
      type        = string
      default     = ""
    }

    # Optional tags
    variable "resource_tags" {
      description = "Tags to set for all resources"
      type        = map(string)
      default     = {}
    }

# ----------------------------------------
# My IP Address
# This is used in the creation of the security group
# and will allow access to the ec2-instances on ports
# 22 (ssh), 26257 (database), 8080 (for observability)
# and 3389 (rdp)
# ----------------------------------------
    variable "my_ip_address" {
      description = "User IP address for access to the ec2 instances."
      type        = string
      default     = "0.0.0.0"
    }

# ----------------------------------------
# CRDB Instance Specifications -- the version of the client
# ----------------------------------------
    variable "crdb_version" {
      description = "CockroachDB Version"
      type        = string
      default     = "23.1.10"
    }

# ----------------------------------------
# APP Instance Specifications
# ----------------------------------------
    variable "app_instance_type" {
      description = "App Instance Type"
      type        = string
      default     = "t3a.micro"
    }
    
# ----------------------------------------
# Regions, CIDR, and other cluster info
# ----------------------------------------
variable "cluster_info" {
  description = "Cluster configuration for each region"
  type = map(object({
    database_region_name       = string
    aws_region_name            = string
    database_connection_string = string
    aws_instance_key           = string
    vpc_cidr                   = string
  }))
}

# ----------------------------------------
# Demo
# ----------------------------------------
    variable "include_demo" {
      description = "'yes' or 'no' to include an HAProxy Instance"
      type        = string
      default     = "no"
      validation {
        condition = contains(["yes", "no"], var.include_demo)
        error_message = "Valid value for variable 'include_demo' is : 'yes' or 'no'"        
      }
    }

# ----------------------------------------
# TLS Vars -- Leave blank to have then generated
# ----------------------------------------
    variable "tls_private_key" {
      description = "TLS Private Key PEM"
      type        = string
      default     = ""
    }

    variable "tls_public_key" {
      description = "TLS Public Key PEM"
      type        = string
      default     = ""
    }

