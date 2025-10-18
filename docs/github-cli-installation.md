# GitHub CLI Installation Guide

## Installation Commands

GitHub CLI (gh) 설치가 필요합니다. 아래 명령어를 터미널에서 직접 실행해주세요.

### Ubuntu/Debian

```bash
# Update package list
sudo apt update

# Install GitHub CLI
sudo apt install -y gh
```

### Alternative: Using Official Repository

```bash
# Add GitHub CLI repository
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

# Add repository to sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Update and install
sudo apt update
sudo apt install gh
```

## Post-Installation Steps

### 1. Verify Installation
```bash
gh --version
```

### 2. Authenticate with GitHub
```bash
gh auth login
```

선택 사항:
- What account do you want to log into? → **GitHub.com**
- What is your preferred protocol for Git operations? → **HTTPS** (또는 SSH)
- Authenticate Git with your GitHub credentials? → **Yes**
- How would you like to authenticate? → **Login with a web browser** (추천)

### 3. Create Repository

```bash
# Create and push repository
gh repo create reading-turtle --public --source=. --remote=origin --push
```

또는 private 저장소로 생성:
```bash
gh repo create reading-turtle --private --source=. --remote=origin --push
```

## User Configuration

이미 설정된 Git 사용자 정보:
```bash
git config --global user.name "syrikx"
git config --global user.email "syrikx@gmail.com"
```

## Next Steps

1. 위의 설치 명령어를 터미널에서 실행
2. `gh auth login` 으로 GitHub 인증
3. `gh repo create` 명령어로 저장소 생성 및 푸시
