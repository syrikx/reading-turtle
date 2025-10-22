# PostgreSQL Installation Guide

## Installation Information

- **Date**: 2025-10-18
- **PostgreSQL Version**: 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
- **Installation Type**: PostgreSQL Server + Extensions

## Installation Commands

```bash
# Update package lists
sudo apt update

# Install PostgreSQL and extensions
sudo apt install -y postgresql postgresql-contrib
```

## Installation Details

### Installed Packages
- `postgresql` - PostgreSQL database server
- `postgresql-contrib` - Additional extensions and utilities
- `postgresql-16` - PostgreSQL 16 main package
- `postgresql-client-16` - PostgreSQL 16 client
- `libpq5` - PostgreSQL C client library

### Cluster Information
- **Cluster Name**: 16/main
- **Data Directory**: /var/lib/postgresql/16/main
- **Authentication**:
  - Local: peer
  - Host: scram-sha-256
- **Locale**: en_US.UTF-8
- **Encoding**: UTF8
- **Time Zone**: Asia/Seoul
- **Default max_connections**: 100
- **Default shared_buffers**: 128MB

## Service Management

### Check Service Status
```bash
sudo systemctl status postgresql
```

### Start Service
```bash
sudo systemctl start postgresql
```

### Stop Service
```bash
sudo systemctl stop postgresql
```

### Restart Service
```bash
sudo systemctl restart postgresql
```

### Enable Service (Auto-start on boot)
```bash
sudo systemctl enable postgresql
```

## Initial Setup

### Access PostgreSQL as postgres user
```bash
sudo -u postgres psql
```

### Create a New Database User
```sql
CREATE USER your_username WITH PASSWORD 'your_password';
```

### Create a New Database
```sql
CREATE DATABASE your_database;
```

### Grant Privileges
```sql
GRANT ALL PRIVILEGES ON DATABASE your_database TO your_username;
```

### Exit psql
```sql
\q
```

## Connection Information

- **Default Port**: 5432
- **Default User**: postgres
- **Default Database**: postgres

## Configuration Files

- **Main Configuration**: `/etc/postgresql/16/main/postgresql.conf`
- **Client Authentication**: `/etc/postgresql/16/main/pg_hba.conf`
- **PostgreSQL Common**: `/etc/postgresql-common/createcluster.conf`

## Verification Commands

```bash
# Check PostgreSQL version
psql --version

# Check service status
sudo systemctl status postgresql

# List all clusters
pg_lsclusters

# Test connection
sudo -u postgres psql -c "SELECT version();"
```

## Next Steps

1. Create a database user for your application
2. Create a database for your project
3. Configure pg_hba.conf for remote access (if needed)
4. Update postgresql.conf for performance tuning (if needed)
5. Set up regular backups

## Common Commands Reference

### User Management
```sql
-- Create user
CREATE USER username WITH PASSWORD 'password';

-- Drop user
DROP USER username;

-- List all users
\du
```

### Database Management
```sql
-- Create database
CREATE DATABASE dbname;

-- Drop database
DROP DATABASE dbname;

-- List all databases
\l

-- Connect to database
\c dbname
```

### Table Management
```sql
-- List all tables
\dt

-- Describe table
\d tablename

-- Show table data
SELECT * FROM tablename;
```

## Troubleshooting

### Service won't start
```bash
# Check logs
sudo journalctl -u postgresql -n 50

# Check PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-16-main.log
```

### Permission denied
Ensure you're using `sudo -u postgres` for administrative tasks.

### Port already in use
```bash
# Check what's using port 5432
sudo lsof -i :5432
```

## Security Recommendations

1. Change the postgres user password immediately
2. Configure pg_hba.conf to restrict access
3. Use strong passwords for all database users
4. Enable SSL/TLS for remote connections
5. Keep PostgreSQL updated with security patches
6. Regular backup schedule
