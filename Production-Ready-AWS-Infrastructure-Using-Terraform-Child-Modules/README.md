# 🌈 Production-Ready AWS Infrastructure with Terraform Child Modules

A polished Terraform sample that builds a reusable AWS stack using child modules for VPC, RDS, and EC2.

---

## 🚀 Project overview

This repository shows how to organize infrastructure with a root Terraform module that delegates cloud resources to smaller child modules.

The stack includes:

- **VPC network** with public and private subnets
- **RDS MySQL** database for application storage
- **EC2 application server** with secure access to the database

The design keeps networking, compute, and database concerns separated while still sharing values and security groups correctly.

---

## 🧠 Architecture at a glance

```text
Root module
  ├─ module.vpc        -> child-module/vpc
  │    ├─ VPC
  │    ├─ public subnets
  │    ├─ private subnets
  │    ├─ NAT gateway
  │    └─ security groups
  ├─ module.rds        -> child-module/databases
  │    └─ MySQL RDS instance
  └─ module.ec2        -> child-module/ec2
       └─ application EC2 instance
```

- The VPC module builds the private/public network and exposes subnet IDs + security group IDs.
- The RDS module consumes VPC subnet and DB security group information.
- The EC2 module consumes the app subnet and bastion security group.

---

## 🧩 What each module does

### `child-module/vpc`

Builds the AWS networking foundation:

- VPC
- Public and private subnets
- Internet Gateway
- NAT Gateway
- Security groups:
  - `bastion_sg_id`
  - `database_sg_id`

This module returns IDs so child modules can attach resources to the same network.

### `child-module/databases`

Deploys MySQL RDS using the VPC configuration and DB security group.

Outputs include:

- `endpoint`
- `reader_endpoint`
- `port`

### `child-module/ec2`

Launches an application EC2 instance with the correct network placement.

It uses:

- a public subnet ID for app access
- the bastion security group for SSH or application-level access
- database connection settings from the RDS module

---

## ⚡ Usage

1. Open a terminal in the root folder:

```bash
cd "d:/weekend task/Production-Grade-Terraform-DevOps-Tasks/Production-Ready-AWS-Infrastructure-Using-Terraform-Child-Modules"
```

2. Initialize Terraform:

```bash
terraform init
```

3. Validate the configuration:

```bash
terraform validate
```

4. Preview changes:

```bash
terraform plan
```

5. Apply the stack:

```bash
terraform apply -auto-approve
```

> If the workspace already has an existing Terraform state, run `terraform refresh` after adding new outputs so the state values are updated.

---

## 📤 Root outputs explained

The root `output.tf` exposes the most useful values after deployment.

- `rds_endpoint` — the primary endpoint for the MySQL database
- `rds_port` — database port, usually `3306`
- `app_server_id` — the created EC2 instance ID
- `app_server_private_ip` — private IP address of the application server
- `vpc_id` — the VPC ID created by the VPC module

These outputs are available with:

```bash
terraform output
```

---

## 🔐 Security and wiring notes

- The EC2 instance is intentionally attached to the **bastion security group**, not the database security group.
- The database security group is used only for the RDS instance.
- Use the VPC module outputs to avoid hard-coding subnet IDs or security group IDs across modules.

---

## 🛠️ Best practices

- Always keep credentials and AWS secrets out of `.tf` files.
- Use `terraform validate` before planning changes.
- If you update outputs after an existing apply, run `terraform refresh` so `terraform output` returns current values.
- Prefer module input/output wiring over direct resource references across modules.

---

## 📁 Folder structure

```text
child-module/
  ├─ ec2/
  ├─ databases/
  └─ vpc/
main.tf
output.tf
terraform.tfvars
variable.tf


