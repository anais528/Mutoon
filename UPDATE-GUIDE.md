# How to Update Your Website

Updating your website is super easy! Just 3 commands.

## For AWS App Runner

### When you make changes to your website:

```bash
# 1. Build the new version
docker build -t mutoon-website .

# 2. Push to Docker Hub (replace YOUR_USERNAME)
docker tag mutoon-website:latest YOUR_USERNAME/mutoon-website:latest
docker push YOUR_USERNAME/mutoon-website:latest

# 3. Deploy in AWS
# Go to AWS App Runner Console → Your service → Click "Deploy" button
```

**That's it!** Your website will update in 2-3 minutes.

### Make it even easier with a script:

Create a file called `update.sh`:

```bash
#!/bin/bash

# Replace with your Docker Hub username
USERNAME="YOUR_DOCKERHUB_USERNAME"

echo "Building new version..."
docker build -t mutoon-website .

echo "Pushing to Docker Hub..."
docker tag mutoon-website:latest $USERNAME/mutoon-website:latest
docker push $USERNAME/mutoon-website:latest

echo "✅ Done! Now go to AWS App Runner and click 'Deploy'"
echo "URL: https://console.aws.amazon.com/apprunner/"
```

Make it executable:
```bash
chmod +x update.sh
```

Now just run:
```bash
./update.sh
```

Then click "Deploy" in AWS App Runner Console!

---

## For AWS EC2

### When you make changes:

```bash
# 1. Build and push new version
docker build -t mutoon-website .
docker tag mutoon-website:latest YOUR_USERNAME/mutoon-website:latest
docker push YOUR_USERNAME/mutoon-website:latest

# 2. SSH into your EC2 instance
ssh -i ~/Downloads/mutoon-key.pem ec2-user@YOUR_INSTANCE_IP

# 3. Update the container
docker stop mutoon
docker rm mutoon
docker pull YOUR_USERNAME/mutoon-website:latest
docker run -d -p 80:80 --restart unless-stopped --name mutoon YOUR_USERNAME/mutoon-website:latest

# 4. Exit
exit
```

**Done!** Changes are live immediately.

### Make it even easier - Create an update script on EC2:

First time setup - SSH into EC2 and create `update.sh`:

```bash
#!/bin/bash
USERNAME="YOUR_DOCKERHUB_USERNAME"

echo "Stopping old container..."
docker stop mutoon
docker rm mutoon

echo "Pulling new version..."
docker pull $USERNAME/mutoon-website:latest

echo "Starting new container..."
docker run -d -p 80:80 --restart unless-stopped --name mutoon $USERNAME/mutoon-website:latest

echo "✅ Website updated!"
docker ps
```

Make it executable:
```bash
chmod +x update.sh
```

Now whenever you want to update:

```bash
# On your Mac - build and push
./update.sh  # (the local update script)

# SSH and update on server
ssh -i ~/Downloads/mutoon-key.pem ec2-user@YOUR_INSTANCE_IP './update.sh'
```

---

## Comparison: Update Process

| Method | Update Steps | Downtime | Difficulty |
|--------|-------------|----------|------------|
| **App Runner** | 1. Push to Docker Hub<br>2. Click "Deploy" in Console | ~2 min | ⭐ Easiest |
| **EC2** | 1. Push to Docker Hub<br>2. SSH and restart container | ~5 sec | ⭐⭐ Easy |

Both are very easy! App Runner is slightly simpler, EC2 has less downtime.

---

## Common Changes You Might Make

### Change Text or Images
1. Edit `index-draft3.html`
2. Run update process
3. Done!

### Change Author Names on Workbooks
1. Edit `index-draft3.html` - find the author section
2. Run update process
3. Done!

### Add New Workbook Images
1. Add new `.jpeg` or `.png` files to the folder
2. Update `index-draft3.html` to reference them
3. Run update process
4. Done!

### Change Colors/Styling
1. Edit the `<style>` section in `index-draft3.html`
2. Run update process
3. Done!

---

## Testing Changes Before Deploying

**Always test locally first!**

```bash
# After making changes, test locally
docker build -t mutoon-website .
docker run -p 8080:80 mutoon-website

# Visit http://localhost:8080 in your browser
# If it looks good, proceed with deployment
# Press Ctrl+C to stop
```

---

## Automatic Updates (Optional Advanced)

If you want automatic updates whenever you push changes:

### For App Runner:
1. In App Runner Console, go to your service
2. Configuration → Edit
3. Change Deployment to **Automatic**
4. Now whenever you push to Docker Hub, App Runner auto-deploys!

### For EC2 with GitHub Actions:
I can set this up for you if you want - just push to GitHub and it auto-deploys!

---

## Need Help?

The update process is very simple:
1. Make your changes
2. Build Docker image
3. Push to Docker Hub
4. Deploy (click button for App Runner, or run script for EC2)

Takes less than 5 minutes! 🚀
