# ReadingTurtle Flutter App - Deployment Guide

## 프로덕션 배포 (reading-turtle.com)

### 1. Nginx 설정

Flutter 앱과 백엔드 API를 같은 도메인에서 서빙하기 위한 Nginx 설정입니다.

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name reading-turtle.com www.reading-turtle.com;

    # SSL 설정 (certbot으로 자동 생성됨)
    # listen 443 ssl;
    # ssl_certificate /etc/letsencrypt/live/reading-turtle.com/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/reading-turtle.com/privkey.pem;

    # Flutter 웹 앱 (정적 파일)
    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;

        # CORS 헤더 (필요시)
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE';
        add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization';
    }

    # 백엔드 API 프록시
    location /api/ {
        proxy_pass http://localhost:8010;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # 책 이미지 프록시
    location /bookimg/ {
        proxy_pass http://localhost:8010;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;

        # 이미지 캐싱 설정
        expires 7d;
        add_header Cache-Control "public, immutable";
    }

    # 정적 파일 캐싱
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://localhost:8080;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

### 2. 프로덕션 빌드

#### 웹 빌드 (정적 파일)
```bash
cd /home/syrikx/booktaco/reading_turtle

# 웹용 릴리스 빌드
flutter build web --release

# 빌드된 파일은 build/web/ 에 생성됨
# Nginx로 직접 서빙하려면:
# sudo cp -r build/web/* /var/www/reading-turtle/
```

#### 개발 서버로 실행 (현재 방식)
```bash
# Flutter 개발 서버 실행 (포트 8080, IPv4+IPv6 지원)
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080

# 또는 백그라운드 실행
nohup flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 > flutter.log 2>&1 &

# VS Code launch.json 설정을 사용하는 경우:
# F5를 누르고 "Flutter Web Server (0.0.0.0:8080)" 선택
```

**주의**: `--web-hostname 0.0.0.0`을 사용하면 IPv4와 IPv6 모두에서 리스닝합니다.
- IPv4: `127.0.0.1:8080`
- IPv6: `[::1]:8080`
- 외부 접근: `<서버IP>:8080`

### 3. 환경별 API URL 설정

앱은 자동으로 환경을 감지합니다:

- **localhost 개발**: `http://localhost:8010` 사용
- **reading-turtle.com 프로덕션**: 상대 경로 사용 (Nginx가 프록시)

코드 위치: `lib/core/config/api_config.dart`

```dart
static String get baseUrl {
  final hostname = Uri.base.host;

  if (hostname == 'localhost' || hostname == '127.0.0.1') {
    return 'http://localhost:8010';  // 개발
  } else {
    return '';  // 프로덕션 (상대 경로)
  }
}
```

### 4. 백엔드 서버 실행

```bash
cd /home/syrikx/booktaco

# Node.js 서버 실행 (포트 8010)
node server.js

# 또는 PM2로 데몬화
pm2 start server.js --name reading-turtle-api
pm2 save
pm2 startup
```

### 5. 배포 체크리스트

#### 백엔드 (Node.js + PostgreSQL)
- [ ] PostgreSQL 데이터베이스 실행 중
- [ ] 환경변수 설정 (DB_HOST, DB_USER, DB_PASSWORD 등)
- [ ] Node.js 서버 실행 (포트 8010)
- [ ] `/api/auth/login` 엔드포인트 테스트

#### 프론트엔드 (Flutter Web)
- [ ] Flutter 웹 빌드 완료
- [ ] 정적 파일 또는 dev server 실행 (포트 8080)
- [ ] Nginx 설정 완료 및 재시작

#### Nginx
- [ ] Nginx 설정 파일 작성
- [ ] 설정 테스트: `sudo nginx -t`
- [ ] Nginx 재시작: `sudo systemctl restart nginx`
- [ ] SSL 인증서 설정 (Let's Encrypt)

#### DNS
- [ ] reading-turtle.com → 서버 IP 연결 확인
- [ ] www.reading-turtle.com → 서버 IP 연결 확인

### 6. 테스트

#### 로컬 테스트
```bash
# localhost로 접속
http://localhost:8080

# API 직접 테스트
curl http://localhost:8010/api/auth/login
```

#### 프로덕션 테스트
```bash
# 도메인으로 접속
https://reading-turtle.com

# API 테스트 (Nginx 프록시 통과)
curl https://reading-turtle.com/api/auth/login

# 브라우저 개발자 도구에서 확인
# Network 탭 -> /api/auth/login 요청 확인
# 요청 URL이 https://reading-turtle.com/api/auth/login 이어야 함
```

### 7. 문제 해결

#### CORS 에러가 발생하는 경우
- Nginx 설정에서 CORS 헤더 확인
- 백엔드 `server.js`에서 CORS 설정 확인

#### API 연결 안 되는 경우
1. 백엔드 서버 실행 확인: `curl http://localhost:8010/api/auth/login`
2. Nginx 프록시 확인: `curl http://localhost/api/auth/login`
3. Nginx 로그 확인: `sudo tail -f /var/log/nginx/error.log`

#### 이미지 안 보이는 경우
1. 이미지 파일 존재 확인: `ls /home/syrikx/booktaco/public/bookimg/`
2. Nginx `/bookimg/` 프록시 설정 확인
3. 브라우저 Network 탭에서 이미지 요청 확인

### 8. 모니터링

#### 서비스 상태 확인
```bash
# Nginx 상태
sudo systemctl status nginx

# Node.js 서버 (PM2 사용시)
pm2 status
pm2 logs reading-turtle-api

# PostgreSQL
sudo systemctl status postgresql
```

#### 로그 확인
```bash
# Nginx 액세스 로그
sudo tail -f /var/log/nginx/access.log

# Nginx 에러 로그
sudo tail -f /var/log/nginx/error.log

# Node.js 로그 (PM2)
pm2 logs reading-turtle-api

# Flutter dev server 로그
tail -f flutter.log
```

## 개발 환경 vs 프로덕션 환경

| 항목 | 개발 (localhost) | 프로덕션 (reading-turtle.com) |
|------|------------------|------------------------------|
| Flutter App | http://localhost:8080 | http://reading-turtle.com (Nginx) |
| API Base URL | http://localhost:8010 | 상대 경로 (Nginx 프록시) |
| 인증 API | http://localhost:8010/api/auth/login | https://reading-turtle.com/api/auth/login |
| 이미지 | http://localhost:8010/bookimg/xxx.jpg | https://reading-turtle.com/bookimg/xxx.jpg |

## 보안 고려사항

1. **HTTPS 필수**: Let's Encrypt로 SSL 인증서 설정
2. **JWT 토큰**: HttpOnly 쿠키 사용 (XSS 방지)
3. **CORS**: 필요한 도메인만 허용
4. **환경변수**: DB 비밀번호 등 민감 정보 관리
5. **Rate Limiting**: Nginx에서 요청 제한 설정

## 성능 최적화

1. **정적 파일 캐싱**: Nginx에서 이미지, JS, CSS 캐싱
2. **Gzip 압축**: Nginx에서 텍스트 압축 활성화
3. **CDN**: CloudFlare 등 CDN 사용 고려
4. **이미지 최적화**: WebP 포맷 사용 고려
5. **코드 분할**: Flutter 빌드 최적화
