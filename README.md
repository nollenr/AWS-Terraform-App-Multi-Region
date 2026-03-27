# AWS Multi-Region EC2 Application Deployment

This Terraform configuration deploys EC2 application servers across multiple AWS regions with full VPC peering connectivity, using the [AWS-Terraform-App-Module](https://github.com/nollenr/AWS-Terraform-App-Module.git). The deployed module includes an IAM Multi-Region demo with tools for disrupting a CockroachDB Advanced Cluster to test resilience and failover scenarios.

**Prerequisites:** Create your CockroachDB Advanced Cluster first. Once the cluster is deployed, roll out this infrastructure in the same regions as your database cluster for optimal performance.

## Architecture

The infrastructure deploys:
- **3 AWS regions** (configurable via `cluster_info`)
- **EC2 instances** in each region running a demo application
- **VPC peering** connections creating a full mesh topology between all regions
- **Security groups** configured for cross-region communication
- **TLS certificates** for secure connections

### Network Topology

```
Region 0  ←→  Region 1
    ↖            ↙
       Region 2
```

All three regions are fully peered with bi-directional routing and security group rules allowing cross-region communication on ports 22 (SSH) and 8000 (Prometheus metrics).

## Prerequisites

- Terraform >= 1.2.0
- AWS CLI configured with appropriate credentials
- AWS provider >= 4.61.0
- SSH key pairs created in each target region

## Quick Start

1. **Clone the repository**
   ```bash
   cd AWS-Terraform-App-Multi-Region
   ```

2. **Create a `terraform.tfvars` file** with your settings:
   ```hcl
   owner             = "your-name"
   project_name      = "my-app-project"
   environment       = "dev"
   my_ip_address     = "1.2.3.4"
   include_demo      = "yes"

   cluster_info = {
     region0 = {
       database_region_name       = "aws-us-east-2"
       aws_region_name            = "us-east-2"
       database_connection_string = "postgresql://user@cluster.aws-us-east-2.cockroachlabs.cloud:26257/defaultdb?sslmode=verify-full&sslrootcert=$HOME/certs/ca.crt"
       aws_instance_key           = "key-us-east-2"
       vpc_cidr                   = "192.168.3.0/24"
     }
     region1 = {
       database_region_name       = "aws-us-west-2"
       aws_region_name            = "us-west-2"
       database_connection_string = "postgresql://user@cluster.aws-us-west-2.cockroachlabs.cloud:26257/defaultdb?sslmode=verify-full&sslrootcert=$HOME/certs/ca.crt"
       aws_instance_key           = "key-us-west-2"
       vpc_cidr                   = "192.168.4.0/24"
     }
     region2 = {
       database_region_name       = "aws-ca-central-1"
       aws_region_name            = "ca-central-1"
       database_connection_string = "postgresql://user@cluster.aws-ca-central-1.cockroachlabs.cloud:26257/defaultdb?sslmode=verify-full&sslrootcert=$HOME/certs/ca.crt"
       aws_instance_key           = "key-ca-central-1"
       vpc_cidr                   = "192.168.5.0/24"
     }
   }
   ```

3. **Initialize and apply**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `owner` | Owner of the infrastructure | `"john-doe"` |
| `project_name` | Name of the project | `"terraform-test"` |
| `environment` | Environment name | `"dev"` |

### Cluster Configuration (`cluster_info`)

The `cluster_info` variable contains the configuration for each region. You need to provide the following information for each region (region0, region1, region2):

#### How to Obtain Values

**`database_region_name`**
- Connect to your CockroachDB cluster
- Run the SQL command: `SHOW REGIONS;`
- Use the region names from the output (e.g., `aws-us-east-2`, `aws-us-west-2`, `aws-ca-central-1`)

**`aws_region_name`**
- AWS region where the VPC and EC2 instances will be deployed
- Should correspond to the database regions for optimal latency
- Examples: `us-east-2`, `us-west-2`, `ca-central-1`

**`database_connection_string`**
- Open your CockroachDB Cloud Console
- Click the **Connect** button for your cluster
- Select your SQL user (must have permissions to drop/create databases, run DDL and DML)
- Choose the **primary region** first
- Select **defaultdb** as the database
- From the **Connection String** dropdown menu, copy **The Connection String**
- Repeat for each region, selecting the appropriate region each time

**`aws_instance_key`**
- Name of the SSH key pair in the AWS region
- The key pair must already exist in the target AWS region

**`vpc_cidr`**
- CIDR block for the VPC in this region
- Must be non-overlapping across all regions
- Example: `192.168.3.0/24`, `192.168.4.0/24`, `192.168.5.0/24`

### Application Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `my_ip_address` | string | `"0.0.0.0"` | Your IP address for security group access (SSH, DB, observability) |
| `crdb_version` | string | `"23.1.10"` | CockroachDB client version |
| `app_instance_type` | string | `"t3a.micro"` | EC2 instance type for app servers |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_tags` | map(string) | `{}` | Additional tags for resources |
| `include_demo` | string | `"no"` | Include demo application (`"yes"` or `"no"`) |
| `tls_private_key` | string | `""` | TLS private key PEM (auto-generated if blank) |
| `tls_public_key` | string | `""` | TLS public key PEM (auto-generated if blank) |

## File Structure

```
.
├── main.tf          # Provider configuration and local variables
├── instances.tf     # Module calls for EC2 instances per region
├── networking.tf    # VPC peering and cross-region connectivity
├── outputs.tf       # Output values for instance IPs and regions
├── variables.tf     # Variable definitions
├── tls.tf          # TLS certificate generation
└── terraform.tf    # Terraform version requirements
```

## Network Configuration

### VPC Peering

The [networking.tf](networking.tf) file creates:
- **3 VPC peering connections** (region-0 ↔ region-1, region-1 ↔ region-2, region-2 ↔ region-0)
- **Route table entries** for cross-region traffic
- **Security group rules** allowing:
  - Port 8000 (Prometheus metrics) between all regions
  - Port 22 (SSH) between all regions

### Security Groups

Each region's security group allows inbound traffic from the other two regions' CIDR blocks for application communication and SSH access.

## TLS Configuration

The configuration automatically generates:
- RSA 2048-bit private/public key pair
- Self-signed CA certificate valid for 5 years
- Certificates are shared across all regions for consistent security

To use your own certificates, set `tls_private_key` and `tls_public_key` variables.

## Module Source

This configuration uses the remote module:
```hcl
source = "github.com/nollenr/AWS-Terraform-App-Module.git"
```

The module is instantiated three times (once per region) with region-specific configuration.

## Outputs

After running `terraform apply`, the following outputs are available for each region:

```
region_0_app_instance_ips = {
  "region"     = "us-east-2"
  "private_ip" = "192.168.3.126"
  "public_ip"  = "18.119.114.175"
}
region_1_app_instance_ips = {
  "region"     = "us-west-2"
  "private_ip" = "192.168.4.112"
  "public_ip"  = "54.185.48.95"
}
region_2_app_instance_ips = {
  "region"     = "ca-central-1"
  "private_ip" = "192.168.5.118"
  "public_ip"  = "15.223.200.96"
}
```

Each output includes:
- **region**: The AWS region where the instance is deployed
- **private_ip**: Private IP address within the VPC
- **public_ip**: Public IP address for external access

## Important Notes

1. **SSH Keys**: Ensure SSH key pairs exist in each region before deployment
2. **CIDR Blocks**: VPC CIDR blocks must not overlap across regions
3. **Database Setup**: A CockroachDB multi-region cluster must be configured before deployment
4. **Region Correspondence**: AWS regions should correspond to your CockroachDB cluster regions for optimal latency
5. **Costs**: Running EC2 instances across 3 regions will incur AWS charges
6. **IP Access**: Set `my_ip_address` to your public IP for secure access (default `0.0.0.0` allows all)

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## References

- [AWS Multi-Region VPC Peering Tutorial](https://dev.to/z4ck404/aws-multi-region-vpc-peering-using-terraform-47jl)
- [CockroachDB Security Certificates](https://www.cockroachlabs.com/docs/v22.2/create-security-certificates-openssl)
