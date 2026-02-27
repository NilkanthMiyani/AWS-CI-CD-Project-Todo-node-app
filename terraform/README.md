# Terraform AWS CI/CD Infrastructure

This Terraform configuration sets up a complete AWS CI/CD pipeline infrastructure for the Node.js Todo Application, including VPC, EC2, IAM, CodePipeline, CodeBuild, CodeDeploy, and other essential AWS services.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Module Structure](#module-structure)
- [Quick Start](#quick-start)
- [Variables Configuration](#variables-configuration)
- [Deployment Steps](#deployment-steps)
- [Outputs](#outputs)
- [Module Details](#module-details)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

## Architecture Overview

This infrastructure implements a three-stage CI/CD pipeline:

```
GitHub Repository
    ↓
CodePipeline (Orchestration)
    ↓
┌─────────────────────────────────┐
│ Source Stage                    │
│ (CodeStar Connection + GitHub)  │
└────────────┬────────────────────┘
             ↓
┌─────────────────────────────────┐
│ Build Stage                     │
│ (CodeBuild)                     │
│ - Install dependencies          │
│ - Run tests                     │
│ - Build Docker image            │
│ - Code quality scan             │
└────────────┬────────────────────┘
             ↓
┌─────────────────────────────────┐
│ Deploy Stage                    │
│ (CodeDeploy)                    │
│ - Deploy to EC2 instances       │
│ - Start application             │
└────────────┬────────────────────┘
             ↓
        Application Running
        http://<EC2-IP>:8000
```

### Infrastructure Components

- **VPC**: Virtual Private Cloud with public subnet, internet gateway, and security groups
- **EC2**: Amazon Linux 2 instance with CodeDeploy agent and Docker
- **S3**: Bucket for storing build artifacts and pipeline artifacts
- **IAM**: Roles and policies for CodeBuild, CodeDeploy, CodePipeline, and EC2
- **CodeStar**: GitHub connection for webhook-based triggers
- **CodeBuild**: Builds Docker images, runs tests, and pushes to registry
- **CodeDeploy**: Deploys application to EC2 instances
- **CodePipeline**: Orchestrates the entire CI/CD workflow
- **SSM Parameter Store**: Stores secrets like Docker credentials
- **CloudWatch**: Logs for CodeBuild and CodeDeploy

## Prerequisites

### Required Tools

- **Terraform** >= 1.0: [Install Terraform](https://www.terraform.io/downloads.html)
- **AWS CLI** >= 2.0: [Install AWS CLI](https://aws.amazon.com/cli/)
- **AWS Account** with appropriate permissions
- **GitHub Account** with a repository containing the application code

### AWS Permissions Required

The AWS account should have permissions to create:
- VPC, Subnets, Security Groups, Internet Gateway, Route Tables
- EC2 instances
- IAM roles and policies
- S3 buckets
- CodePipeline, CodeBuild, CodeDeploy, CodeStar
- Systems Manager Parameter Store
- CloudWatch Logs

### Local Setup

1. **Configure AWS CLI credentials:**

```bash
aws configure
```

Provide your AWS Access Key ID, Secret Access Key, region (e.g., `us-east-1`), and output format.

2. **Create an SSH key pair for EC2 access:**

```bash
# Generate key pair
aws ec2 create-key-pair --key-name todo-app-key --region us-east-1 \
  --query 'KeyMaterial' --output text > todo-app-key.pem

# Set correct permissions (Linux/macOS)
chmod 400 todo-app-key.pem

# On Windows, you can use AWS Console to create the key pair
```

3. **Create GitHub Personal Access Token:**
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Click "Generate new token"
   - Select scopes: `repo`, `admin:repo_hook`
   - Copy the token (needed for terraform.tfvars)

## Module Structure

```
terraform/
├── main.tf                    # Root module - orchestrates all modules
├── variables.tf              # Input variables
├── outputs.tf                # Output values
├── providers.tf              # AWS provider configuration
├── terraform.tfvars          # Variables (DO NOT COMMIT)
└── modules/
    ├── vpc/                  # VPC, subnets, security groups
    │   ├── main.tf
    │   ├── security_groups.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/                  # EC2 instances, user data script
    │   ├── main.tf
    │   ├── user_data.sh
    │   ├── variables.tf
    │   └── outputs.tf
    ├── s3/                   # S3 buckets for artifacts
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── iam/                  # IAM roles and policies
    │   ├── main.tf
    │   ├── codebuild_role.tf
    │   ├── codedeploy_role.tf
    │   ├── codepipeline_role.tf
    │   ├── ec2_role.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── codebuild/            # CodeBuild project
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── codedeploy/           # CodeDeploy application
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── codepipeline/         # CodePipeline orchestration
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── codestar/             # GitHub connection
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ssm/                  # Parameter Store for secrets
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Quick Start

### 1. Navigate to Terraform Directory

```bash
cd terraform
```

### 2. Create terraform.tfvars

Create a `terraform.tfvars` file with your configuration:

```hcl
aws_region              = "us-east-1"
project_name            = "todo-app"
environment             = "dev"

# VPC Configuration
vpc_cidr                = "10.0.0.0/16"
public_subnet_cidr      = "10.0.1.0/24"
availability_zone       = "us-east-1a"
allowed_ssh_cidr        = "YOUR_IP/32"  # Your IP address for SSH access

# EC2 Configuration
ec2_instance_type       = "t2.micro"
ec2_key_name            = "todo-app-key"  # Key pair created in prerequisites

# GitHub Configuration
github_repo_owner       = "your-github-username"
github_repo_name        = "AWS-CI-CD-Project-Todo-node-app"
github_branch           = "main"
github_token            = "your-github-personal-access-token"

# Docker Configuration
docker_hub_username     = "your-docker-username"
docker_hub_password     = "your-docker-password"
docker_registry_url     = "docker.io"
docker_image_repo_name  = "your-docker-username/todo-app"
docker_image_tag        = "latest"
```

⚠️ **Important**: Add `terraform.tfvars` to `.gitignore` - it contains sensitive data!

### 3. Initialize Terraform

```bash
terraform init
```

This downloads required providers and initializes the Terraform working directory.

### 4. Plan Deployment

```bash
terraform plan -out=tfplan
```

Review the planned changes to understand what will be created.

### 5. Apply Configuration

```bash
terraform apply tfplan
```

Wait for completion (usually 10-15 minutes). Terraform will output the EC2 instance IP and application URL.

### 6. Complete CodeStar Connection

After deployment, you must authorize the GitHub connection:

1. Go to AWS Console → Developer Tools → Connections
2. Find the connection status (likely "PENDING")
3. Click "Update pending connection"
4. Click "Connect to GitHub"
5. Authorize AWS Connector for GitHub
6. Once status is "AVAILABLE", the pipeline will start automatically

## Variables Configuration

### Essential Variables (Required)

| Variable | Description | Example |
|----------|-------------|---------|
| `github_repo_owner` | GitHub username/organization | `my-username` |
| `github_repo_name` | Repository name | `AWS-CI-CD-Project-Todo-node-app` |
| `github_token` | GitHub PAT for authentication | `ghp_xxxxxxxxxxxxxxxxxxxx` |
| `ec2_key_name` | EC2 SSH key pair name | `todo-app-key` |
| `docker_hub_username` | Docker Hub username | `dockerusername` |
| `docker_hub_password` | Docker Hub password/token | `dckr_xxxxxxxxxxxxxxxxxxxx` |

### Optional Variables (Have Defaults)

| Variable | Default | Description |
|----------|---------|-------------|
| `project_name` | `todo-app` | Project name prefix |
| `environment` | `dev` | Environment name |
| `aws_region` | `us-east-1` | AWS region |
| `ec2_instance_type` | `t2.micro` | EC2 instance type |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `public_subnet_cidr` | `10.0.1.0/24` | Public subnet CIDR |
| `allowed_ssh_cidr` | `0.0.0.0/0` | CIDR allowed for SSH |

## Deployment Steps

### Step 1: Verify AWS Credentials

```bash
aws sts get-caller-identity
```

Should return your AWS account ID and user ARN.

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Validate Configuration

```bash
terraform validate
```

Checks syntax and configuration for errors.

### Step 4: Plan Changes

```bash
terraform plan
```

Shows all resources that will be created/modified/destroyed.

### Step 5: Apply Configuration

```bash
terraform apply
```

Interactively confirm by typing `yes`.

### Step 6: Wait for Completion

Monitor progress in the terminal. This typically takes 10-15 minutes:

1. VPC and networking resources (1-2 min)
2. IAM roles (1 min)
3. EC2 instance launch (3-5 min)
4. CodeBuild/CodeDeploy/CodePipeline setup (2-3 min)
5. CodeDeploy agent initialization (2-3 min)

### Step 7: Authorize GitHub Connection

1. Note the CodeStar connection status from outputs
2. Go to AWS Console → Developer Tools → Connections
3. Find the pending connection and click "Update pending connection"
4. Authorize the GitHub app
5. Status should change to "AVAILABLE"

### Step 8: Verify Deployment

Once Terraform completes:

```bash
# Get application URL
terraform output application_url

# SSH into EC2 instance
ssh -i /path/to/todo-app-key.pem ec2-user@<EC2_PUBLIC_IP>

# Check application status
curl http://<EC2_PUBLIC_IP>:8000/todo
```

## Outputs

After `terraform apply`, you'll see outputs like:

```
Outputs:

application_url = "http://54.123.45.67:8000"
ec2_instance_id = "i-0123456789abcdef0"
ec2_public_ip = "54.123.45.67"
ec2_public_dns = "ec2-54-123-45-67.compute-1.amazonaws.com"
codebuild_project_name = "todo-app-dev-build"
codedeploy_app_name = "todo-app-dev-app"
codepipeline_name = "todo-app-dev-pipeline"
s3_artifacts_bucket = "todo-app-dev-artifacts-123456789"
```

Use these values to access and manage your infrastructure.

## Module Details

### VPC Module

**Purpose**: Creates isolated network infrastructure

**Resources Created**:
- VPC with specified CIDR block
- Public subnet
- Internet Gateway
- Route table and routes
- Security groups (EC2, ALB)

**Key Features**:
- Single availability zone for cost optimization
- Public subnet for application access
- Security groups with configurable SSH access
- NAT Gateway option available

**Example**: Allows HTTP/HTTPS traffic to EC2 while restricting SSH to specific IPs

---

### EC2 Module

**Purpose**: Launches and configures the application server

**Resources Created**:
- Amazon Linux 2 EC2 instance
- Root volume (20GB, encrypted)
- IAM instance profile attachment

**Key Features**:
- Automatically fetches latest Amazon Linux 2 AMI
- User data script installs CodeDeploy agent and Docker
- IAM role for SSM Parameter Store access
- EBS encryption enabled
- 20GB root volume with gp3 type

**User Data Script** (`user_data.sh`):
- Installs CodeDeploy agent
- Installs Docker and Docker Compose
- Configures EC2 for deployment
- Enables CloudWatch monitoring

---

### S3 Module

**Purpose**: Stores CI/CD artifacts and build outputs

**Resources Created**:
- S3 bucket for artifacts
- Bucket versioning enabled
- Server-side encryption
- Public access blocked

**Key Features**:
- Stores CodePipeline artifacts between stages
- Stores Docker images and build outputs
- Encryption enabled for security
- All public access blocked

**Lifecycle**: Artifacts retained for build history and rollback capability

---

### IAM Module

**Purpose**: Defines security roles and policies

**Resources Created**:
- CodePipeline execution role
- CodeBuild service role
- CodeDeploy service role
- EC2 instance role (IAM profile)

**Key Features**:
- Least privilege principle - only required permissions
- CodeBuild role: S3, CodePipeline, Parameter Store, CloudWatch
- CodeDeploy role: S3, CodeDeploy, auto-scaling
- EC2 role: Parameter Store access, CloudWatch logs
- CodePipeline role: CodeBuild, CodeDeploy, S3, CodeStar

**Permission Examples**:
- CodeBuild can pull from Parameter Store for Docker credentials
- EC2 can pull Docker image from registry
- CodeDeploy reads artifacts from S3

---

### CodeStar Module

**Purpose**: Creates GitHub connection for webhook-based pipeline triggers

**Resources Created**:
- CodeStar connection to GitHub

**Key Features**:
- Secure authentication without storing tokens
- Automatic webhook management
- Real-time push detection
- No manual polling needed

**Important**: Connection must be manually authorized in AWS Console before pipeline works

---

### CodeBuild Module

**Purpose**: Compiles, tests, and builds Docker images

**Resources Created**:
- CodeBuild project
- CloudWatch log group

**Build Process** (defined in `buildspec.yml`):
1. Install dependencies (`npm install`)
2. Run tests (`npm test`)
3. Build Docker image
4. Push to Docker registry
5. Run SonarQube analysis (optional)

**Build Environment**:
- Compute type: BUILD_GENERAL1_SMALL
- Image: aws/codebuild/standard:5.0
- Docker privileged mode enabled
- Build timeout: 30 minutes

**Environment Variables** (from SSM Parameter Store):
- `DOCKER_REGISTRY_USERNAME`: Docker credentials
- `DOCKER_REGISTRY_PASSWORD`: Docker credentials
- `DOCKER_REGISTRY_URL`: Registry URL
- `IMAGE_REPO_NAME`: Docker image repository
- `IMAGE_TAG`: Docker image tag

---

### CodeDeploy Module

**Purpose**: Deploys application to EC2 instances

**Resources Created**:
- CodeDeploy application
- Deployment groups
- Deployment configuration

**Deployment Process** (defined in `appspec.yml`):
1. Stop current application
2. Download latest Docker image
3. Start Docker container
4. Verify health checks
5. Update DNS/routing if needed

**Deployment Config**:
- Strategy: One-at-a-time (safer)
- Auto-rollback on failure
- Health check grace period: 5 minutes

---

### CodePipeline Module

**Purpose**: Orchestrates the entire CI/CD workflow

**Pipeline Stages**:

1. **Source Stage**:
   - Monitors GitHub repository
   - Triggers on push via CodeStar webhook
   - Outputs: Source code

2. **Build Stage**:
   - Invokes CodeBuild project
   - Runs buildspec.yml
   - Outputs: Docker image, test results, build artifacts

3. **Deploy Stage**:
   - Invokes CodeDeploy
   - Runs appspec.yml on EC2
   - Outputs: Running application

**Important**: Pipeline automatically starts when GitHub connection is authorized

---

### SSM Module

**Purpose**: Stores sensitive deployment information securely

**Parameters Stored**:
- Docker Hub username
- Docker Hub password
- Docker registry URL

**Security Features**:
- Encrypted at rest with KMS
- Access controlled via IAM policies
- No exposure in logs or console output

**Usage**: CodeBuild retrieves these during build process

## Troubleshooting

### Issue: CodePipeline Not Starting

**Symptoms**: Pipeline created but not running automatically

**Cause**: CodeStar connection not authorized

**Solution**:
```bash
# Check connection status
aws codestarconnections list-connections --region us-east-1

# Manually authorize:
# 1. AWS Console → Developer Tools → Connections
# 2. Find "PENDING" connection
# 3. Click "Update pending connection"
# 4. Authorize GitHub app
```

---

### Issue: CodeBuild Failing with Docker Credentials

**Symptoms**: Build fails with "docker login" error

**Cause**: Docker credentials not in Parameter Store or incorrect format

**Solution**:
```bash
# Verify parameters exist
aws ssm get-parameter --name /myapp/docker-credentials/username --region us-east-1

# If missing, create them:
aws ssm put-parameter \
  --name /myapp/docker-credentials/username \
  --value "your-docker-username" \
  --type "String" \
  --region us-east-1
```

---

### Issue: EC2 Instance Launch Failed

**Symptoms**: Terraform apply fails during EC2 creation

**Cause**: Subnet or security group not properly created, or insufficient permissions

**Solution**:
```bash
# Check VPC and subnet
terraform state show module.vpc.aws_subnet.public

# Verify security group
terraform state show module.vpc.aws_security_group.ec2

# Retry apply
terraform apply
```

---

### Issue: SSH Connection to EC2 Fails

**Symptoms**: `Permission denied (publickey)` when SSH-ing

**Cause**: Wrong key file, incorrect permissions, or security group blocking SSH

**Solution**:
```bash
# Verify key file ownership (Linux/macOS)
chmod 400 todo-app-key.pem

# Check security group allows SSH from your IP
aws ec2 describe-security-groups --group-ids <SG_ID> --region us-east-1

# Verify you're using correct key:
ssh -i todo-app-key.pem -v ec2-user@<IP>  # -v for verbose
```

---

### Issue: Application Not Accessible

**Symptoms**: Can SSH to EC2 but application returns 404

**Cause**: Application not running, wrong port, or security group misconfiguration

**Solution**:
```bash
# SSH to instance
ssh -i todo-app-key.pem ec2-user@<IP>

# Check Docker running
docker ps

# Check logs
docker logs <container-name>

# Test locally on EC2
curl localhost:8000/todo

# Check security group allows port 8000
aws ec2 describe-security-groups --group-ids <SG_ID> --region us-east-1
```

---

### Issue: CodeDeploy Agent Not Running

**Symptoms**: Deployment fails at "Install" phase

**Cause**: CodeDeploy agent not installed or stopped

**Solution**:
```bash
# SSH to EC2 and check agent
sudo systemctl status codedeploy-agent

# Start if stopped
sudo systemctl start codedeploy-agent

# Check logs
sudo tail -f /var/log/codedeploy-agent/codedeploy-agent.log
```

---

### Issue: Plan Shows Resources to Destroy

**Symptoms**: `terraform plan` shows `- resource` instead of no changes

**Cause**: State file corruption or variable changes

**Solution**:
```bash
# Refresh state
terraform refresh

# Check variable values
terraform plan

# If still problematic, check state:
terraform state list
terraform state show <resource>
```

---

### View Detailed Logs

**CodeBuild Logs**:
```bash
# View build logs
aws codebuild batch-get-builds \
  --ids <BUILD_ID> \
  --region us-east-1

# Or via CloudWatch
aws logs tail /aws/codebuild/todo-app-dev --follow
```

**CodeDeploy Logs**:
```bash
# SSH to EC2 and check
sudo tail -f /var/log/codedeploy-agent/codedeploy-agent.log
sudo tail -f /var/log/codedeploy-agent/deployments/codedeploy-agent-deployments.log
```

## Cleanup

### Delete All AWS Resources

⚠️ This will destroy all created resources and cannot be undone!

```bash
# Remove the pipeline (optional, helps with cleanup order)
terraform destroy

# Confirm by typing 'yes'
```

### Manual Cleanup (if terraform destroy fails)

```bash
# Delete specific resources in order
aws codepipeline delete-pipeline --name todo-app-dev-pipeline
aws codebuild delete-project --name todo-app-dev-build
aws codedeploy delete-app --application-name todo-app-dev-app

# Terminate EC2
aws ec2 terminate-instances --instance-ids <INSTANCE_ID>

# Delete security groups (after EC2 terminates)
aws ec2 delete-security-group --group-id <SG_ID>

# Empty and delete S3 bucket
aws s3 rm s3://bucket-name --recursive
aws s3 rb s3://bucket-name

# Delete VPC (after all resources removed)
aws ec2 delete-subnet --subnet-id <SUBNET_ID>
aws ec2 detach-internet-gateway --internet-gateway-id <IGW_ID> --vpc-id <VPC_ID>
aws ec2 delete-internet-gateway --internet-gateway-id <IGW_ID>
aws ec2 delete-vpc --vpc-id <VPC_ID>
```

### Clean Local Files

```bash
# Remove local state (careful!)
rm -rf .terraform terraform.tfstate*

# Reinitialize for fresh deployment
terraform init
```

## Best Practices

1. **State Management**:
   - Never commit `terraform.tfstate` or `terraform.tfvars`
   - Consider using S3 backend for team environments
   - Enable state locking with DynamoDB

2. **Security**:
   - Use AWS Secrets Manager instead of Parameter Store for highly sensitive data
   - Enable MFA for AWS account
   - Regularly rotate Docker credentials
   - Restrict SSH access to known IPs

3. **Cost Optimization**:
   - Use `t2.micro` for development (eligible for free tier)
   - Set up CloudWatch alarms for unusual spending
   - Schedule EC2 shutdown during off-hours
   - Review S3 lifecycle policies for artifact retention

4. **Architecture**:
   - Add multiple EC2 instances with load balancer for production
   - Enable Auto Scaling Groups
   - Use RDS for database if needed
   - Add CloudFront CDN for static assets

5. **Monitoring**:
   - Set up CloudWatch dashboards for pipeline metrics
   - Configure SNS notifications for pipeline failures
   - Monitor EC2 metrics (CPU, Memory, Disk)
   - Enable VPC Flow Logs for network monitoring

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/)
- [Terraform Best Practices](https://www.terraform.io/docs/glossary)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## Support

For issues:

1. Check Terraform debug output: `TF_LOG=DEBUG terraform apply`
2. Review AWS CloudTrail for API errors
3. Check CloudWatch logs for service-specific issues
4. Verify IAM permissions using AWS Policy Simulator
5. Check GitHub connection status in AWS Console
