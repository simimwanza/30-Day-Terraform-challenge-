# Day 12 Submission

## Personal Information
- **Name:** Simi Mwanza
- **Date:** 8th June 2025
- **GitHub Username:** simi-ops

## Task Completion
- [x] Read Chapter 5 (Pages 160-169)
- [x] Completed Required Hands-on Labs
- [x] Refactored Terraform code to use conditionals for dynamic infrastructure deployment

## Infrastructure Details

### Dynamic Infrastructure with Conditionals


1. **Environment-specific Resource Deployment**


## Infrastructure Diagram
Please see the `architecture/web-server.png` file for the infrastructure diagram.

## Blog Post
- **Title:** "Mastering Terraform Conditionals for Dynamic Infrastructure"
- **Link:** [Blog Post](https://simiops.hashnode.dev/how-to-implement-bluegreen-deployments-with-terraform-for-zero-downtime?showSharer=true)

## Social Media
- **Platform:** Twitter
- **Post Link:** [Twitter Post](https://x.com/simiOps/status/1938551753974157316)

## Notes and Observations


## Additional Resources Used
- Terraform Documentation: https://www.terraform.io/docs/language/expressions/conditionals.html
- AWS Architecture Best Practices: https://aws.amazon.com/architecture/well-architected/

## Time Spent
- Reading: [2 hours]
- Infrastructure Refactoring: [4 hours]
- Diagram Creation: [1 hour]
- Blog Writing: [2 hours]
- Total: [9 hours]

## Repository Structure
```
terraform/
├── main.tf                     # Main Terraform configuration with conditional resource deployment
├── variables.tf                # Variable definitions including environment-specific settings
├── deploy.sh                   # Deployment script for different environments
├── README.md                   # Documentation
├── environments/               # Environment-specific configurations
│   ├── dev/
│   │   └── terraform.tfvars
│   ├── staging/
│   │   └── terraform.tfvars
│   └── production/
│       └── terraform.tfvars
├── modules/                    # Reusable Terraform modules with conditional logic
│   ├── alb/                    # Application Load Balancer module
│   │   ├── main.tf            # Includes conditional health checks and listeners
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2/                    # EC2 instance module
│   │   ├── main.tf            # Includes conditional instance counts and volume configurations
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── user_data.sh
│   └── security_group/         # Security Group module
│       ├── main.tf            # Includes conditional security rules based on environment
│       ├── variables.tf
│       └── outputs.tf
```