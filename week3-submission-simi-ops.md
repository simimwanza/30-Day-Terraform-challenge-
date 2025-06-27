# Week 3 Submission - Days 10-16

## Participant Information
- **GitHub Username:** simi-ops
- **Week Number:** 3
- **Target Branch:** week3
- **Days Completed:** Days 10-16
- **Check-in Attendance:** Yes

## Submissions Overview

### Day 10
- **Topic:** Terraform Loops and Conditionals
- **Key Learnings:**
  - Mastered `count` and `for_each` for dynamic resource creation
  - Implemented conditional logic for environment-specific deployments
  - Created modular approach with ALB, EC2, and Security Group modules
- **Resources Created:**
  - Application Load Balancer with conditional health checks
  - EC2 instances with environment-specific configurations
  - Security Groups with dynamic rules
  - S3 bucket and DynamoDB table for state management
- **File Structure:**
  ```
  Day10/
  ├── terraform/
  │   ├── main.tf
  │   ├── variables.tf
  │   ├── backend.tf
  │   ├── deploy.sh
  │   ├── environments/
  │   │   ├── dev/exampletfvars
  │   │   ├── staging/exampletfvars
  │   │   └── production/exampletfvars
  │   └── modules/
  │       ├── alb/
  │       ├── ec2/
  │       └── security_group/
  ├── architecture/web-server.png
  └── day10-SimiMwanza.md
  ```
- **Testing Completed:**
  - [x] `terraform init` successful
  - [x] `terraform plan` shows expected changes
  - [x] `terraform apply` completed without errors
  - [x] `terraform destroy` cleaned up all resources
