# Day 03 – AWS VPC & S3 using Terraform 

#30DaysOfTerraform

Day 3 focused on building AWS infrastructure using Terraform while understanding how Terraform behaves in real-world failure and recovery scenarios.

---

**Blog Link** [Click here](https://medium.com/@ars0a/day-3-of-terraform-when-infrastructure-becomes-predictable-7a947d96c26a)

---

## 📌 Overview

On Day 3, I worked with Terraform to provision AWS resources and, more importantly, learned how Terraform handles state, partial failures, and infrastructure updates.

**This day covered:**

- Creating AWS resources using Terraform

- Debugging real Terraform errors

- Understanding state-driven infrastructure changes

- Applying best practices for safe and repeatable deployments

---

## 🏗️ Infrastructure Created

- ✅ AWS VPC

- ✅ Private S3 Bucket

- ✅ Dynamic S3 bucket naming using random_id

- ✅ Updated existing infrastructure using Terraform state

---

## 🛠️ Terraform Stack

**Provider:** 

- `AWS`

**Resources:**

- `aws_vpc`

- `aws_s3_bucket`

- `random_id`

- `Region: us-east-1`

---

## Project Structure

```bash
Day-3/
├── main.tf
├── README.md
├── .terraform/
├── .terraform.lock.hcl
└── terraform.tfstate
```

---

## 🧠 Key Learnings

### 1. Terraform Workflow (Non-Negotiable)

The correct workflow followed throughout the day:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
```
---

**Why this matters:**

- Prevents unexpected changes

- Catches errors early

- Makes infrastructure changes predictable

--- 

### 2. Terraform State Is the Source of Truth

- Terraform tracks infrastructure using a state file
- State updates only after a successful `terraform apply`
- Terraform never rolls back automatically
- Partial failures are expected and safe


---

**Example learned:**

- VPC created successfully

- S3 bucket failed due to name conflict

- Terraform state updated only with VPC

- Next apply resumed from the failed resource

---

### 3. S3 Bucket Name Collision (Global Namespace)

**S3 bucket names are:**

- 🌍 Globally unique

- ❌ Unsafe to hardcode

**Solution used:**

```hcl
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "example" {
  bucket = "aditya-tf-day3-${random_id.suffix.hex}"
}

```
This approach permanently avoids bucket name conflicts.

---

### 4. Updating Existing Resources Safely

Terraform can update infrastructure in place.

Example:

- Added tags to an existing VPC

- No destroy or recreation required

Process:

```bash
terraform plan
terraform apply
```
Terraform detected the drift and updated only what changed.

---

### 5. Common Errors Faced & Resolved

Real errors encountered and fixed:

-  No changes. Infrastructure matches configuration

-  Missing provider error

-  S3 BucketAlreadyExists error

-  Inconsistent dependency lock file

-  Partial state confusion

Each issue was resolved by:

-  Trusting terraform plan

-  Re-running terraform init when required

-  Managing state correctly

-  Avoiding hardcoded global names

---

### 🧨 Destroying Infrastructure

To clean up all Terraform-managed resources:

```hcl
terraform destroy
```

- Destroys only what exists in the state file

- Prevents unexpected AWS charges

- Leaves configuration files untouched

---

### ✅ Best Practices Followed

- Always ran `terraform plan` before apply

- Avoided manual state changes

- Used dynamic naming for global resources

- Applied incremental changes

- Destroyed infrastructure after testing

---

### 🔑 Key Takeaway

Day 3 was not just about provisioning AWS resources.

It was about learning:

How Terraform thinks

- How state controls infrastructure

- How to recover safely from failures

- How real infrastructure debugging works

This foundation is essential before moving into modules and production-grade Terraform.



