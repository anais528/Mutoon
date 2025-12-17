# Quick Start: Deploy to AWS App Runner

## Step 1: Create Docker Hub Account (Free)

1. Go to https://hub.docker.com
2. Click "Sign Up"
3. Create a free account

## Step 2: Build and Push Your Website

Open your terminal in the Mutoon folder and run:

```bash
# Build your Docker image
docker build -t mutoon-website .

# Test it locally (optional but recommended)
docker run -p 8080:80 mutoon-website
# Visit http://localhost:8080 to verify it works
# Press Ctrl+C to stop

# Login to Docker Hub
docker login
# Enter your Docker Hub username and password

# Tag your image (replace YOUR_USERNAME with your Docker Hub username)
docker tag mutoon-website:latest YOUR_USERNAME/mutoon-website:latest

# Push to Docker Hub
docker push YOUR_USERNAME/mutoon-website:latest
```

## Step 3: Deploy on AWS App Runner

1. Go to **AWS Console**: https://console.aws.amazon.com
2. Log in or create an AWS account (free tier available)
3. Search for "**App Runner**" in the search bar
4. Click **"Create service"**

### Configuration:

**Repository:**
- Source: **Container registry**
- Provider: **ECR Public** or **Other registry**
- Repository type: **Public**
- Repository URL: `docker.io/YOUR_USERNAME/mutoon-website:latest`
  (Replace YOUR_USERNAME with your Docker Hub username)
- Deployment: **Manual**
- Click **Next**

**Service settings:**
- Service name: `mutoon-website`
- Port: `80`
- Click **Next**

**Configure service:**
- CPU: `1 vCPU`
- Memory: `2 GB`
- Environment variables: None needed
- Click **Next**

**Review and create:**
- Review all settings
- Click **Create & deploy**

## Step 4: Wait and Access Your Website

1. Wait 5-10 minutes for deployment to complete
2. You'll see a URL like: `https://xxxxx.eu-west-2.awsapprunner.com`
3. Click on the URL to view your live website!

## Cost

- **App Runner**: ~$0.007 per hour when running
- If running 24/7: ~$5/month
- If paused when not in use: ~$1-2/month

## Update Your Website

When you make changes:

```bash
# Build new version
docker build -t mutoon-website .

# Push to Docker Hub
docker tag mutoon-website:latest YOUR_USERNAME/mutoon-website:latest
docker push YOUR_USERNAME/mutoon-website:latest

# In AWS App Runner Console:
# Click on your service → "Deploy" → "Deploy latest"
```

---

## Alternative: EC2 with Docker (Free Tier Eligible)

If you prefer EC2 (more control, free for 1 year):

### Step 1: Launch EC2 Instance

1. Go to **EC2 Console**: https://console.aws.amazon.com/ec2
2. Click **"Launch Instance"**
3. Name: `mutoon-server`
4. Choose **Amazon Linux 2023** (Free tier eligible)
5. Instance type: **t2.micro** (Free tier eligible)
6. Key pair: Create new key pair
   - Name: `mutoon-key`
   - Type: RSA
   - Format: .pem
   - **Download and save** the key file
7. Network settings:
   - Click "Edit"
   - Allow HTTP traffic (port 80) ✓
   - Allow SSH traffic (port 22) ✓
8. Click **"Launch instance"**

### Step 2: Connect to Your Server

```bash
# Make key file private (on your Mac)
chmod 400 ~/Downloads/mutoon-key.pem

# Get your instance public IP from EC2 console
# Replace YOUR_INSTANCE_IP below

# Connect via SSH
ssh -i ~/Downloads/mutoon-key.pem ec2-user@YOUR_INSTANCE_IP
```

### Step 3: Install Docker on EC2

Once connected, run these commands:

```bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install docker -y
 
# Start Docker service done
sudo service docker start

# Add user to docker group
sudo usermod -a -G docker ec2-user

# Exit and reconnect for changes to take effect
exit
```

Reconnect:

```bash
ssh -i mutoon-key.pem ec2-user@YOUR_INSTANCE_IP
```

### Step 4: Run Your Website

```bash
# Pull your image from Docker Hub
docker pull YOUR_USERNAME/mutoon-website:latest

# Run the container
docker run -d -p 80:80 --restart unless-stopped --name mutoon YOUR_USERNAME/mutoon-website:latest

# Check if it's running
docker ps
```

### Step 5: Access Your Website

Visit `http://YOUR_INSTANCE_IP` in your browser!

---

## Which Method Should You Choose?

| Method | Pros | Cons | Cost |
|--------|------|------|------|
| **App Runner** | ✅ Easiest<br>✅ Auto-scaling<br>✅ Managed | ❌ Less control | $5/month |
| **EC2** | ✅ Free tier (1 year)<br>✅ Full control<br>✅ Cheapest long-term | ❌ Manual setup<br>❌ You manage server | $0-8/month |

**Recommendation**: Start with **App Runner** for simplicity. You can always migrate to EC2 later if needed.

---

## Need Help?

If you get stuck at any step, let me know which step and what error you're seeing!
