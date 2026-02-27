# AWS CI/CD Node Todo Application

A full-stack Node.js Todo application with complete AWS CI/CD infrastructure using CodePipeline, CodeBuild, CodeDeploy, and Terraform for Infrastructure as Code (IaC).

## Table of Contents
- [Features](#features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Docker](#docker)
- [Testing](#testing)
- [AWS CI/CD Infrastructure](#aws-cicd-infrastructure)
- [Deployment](#deployment)
- [Contributing](#contributing)

## Features

- **Todo List Management**: Create, read, update, and delete todo items
- **Web Interface**: EJS-based frontend for easy interaction
- **Input Sanitization**: Secure handling of user input
- **Docker Support**: Containerized deployment
- **AWS CI/CD Pipeline**: Fully automated build, test, and deployment process
- **Infrastructure as Code**: Terraform modules for AWS resource management
- **Code Quality**: SonarQube integration for code analysis
- **Automated Testing**: Mocha and Chai test framework

## Project Structure

```
├── app.js                    # Express.js application entry point
├── test.js                   # Test suite
├── package.json              # Node.js dependencies and scripts
├── Dockerfile                # Docker container configuration
├── appspec.yml               # CodeDeploy configuration
├── buildspec.yml             # CodeBuild configuration
├── sonar-project.properties  # SonarQube configuration
├── views/                    # EJS templates
│   ├── todo.ejs              # Todo list display template
│   └── edititem.ejs          # Edit todo item template
├── scripts/                  # Helper scripts
│   ├── start_container.sh    # Start Docker container
│   └── stop_container.sh     # Stop Docker container
└── terraform/                # Infrastructure as Code
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── modules/
        ├── codebuild/        # CodeBuild configuration
        ├── codedeploy/       # CodeDeploy configuration
        ├── codepipeline/     # CodePipeline configuration
        ├── ec2/              # EC2 instances
        ├── iam/              # IAM roles and policies
        ├── s3/               # S3 buckets
        ├── vpc/              # VPC and networking
        └── ssm/              # Systems Manager
```

## Prerequisites

### Local Development
- **Node.js** (v12 or higher)
- **npm** (comes with Node.js)
- **Docker** (for containerized development)

### AWS Deployment
- **AWS Account** with appropriate permissions
- **Terraform** (v1.0 or higher)
- **AWS CLI** configured with credentials
- **GitHub Account** (for CodePipeline integration)

## Local Development

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/AWS-CI-CD-Project-Todo-node-app.git
cd AWS-CI-CD-Project-Todo-node-app
```

2. Install dependencies:
```bash
npm install
```

### Running the Application

Start the development server:
```bash
npm start
```

The application will be available at `http://localhost:8000/todo`

### Application Routes

- `GET /todo` - Display all todo items
- `POST /todo/add/` - Add a new todo item
- `GET /todo/delete/:id` - Delete a todo item by ID
- `GET /todo/:id` - Get a specific todo item for editing
- `PUT /todo/:id` - Update a todo item

## Docker

### Build Docker Image

```bash
docker build -t todo-app:latest .
```

### Run Docker Container

```bash
docker run -p 8000:8000 todo-app:latest
```

Or use the provided scripts:

```bash
./scripts/start_container.sh    # Start container
./scripts/stop_container.sh     # Stop container
```

## Testing

Run the test suite:
```bash
npm test
```

Run tests with coverage:
```bash
npx nyc npm test
```

## AWS CI/CD Infrastructure

### Overview

This project uses a complete AWS CI/CD pipeline:

1. **CodePipeline** - Orchestrates the entire CI/CD workflow
2. **CodeBuild** - Builds the application and runs tests
3. **CodeDeploy** - Deploys the application to EC2 instances
4. **S3** - Stores build artifacts
5. **EC2** - Hosts the application
6. **VPC** - Network infrastructure
7. **IAM** - Access control and roles
8. **Systems Manager** - Parameter and secret storage

### Infrastructure Setup with Terraform

#### Prerequisites
- AWS credentials configured
- Terraform installed locally
- GitHub personal access token

#### Initialize Terraform

Navigate to the terraform directory:
```bash
cd terraform
```

Initialize Terraform:
```bash
terraform init
```

#### Configure Variables

Update `terraform.tfvars` with your values:
```hcl
aws_region              = "us-east-1"
github_repo             = "YOUR_GITHUB_REPO"
github_branch           = "main"
github_token            = "YOUR_GITHUB_TOKEN"
instance_type           = "t2.micro"
environment             = "dev"
```

#### Plan Deployment

```bash
terraform plan
```

#### Apply Configuration

```bash
terraform apply
```

Confirm the changes by typing `yes`

### CI/CD Workflow

1. **Source**: Push code to GitHub
2. **Build**: 
   - Install dependencies
   - Run tests
   - Build Docker image
   - Run SonarQube analysis
3. **Deploy**:
   - Deploy to EC2 instances
   - Health checks
   - Traffic routing

### Monitoring the Pipeline

View pipeline status in AWS Console:
- CodePipeline → Pipelines → Your Pipeline
- CodeBuild → Build Projects
- CodeDeploy → Applications

## Deployment

### Manual Deployment

1. Build the application:
```bash
npm install
npm test
```

2. Deploy using CodeDeploy:
```bash
aws deploy create-deployment \
  --application-name todo-app \
  --deployment-group-name todo-app-deployment \
  --s3-location s3://bucket-name/app-bundle.zip \
  --deployment-config-name CodeDeployDefault.OneAtATime
```

### Automatic Deployment

The CI/CD pipeline automatically deploys on every push to the main branch.

## Troubleshooting

### Application Not Starting
- Check Node.js version: `node --version`
- Verify dependencies: `npm install`
- Check port availability: The app runs on port 8000

### Docker Issues
- Rebuild image: `docker build -t todo-app:latest .`
- Check Docker daemon is running

### AWS Deployment Issues
- Verify AWS CLI credentials: `aws sts get-caller-identity`
- Check Terraform state: `terraform state list`
- Review CodeBuild logs in AWS Console
- Check CodeDeploy agent on EC2 instance

### Port Already in Use
If port 8000 is already in use:
```bash
# Find process using the port
netstat -ano | findstr :8000  # Windows
lsof -i :8000                 # macOS/Linux

# Kill the process or use a different port
```

## Environment Variables

Create a `.env` file for local development (not committed to git):

```env
NODE_ENV=development
PORT=8000
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature/your-feature`
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- GitHub Issues: Open an issue on the repository
- Email: miyaninilkanth2@gmail.com

## Useful Links

- [Express.js Documentation](https://expressjs.com/)
- [AWS CodePipeline](https://docs.aws.amazon.com/codepipeline/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Docker Documentation](https://docs.docker.com/)