# Simple AWS Deployment (No EB CLI Required)

The easiest way to deploy without the EB CLI is using AWS Lightsail or manual Docker deployment.

## Method 1: AWS Lightsail (Recommended - Easiest & Cheapest)

### Step 1: Build Your Docker Image Locally

```bash
docker build -t mutoon-website .
```

### Step 2: Deploy via AWS Console

1. Go to [AWS Lightsail Console](https://lightsail.aws.amazon.com/)
2. Click **Create container service**
3. Choose your region (e.g., London - eu-west-2)
4. Choose capacity: **Nano** ($10/month) or **Micro** ($15/month)
5. Set number of nodes: **1**
6. Click **Set up deployment**
7. Click **Upload your container image**
8. Upload your image or use the manual method below

### Step 3: Manual Image Upload

```bash
# Install AWS CLI if you haven't
# macOS:
brew install awscli

# Configure AWS
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Region: eu-west-2
# Output format: json

# Create Lightsail container service
aws lightsail create-container-service \
  --service-name mutoon-website \
  --power nano \
  --scale 1 \
  --region eu-west-2

# Push your image
aws lightsail push-container-image \
  --service-name mutoon-website \
  --label mutoon-v1 \
  --image mutoon-website \
  --region eu-west-2
```

### Step 4: Deploy Container

After pushing, you'll get an image name like `:mutoon-website.mutoon-v1.X`

Create file `deployment.json`:

```json
{
  "containers": {
    "mutoon": {
      "image": ":mutoon-website.mutoon-v1.1",
      "ports": {
        "80": "HTTP"
      }
    }
  },
  "publicEndpoint": {
    "containerName": "mutoon",
    "containerPort": 80,
    "healthCheck": {
      "path": "/"
    }
  }
}
```

Deploy:

```bash
aws lightsail create-container-service-deployment \
  --service-name mutoon-website \
  --cli-input-json file://deployment.json \
  --region eu-west-2
```

### Step 5: Get Your Website URL

```bash
aws lightsail get-container-services \
  --service-name mutoon-website \
  --region eu-west-2
```

Look for the `url` field - that's your live website!

---

## Method 2: Docker Hub + AWS App Runner (Very Easy)

### Step 1: Push to Docker Hub

```bash
# Login to Docker Hub (create free account at hub.docker.com)
docker login

# Tag your image
docker tag mutoon-website:latest YOUR_DOCKERHUB_USERNAME/mutoon-website:latest

# Push to Docker Hub
docker push YOUR_DOCKERHUB_USERNAME/mutoon-website:latest
```

### Step 2: Deploy with AWS App Runner

1. Go to [AWS App Runner Console](https://console.aws.amazon.com/apprunner/)
2. Click **Create service**
3. Choose **Container registry** → **Docker Hub**
4. Repository URL: `docker.io/YOUR_DOCKERHUB_USERNAME/mutoon-website:latest`
5. Deployment: **Manual**
6. Configure:
   - Port: `80`
   - CPU: `1 vCPU`
   - Memory: `2 GB`
7. Click **Create & deploy**

Your website will be live in a few minutes with a URL like: `https://xxxxx.eu-west-2.awsapprunner.com`

**Cost**: ~$0.007/hour when running (~$5/month if always on)

---

## Method 3: Simple EC2 with Docker

### Step 1: Launch EC2 Instance

1. Go to [EC2 Console](https://console.aws.amazon.com/ec2/)
2. Click **Launch Instance**
3. Choose **Amazon Linux 2023**
4. Instance type: **t2.micro** (free tier)
5. Key pair: Create new or use existing
6. Network settings: Allow HTTP (port 80) and SSH (port 22)
7. Click **Launch instance**

### Step 2: Connect and Install Docker

```bash
# Connect to your instance
ssh -i your-key.pem ec2-user@YOUR_INSTANCE_IP

# Install Docker
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Logout and login again for group changes to take effect
exit
ssh -i your-key.pem ec2-user@YOUR_INSTANCE_IP
```

### Step 3: Transfer and Run Your Website

**Option A: Build on EC2**

```bash
# Copy your files to EC2
scp -i your-key.pem -r * ec2-user@YOUR_INSTANCE_IP:~/mutoon/

# On EC2, build and run
cd ~/mutoon
docker build -t mutoon-website .
docker run -d -p 80:80 --restart unless-stopped mutoon-website
```

**Option B: Use Docker Hub**

```bash
# On EC2
docker pull YOUR_DOCKERHUB_USERNAME/mutoon-website:latest
docker run -d -p 80:80 --restart unless-stopped YOUR_DOCKERHUB_USERNAME/mutoon-website:latest
```

Visit your EC2 public IP to see your website!

**Cost**: Free tier eligible (~$0 for first year, then ~$8/month)

---

## Fix EB CLI Python Issue (Alternative)

If you still want to use Elastic Beanstalk:

### Option 1: Use Python 3.9

```bash
# Using pyenv (recommended)
brew install pyenv
pyenv install 3.9.18
pyenv local 3.9.18

# Install EB CLI
pip install awsebcli --upgrade
```

### Option 2: Use Virtual Environment

```bash
# Create virtual environment with Python 3.9
python3.9 -m venv eb-venv
source eb-venv/bin/activate

# Install EB CLI
pip install awsebcli
```

### Option 3: Use Docker to Run EB CLI

```bash
# Use official EB CLI Docker image
docker run -it --rm \
  -v ~/.aws:/root/.aws \
  -v $(pwd):/app \
  -w /app \
  amazon/aws-cli:latest eb --version
```

---

## Comparison

| Method | Cost/Month | Difficulty | Deploy Time | Best For |
|--------|-----------|------------|-------------|----------|
| **Lightsail** | $10-15 | Easy | 10 min | Simple sites |
| **App Runner** | $5-10 | Easiest | 5 min | Quick deploys |
| **EC2** | $0-8 | Medium | 15 min | Full control |
| **EB (fixed)** | $15-30 | Easy | 10 min | Scalability |

## Recommendation

**Start with AWS Lightsail** - it's the perfect balance of easy, cheap, and reliable for your website.

Quick command summary:
```bash
# 1. Build locally
docker build -t mutoon-website .

# 2. Configure AWS
aws configure

# 3. Create service
aws lightsail create-container-service \
  --service-name mutoon-website \
  --power nano \
  --scale 1 \
  --region eu-west-2

# 4. Push image
aws lightsail push-container-image \
  --service-name mutoon-website \
  --label mutoon-v1 \
  --image mutoon-website \
  --region eu-west-2

# 5. Create deployment.json file and deploy
aws lightsail create-container-service-deployment \
  --service-name mutoon-website \
  --cli-input-json file://deployment.json \
  --region eu-west-2
```

That's it! Your website will be live in minutes.
