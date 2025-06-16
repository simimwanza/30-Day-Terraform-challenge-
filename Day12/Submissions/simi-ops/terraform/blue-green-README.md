# Zero-Downtime Deployment with Terraform - Blue/Green Strategy

This project demonstrates how to implement a blue/green deployment strategy using Terraform to ensure zero-downtime during application updates.

## Architecture Overview

The blue/green deployment strategy involves maintaining two identical environments (blue and green) and switching traffic between them during deployments:

1. **Blue Environment**: The currently active production environment serving user traffic
2. **Green Environment**: The new environment with updated application code/configuration

When deploying a new version:
1. Deploy changes to the inactive environment (green)
2. Test the green environment thoroughly
3. Switch traffic from blue to green (making green the new production)
4. The old blue environment becomes the new inactive environment for future updates

This approach ensures zero-downtime as users are only switched to the new environment once it's fully provisioned and tested.

## Implementation Details

This Terraform configuration includes:

- **AWS Application Load Balancer**: Routes traffic between blue and green environments
- **Target Groups**: Separate target groups for blue and green environments
- **Auto Scaling Groups**: Maintains the EC2 instances for each environment
- **Launch Templates**: Defines the EC2 instance configuration for each environment
- **CloudWatch Alarms**: Monitors the health of both environments during and after deployment
- **SSM Parameters**: Stores the current deployment state and traffic distribution

## Key Features

- ✅ Complete separation between blue and green environments
- ✅ Automated traffic shifting with configurable weights
- ✅ Rollback capability if issues are detected in the new environment
- ✅ Health checks to ensure the new environment is ready before traffic shifting
- ✅ Parameterized configuration for different environments (dev, staging, production)
- ✅ Tagging strategy for clear resource identification

## Directory Structure

```
terraform/
├── modules/
│   └── blue-green/
│       ├── main.tf              # Main module configuration
│       ├── variables.tf         # Module variables
│       ├── outputs.tf           # Module outputs
│       └── user_data.sh.tpl     # Template for EC2 user data
├── environments/
│   ├── dev/
│   │   └── blue-green.tfvars    # Dev environment variables
│   ├── staging/
│   │   └── blue-green.tfvars    # Staging environment variables
│   └── production/
│       └── blue-green.tfvars    # Production environment variables
├── blue-green-main.tf           # Main configuration file
├── blue-green-variables.tf      # Variables definition
├── blue-green-deploy.sh         # Deployment script
└── blue-green-README.md         # This README file
```

## Usage

### Initial Deployment

```bash
# Make the deployment script executable
chmod +x blue-green-deploy.sh

# Deploy to dev environment
./blue-green-deploy.sh dev apply
```

### Deploying a New Version

```bash
# 1. Update the inactive environment with a new version
# If blue is active, update green
./blue-green-deploy.sh dev apply - - 2.0.0

# 2. Gradually shift traffic to the new environment
./blue-green-deploy.sh dev shift - 10
./blue-green-deploy.sh dev shift - 25
./blue-green-deploy.sh dev shift - 50
./blue-green-deploy.sh dev shift - 75
./blue-green-deploy.sh dev shift - 100

# 3. Complete the deployment by switching the active environment
./blue-green-deploy.sh dev switch
```

### Rollback

If issues are detected during deployment, you can quickly rollback:

```bash
./blue-green-deploy.sh dev rollback
```

## Environment Differences

| Environment | Instance Type | Region    | Min Instances | Max Instances |
|-------------|---------------|-----------|--------------|---------------|
| dev         | t3.micro      | us-west-2 | 1            | 2             |
| staging     | t3.small      | us-west-2 | 2            | 4             |
| production  | t3.medium     | us-east-1 | 2            | 6             |

## Monitoring

The deployment includes CloudWatch alarms for:
- High CPU utilization in both environments
- Unhealthy hosts in both environments

These alarms can be used to trigger automated rollbacks or notifications if issues are detected during or after deployment.