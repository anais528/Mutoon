# Mutoon Website - AWS Deployment Guide

This guide will help you deploy your Mutoon website to AWS using Docker.

## Prerequisites

1. **AWS Account**: Sign up at [aws.amazon.com](https://aws.amazon.com)
2. **Docker**: Install from [docker.com](https://www.docker.com/products/docker-desktop)
3. **AWS CLI**: Install from [aws.amazon.com/cli](https://aws.amazon.com/cli/)

## Option 1: Deploy to AWS Elastic Beanstalk (Easiest)

### Step 1: Build and Test Locally

```bash
# Build the Docker image
docker build -t mutoon-website .

# Test it locally
docker run -p 8080:80 mutoon-website

# Visit http://localhost:8080 in your browser to test
```

### Step 2: Install Elastic Beanstalk CLI

```bash
pip install awsebcli
```

### Step 3: Initialize and Deploy

```bash
# Initialize EB application
eb init -p docker mutoon-website --region eu-west-2

# Create environment and deploy
eb create mutoon-production

# Open in browser
eb open
```

### Step 4: Update Deployment

```bash
# After making changes, redeploy with:
eb deploy
```

## Option 2: Deploy to AWS ECS (Recommended for Production)

### Step 1: Create ECR Repository

```bash
# Login to AWS
aws configure

# Create ECR repository
aws ecr create-repository --repository-name mutoon-website --region eu-west-2

# Get repository URI (save this)
aws ecr describe-repositories --repository-names mutoon-website --region eu-west-2
```

### Step 2: Build and Push Docker Image

```bash
# Login to ECR
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com

# Build image
docker build -t mutoon-website .

# Tag image
docker tag mutoon-website:latest YOUR_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/mutoon-website:latest

# Push to ECR
docker push YOUR_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/mutoon-website:latest
```

### Step 3: Create ECS Cluster (via AWS Console)

1. Go to **ECS** in AWS Console
2. Click **Create Cluster**
3. Choose **Networking only** (Fargate)
4. Name: `mutoon-cluster`
5. Click **Create**

### Step 4: Create Task Definition

1. Go to **Task Definitions** → **Create new Task Definition**
2. Choose **Fargate**
3. Configure:
   - Task Definition Name: `mutoon-task`
   - Task Memory: `0.5GB`
   - Task CPU: `0.25 vCPU`
   - Container Definitions:
     - Name: `mutoon-container`
     - Image: `YOUR_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/mutoon-website:latest`
     - Port mappings: `80`
4. Click **Create**

### Step 5: Create Service

1. Go to your cluster → **Services** → **Create**
2. Configure:
   - Launch type: `Fargate`
   - Task Definition: `mutoon-task`
   - Service name: `mutoon-service`
   - Number of tasks: `1`
   - VPC: Default VPC
   - Subnets: Select all
   - Security group: Create new, allow port 80
   - Load balancer: Application Load Balancer (optional but recommended)
3. Click **Create Service**

## Option 3: Deploy to AWS Lightsail (Cheapest)

### Step 1: Create Container Service

```bash
# Create container service
aws lightsail create-container-service \
  --service-name mutoon-container \
  --power small \
  --scale 1 \
  --region eu-west-2
```

### Step 2: Push Container

```bash
# Build and push
aws lightsail push-container-image \
  --service-name mutoon-container \
  --label mutoon-website \
  --image mutoon-website:latest \
  --region eu-west-2
```

### Step 3: Deploy Container

Create a file `containers.json`:

```json
{
  "mutoon": {
    "image": ":mutoon-container.mutoon-website.1",
    "ports": {
      "80": "HTTP"
    }
  }
}
```

Create a file `public-endpoint.json`:

```json
{
  "containerName": "mutoon",
  "containerPort": 80
}
```

Deploy:

```bash
aws lightsail create-container-service-deployment \
  --service-name mutoon-container \
  --containers file://containers.json \
  --public-endpoint file://public-endpoint.json \
  --region eu-west-2
```

## Adding Custom Domain (Optional)

### For Elastic Beanstalk or ECS with ALB:

1. Go to **Route 53** → **Hosted Zones**
2. Create hosted zone for `mutoon.co.uk`
3. Create **A Record** pointing to your Load Balancer
4. Update nameservers with your domain registrar

### For SSL Certificate:

1. Go to **AWS Certificate Manager**
2. Request public certificate for `mutoon.co.uk` and `www.mutoon.co.uk`
3. Validate via DNS
4. Attach certificate to your Load Balancer

## Monitoring and Logs

```bash
# View logs (Elastic Beanstalk)
eb logs

# View logs (ECS)
# Go to CloudWatch Logs in AWS Console

# Check service status
aws ecs describe-services --cluster mutoon-cluster --services mutoon-service --region eu-west-2
```

## Cost Estimates (Monthly)

- **Lightsail**: $10-20/month (cheapest)
- **Elastic Beanstalk**: $15-30/month (easiest)
- **ECS Fargate**: $20-40/month (most scalable)

## Troubleshooting

### Container won't start
```bash
# Check logs
docker logs [container-id]

# Test locally first
docker run -p 8080:80 mutoon-website
```

### Images not loading
- Ensure all image files (.jpeg, .png) are in the same directory as Dockerfile
- Check nginx logs for 404 errors

### Port issues
- Ensure security groups allow inbound traffic on port 80
- Check if health checks are passing

## Support

For issues, contact your AWS support or check:
- [AWS Documentation](https://docs.aws.amazon.com)
- [Docker Documentation](https://docs.docker.com)

---

**Quick Start Command Summary:**

```bash
# Build and test locally
docker build -t mutoon-website .
docker run -p 8080:80 mutoon-website

# Deploy to Elastic Beanstalk (easiest)
eb init -p docker mutoon-website --region eu-west-2
eb create mutoon-production
eb open

# Update after changes
eb deploy
```
