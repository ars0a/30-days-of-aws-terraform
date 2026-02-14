# Day 22: 2-Tier AWS Architecture with Terraform

Blog: [click here:][https://medium.com/@ars0a/building-my-first-secure-2-tier-aws-web-application-with-terraform-a-beginners-journey-through-e54bf5d8db63]

## Overview

Day-22 contains Terraform code to provision a secure 2-tier architecture on AWS. It sets up a custom VPC with public and private subnets, deploys a Flask web application on an EC2 instance in the public subnet, and connects it to a MySQL RDS database in private subnets. The setup emphasizes security best practices, modular design, and automated deployment.

The project is part of my #30DaysOfTerraform challenge, where I'm learning Cloud and DevOps hands-on. I built this step by step, incorporating lessons from mistakes like missing route table associations and hardcoded credentials.

**Key features:**

- Custom VPC for network isolation
- Public subnet for EC2 (web tier)
- Two private subnets for RDS (database tier, Multi-AZ compliant)
- Internet Gateway and route tables for public access
- Security groups for layered isolation (web allows HTTP from anywhere; DB only from web SG)
- AWS Secrets Manager for random password generation and secure storage
- Modular Terraform structure with outputs for dependency management
- EC2 user data script to deploy Flask app, including DB connection retries and systemd service
- Flask endpoints: /health for DB check, /db-info for database details, and /post for message insertion

This mimics real-world DevOps setups: infrastructure as code, secure by default, and application-integrated.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         VPC (10.0.0.0/16)                   │
│  ┌─────────────────────┐   ┌─────────────────────────────┐  │
│  │   Public Subnet     │   │     Private Subnets         │  │
│  │   (10.0.1.0/24)     │   │  (10.0.2.0/24, 10.0.3.0/24) │  │
│  │                     │   │                             │  │
│  │  ┌───────────────┐  │   │    ┌──────────────────┐     │  │
│  │  │  EC2 (Flask)  │──│───│───►│   RDS MySQL      │     │  │
│  │  │  Web Server   │  │   │    │   Database       │     │  │
│  │  └───────────────┘  │   │    └──────────────────┘     │  │
│  └─────────────────────┘   └─────────────────────────────┘  │
│           │                                                  │
│           ▼                                                  │
│  ┌─────────────────┐                                        │
│  │ Internet Gateway│                                        │
│  └─────────────────┘                                        │
└─────────────────────────────────────────────────────────────┘
           │
           ▼
      Internet (Users)
    
```

## Project Structure

```
.
├── main.tf               # Root module orchestrating everything
├── variables.tf          # Global variables
├── outputs.tf            # Root-level outputs (e.g., EC2 public DNS, RDS endpoint)
├── modules/
│   ├── vpc/
│   │   ├── main.tf       # VPC, subnets, IGW, route tables
│   │   ├── variables.tf
│   │   └── outputs.tf    # Exports subnet IDs, VPC ID
│   ├── security_groups/
│   │   ├── main.tf       # Web and DB security groups
│   │   ├── variables.tf
│   │   └── outputs.tf    # Exports SG IDs
│   ├── secrets/
│   │   ├── main.tf       # Random password and Secrets Manager
│   │   ├── variables.tf
│   │   └── outputs.tf    # Exports DB password (sensitive)
│   ├── rds/
│   │   ├── main.tf       # RDS instance and subnet group
│   │   ├── variables.tf
│   │   └── outputs.tf    # Exports DB endpoint
│   └── ec2/
│       ├── main.tf       # EC2 instance with dynamic AMI
│       ├── variables.tf
│       ├── outputs.tf    # Exports instance public DNS
│       └── templates/
│           └── user_data.sh.tpl  # Templated user data script
└── README.md             # This file
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- An AWS account with permissions to create VPC, EC2, RDS, and Security Group resources

## Usage

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

### 3. Deploy the Infrastructure

```bash
terraform apply
```

### 4. Access the Application

After deployment, Terraform will output the application URL. Open it in your browser:

```bash
# Get the application URL
terraform output application_url
```

The Flask application has three endpoints:
- `/` - Home page
- `/health` - Database connectivity health check
- `/db-info` - Database information

### 5. Clean Up

```bash
terraform destroy
```

## Configuration

You can customize the deployment by creating a `terraform.tfvars` file:

```hcl
# Copy from terraform.tfvars.example
project_name = "my-rds-project"
environment  = "dev"
aws_region   = "us-west-2"

# Database settings
db_name     = "myappdb"
db_username = "admin"
db_password = "YourSecurePassword123!"  # Use a strong password!
```

## Modules

### VPC Module
Creates the network infrastructure including VPC, subnets, internet gateway, and route tables.

### Security Groups Module
Creates security groups for:
- **Web Server**: Allows HTTP (80) and SSH (22) from anywhere
- **Database**: Allows MySQL (3306) only from the web server security group

### RDS Module
Deploys a MySQL RDS instance in private subnets with a DB subnet group.

### EC2 Module
Deploys an Ubuntu EC2 instance with:
- Flask web application
- MySQL client for database connectivity
- Systemd service for application management

## Security Notes

⚠️ **Important Security Considerations:**

1. The default password in `variables.tf` is for demo purposes only. Always use strong, unique passwords in production.
2. SSH access is open to the world (0.0.0.0/0). Restrict this to your IP in production.
3. Consider using AWS Secrets Manager for database credentials in production.
4. Enable RDS encryption for production workloads.

## Troubleshooting

1. **Application not responding**: Wait 2-3 minutes after deployment for EC2 user data script to complete.
2. **Database connection errors**: Verify security group rules and ensure RDS is in `available` state.
3. **RDS creation slow**: RDS instances typically take 5-10 minutes to provision.

## Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | ID of the created VPC |
| `web_server_public_ip` | Public IP of the EC2 instance |
| `web_server_public_dns` | Public DNS of the EC2 instance |
| `application_url` | URL to access the Flask application |
| `rds_endpoint` | RDS instance endpoint |
| `rds_port` | RDS instance port |
| `database_name` | Name of the database |
