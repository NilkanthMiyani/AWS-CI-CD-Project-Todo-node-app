#!/bin/bash
set -e

echo "Stopping existing containers..."

# Stop and remove the todo-app container by name (if exists)
if docker ps -a --format '{{.Names}}' | grep -q "^todo-app$"; then
    echo "Stopping todo-app container..."
    docker stop todo-app || true
    docker rm -f todo-app || true
    echo "todo-app container stopped and removed."
fi

# Also stop any other containers on port 8000 (cleanup)
containerid=$(docker ps -q --filter "publish=8000")
if [ -n "$containerid" ]; then
    echo "Stopping container using port 8000..."
    docker stop $containerid && docker rm -f $containerid
    echo "Container stopped and removed."
fi

# Clean up dangling images to save space
docker image prune -f || true

echo "Cleanup completed."
