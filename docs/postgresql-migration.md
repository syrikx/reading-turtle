# PostgreSQL Online Migration Guide

## 원격 DB에서 로컬로 직접 마이그레이션

원격 PostgreSQL 데이터베이스(121.0.122.46)에서 로컬로 데이터를 직접 마이그레이션하는 방법입니다.

## 방법 1: pg_dump를 통한 직접 파이프 (추천)

이 방법은 원격 DB에서 직접 덤프를 받아 로컬 DB로 바로 복원합니다.

### 단계별 진행

#### 1. 원격 DB에서 로컬 DB로 직접 마이그레이션

```bash
# 방법 A: 파이프를 통한 직접 마이그레이션
pg_dump -h 121.0.122.46 -U username -d source_database | psql -U local_user -d target_database

# 방법 B: 압축을 사용한 마이그레이션 (더 빠름)
pg_dump -h 121.0.122.46 -U username -d source_database | gzip | gunzip | psql -U local_user -d target_database

# 방법 C: 네트워크를 통한 직접 마이그레이션 (가장 권장)
pg_dump -h 121.0.122.46 -U username -d source_database -Fc | pg_restore -d target_database
```

#### 2. 대상 데이터베이스 생성 (먼저 실행)

```bash
# 로컬에 대상 데이터베이스 생성
sudo -u postgres createdb target_database

# 또는 psql에서
sudo -u postgres psql
CREATE DATABASE target_database;
\q
```

#### 3. 실제 마이그레이션 실행

```bash
# Custom format으로 덤프 및 복원 (권장)
pg_dump -h 121.0.122.46 -p 5432 -U username -d source_database -Fc -f - | pg_restore -U postgres -d target_database -v

# Plain SQL format (더 간단)
pg_dump -h 121.0.122.46 -p 5432 -U username -d source_database | sudo -u postgres psql target_database
```

## 방법 2: SSH 터널을 통한 마이그레이션

원격 서버에 SSH 접근이 가능한 경우:

```bash
# SSH 터널 생성
ssh -L 5433:localhost:5432 user@121.0.122.46

# 다른 터미널에서 마이그레이션 실행
pg_dump -h localhost -p 5433 -U username -d source_database | sudo -u postgres psql target_database
```

## 방법 3: pg_basebackup (전체 클러스터 복제)

전체 PostgreSQL 클러스터를 복제하는 경우:

```bash
# 원격 서버에서 복제 사용자 설정 필요
pg_basebackup -h 121.0.122.46 -U replication_user -D /var/lib/postgresql/16/main -P -v
```

## 방법 4: 외부 데이터 래퍼 (postgres_fdw)

실시간으로 원격 데이터에 접근:

```sql
-- 로컬 PostgreSQL에서 실행
CREATE EXTENSION postgres_fdw;

CREATE SERVER remote_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host '121.0.122.46', port '5432', dbname 'source_database');

CREATE USER MAPPING FOR local_user
    SERVER remote_server
    OPTIONS (user 'remote_user', password 'remote_password');

-- 외부 테이블 생성
CREATE FOREIGN TABLE remote_table (
    id integer,
    name text
) SERVER remote_server
OPTIONS (schema_name 'public', table_name 'table_name');

-- 데이터 복사
INSERT INTO local_table SELECT * FROM remote_table;
```

## 실전 예제

### 예제 1: 전체 데이터베이스 마이그레이션

```bash
# 1. 로컬에 데이터베이스 생성
sudo -u postgres createdb myapp_db

# 2. 원격에서 직접 마이그레이션
pg_dump -h 121.0.122.46 -p 5432 -U myuser -d myapp_db -W | sudo -u postgres psql myapp_db

# 비밀번호 입력 후 자동으로 마이그레이션 진행
```

### 예제 2: 특정 스키마만 마이그레이션

```bash
pg_dump -h 121.0.122.46 -U username -d source_database -n schema_name | sudo -u postgres psql target_database
```

### 예제 3: 특정 테이블만 마이그레이션

