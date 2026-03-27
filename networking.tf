# https://dev.to/z4ck404/aws-multi-region-vpc-peering-using-terraform-47jl
# Create vpc-peering-connection from region-0 to region-1
resource "aws_vpc_peering_connection" "peer0" {
  provider      = aws.region-0
  vpc_id        = module.app-region-0.vpc_id
  peer_vpc_id   = module.app-region-1.vpc_id
  peer_region   = var.cluster_info["region1"].aws_region_name
  auto_accept   = false
  tags = local.tags
}

resource "aws_vpc_peering_connection_accepter" "peer0" {
  provider                  = aws.region-1
  vpc_peering_connection_id = aws_vpc_peering_connection.peer0.id
  auto_accept               = true
}

# Create routes in region-0 for the cidr in region-1
resource "aws_route" "vpc0-to-vpc1" {
  route_table_id = module.app-region-0.route_table_public_id
  destination_cidr_block = var.cluster_info["region1"].vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer0.id
  provider = aws.region-0
}

# Create routes in region-1 for the cidr in region-0
resource "aws_route" "vpc1_to_vpc0" {
  route_table_id = module.app-region-1.route_table_public_id
  destination_cidr_block = var.cluster_info["region0"].vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer0.id
  provider = aws.region-1
}

# Create the security group ingress rule in region-0 for the region-1 cidr
resource "aws_vpc_security_group_ingress_rule" "into-vpc0-from-vpc1-db" {
  provider = aws.region-0
  security_group_id = module.app-region-0.security_group_intra_node_id
  from_port = 8000
  to_port = 8000
  ip_protocol = "tcp"
  cidr_ipv4 = var.cluster_info["region1"].vpc_cidr
  description = "Allow Prometheus to scrape metrics from peer"
}

resource "aws_vpc_security_group_ingress_rule" "into-vpc0-from-vpc1-ssh" {
  provider = aws.region-0
  security_group_id = module.app-region-0.security_group_intra_node_id
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  cidr_ipv4 = var.cluster_info["region1"].vpc_cidr
  description = "Allow SSH access from peer"
}

# Create the security group ingress rule in region-1 for the region-0 cidr
resource "aws_vpc_security_group_ingress_rule" "into-vpc1-from-vpc0-db" {
  provider = aws.region-1
  security_group_id = module.app-region-1.security_group_intra_node_id
  from_port = 8000
  to_port = 8000
  ip_protocol = "tcp"
  cidr_ipv4 = var.cluster_info["region0"].vpc_cidr
  description = "Allow Prometheus to scrape metrics from peer"
}

resource "aws_vpc_security_group_ingress_rule" "into-vpc1-from-vpc0-ssh" {
  provider = aws.region-1
  security_group_id = module.app-region-1.security_group_intra_node_id
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  cidr_ipv4 = var.cluster_info["region0"].vpc_cidr
  description = "Allow SSH access from peer"
}

# Create vpc-peering-connection from region-1 to region-2
resource "aws_vpc_peering_connection" "peer1" {
  provider      = aws.region-1
  vpc_id        = module.app-region-1.vpc_id
  peer_vpc_id   = module.app-region-2.vpc_id
  peer_region   = var.cluster_info["region2"].aws_region_name
  auto_accept   = false
  tags = local.tags
}

resource "aws_vpc_peering_connection_accepter" "peer1" {
  provider                  = aws.region-2
  vpc_peering_connection_id = aws_vpc_peering_connection.peer1.id
  auto_accept               = true
}

# Create routes in region-1 for the cidr in region-2
resource "aws_route" "vpc1-to-vpc2" {
  route_table_id = module.app-region-1.route_table_public_id
  destination_cidr_block = var.cluster_info["region2"].vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer1.id
  provider = aws.region-1
}

# Create routes in region-2 for the cidr in region-1
resource "aws_route" "vpc2_to_vpc1" {
  route_table_id = module.app-region-2.route_table_public_id
  destination_cidr_block = var.cluster_info["region1"].vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer1.id
  provider = aws.region-2
}

