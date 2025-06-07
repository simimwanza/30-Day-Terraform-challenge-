# Day 9 Submission

## Personal Information
- **Name:** Simi Mwanza
- **Date:** 3rd June 2025
- **GitHub Username:** simi-ops

## Task Completion
- [x] Read Chapter 2 of "Terraform: Up & Running"
- [x] Completed Required Hands-on Labs
- [ ] Deployed Single Server
- [x] Deployed Web Server
- [x] Created Infrastructure Diagrams

## Infrastructure Details

### Web Server Deployment
- **Region:** us-west-2
- **Instance Type:** t2-micro
- **Key Features:** S3 bucket and DynamoDB table for state file and locking

## Infrastructure Diagrams
Please place your infrastructure diagrams in the `architecture` folder with the following files:
- `web-server.png` - Diagram for the web server deployment

## Blog Post
- **Title:** 
- **Link:** 

## Social Media
- **Platform:** Twitter
- **Post Link:** 

## Notes and Observations


## Additional Resources Used


## Time Spent
- Reading: [ hours]
- Infrastructure Deployment: [ hours]
- Diagram Creation: [ hours]
- Blog Writing: [ hours]
- Total: [ hours]

## Repository Structure
```
Day9/
└── Submissions/
    └── simi-ops/
        ├── architecture/
        │   └── web-server.png
        ├── terraform/
        │   └── web-server/
        │       ├── main.tf
        │       ├── variables.tf
        │       ├── outputs.tf
        │       ├── modules/
        │       │   ├── ec2/
        │       │   │   ├── main.tf
        │       │   │   ├── variables.tf
        │       │   │   └── outputs.tf
        │       │   ├── security_group/
        │       │   │   ├── main.tf
        │       │   │   ├── variables.tf
        │       │   │   └── outputs.tf
        │       │   └── alb/
        │       │       ├── main.tf
        │       │       ├── variables.tf
        │       │       └── outputs.tf
        └── day9-SimiMwanza.md
``` 



