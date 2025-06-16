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
- ✅ Parameterized configuration for different environments

## Directory Structure

```
terraform/
├── blue-green/
│   ├── main.tf              # Main module configuration
│   ├── variables.tf         # Module variables
│   ├── outputs.tf           # Module outputs
│   └── user_data.sh.tpl     # Template for EC2 user data
├── zero-downtime.tf         # Implementation using the blue/green module
├── deploy-blue-green.sh     # Deployment script
└── README-blue-green.md     # This README file
```

## Usage

### Initial Deployment

```bash
# Make the deployment script executable
chmod +x deploy-blue-green.sh

# Deploy the initial environment
./deploy-blue-green.sh apply
```

### Deploying a New Version

```bash
# 1. Update the inactive environment with a new version
# If blue is active, update green with version 2.0.0
./deploy-blue-green.sh apply - - 2.0.0

# 2. Gradually shift traffic to the new environment
./deploy-blue-green.sh shift - 10
./deploy-blue-green.sh shift - 25
./deploy-blue-green.sh shift - 50
./deploy-blue-green.sh shift - 75
./deploy-blue-green.sh shift - 100

# 3. Complete the deployment by switching the active environment
./deploy-blue-green.sh switch
```

### Rollback

If issues are detected during deployment, you can quickly rollback:

```bash
./deploy-blue-green.sh rollback
```

## Zero-Downtime Process Flow

1. **Initial State**: All traffic goes to the active environment (e.g., blue).
2. **Prepare New Environment**: Deploy the new application version to the inactive environment (e.g., green).
3. **Test New Environment**: Verify the new environment is functioning correctly.
4. **Gradual Traffic Shift**: Gradually shift traffic from blue to green (e.g., 10%, 25%, 50%, 75%, 100%).
5. **Complete Transition**: Once all traffic is on the new environment, make it the active environment.
6. **Cleanup**: The old environment becomes the new inactive environment for future updates.