# Day 14: Hosting a Static Website with S3 and CloudFront Using Terraform

Welcome to Day 14 of #30DaysOfTerraform 👋

Up to Day 13, the focus was on individual Terraform concepts. We explored data sources and learned how Terraform can fetch and reuse information from AWS dynamically, helping keep configurations clean and reusable.

From Day 14 onward, the journey shifts toward real mini-projects.

This day marks the beginning of applying Terraform concepts to something tangible:
hosting a static website using Amazon S3 and CloudFront, fully automated with Terraform.

Blog Link [click here]()

---

## 📌 What We’re Building

In this project, we build a secure and globally distributed static website with:

Amazon S3 – to store website files

Amazon CloudFront – to serve content globally and securely

Terraform – to provision and manage everything as code

Many of us may have done this manually through the AWS Console before. Doing it with Terraform shows how infrastructure can be reproducible, version-controlled, and automated.

---

## 🤔 Why Use S3 and CloudFront Together?

Before writing any Terraform code, it’s important to understand the architecture.

**Challenges with a Public S3 Website**

- Performance: Users far from the S3 region experience slower load times

- Cost: Data transfer costs increase with distance

- Security: Public buckets expose content directly to the internet

**How CloudFront Solves This**

CloudFront acts as a CDN (Content Delivery Network):

- Content is cached at edge locations close to users

- Requests are served faster with lower latency

- The S3 bucket remains private

- Cached content reduces load and cost on S3

Each cached object follows a TTL (Time To Live) policy, meaning repeated requests are served locally until the cache expires.

Together, S3 + CloudFront provide a secure, fast, and cost-efficient global website.

---


### 🛠️ Step 1: Creating a Private S3 Bucket

We start by creating an S3 bucket to store all website files.

```hcl 
resource "aws_s3_bucket" "day_14_demo_bucket" {
  bucket_prefix = "day-14-demo-${var.bucket_prefix}"
}
```
To ensure the bucket is not publicly accessible, we explicitly block public access:
```hcl
resource "aws_s3_bucket_public_access_block" "day_14_demo" {
  bucket = aws_s3_bucket.day_14_demo_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```
Why this matters

- Keeps the bucket private

- Prevents accidental public exposure

- Forces all access to go through CloudFront

---

### 🔐 Step 2: Origin Access Control (OAC)

CloudFront needs permission to read files from the private S3 bucket.
We achieve this using Origin Access Control (OAC).

```hcl
resource "aws_cloudfront_origin_access_control" "day_14_demo_oac" {
  name                              = "day-14-demo-oac"
  description                       = "OAC for Day-14 demo static website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
```
This ensures:

- CloudFront authenticates requests using AWS SigV4
- Direct access to S3 is blocked

---

### 📜 Step 3: S3 Bucket Policy for CloudFront

Next, we attach a bucket policy that allows only CloudFront to read objects.

```hcl
resource "aws_s3_bucket_policy" "day_14_demo_policy" {
  bucket = aws_s3_bucket.day_14_demo_bucket.id

  depends_on = [
    aws_s3_bucket_public_access_block.day_14_demo,
    aws_cloudfront_distribution.day_14_demo_distribution
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowCloudFrontAccess"
        Effect   = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = ["s3:GetObject"]
        Resource = ["${aws_s3_bucket.day_14_demo_bucket.arn}/*"]
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.day_14_demo_distribution.arn
          }
        }
      }
    ]
  })
}
```
This guarantees that:

- The bucket stays private

- Only the specific CloudFront distribution can fetch objects

---

### 📂 Step 4: Uploading Website Files to S3

Terraform can also manage file uploads.
All static files are stored in a local www/ directory and uploaded automatically.
```hcl
resource "aws_s3_object" "day_14_demo_files" {
  for_each = fileset("${path.module}/www", "**/*")

  bucket = aws_s3_bucket.day_14_demo_bucket.id
  key    = each.value
  source = "${path.module}/www/${each.value}"
  etag   = filemd5("${path.module}/www/${each.value}")

  content_type = lookup({
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    json = "application/json"
    png  = "image/png"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    gif  = "image/gif"
    svg  = "image/svg+xml"
    ico  = "image/x-icon"
    txt  = "text/plain"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}
```
What this does

- Loops through all files in www/
- Uploads each file to S3
- Sets correct content-type
- Automatically detects file changes using etag

---

### 🌍 Step 5: Creating the CloudFront Distribution

CloudFront is responsible for delivering content securely and globally.
```hcl
resource "aws_cloudfront_distribution" "day_14_demo_distribution" {
  origin {
    domain_name              = aws_s3_bucket.day_14_demo_bucket.bucket_regional_domain_name
    origin_id                = "day-14-demo-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.day_14_demo_oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "day-14-demo-s3-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
```
Key points

