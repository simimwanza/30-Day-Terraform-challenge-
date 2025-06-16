#!/bin/bash

set -e

ENVIRONMENT=${1:-dev}
ACTION=${2:-plan}
DEPLOYMENT_STATE=${3:-}
TRAFFIC_DISTRIBUTION=${4:-}
NEW_VERSION=${5:-}

if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|production)$ ]]; then
    echo "Error: Environment must be dev, staging, or production"
    exit 1
fi

echo "🚀 Blue/Green Deployment for $ENVIRONMENT environment..."

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Get current deployment state from SSM Parameter Store if not provided
if [[ -z "$DEPLOYMENT_STATE" ]]; then
    echo "Getting current deployment state from SSM Parameter Store..."
    DEPLOYMENT_STATE=$(aws ssm get-parameter --name "/$ENVIRONMENT/web-app/deployment-state" --query "Parameter.Value" --output text 2>/dev/null || echo "blue")
    echo "Current deployment state: $DEPLOYMENT_STATE"
fi

# Get current traffic distribution from SSM Parameter Store if not provided
if [[ -z "$TRAFFIC_DISTRIBUTION" ]]; then
    echo "Getting current traffic distribution from SSM Parameter Store..."
    TRAFFIC_DISTRIBUTION=$(aws ssm get-parameter --name "/$ENVIRONMENT/web-app/traffic-distribution" --query "Parameter.Value" --output text 2>/dev/null || echo "0")
    echo "Current traffic distribution: $TRAFFIC_DISTRIBUTION%"
fi

# Determine which environment to update based on current deployment state
INACTIVE_ENV=$([ "$DEPLOYMENT_STATE" == "blue" ] && echo "green" || echo "blue")

# Prepare variable arguments
VAR_ARGS="-var-file=environments/$ENVIRONMENT/terraform.tfvars"
VAR_ARGS="$VAR_ARGS -var=deployment_state=$DEPLOYMENT_STATE"
VAR_ARGS="$VAR_ARGS -var=traffic_distribution=$TRAFFIC_DISTRIBUTION"

# If new version is provided, update the inactive environment
if [[ ! -z "$NEW_VERSION" ]]; then
    if [[ "$INACTIVE_ENV" == "blue" ]]; then
        VAR_ARGS="$VAR_ARGS -var=blue_app_version=$NEW_VERSION"
        echo "Updating blue environment to version $NEW_VERSION"
    else
        VAR_ARGS="$VAR_ARGS -var=green_app_version=$NEW_VERSION"
        echo "Updating green environment to version $NEW_VERSION"
    fi
fi

# Plan or apply
case $ACTION in
    plan)
        echo "📋 Planning deployment for $ENVIRONMENT..."
        terraform plan $VAR_ARGS
        ;;
    apply)
        echo "🔨 Applying changes to $ENVIRONMENT..."
        terraform apply $VAR_ARGS -auto-approve
        ;;
    destroy)
        echo "💥 Destroying resources in $ENVIRONMENT..."
        terraform destroy $VAR_ARGS -auto-approve
        ;;
    switch)
        # Switch active environment
        NEW_STATE=$([ "$DEPLOYMENT_STATE" == "blue" ] && echo "green" || echo "blue")
        echo "🔄 Switching from $DEPLOYMENT_STATE to $NEW_STATE environment..."
        terraform apply -var-file="environments/$ENVIRONMENT/terraform.tfvars" -var="deployment_state=$NEW_STATE" -var="traffic_distribution=0" -auto-approve
        ;;
    shift)
        # Shift traffic gradually
        if [[ -z "$TRAFFIC_DISTRIBUTION" ]]; then
            echo "Error: Traffic distribution percentage required for shift action"
            exit 1
        fi
        echo "⚖️ Shifting $TRAFFIC_DISTRIBUTION% traffic to $INACTIVE_ENV environment..."
        terraform apply -var-file="environments/$ENVIRONMENT/terraform.tfvars" -var="deployment_state=$DEPLOYMENT_STATE" -var="traffic_distribution=$TRAFFIC_DISTRIBUTION" -auto-approve
        ;;
    rollback)
        # Rollback to previous environment
        echo "⏪ Rolling back to previous environment..."
        terraform apply -var-file="environments/$ENVIRONMENT/terraform.tfvars" -var="deployment_state=$DEPLOYMENT_STATE" -var="traffic_distribution=0" -auto-approve
        ;;
    *)
        echo "Error: Action must be plan, apply, destroy, switch, shift, or rollback"
        exit 1
        ;;
esac

echo "✅ Deployment action completed for $ENVIRONMENT!"

# Display current state
echo "Current deployment state: $DEPLOYMENT_STATE"
if [[ "$TRAFFIC_DISTRIBUTION" == "0" ]]; then
    echo "100% of traffic is going to the $DEPLOYMENT_STATE environment"
elif [[ "$TRAFFIC_DISTRIBUTION" == "100" ]]; then
    echo "100% of traffic is going to the $INACTIVE_ENV environment"
else
    ACTIVE_ENV_TRAFFIC=$((100 - $TRAFFIC_DISTRIBUTION))
    echo "$ACTIVE_ENV_TRAFFIC% of traffic is going to the $DEPLOYMENT_STATE environment"
    echo "$TRAFFIC_DISTRIBUTION% of traffic is going to the $INACTIVE_ENV environment"
fi