# AWS Redis Cache with Terraform Modules

This project provisions a small AWS application environment using reusable Terraform modules. It creates a VPC, places two EC2 application instances in private subnets, and deploys a highly available Redis cache using Amazon ElastiCache.

## Architecture

```text
                                 Internet
                                    |
                             Internet Gateway
                                    |
                      Public subnet (us-east-1a)
                                    |
                              NAT Gateway
                                    |
           +------------------------+------------------------+
           |                                                 |
Private subnet (us-east-1a)                     Private subnet (us-east-1b)
    EC2 application 1                                EC2 application 2
           |                                                 |
           +-------------- Redis port 6379 -----------------+
                                     |
                    ElastiCache Redis replication group
                    Primary node + replica, Multi-AZ
```

The NAT gateway gives the private EC2 instances outbound internet access for actions such as package updates. Redis remains in the private subnets and accepts port `6379` traffic only from the EC2 security group.

## What Terraform Creates

| Area | Resources |
| --- | --- |
| Networking | VPC, internet gateway, two public subnets, two private subnets, public/private route tables, one Elastic IP, and one NAT gateway |
| Application | An EC2 security group and two EC2 instances across the private subnets |
| Cache | An ElastiCache subnet group, a Redis security group, and a two-node Redis replication group with Multi-AZ failover |

### Default development configuration

The root module is in [`environments/dev`](environments/dev) and currently uses:

- AWS region: `us-east-1`
- VPC CIDR: `10.0.0.0/16`
- Public subnets: `10.0.1.0/24`, `10.0.2.0/24`
- Private subnets: `10.0.11.0/24`, `10.0.12.0/24`
- Two `t3.micro` EC2 instances using AMI `ami-002192a70217ac181`
- Redis 7.0 on two `cache.t3.micro` cache nodes
- Seven days of Redis snapshot retention
- Encryption at rest and in transit enabled

## Repository Layout

```text
terraform-aws-redis-cache-module/
├── environments/
│   └── dev/                 # Deployable development environment
│       ├── main.tf          # Provider and module composition
│       └── output.tf        # Environment outputs
└── modules/
    ├── vpc/                 # VPC, subnets, routing, NAT
    ├── ec2/                 # Application instances and security group
    └── redis/               # ElastiCache Redis and security group
```

Each module exposes only the values required by the next layer. For example, the VPC module returns private subnet IDs; the EC2 module consumes them and returns its security-group ID; the Redis module uses both to restrict cache access to the app tier.

## Prerequisites

- Terraform 1.x
- An AWS account with permissions to create VPC, EC2, IAM-adjacent network resources, and ElastiCache resources
- AWS credentials configured locally, for example through `aws configure`, environment variables, or an AWS profile
- An EC2 key pair is **not** currently required because the configuration does not assign one. Use AWS Systems Manager Session Manager if you add the appropriate instance profile and access configuration.

Verify access before deploying:

```bash
terraform version
aws sts get-caller-identity
```

## Deploy

Run Terraform from the environment directory:

```bash
cd environments/dev
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
```

After a successful apply, view the values exported by the environment:

```bash
terraform output
```

Expected outputs:

- `vpc_id`
- `private_subnet_ids`
- `ec2_instance_ids`
- `redis_endpoint`

To remove the resources and stop further AWS charges:

```bash
terraform destroy
```

## How the Modules Work

### VPC module

The VPC module creates public and private subnets across the supplied Availability Zones. The public subnet route table directs internet-bound traffic through the internet gateway. Both private subnets use a NAT gateway in the first public subnet for outbound access.

### EC2 module

The EC2 module creates a security group and creates one instance per configured `instance_count`, choosing private subnets by index. The instance user data updates packages and writes a simple status file to `/tmp/app.txt`.

### Redis module

The Redis module creates an ElastiCache subnet group from the private subnets, then creates a Redis replication group with two cache nodes. Automatic failover and Multi-AZ are enabled. The Redis security group permits TCP `6379` only from the EC2 module's security group.

## Important Notes Before Production Use

This is a strong starting structure, but it needs several changes before being treated as a production deployment:

- The EC2 security group currently permits SSH (`22`) and application port (`8080`) from `0.0.0.0/0`. Restrict these rules to approved sources, an application load balancer security group, or remove SSH and use Session Manager.
- Private subnets do not give the EC2 instances public IPs. The open EC2 ingress rules are still unnecessarily broad and should be tightened.
- There is only one NAT gateway, in the first Availability Zone. This lowers cost but does not provide NAT egress high availability. Use one NAT gateway per Availability Zone for resilient production networking.
- The Amazon Linux AMI ID is hard-coded and is region-specific. Select the current approved AMI dynamically, such as via an SSM public parameter or a maintained data source.
- Add Terraform remote state with locking (for example, S3 plus DynamoDB or an equivalent supported backend) before team use. Do not commit local `terraform.tfstate` files.
- Add provider default tags, resource-specific tags, CloudWatch monitoring and alarms, VPC flow logs, backups/restore testing, and a CI pipeline that runs `fmt`, `validate`, and `plan`.
- Redis has TLS enabled. Client applications must use TLS when connecting to the exported endpoint on port `6379`.

## Cost Awareness

This deployment creates billable AWS resources, notably the NAT gateway, Elastic IP, EC2 instances, and ElastiCache nodes. Review current AWS pricing for `us-east-1`, use `terraform plan` before applying changes, and run `terraform destroy` when the environment is no longer needed.

## State and Sensitive Data

Terraform state can contain infrastructure metadata and should be protected. The repository ignores `*.tfstate`, `*.tfstate.*`, `*.tfvars`, and `.terraform/`. Keep state out of source control and store production state in an encrypted, access-controlled remote backend.

## Customization

Edit [`environments/dev/main.tf`](environments/dev/main.tf) to adjust the region, CIDR ranges, instance type/count, AMI, or Redis node type. The inputs expected by each module are defined in that module's `variable.tf`, and its reusable outputs are defined in `output.tf`.
