# Terraform DevOps Project

AWS infrastructure provisioned with Terraform modules - VPC, EC2, Security Groups with S3 remote state and DynamoDB locking.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [How It Works](#how-it-works)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Remote State](#remote-state)
- [Screenshots](#screenshots)

---

## Overview

This project demonstrates production-grade Infrastructure as Code (IaC) using Terraform to provision a complete AWS environment. The infrastructure is broken into reusable modules following industry best practices — separating networking, compute, and security concerns. Remote state is stored in S3 with DynamoDB locking to enable safe team collaboration.

---

## Architecture

```
                    ┌─────────────────────────────────────┐
                    │           AWS VPC (10.0.0.0/16)      │
                    │                                       │
                    │  ┌─────────────────────────────────┐ │
                    │  │     Public Subnet (10.0.1.0/24) │ │
                    │  │                                 │ │
                    │  │  ┌──────────────────────────┐  │ │
                    │  │  │      EC2 Instance         │  │ │
                    │  │  │      (t2.micro)           │  │ │
                    │  │  │      Ubuntu 22.04         │  │ │
                    │  │  └──────────────────────────┘  │ │
                    │  └─────────────────────────────────┘ │
                    │                                       │
                    │  Internet Gateway ──► Route Table     │
                    │  Security Group (SSH, HTTP, HTTPS)    │
                    └─────────────────────────────────────┘
                                      │
                    ┌─────────────────┴─────────────────┐
                    │         Remote State Storage        │
                    │   S3 Bucket + DynamoDB Lock Table   │
                    └───────────────────────────────────┘
```

---

## Features

- Modular Terraform structure — VPC, EC2, and Security modules
- Remote state storage in AWS S3
- State locking with DynamoDB to prevent concurrent apply conflicts
- Dynamic AMI lookup — always uses latest Ubuntu 22.04
- Fully tagged resources for easy identification
- Clean separation of variables, outputs, and resources per module
- Single command provisioning and destruction

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| Terraform v1.14.8 | Infrastructure as Code |
| AWS Provider v5.x | AWS resource management |
| Amazon EC2 | Compute instance |
| Amazon VPC | Network isolation |
| Amazon S3 | Remote state storage |
| Amazon DynamoDB | State locking |
| GitHub | Version control |

---

## Project Structure

```
terraform-devops-project/
├── main.tf                    # Root module — calls all child modules
├── variables.tf               # Input variable declarations
├── outputs.tf                 # Output values displayed after apply
├── .gitignore                 # Excludes sensitive and generated files
├── .terraform.lock.hcl        # Provider version lock file
└── modules/
    ├── vpc/
    │   ├── main.tf            # VPC, Subnet, IGW, Route Table
    │   ├── variables.tf       # VPC module inputs
    │   └── outputs.tf         # Exports vpc_id, public_subnet_id
    ├── security/
    │   ├── main.tf            # Security Group (SSH, HTTP, HTTPS)
    │   ├── variables.tf       # Security module inputs
    │   └── outputs.tf         # Exports security_group_id
    └── ec2/
        ├── main.tf            # EC2 instance with dynamic AMI lookup
        ├── variables.tf       # EC2 module inputs
        └── outputs.tf         # Exports instance_id, public_ip
```

---

## How It Works

The root `main.tf` acts as the orchestrator — it calls each module in the correct order and passes outputs from one module as inputs to the next:

1. **VPC module** creates the network foundation and outputs `vpc_id` and `public_subnet_id`
2. **Security module** receives `vpc_id` from the VPC module and creates a security group, outputting `security_group_id`
3. **EC2 module** receives `subnet_id` and `security_group_id` from the previous modules and provisions the instance

This dependency chain means Terraform automatically understands the correct order to create resources.

---

## Prerequisites

- Terraform v1.0+ installed
- AWS CLI installed and configured (`aws configure`)
- AWS account with appropriate IAM permissions
- S3 bucket for remote state (see Remote State section)
- DynamoDB table for state locking (see Remote State section)

---

## Usage

**Clone the repository:**
```bash
git clone https://github.com/isaacambi/terraform-devops-project.git
cd terraform-devops-project
```

**Create the S3 bucket for remote state:**
```bash
aws s3api create-bucket --bucket devops-terraform-state-isaac --region us-east-1
```

**Create the DynamoDB table for state locking:**
```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

**Initialise Terraform:**
```bash
terraform init
```

**Preview the infrastructure plan:**
```bash
terraform plan
```

**Apply the infrastructure:**
```bash
terraform apply
```

**Destroy the infrastructure when done:**
```bash
terraform destroy
```

---

## Remote State

This project uses remote state stored in AWS S3 with DynamoDB locking configured in the root `main.tf` backend block:

```hcl
backend "s3" {
  bucket         = "devops-terraform-state-isaac"
  key            = "dev/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-state-lock"
}
```

**Why remote state?**
- State is backed up and never lost if a local machine fails
- Multiple engineers can safely collaborate on the same infrastructure
- DynamoDB locking prevents two engineers from running `terraform apply` simultaneously which could corrupt the state file

---

## Outputs

After a successful `terraform apply` the following values are displayed:

| Output | Description |
|--------|-------------|
| `vpc_id` | ID of the created VPC |
| `instance_id` | ID of the EC2 instance |
| `public_ip` | Public IP address of the EC2 instance |

---

## Screenshots

> Screenshots are located in the `/screenshots` folder of this repository.

| Screenshot | Description |
|------------|-------------|
| `terraform-init.png` | Successful terraform init output |
| `terraform-plan.png` | Plan showing 7 resources to add |
| `terraform-apply.png` | Apply complete — 7 resources created |
| `ec2-console.png` | EC2 instance running in AWS console |
| `terraform-destroy.png` | Destroy complete — 7 resources destroyed |
| `s3-state.png` | Terraform state file stored in S3 |
| `dynamodb-table.png` | DynamoDB lock table in AWS console |

---

## Author

Isaac Ambi Abraham — Senior DevOps Engineer
[GitHub](https://github.com/isaacambi) | [LinkedIn](https://www.linkedin.com/in/isaac-ambi-012b75135/)
