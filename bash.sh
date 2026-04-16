#!/bin/bash

# Folder utama
mkdir -p src
mkdir -p k8s
mkdir -p .github/workflows

# File aplikasi
cat > src/app.py << 'EOF'
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Repo B! 🚀"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF

# Requirements
echo "flask==2.2.5" > src/requirements.txt

# Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.10-slim

WORKDIR /app

COPY src/requirements.txt .
RUN pip install -r requirements.txt

COPY src/ .

CMD ["python", "app.py"]
EOF

# Deployment YAML
cat > k8s/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: repo-b-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: repo-b-app
  template:
    metadata:
      labels:
        app: repo-b-app
    spec:
      containers:
      - name: repo-b-app
        image: mini-project:production
        ports:
        - containerPort: 5000
EOF

# Service YAML
cat > k8s/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: repo-b-service
spec:
  type: NodePort
  selector:
    app: repo-b-app
  ports:
    - port: 5000
      targetPort: 5000
      nodePort: 30007
EOF

# Workflow caller
cat > .github/workflows/ci.yml << 'EOF'
name: Caller Workflow

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  use-reusable:
    uses: abdlroman/reusable-workflow-repo/.github/workflows/reusable-ci.yml@main
    with:
      environment: production
    secrets:
      docker_username: ${{ secrets.DOCKER_USERNAME }}
      docker_password: ${{ secrets.DOCKER_PASSWORD }}
EOF

# README
echo "# Repo B - Sample Web App with CI/CD" > README.md
echo "This repository contains a simple Flask application with a reusable GitHub Actions workflow for CI/CD." >> README.md
echo "The workflow builds a Docker image and pushes it to Docker Hub, then deploys the application to a Kubernetes cluster." >> README.md   