- **Blog Post:** [How Loops and Conditionals Simplify Infrastructure as Code with Terraform](https://simiops.hashnode.dev/how-loops-and-conditionals-simplify-infrastructure-as-code-with-terraform?showSharer=true)
- **Social Media:** [Twitter Post](https://x.com/simi_mwanza/status/1931811337828475098)

### Day 11
- **Topic:** Terraform Conditionals
- **Key Learnings:**
  - Advanced conditional logic for dynamic infrastructure deployment
  - Environment-specific resource configurations
  - Cost optimization through conditional resource deployment
- **Resources Created:**
  - Environment-specific instance types and counts
  - Conditional EBS volumes for staging/production
  - Dynamic security group rules based on environment
- **Blog Post:** [Mastering Terraform Conditionals for Dynamic Infrastructure](https://simiops.hashnode.dev/mastering-terraform-conditionals-for-dynamic-infrastructure?showSharer=true)
- **Social Media:** [Twitter Post](https://x.com/simi_mwanza/status/1934580430474473849)

### Day 12
- **Topic:** Zero-Downtime Deployment with Terraform
- **Key Learnings:**
  - Implemented Auto Scaling Groups with Launch Templates
  - Rolling instance refresh for zero-downtime updates
  - Blue/green deployment strategies
- **Resources Created:**
  - Auto Scaling Group with 3-6 instances (production)
  - Launch Templates with `create_before_destroy = true`
  - Application Load Balancer with health checks
  - CloudWatch alarms for auto-scaling policies
- **File Structure:**
  ```
  Day12/
  ├── terraform/
  │   ├── modules/
  │   │   ├── asg/ (NEW)
  │   │   ├── alb/
  │   │   ├── ec2/
  │   │   └── security_group/
  │   └── [other files]
  ```
- **Blog Post:** [How to implement blue green deployments with terraform for zero downtime](https://simiops.hashnode.dev/how-to-implement-bluegreen-deployments-with-terraform-for-zero-downtime?showSharer=true)
- **Social Media:** [Twitter Post](https://x.com/simiOps/status/1938551753974157316)

### Day 13
- **Topic:** Managing Sensitive Data in Terraform
- **Key Learnings:**
  - AWS Secrets Manager integration for encrypted secret storage
  - IAM role-based access control with principle of least privilege
  - Sensitive data masking in Terraform state files
- **Resources Created:**
  - AWS Secrets Manager secrets with KMS encryption
  - IAM roles and policies for secure secret access
  - Instance profiles for EC2 secret retrieval
- **File Structure:**
  ```
  Day13/
  ├── terraform/
  │   ├── modules/
  │   │   ├── secrets/ (NEW)
  │   │   └── [existing modules]
  │   ├── SECURITY.md
  │   └── .gitignore
  ```
- **Blog Post:** [How to Handle Sensitive Data Securely in Terraform](https://simiops.hashnode.dev/how-to-handle-sensitive-data-securely-in-terraform)
- **Social Media:** [Twitter Post](https://x.com/simiOps/status/1938574976019230970)

### Day 14
- **Topic:** Working with Multiple Providers - Part 1
- **Key Learnings:**
  - Multiple AWS provider configuration with aliases
  - Multi-region deployment strategies
  - Provider-specific resource targeting
- **Resources Created:**
  - Primary and backup region deployments
  - Region-specific AMI data sources
  - Independent secrets management per region
- **Blog Post:** [Managing Multi-Region Deployments with Terraform Providers](https://simiops.hashnode.dev/managing-multi-region-deployments-with-terraform-providers)
- **Social Media:** [Twitter Post](https://x.com/simiOps/status/1938591317191242128)

### Day 15
- **Topic:** Working with Multiple Providers - Part 2
- **Key Learnings:**
  - Docker containerization integration with Terraform
  - Multi-cloud infrastructure deployment
  - Container health monitoring and auto-restart
- **Resources Created:**
  - Docker containers with `simimwanza/simi-ops` image
  - Automated health checks and restart policies
  - Container deployment scripts
- **File Structure:**
  ```
  Day15/
  ├── deploy-docker.sh
  ├── update-docker-instances.sh
  ├── validate-deployment.sh
  ├── DOCKER_DEPLOYMENT.md
  └── terraform/
      └── modules/ec2/docker_user_data.sh (NEW)
  ```
- **Blog Post:** [Deploying Multi-Cloud Infrastructure with Terraform Modules](https://simiops.hashnode.dev/deploying-multi-cloud-infrastructure-with-terraform-modules)
- **Social Media:** [Twitter Post](https://x.com/simiOps/status/1938640628478329340)

### Day 16
- **Topic:** Building Production-Grade Infrastructure
- **Key Learnings:**
  - Production-grade module organization and versioning
  - Terratest framework for automated testing
  - Comprehensive automation with Makefiles
- **Resources Created:**
  - Production modules v2.0.0 with semantic versioning
  - Terratest unit tests for ALB module
  - Makefile for standardized operations
  - Comprehensive module documentation
- **File Structure:**
  ```
  Day16/
  ├── Makefile
  ├── tests/
  │   ├── go.mod
  │   └── alb_test.go
  └── terraform/
      ├── versions.tf
      ├── locals.tf
      ├── outputs.tf
      └── modules/
          ├── alb/ (v2.0.0 with README.md, versions.tf)
          ├── asg/ (v2.0.0 with README.md, versions.tf)
          └── security_group/ (v2.0.0 with README.md, versions.tf)
  ```
- **Blog Post:** [Creating Production-Grade Infrastructure with Terraform](https://simiops.hashnode.dev/creating-production-grade-infrastructure-with-terraform)
- **Social Media:** [Twitter Post](https://x.com/simiOps/status/1938720880927866887)

## Weekly Check-in Details
- **Date:** 2025-06-12
- **Time:** 6:00 PM EAT
- **Meeting Link:** [Shared in WhatsApp group]
- **Preparation Completed:**
  - [x] Reviewed this week's tasks and progress
  - [x] Prepared questions for discussion
  - [x] Updated progress tracking files
  - [x] Reviewed other participants' PRs
  - [x] Ready to demo production-grade infrastructure solutions

## Code Quality Requirements
- **Security:**
  - [x] No hardcoded credentials
  - [x] Using variables for sensitive data
  - [x] Implemented proper IAM roles/policies
  - [x] Security groups properly configured
  - [x] AWS Secrets Manager integration
  - [x] Encrypted volumes in production
- **Best Practices:**
  - [x] Code is properly formatted (`terraform fmt`)
  - [x] Code passes validation (`terraform validate`)
  - [x] Resources have proper tags
  - [x] Using data sources where appropriate
  - [x] Implemented state management
  - [x] Added necessary providers and versions
  - [x] Module versioning with semantic versioning
  - [x] Comprehensive testing with Terratest

## Points Breakdown
1. **Base Points per Day (10 points each)**
   - PR Submission: 10 points
   - Number of Days: 7 × 10 = 70 points

2. **Code Quality (max 5 points per day)**
   - Clean commits (1 point per commit, max 5): 35 points
   - PR Size (1-5 files: 3 points): 21 points

3. **Documentation (2 points each)**
   - README.md: 14 points (2 × 7 days)
   - Blog post: 14 points (2 × 7 days)
   - Proper comments: 14 points (2 × 7 days)

4. **Community Engagement**
   - Check-in attendance: 5 points
   - PR comments/reviews: 5 points (max 5)
   - Helping others: 5 points (max 5)

Total Expected Points: 183 points

## Checklist
- [x] I have completed all tasks for the days included
- [x] Each day's work is properly documented
- [x] All Terraform code follows required structure
- [x] Security best practices implemented
- [x] State management configured
- [x] All resources have proper tagging
- [x] Blog posts published and linked
- [x] Social media posts made with #AWSAIMLKenyaTerraformChallenge
- [x] Attended weekly check-in or notified about absence
- [x] Reviewed and commented on other participants' PRs
- [x] All code tested (init, plan, apply, destroy)
- [x] No sensitive data in commits
- [x] Production-grade standards implemented
- [x] Module versioning and testing completed

## Additional Notes
This week focused heavily on advanced Terraform concepts including loops, conditionals, zero-downtime deployments, secrets management, multi-provider configurations, and production-grade infrastructure. Key achievements include:

- Successfully implemented zero-downtime deployment with Auto Scaling Groups
- Integrated AWS Secrets Manager for secure credential management
- Created production-grade modules with comprehensive testing
- Implemented Docker containerization with health monitoring
- Established multi-region deployment capabilities
- Achieved 100% task completion with comprehensive documentation

The progression from basic conditionals to production-grade infrastructure demonstrates significant growth in Terraform expertise and DevOps best practices.

## Terraform Validation Results
```hcl
Success! The configuration is valid.
```

## Cost Estimation
```hcl
# Production environment estimated monthly cost: ~$150-200
# - t3.medium instances (3-6): ~$100-200
# - Application Load Balancer: ~$20
# - EBS volumes (encrypted): ~$15-30
# - Secrets Manager: ~$1-2
# - CloudWatch: ~$5-10

# Development environment estimated monthly cost: ~$20-30
# - t3.micro instances (1-2): ~$15-30
# - Basic monitoring: ~$2-5
```