# Create the security group ingress rule in region-1 for the region-2 cidr
resource "aws_vpc_security_group_ingress_rule" "into-vpc1-from-vpc2-db" {
  provider = aws.region-1
  security_group_id = module.app-region-1.security_group_intra_node_id
  from_port = 8000
  to_port = 8000
  ip_protocol = "tcp"
  cidr_ipv4 = var.cluster_info["region2"].vpc_cidr
  description = "Allow Prometheus to scrape metrics from peer"
}

resource "aws_vpc_security_group_ingress_rule" "into-vpc1-from-vpc2-ssh" {
  provider = aws.region-1
  security_group_id = module.app-region-1.security_group_intra_node_id
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  cidr_ipv4 = var.cluster_info["region2"].vpc_cidr
  description = "Allow Prometheus to scrape metrics from peer"
}

# Create the security group ingress rule in region-2 for the region-1 cidr
resource "aws_vpc_security_group_ingress_rule" "into-vpc2-from-vpc1-db" {
  provider = aws.region-2
  security_group_id = module.app-region-2.security_group_intra_node_id
  from_port = 8000
  to_port = 8000
  ip_protocol = "tcp"
  cidr_ipv4 = var.cluster_info["region1"].vpc_cidr
  description = "Allow Prometheus to scrape metrics from peer"
}

resource "aws_vpc_security_group_ingress_rule" "into-vpc2-from-vpc1-ssh" {
  provider = aws.region-2
  security_group_id = module.app-region-2.security_group_intra_node_id
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  cidr_ipv4 = var.cluster_info["region1"].vpc_cidr
  description = "Allow Prometheus to scrape metrics from peer"
}

# Create vpc-peering-connection from region-2 to region-0
resource "aws_vpc_peering_connection" "peer2" {
  provider      = aws.region-2
  vpc_id        = module.app-region-2.vpc_id
  peer_vpc_id   = module.app-region-0.vpc_id
  peer_region   = var.cluster_info["region0"].aws_region_name
  auto_accept   = false
  tags = local.tags
}

resource "aws_vpc_peering_connection_accepter" "peer2" {
  provider                  = aws.region-0
  vpc_peering_connection_id = aws_vpc_peering_connection.peer2.id
  auto_accept               = true
}

# Create routes in region-2 for the cidr in region-0
resource "aws_route" "vpc2-to-vpc0" {
  route_table_id = module.app-region-2.route_table_public_id
  destination_cidr_block = var.cluster_info["region0"].vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer2.id
  provider = aws.region-2
}

# Create routes in region-0 for the cidr in region-2
resource "aws_route" "vpc0_to_vpc2" {
  route_table_id = module.app-region-0.route_table_public_id
  destination_cidr_block = var.cluster_info["region2"].vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer2.id
  provider = aws.region-0
}

# Create the security group ingress rule in region-2 for the region-0 cidr
resource "aws_vpc_security_group_ingress_rule" "into-vpc2-from-vpc0-db" {
  provider = aws.region-2
  security_group_id = module.app-region-2.security_group_intra_node_id
  from_port = 8000
  to_port = 8000
  ip_protocol = "tcp"
  cidr_ipv4 = var.cluster_info["region0"].vpc_cidr
  description = "Allow Prometheus to scrape metrics from peer"
}

resource "aws_vpc_security_group_ingress_rule" "into-vpc2-from-vpc0-ssh" {
  provider = aws.region-2
  security_group_id = module.app-region-2.security_group_intra_node_id
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  cidr_ipv4 = var.cluster_info["region0"].vpc_cidr
  description = "Allow SSH access from peer"
}

# Create the security group ingress rule in region-0 for the region-2 cidr
resource "aws_vpc_security_group_ingress_rule" "into-vpc0-from-vpc2-db" {
  provider = aws.region-0
  security_group_id = module.app-region-0.security_group_intra_node_id
  from_port = 8000
  to_port = 8000
  ip_protocol = "tcp"
  cidr_ipv4 = var.cluster_info["region2"].vpc_cidr
  description = "Allow Prometheus to scrape metrics from peer"
}

resource "aws_vpc_security_group_ingress_rule" "into-vpc0-from-vpc2-ssh" {
  provider = aws.region-0
  security_group_id = module.app-region-0.security_group_intra_node_id
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  cidr_ipv4 = var.cluster_info["region2"].vpc_cidr
  description = "Allow SSH access from peer"
}
