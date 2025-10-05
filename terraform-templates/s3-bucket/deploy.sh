#!/bin/bash

# S3 Bucket Deployment Script
# Usage: ./deploy.sh [plan|apply|destroy]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_error ".env file not found. Please copy from .env.example and customize."
    exit 1
fi

# Load environment variables
print_status "Loading environment variables from .env file..."
source .env

# Validate required variables
if [ -z "$TF_VAR_bucket_name" ] || [ -z "$TF_VAR_project_name" ]; then
    print_error "Required variables TF_VAR_bucket_name and TF_VAR_project_name must be set in .env file"
    exit 1
fi

# Show current configuration
print_status "Current Configuration:"
echo "  Bucket Name: $TF_VAR_bucket_name"
echo "  Project: $TF_VAR_project_name"
echo "  Environment: $TF_VAR_environment"
echo "  Region: $TF_VAR_aws_region"
echo "  Encryption: $TF_VAR_enable_encryption"
echo "  Versioning: $TF_VAR_enable_versioning"
echo "  Public Read: $TF_VAR_enable_public_read"
echo "  Static Website: $TF_VAR_enable_static_website"
echo "  CloudFront: $TF_VAR_enable_cloudfront"
echo "  CORS: $TF_VAR_enable_cors"
echo ""

# Get action from command line argument
ACTION=${1:-plan}

case $ACTION in
    "init")
        print_status "Initializing Terraform..."
        terraform init
        print_success "Terraform initialized successfully!"
        ;;
    "plan")
        print_status "Creating Terraform plan..."
        terraform init -upgrade
        terraform plan
        print_success "Terraform plan completed successfully!"
        ;;
    "apply")
        print_status "Applying Terraform configuration..."
        terraform init -upgrade
        terraform plan
        
        print_warning "This will create AWS resources that may incur costs."
        read -p "Do you want to continue? (y/N): " confirm
        
        if [[ $confirm =~ ^[Yy]$ ]]; then
            terraform apply
            print_success "S3 bucket created successfully!"
            
            # Show bucket information
            print_status "Bucket Information:"
            terraform output
        else
            print_warning "Deployment cancelled."
            exit 0
        fi
        ;;
    "destroy")
        print_warning "This will destroy the S3 bucket and all its contents!"
        print_warning "Bucket: $TF_VAR_bucket_name"
        
        read -p "Are you sure you want to destroy the bucket? Type 'yes' to confirm: " confirm
        
        if [[ $confirm == "yes" ]]; then
            print_status "Destroying S3 bucket..."
            terraform destroy
            print_success "S3 bucket destroyed successfully!"
        else
            print_warning "Destroy cancelled."
            exit 0
        fi
        ;;
    "validate")
        print_status "Validating Terraform configuration..."
        terraform init -backend=false
        terraform validate
        print_success "Terraform configuration is valid!"
        ;;
    "format")
        print_status "Formatting Terraform files..."
        terraform fmt -recursive
        print_success "Terraform files formatted!"
        ;;
    *)
        echo "Usage: $0 [init|plan|apply|destroy|validate|format]"
        echo ""
        echo "Commands:"
        echo "  init      - Initialize Terraform"
        echo "  plan      - Create and show Terraform plan"
        echo "  apply     - Apply Terraform configuration"
        echo "  destroy   - Destroy all resources"
        echo "  validate  - Validate Terraform syntax"
        echo "  format    - Format Terraform files"
        exit 1
        ;;
esac