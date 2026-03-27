#main.tf 

locals {
  required_tags = {
    owner       = var.owner,
    project     = var.project_name,
    environment = var.environment
  }
  tags = merge(var.resource_tags, local.required_tags)
}

provider "aws" {
  region = var.cluster_info["region0"].aws_region_name
  alias = "region-0"
}

provider "aws" {
  region = var.cluster_info["region1"].aws_region_name
  alias = "region-1"
}

provider "aws" {
  region = var.cluster_info["region2"].aws_region_name
  alias = "region-2"
}
