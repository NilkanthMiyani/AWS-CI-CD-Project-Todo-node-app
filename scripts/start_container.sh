#!/bin/bash
set -e

# Configuration - Read from imageDefinitions.json or use default
APP_DIR="/home/ubuntu/node-todo-app"
IMAGE_DEF_FILE="$APP_DIR/imageDefinitions.json"

# Default image (fallback)
DEFAULT_IMAGE="amitabhdevops/aws-node-todo-app-cicd:latest"

# Try to get image from imageDefinitions.json created by CodeBuild
if [ -f "$IMAGE_DEF_FILE" ]; then
    IMAGE_URI=$(cat "$IMAGE_DEF_FILE" | grep -o '"ImageURI":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$IMAGE_URI" ]; then
        DOCKER_IMAGE="$IMAGE_URI"
        echo "Using image from imageDefinitions.json: $DOCKER_IMAGE"
    else
        DOCKER_IMAGE="$DEFAULT_IMAGE"
        echo "ImageURI not found in imageDefinitions.json, using default: $DOCKER_IMAGE"
    fi
else
    DOCKER_IMAGE="$DEFAULT_IMAGE"
    echo "imageDefinitions.json not found, using default: $DOCKER_IMAGE"
fi

# Pull the Docker image
echo "Pulling Docker image: $DOCKER_IMAGE"
docker pull "$DOCKER_IMAGE"

# Run the Docker container
echo "Starting container..."
docker run -d --name todo-app -p 8000:8000 "$DOCKER_IMAGE"

echo "Container started successfully!"
docker ps | grep todo-app