```bash
pg_dump -h 121.0.122.46 -U username -d source_database -t table_name | sudo -u postgres psql target_database
```

### 예제 4: 데이터만 마이그레이션 (스키마 제외)

```bash
pg_dump -h 121.0.122.46 -U username -d source_database --data-only | sudo -u postgres psql target_database
```

### 예제 5: 스키마만 마이그레이션 (데이터 제외)

```bash
pg_dump -h 121.0.122.46 -U username -d source_database --schema-only | sudo -u postgres psql target_database
```

## 필수 확인 사항

### 1. 원격 서버 접근 가능 여부 확인

```bash
# 네트워크 연결 테스트
ping 121.0.122.46

# PostgreSQL 포트 확인
telnet 121.0.122.46 5432
# 또는
nc -zv 121.0.122.46 5432
```

### 2. 원격 PostgreSQL 연결 테스트

```bash
psql -h 121.0.122.46 -U username -d database_name -c "SELECT version();"
```

### 3. 원격 서버 pg_hba.conf 설정 확인

원격 서버의 `/etc/postgresql/16/main/pg_hba.conf`에 다음 항목이 있어야 함:

```conf
# 현재 서버 IP 허용
host    all             all             YOUR_IP/32            scram-sha-256
```

### 4. 원격 서버 postgresql.conf 설정 확인

원격 서버의 `/etc/postgresql/16/main/postgresql.conf`에서:

```conf
listen_addresses = '*'  # 또는 특정 IP
port = 5432
```

## 마이그레이션 시 주의사항

1. **버전 호환성**: 원격과 로컬의 PostgreSQL 버전 확인
2. **인코딩**: 데이터베이스 인코딩 확인
3. **권한**: 충분한 권한이 있는 사용자로 실행
4. **디스크 공간**: 로컬에 충분한 저장 공간 확인
5. **네트워크**: 안정적인 네트워크 연결 필요
6. **방화벽**: 5432 포트 방화벽 열려있는지 확인

## 마이그레이션 진행 상황 모니터링

```bash
# 진행 상황 표시 옵션 사용
pg_dump -h 121.0.122.46 -U username -d source_database -Fc -v -f - | pg_restore -d target_database -v --progress

# 또는 별도 터미널에서 진행 상황 모니터링
watch -n 1 'sudo -u postgres psql -c "SELECT count(*) FROM pg_stat_activity WHERE datname = '\''target_database'\'';"'
```

## 마이그레이션 후 확인

```bash
# 테이블 개수 확인
sudo -u postgres psql target_database -c "\dt"

# 데이터 행 수 확인 (예시)
sudo -u postgres psql target_database -c "SELECT schemaname, tablename, n_live_tup FROM pg_stat_user_tables;"

# 데이터베이스 크기 확인
sudo -u postgres psql -c "SELECT pg_size_pretty(pg_database_size('target_database'));"
```

## 문제 해결

### 연결 거부 (Connection refused)

```bash
# 방화벽 확인
sudo ufw status

# PostgreSQL 서비스 확인
sudo systemctl status postgresql
```

### 비밀번호 프롬프트 반복

```bash
# .pgpass 파일 생성
echo "121.0.122.46:5432:database_name:username:password" > ~/.pgpass
chmod 0600 ~/.pgpass
```

### 권한 오류

```bash
# SUPERUSER 권한으로 실행하거나
# --no-owner --no-privileges 옵션 사용
pg_dump -h 121.0.122.46 -U username -d source_database --no-owner --no-privileges | sudo -u postgres psql target_database
```

## 추천 방법 요약

**가장 간단하고 안전한 방법:**

```bash
# 1단계: 대상 DB 생성
sudo -u postgres createdb your_database_name

# 2단계: 직접 마이그레이션 (비밀번호 입력 필요)
pg_dump -h 121.0.122.46 -p 5432 -U your_username -d source_database -W | sudo -u postgres psql your_database_name
```

이 방법은 중간 파일 없이 메모리를 통해 직접 전송되므로 디스크 공간을 절약하고 빠릅니다.
