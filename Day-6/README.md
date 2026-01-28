# 📘 Day 6 – Terraform Modules & Code Organization #

#30DaysOfTerraform

Blog Link: [Click Here](https://medium.com/@ars0a/day-6-of-30daysofterraform-thinking-in-modules-not-files-d926a0e5a4bc)

---

## Overview ##

Day 6 focuses on structuring Terraform projects properly using modules.
Instead of writing all resources in a single file, we split the configuration into reusable, logical components.

**This day introduces:**

- Terraform modules

- Clean project structure

- Separation of concerns using main.tf, variables.tf, locals.tf, etc.

- Reusable infrastructure design

- By the end of Day 6, Terraform stops feeling like a script and starts feeling like real Infrastructure Engineering.


## Project Structure ##

```bash

Day-6/
├── main.tf
├── variables.tf
├── locals.tf
├── outputs.tf
├── providers.tf
├── README.md
└── modules/
    └── vpc/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf

```

## 🧠 What Are Terraform Modules? ##

A Terraform module is simply a folder containing Terraform files.

**Modules allow:**

- Reusability

- Cleaner code

- Environment isolation

- Team collaboration

- You write infrastructure once, then reuse it everywhere.

---

## 🔧 Root Module Files (Day-6) ##

[providers.tf](Day-6/providers.tf)


[variables.tf](Day-6/variables.tf)


[locals.tf](Day-6/locals.tf)

**Why locals?**

- Avoid repeated values

- Centralize shared logic 

- Safer refactoring


[main.tf](Day-6/main.tf)

This is where composition happens.
The root module orchestrates infrastructure using child modules.


[output.tf](Day-6/output.tf)

Outputs expose useful data to users or automation.


## 🧩 VPC Module (modules/vpc) ##

`modules/vpc/variables.tf`

```hcl
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the VPC"
  type        = map(string)
}
```

---

`modules/vpc/main.tf`

```hcl
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = var.tags
}
```

The module does one thing well: create a VPC.

---

`modules/vpc/outputs.tf`

```hcl
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}
```
This allows other modules or the root module to consume the VPC.

---


## ▶️ How to Run This Project ##

```bash
terraform init
terraform validate
terraform plan -var="vpc_cidr=10.0.0.0/16" -var="environment=dev"
terraform apply
```

To Destroy

```bash
terraform destroy
```
---

## 🧠 Key Learnings from Day 6 ## 

1. Modules introduce structure and reusability
Infrastructure logic is written once and reused safely.

2. Inputs and outputs define clean interfaces
Modules behave like functions in software engineering.

3. Root modules orchestrate, child modules implement
This separation keeps Terraform scalable and readable.

---

## 🔑 Takeaway ##

Day 6 marks the transition from writing Terraform to engineering infrastructure.

Once you adopt modules:

- Code duplication disappears

- Changes become safer

- Terraform scales with your projects

- This is the foundation of production-grade Terraform.


