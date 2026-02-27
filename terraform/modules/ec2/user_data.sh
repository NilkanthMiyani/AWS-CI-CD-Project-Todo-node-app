#!/bin/bash
set -e

# Log output to file for debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting user data script..."

# Update system packages
echo "Updating system packages..."
yum update -y

# Install Docker
echo "Installing Docker..."
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Install CodeDeploy Agent
echo "Installing CodeDeploy Agent..."
yum install -y ruby wget

cd /home/ec2-user
wget https://aws-codedeploy-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/latest/install
chmod +x ./install
./install auto

# Start CodeDeploy Agent
systemctl start codedeploy-agent
systemctl enable codedeploy-agent

# Create application directory
echo "Creating application directory..."
mkdir -p /home/ubuntu/node-todo-app
chown -R ec2-user:ec2-user /home/ubuntu

# Verify installations
echo "Verifying installations..."
docker --version
systemctl status docker
systemctl status codedeploy-agent

echo "User data script completed successfully!"
