project_name = "crdb-multi-region-iam-demo"
environment  = "demo"
owner        = "nollen"
my_ip_address = "98.148.51.154"
crdb_version = "25.2.5"
app_instance_type = "t3a.micro"
include_demo = "yes"

cluster_info = {
  region0 = {
    database_region_name       = "aws-us-east-2"
    aws_region_name            = "us-east-2"
    database_connection_string = "postgresql://ron@nollen-iam-demo-w7v.aws-us-east-2.cockroachlabs.cloud:26257/defaultdb?sslmode=verify-full&sslrootcert=$HOME/Library/CockroachCloud/certs/1d4d68ed-a173-461e-a522-4fbca2b062e1/nollen-iam-demo-ca.crt"
    aws_instance_key           = "nollen-cockroach-revenue-us-east-2-kp01"
    vpc_cidr                   = "192.168.3.0/24"
  }
  region1 = {
    database_region_name       = "aws-us-west-2"
    aws_region_name            = "us-west-2"
    database_connection_string = "postgresql://ron@nollen-iam-demo-w7v.aws-us-west-2.cockroachlabs.cloud:26257/defaultdb?sslmode=verify-full&sslrootcert=$HOME/Library/CockroachCloud/certs/1d4d68ed-a173-461e-a522-4fbca2b062e1/nollen-iam-demo-ca.crt"
    aws_instance_key           = "nollen-cockroach-revenue-us-west-2-kp01"
    vpc_cidr                   = "192.168.4.0/24"
  }
  region2 = {
    database_region_name       = "aws-ca-central-1"
    aws_region_name            = "ca-central-1"
    database_connection_string = "postgresql://ron@nollen-iam-demo-w7v.aws-ca-central-1.cockroachlabs.cloud:26257/defaultdb?sslmode=verify-full&sslrootcert=$HOME/Library/CockroachCloud/certs/1d4d68ed-a173-461e-a522-4fbca2b062e1/nollen-iam-demo-ca.crt"
    aws_instance_key           = "nollen-cockroach-revenue-ca-central-1-kp01"
    vpc_cidr                   = "192.168.5.0/24"
  }
}
