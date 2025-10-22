# Installation Commands Log

## GitHub CLI Installation

### Date: 2025-10-18

### Commands Executed

```bash
# Update package lists
sudo apt update

# Install GitHub CLI
sudo apt install -y gh

# Verify installation
gh --version
# Output: gh version 2.45.0 (2025-07-18 Ubuntu 2.45.0-1ubuntu0.3)

# Authenticate with GitHub
gh auth login
# Interactive authentication completed for account: syrikx
# Protocol: SSH

# Check authentication status
gh auth status
# Logged in to github.com account syrikx
# Git operations protocol: ssh

# Rename branch to main
git branch -M main

# Create GitHub repository
gh repo create reading-turtle --public --source=. --remote=origin
# Repository created: https://github.com/syrikx/reading-turtle
```

## Installation Result

- GitHub CLI version: 2.45.0
- GitHub account: syrikx
- Repository URL: https://github.com/syrikx/reading-turtle
- Repository visibility: Public
- Git protocol: SSH

## PostgreSQL Installation

### Date: 2025-10-18

### Commands Executed

```bash
# Update package lists
sudo apt update

# Install PostgreSQL and extensions
sudo apt install -y postgresql postgresql-contrib

# Verify installation
psql --version
# Output: psql (PostgreSQL) 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

# Check service status
sudo systemctl status postgresql
# Output: Active: active (exited)
```

## Installation Result

- PostgreSQL version: 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
- Cluster: 16/main
- Data directory: /var/lib/postgresql/16/main
- Service status: Active and enabled
- Default port: 5432
- Locale: en_US.UTF-8
- Encoding: UTF8
- Time zone: Asia/Seoul

## Flutter Installation

### Date: 2025-10-19

### Disk Space Preparation

```bash
# Check disk space
df -h ~
# Output: 99% used, only 304MB available

# Remove temporary files to free space
rm -f booktaco_response*.txt booktaco_response_cleaned*.txt booktaco_search_response*.json *.mp3 reading_turtle.zip

# Remove Python virtual environment and cache
rm -rf __pycache__ venv

# Remove book images temporarily (4.5GB)
rm -rf public/bookimg

# Final disk space
df -h ~
# Output: 78% used, 5.0GB available
```

### Commands Executed

```bash
# Clone Flutter SDK
cd ~
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to PATH (add to ~/.bashrc for permanent)
export PATH="$HOME/flutter/bin:$PATH"

# Update PATH in .bashrc for future sessions
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc

# Verify Flutter installation
flutter --version
# Output: Flutter 3.35.6 • channel stable
#         Framework • revision 9f455d2486 (10 days ago)
#         Engine • hash d2913632a4
#         Tools • Dart 3.9.2 • DevTools 2.48.0

# Run Flutter doctor to check setup
flutter doctor
# Output shows Flutter installed successfully
# Android SDK, Chrome, and Linux toolchain optional for web-only development

# Navigate to project directory
cd /home/syrikx0/reading-turtle/flutter

# Install project dependencies
flutter pub get
# Output: Changed 16 dependencies!
#         48 packages have newer versions available

# Build Flutter web application (debug mode)
flutter build web --debug
# Output: ✓ Built build/web (440.9s)

# Serve the web application
cd build/web
python3 -m http.server 8080 --bind 0.0.0.0
# Server running on http://0.0.0.0:8080
```

## Installation Result

- Flutter version: 3.35.6 (stable channel)
- Dart version: 3.9.2
- DevTools version: 2.48.0
- Installation path: ~/flutter
- Project dependencies: Installed successfully
- Web build: Completed successfully in 440.9 seconds
- Debug server: Running on port 8080
- Server binding: 0.0.0.0 (accessible from all network interfaces)

## Flutter Web Server Access

To access the Flutter web application:
- Local: http://localhost:8080
- Network: http://<your-server-ip>:8080

## Starting Flutter Web Server (Future Sessions)