- HTTPS enforced automatically
- Cached content improves performance
- PriceClass_100 helps reduce cost
- Users never access S3 directly

---

### 📤 Step 6: Terraform Outputs

Terraform outputs expose important values after deployment.
```hcl
output "day_14_demo_website_url" {
  description = "CloudFront URL for the Day-14 demo website"
  value       = "https://${aws_cloudfront_distribution.day_14_demo_distribution.domain_name}"
}

output "day_14_demo_cloudfront_distribution_id" {
  description = "CloudFront distribution ID for Day-14 demo"
  value       = aws_cloudfront_distribution.day_14_demo_distribution.id
}

output "day_14_demo_s3_bucket_name" {
  description = "S3 bucket name for Day-14 demo"
  value       = aws_s3_bucket.day_14_demo_bucket.bucket
}
```

These outputs give:

- Live website URL
![Live webpage](https://private-user-images.githubusercontent.com/143114287/543306423-c04c8bdd-0a8c-42c4-aaa9-7c499125178f.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3Njk4ODA0NDEsIm5iZiI6MTc2OTg4MDE0MSwicGF0aCI6Ii8xNDMxMTQyODcvNTQzMzA2NDIzLWMwNGM4YmRkLTBhOGMtNDJjNC1hYWE5LTdjNDk5MTI1MTc4Zi5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjYwMTMxJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI2MDEzMVQxNzIyMjFaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1jNmNiZjE2MGNmYThmZTM5YzZkNmE4ZjA5MDNhNTFmZTM3ODAyYWY0NTVkZWUzZDc4YmViNTRiNDc1ZDNjNjQ1JlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.sn-18dqeYkBo8PpXDn15PU-jzvemfv32-larUehgI_E)

---
![ive webpage](https://private-user-images.githubusercontent.com/143114287/543306422-b52aea87-9508-4884-91a3-3de9dea07898.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3Njk4ODA0NDEsIm5iZiI6MTc2OTg4MDE0MSwicGF0aCI6Ii8xNDMxMTQyODcvNTQzMzA2NDIyLWI1MmFlYTg3LTk1MDgtNDg4NC05MWEzLTNkZTlkZWEwNzg5OC5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjYwMTMxJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI2MDEzMVQxNzIyMjFaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1iMjc2ZWEzMzg1OGRhMDEzYmIzYTc0ZDk5OGEzMzBiZjJhMDc1ZmUzMDAyMWExYjViNTVlNWVjMzllODQ0NjNiJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.XDXad_GZQMfUEo390ceha22039hJR3EdCD4wfs-Kjfc)

---

- CloudFront distribution ID
![CloudFront ID](https://private-user-images.githubusercontent.com/143114287/543306787-67143752-5397-4d47-9688-72cd23ce63d8.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3Njk4ODA5ODQsIm5iZiI6MTc2OTg4MDY4NCwicGF0aCI6Ii8xNDMxMTQyODcvNTQzMzA2Nzg3LTY3MTQzNzUyLTUzOTctNGQ0Ny05Njg4LTcyY2QyM2NlNjNkOC5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjYwMTMxJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI2MDEzMVQxNzMxMjRaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT01YTA1ZjBiOGI2MWE5M2VjOTBmOTNkY2FjODFlZTQ3ZTBiNzliYmVhMGZkZjk5MTU3YTJjODJiNjE1MmE3MTBjJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.Ese26KPyDxuhOKf0_q_5XEesEsegsjym_a7oSnrx6OA)

---

- Private S3 bucket name
![S3 Bucket name](https://private-user-images.githubusercontent.com/143114287/543306786-4c2c4321-5d5a-4611-b02b-50098b1a86a2.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3Njk4ODA5ODQsIm5iZiI6MTc2OTg4MDY4NCwicGF0aCI6Ii8xNDMxMTQyODcvNTQzMzA2Nzg2LTRjMmM0MzIxLTVkNWEtNDYxMS1iMDJiLTUwMDk4YjFhODZhMi5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjYwMTMxJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI2MDEzMVQxNzMxMjRaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT04ZmE0ZjZkZTMwZTI3MTM5ZGU2MDYyYjNiZmU1MjNiMDY0ZDE3MjI3NDU5NjI1NWVkN2ExYzEyMmRjMzFmZGZiJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.gJs5_fDYZT0GNV4qsNZ56fxzzuAv6Y2ghpeMt7eg6wM)
---

### ✅ Conclusion

Day 14 marks the first end-to-end demo project in this Terraform journey.

We successfully:

- Created a private S3 bucket

- Secured access using CloudFront OAC

- Uploaded static files via Terraform

- Delivered content globally using CloudFront

- This project ties together many concepts learned so far and sets the foundation for more advanced Terraform projects ahead.