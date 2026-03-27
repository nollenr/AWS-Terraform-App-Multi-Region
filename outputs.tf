# outputs.tf

output "region_0_app_instance_ips" {
  description = "IP addresses of app instance in region 0"
  value       = merge(
    { region = var.cluster_info["region0"].aws_region_name },
    module.app-region-0.app_instance_ips
  )
}

output "region_1_app_instance_ips" {
  description = "IP addresses of app instance in region 1"
  value       = merge(
    { region = var.cluster_info["region1"].aws_region_name },
    module.app-region-1.app_instance_ips
  )
}

output "region_2_app_instance_ips" {
  description = "IP addresses of app instance in region 2"
  value       = merge(
    { region = var.cluster_info["region2"].aws_region_name },
    module.app-region-2.app_instance_ips
  )
}
