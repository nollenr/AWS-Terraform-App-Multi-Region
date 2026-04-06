module "app-region-1" {
  # use the https clone url from github, but without the "https://"
  source = "github.com/nollenr/AWS-Terraform-App-Module.git"

  providers = {
    aws = aws.region-1
  }

  my_ip_address           = var.my_ip_address          # same for all
  owner                   = var.owner                  # same for all
  project_name            = var.project_name           # same for all
  crdb_version            = var.crdb_version           # same for all
  app_instance_type       = var.app_instance_type_primary
  include_demo            = var.include_demo           # same for all

  cluster_info = {
    region = {
      database_region_name       = var.cluster_info["region1"].database_region_name
      aws_region_name            = var.cluster_info["region1"].aws_region_name
      database_connection_string = var.cluster_info["region1"].database_connection_string
      aws_instance_key           = var.cluster_info["region1"].aws_instance_key
      vpc_cidr                   = var.cluster_info["region1"].vpc_cidr
    }
  }

  other_app_nodes = []  # or omit, uses default
  crdb_region_list = [
    var.cluster_info["region0"].database_region_name,
    var.cluster_info["region1"].database_region_name,
    var.cluster_info["region2"].database_region_name
  ]

  tls_private_key = tls_private_key.crdb_ca_keys.private_key_pem # same for all
  tls_public_key  = tls_private_key.crdb_ca_keys.public_key_pem  # same for all
  tls_cert        = tls_self_signed_cert.crdb_ca_cert.cert_pem   # same for all
}

module "app-region-2" {
  # use the https clone url from github, but without the "https://"
  source = "github.com/nollenr/AWS-Terraform-App-Module.git"

  providers = {
    aws = aws.region-2
  }

  my_ip_address           = var.my_ip_address          # same for all
  owner                   = var.owner                  # same for all
  project_name            = var.project_name           # same for all
  crdb_version            = var.crdb_version           # same for all
  app_instance_type       = var.app_instance_type_secondary      
  include_demo            = var.include_demo           # same for all

  cluster_info = {
    region = {
      database_region_name       = var.cluster_info["region2"].database_region_name
      aws_region_name            = var.cluster_info["region2"].aws_region_name
      database_connection_string = var.cluster_info["region2"].database_connection_string
      aws_instance_key           = var.cluster_info["region2"].aws_instance_key
      vpc_cidr                   = var.cluster_info["region2"].vpc_cidr
    }
  }

  other_app_nodes = []  # or omit, uses default
  crdb_region_list = [
    var.cluster_info["region0"].database_region_name,
    var.cluster_info["region1"].database_region_name,
    var.cluster_info["region2"].database_region_name
  ]

  tls_private_key = tls_private_key.crdb_ca_keys.private_key_pem # same for all
  tls_public_key  = tls_private_key.crdb_ca_keys.public_key_pem  # same for all
  tls_cert        = tls_self_signed_cert.crdb_ca_cert.cert_pem   # same for all
}

module "app-region-0" {
  # use the https clone url from github, but without the "https://"
  source = "github.com/nollenr/AWS-Terraform-App-Module.git"

  providers = {
    aws = aws.region-0
  }

  my_ip_address           = var.my_ip_address
  owner                   = var.owner
  project_name            = var.project_name
  crdb_version            = var.crdb_version
  app_instance_type       = var.app_instance_type_secondary
  include_demo            = var.include_demo

  cluster_info = {
    region = {
      database_region_name       = var.cluster_info["region0"].database_region_name
      aws_region_name            = var.cluster_info["region0"].aws_region_name
      database_connection_string = var.cluster_info["region0"].database_connection_string
      aws_instance_key           = var.cluster_info["region0"].aws_instance_key
      vpc_cidr                   = var.cluster_info["region0"].vpc_cidr
    }
  }
  
  other_app_nodes = [
    {
      private_ip = module.app-region-1.app_instance_ips.private_ip
      public_ip  = module.app-region-1.app_instance_ips.public_ip
    },
    {
      private_ip = module.app-region-2.app_instance_ips.private_ip
      public_ip  = module.app-region-2.app_instance_ips.public_ip
    }
  ] 
  crdb_region_list = [
    var.cluster_info["region0"].database_region_name,
    var.cluster_info["region1"].database_region_name,
    var.cluster_info["region2"].database_region_name
  ]

  tls_private_key = tls_private_key.crdb_ca_keys.private_key_pem
  tls_public_key  = tls_private_key.crdb_ca_keys.public_key_pem
  tls_cert        = tls_self_signed_cert.crdb_ca_cert.cert_pem
}
