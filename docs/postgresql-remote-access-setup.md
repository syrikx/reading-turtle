# PostgreSQL 원격 접속 설정 가이드

## 문제 상황
```
pg_dump: error: connection to server at "121.0.122.46", port 5432 failed: Connection timed out
Is the server running on that host and accepting TCP/IP connections?
```

이 오류는 원격 PostgreSQL 서버가 TCP/IP 연결을 허용하지 않거나 방화벽에서 차단되어 발생합니다.

## 해결 방법

원격 서버(121.0.122.46)에 SSH로 접속하여 다음 설정을 진행해야 합니다.

### 1단계: 원격 서버에 SSH 접속

```bash
ssh user@121.0.122.46
```

### 2단계: postgresql.conf 파일 수정

```bash
# PostgreSQL 버전 확인
psql --version

# postgresql.conf 파일 편집 (PostgreSQL 16 기준)
sudo nano /etc/postgresql/16/main/postgresql.conf

# 또는 PostgreSQL 버전이 다른 경우
sudo nano /etc/postgresql/*/main/postgresql.conf
```

다음 항목을 찾아서 수정:

```conf
# 이 줄을 찾아서
#listen_addresses = 'localhost'

# 다음과 같이 변경 (모든 IP에서 접속 허용)
listen_addresses = '*'

# 또는 특정 IP만 허용하고 싶다면
listen_addresses = 'localhost,121.0.122.46,현재_컴퓨터_IP'
```

### 3단계: pg_hba.conf 파일 수정

```bash
# pg_hba.conf 파일 편집
sudo nano /etc/postgresql/16/main/pg_hba.conf
```

파일 끝에 다음 줄 추가:

```conf
# 모든 IP에서 접속 허용 (개발/테스트용)
host    all             all             0.0.0.0/0               scram-sha-256

# 또는 특정 IP만 허용 (더 안전함 - 권장)
host    all             all             현재_컴퓨터_IP/32       scram-sha-256

# 예시: 192.168.1.100에서만 접속 허용
host    all             all             192.168.1.100/32        scram-sha-256
```

**pg_hba.conf 설명:**
- `host`: TCP/IP 연결 허용
- `all`: 모든 데이터베이스
- `all`: 모든 사용자
- `0.0.0.0/0`: 모든 IP (또는 특정 IP/32)
- `scram-sha-256`: 인증 방법

### 4단계: PostgreSQL 서비스 재시작

```bash
sudo systemctl restart postgresql

# 또는
sudo service postgresql restart
```

### 5단계: 서비스 상태 확인

```bash
sudo systemctl status postgresql
```

### 6단계: PostgreSQL이 5432 포트에서 리스닝하는지 확인

```bash
sudo netstat -tuln | grep 5432

# 또는
sudo ss -tuln | grep 5432

# 다음과 같이 표시되어야 함:
# tcp  0  0  0.0.0.0:5432  0.0.0.0:*  LISTEN
```

### 7단계: 방화벽 설정 (필요한 경우)

#### UFW 사용하는 경우:

```bash
# 방화벽 상태 확인
sudo ufw status

# 5432 포트 허용
sudo ufw allow 5432/tcp

# 또는 특정 IP에서만 허용 (더 안전함)
sudo ufw allow from 현재_컴퓨터_IP to any port 5432
```

#### firewalld 사용하는 경우:

```bash
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --reload
```

#### iptables 사용하는 경우:

```bash
sudo iptables -A INPUT -p tcp --dport 5432 -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4
```

### 8단계: 클라우드/호스팅 방화벽 확인

클라우드 서비스(AWS, GCP, Azure, Vultr 등)를 사용하는 경우:
- 보안 그룹(Security Group) 설정에서 5432 포트 인바운드 규칙 추가
- 네트워크 ACL 확인

## 로컬 컴퓨터에서 연결 테스트

원격 서버 설정 완료 후, 로컬 컴퓨터에서:

```bash
# 1. 포트 연결 테스트
telnet 121.0.122.46 5432

# 또는
nc -zv 121.0.122.46 5432

# 2. PostgreSQL 연결 테스트
psql -h 121.0.122.46 -U username -d postgres -c "SELECT version();"

# 3. 연결 성공하면 마이그레이션 진행
pg_dump -h 121.0.122.46 -p 5432 -U username -d source_database -W | sudo -u postgres psql target_database
```

## 현재 컴퓨터 IP 확인 방법

로컬 컴퓨터의 공인 IP를 확인하려면:

```bash
# 로컬 컴퓨터에서 실행
curl ifconfig.me

# 또는
curl icanhazip.com

# 또는
curl ipinfo.io/ip
```

이 IP를 pg_hba.conf에 설정하세요.

## 보안 권장사항

1. **특정 IP만 허용**: `0.0.0.0/0` 대신 특정 IP 사용
2. **강력한 비밀번호**: PostgreSQL 사용자 비밀번호 강화
3. **SSL/TLS 사용**: 암호화된 연결 설정
4. **방화벽 규칙**: 필요한 IP만 허용
5. **VPN 사용**: 가능하면 VPN 통해 접속

## 설정 파일 위치 참고

PostgreSQL 버전별 설정 파일 위치:

```bash
# PostgreSQL 16
/etc/postgresql/16/main/postgresql.conf
/etc/postgresql/16/main/pg_hba.conf

# PostgreSQL 15
/etc/postgresql/15/main/postgresql.conf
/etc/postgresql/15/main/pg_hba.conf

# PostgreSQL 14
/etc/postgresql/14/main/postgresql.conf
/etc/postgresql/14/main/pg_hba.conf

# 현재 설정 파일 위치 확인
sudo -u postgres psql -c "SHOW config_file;"
sudo -u postgres psql -c "SHOW hba_file;"
```

## 문제 해결

### 여전히 연결 안 됨

```bash
# PostgreSQL 로그 확인
sudo tail -f /var/log/postgresql/postgresql-16-main.log

# 또는
sudo journalctl -u postgresql -f
```

### 포트 충돌 확인

```bash
# 5432 포트를 사용하는 프로세스 확인
sudo lsof -i :5432
```

### 설정 파일 문법 오류 확인

```bash
# PostgreSQL 설정 검증
sudo -u postgres /usr/lib/postgresql/16/bin/postgres -C config_file
```

## 요약: 빠른 설정 스크립트

원격 서버(121.0.122.46)에서 실행:

```bash
# 1. postgresql.conf 수정
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/16/main/postgresql.conf

# 2. pg_hba.conf에 접속 허용 추가 (모든 IP - 주의!)
echo "host    all             all             0.0.0.0/0               scram-sha-256" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf

# 3. PostgreSQL 재시작
sudo systemctl restart postgresql

# 4. 방화벽 포트 열기
sudo ufw allow 5432/tcp
```

**주의**: 위 스크립트는 모든 IP에서 접속을 허용하므로 보안에 주의하세요!
