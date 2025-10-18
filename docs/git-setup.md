# Git Setup Guide

## Git Configuration

### User Configuration
```bash
git config --global user.email "syrikx@gmail.com"
git config --global user.name "syrikx"
```

## Repository Initialization

### Initialize Local Repository
```bash
git init
```

## GitHub Repository Setup

### Manual Setup Steps

1. **Create GitHub Repository**
   - Go to https://github.com/new
   - Repository name: `reading-turtle`
   - Choose public or private
   - Do NOT initialize with README, .gitignore, or license (since we already have a local repo)
   - Click "Create repository"

2. **Connect Local Repository to GitHub**
   ```bash
   git remote add origin https://github.com/syrikx/reading-turtle.git
   ```

   Or using SSH (recommended):
   ```bash
   git remote add origin git@github.com:syrikx/reading-turtle.git
   ```

3. **Set Default Branch to Main**
   ```bash
   git branch -M main
   ```

4. **Initial Commit**
   ```bash
   git add .
   git commit -m "Initial commit"
   ```

5. **Push to GitHub**
   ```bash
   git push -u origin main
   ```

## Next Steps

After creating the repository on GitHub:
1. Copy the repository URL from GitHub
2. Run the commands in section "Connect Local Repository to GitHub"
3. Make your initial commit
4. Push to GitHub

## Alternative: Install GitHub CLI

If you want to create repositories from command line in the future:

```bash
# Install GitHub CLI (Debian/Ubuntu)
sudo apt update
sudo apt install gh

# Authenticate
gh auth login

# Create repository directly from CLI
gh repo create reading-turtle --public --source=. --remote=origin --push
```