```bash
# Option 1: Using Python HTTP server (simple, for development)
cd /home/syrikx0/reading-turtle/flutter/build/web
python3 -m http.server 8080 --bind 0.0.0.0

# Option 2: Using Flutter run (with hot reload, slower initial build)
cd /home/syrikx0/reading-turtle/flutter
export PATH="$HOME/flutter/bin:$PATH"
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0

# Option 3: Rebuild and serve
cd /home/syrikx0/reading-turtle/flutter
export PATH="$HOME/flutter/bin:$PATH"
flutter build web --debug
cd build/web
python3 -m http.server 8080 --bind 0.0.0.0
```

## Notes

- **Disk Space**: Flutter requires approximately 650MB. Dart SDK is ~207MB.
- **Book Images**: Removed public/bookimg (4.5GB) to free space. Can be restored from backup or re-downloaded if needed.
- **Python venv**: Removed to save 175MB. Can be recreated with `python3 -m venv venv` if needed.
- **Web-only Development**: Android SDK, Chrome browser, and Linux toolchain are optional for web-only development.
- **Hot Reload**: For hot reload functionality, use `flutter run -d web-server` instead of static build.
- **Production Build**: For production, use `flutter build web --release` instead of `--debug` for optimized output.

## Flutter Build Dependencies Installation

### Date: 2025-10-19

### Commands Executed

```bash
# Install Ninja, CMake, C++ compiler and GTK development libraries
sudo apt update
sudo apt install -y ninja-build cmake build-essential libgtk-3-dev

# Install clang for Flutter Linux development
sudo apt install -y clang

# Verify installations
ninja --version
cmake --version
clang++ --version
```

## Installation Result

- ninja-build: Installed successfully
- cmake: Already installed (version 3.28.3)
- build-essential: Already installed (version 12.10ubuntu1)
- libgtk-3-dev: Installed with 87 additional packages (128 MB)
- clang: Installed (version 18.1.3) with llvm-18 and dependencies (567 MB)

## Nginx Reverse Proxy Configuration

### Date: 2025-10-19

### Configuration File

Location: `/etc/nginx/conf.d/reading-turtle.conf`

```nginx
server {
    listen       80;
    server_name  reading-turtle.com www.reading-turtle.com;

    #access_log  /var/log/nginx/reading-turtle.access.log  main;
    #error_log   /var/log/nginx/reading-turtle.error.log;

    location / {
        proxy_pass http://127.0.0.1:8085;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # WebSocket support for Flutter hot reload
    location /ws {
        proxy_pass http://127.0.0.1:8085;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
    }
}
```

### Commands Executed

```bash
# Copy configuration file to nginx conf.d directory
sudo cp /tmp/reading-turtle.conf /etc/nginx/conf.d/reading-turtle.conf

# Test nginx configuration
sudo nginx -t
# Output: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
#         nginx: configuration file /etc/nginx/nginx.conf test is successful

# Reload nginx to apply new configuration
sudo systemctl reload nginx
```

## Configuration Result

- Domain: reading-turtle.com (and www.reading-turtle.com)
- Backend server: http://127.0.0.1:8085 (Flutter web server)
- Protocol: HTTP (Port 80)
- Proxy features:
  - WebSocket support for Flutter hot reload
  - Client IP forwarding (X-Real-IP, X-Forwarded-For)
  - Protocol forwarding (X-Forwarded-Proto)
- Nginx configuration test: Successful
- Service reload: Successful

## Access URLs

- Domain: http://reading-turtle.com
- Alternative: http://www.reading-turtle.com
- Backend (direct): http://localhost:8085

## Running Flutter Server for Production

```bash
# Navigate to Flutter project directory
cd /home/syrikx0/reading-turtle/flutter

# Run Flutter web server on port 8085 (used by Nginx reverse proxy)
/home/syrikx0/flutter/bin/flutter run -d web-server --web-port=8085 --web-hostname=0.0.0.0
```

## Notes for Nginx Configuration

- **Port**: Flutter server runs on port 8085, Nginx proxies from port 80
- **Domain Setup**: Ensure DNS records for reading-turtle.com point to the server IP
- **SSL/HTTPS**: Consider adding SSL certificate using Let's Encrypt for production
- **WebSocket**: Configured for Flutter hot reload functionality
- **Logs**: Access and error logs can be enabled by uncommenting the log directives
