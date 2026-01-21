# Day 01 – Introduction to Terraform  
#30DaysOfAWSTerraform

## 📘 Blog Reference (Day 01)
A detailed explanation of my Day 01 learning is available here:

👉 https://medium.com/@ars0a/day-1-of-30-days-of-aws-terraform-understanding-the-basics-before-writing-code-3a854739a034

---

## Overview

Day 01 of the **30 Days of AWS Terraform** challenge focuses on understanding the fundamentals of Terraform and the concept of Infrastructure as Code (IaC).

This day is intentionally kept conceptual to build a strong mental model before provisioning real cloud infrastructure.

No AWS resources are created on Day 01.

---

## Objectives

- Understand what Terraform is and why it is used
- Learn the concept of Infrastructure as Code (IaC)
- Understand how Terraform works at a high level
- Learn the Terraform workflow and core commands
- Install Terraform on the local system

---

## What is Terraform?

Terraform is an Infrastructure as Code (IaC) tool used to define, create, and manage cloud infrastructure using configuration files instead of manual steps in the cloud console.

By describing infrastructure in code, Terraform enables:
- Automation of infrastructure provisioning
- Consistency across environments
- Easier infrastructure management and recovery

---

## Infrastructure as Code (IaC)

Infrastructure as Code (IaC) is the practice of managing infrastructure using code rather than manual configuration.

With IaC:
- Infrastructure becomes repeatable and predictable
- Changes can be tracked using version control
- Environments such as dev, staging, and production remain consistent

Terraform is one of the most widely adopted tools for implementing IaC.

---

## Cloud-Agnostic Nature of Terraform

Terraform is cloud-agnostic, meaning it can work with multiple cloud providers such as:
- Amazon Web Services (AWS)
- Microsoft Azure
- Google Cloud Platform (GCP)

Terraform achieves this through the use of **providers**.

---

## Providers

Providers act as a bridge between Terraform and cloud platforms.

Examples:
- AWS provider
- Azure provider
- GCP provider

Providers translate Terraform configuration into cloud-specific API calls.

---

## How Terraform Works

Terraform follows a **declarative approach**.  
Instead of defining step-by-step instructions, users describe the desired state of infrastructure.

Terraform then:
- Compares the desired state with the current state
- Determines the required changes
- Applies those changes in the correct order

Terraform also maintains a **state file**, which tracks the resources managed by Terraform and helps determine what needs to be updated, created, or removed.

---

## Terraform Workflow

Every Terraform project follows a standard workflow:

1. **terraform init**  
   Initializes the working directory and downloads required provider plugins.

2. **terraform plan**  
   Shows a preview of changes Terraform will make without applying them.

3. **terraform apply**  
   Applies the configuration and provisions or updates infrastructure.

---

## Terraform Installation

### Installation on Ubuntu / Debian

```bash
sudo apt update
sudo apt install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform
```

#### Verify installation

```bash
terraform -version
```

### Installation on macOS
Using Homebrew:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```
#### Verify Installation

```bash
terraform -version
```

## Sample Terraform Configuration 
```bash
provider "aws" {
  region = "us-east-1"
}
```
This configuration specifies AWS as the provider and defines the region where resources will be created.

** Key Learnings from Day 01 **

- Terraform manages cloud infrastructure using code

- Infrastructure as Code improves reliability and repeatability

- Providers enable Terraform to interact with cloud platforms

- The Terraform workflow (init, plan, apply) is fundamental

- Day 01 focuses on concepts rather than provisioning resources

### Challenge Reference

This work is part of the 30 Days of AWS Terraform challenge by Piyush Sachdeva.