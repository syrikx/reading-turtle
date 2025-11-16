#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  Reading Turtle 포트 스왑 스크립트${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# 현재 상태 확인
echo -e "${YELLOW}[1단계] 현재 서버 상태 확인...${NC}"
echo ""

PORT_8080_PID=$(lsof -ti:8080)
PORT_8090_PID=$(lsof -ti:8090)

if [ -z "$PORT_8080_PID" ]; then
    echo -e "${RED}❌ 포트 8080에서 실행 중인 프로세스 없음${NC}"
else
    echo -e "${GREEN}✓ 포트 8080: PID $PORT_8080_PID${NC}"
    PORT_8080_DIR=$(lsof -p $PORT_8080_PID | grep -oP '/home/syrikx0/[^ ]+/build/web' | head -1)
    echo "  디렉토리: $PORT_8080_DIR"
fi

if [ -z "$PORT_8090_PID" ]; then
    echo -e "${RED}❌ 포트 8090에서 실행 중인 프로세스 없음${NC}"
else
    echo -e "${GREEN}✓ 포트 8090: PID $PORT_8090_PID${NC}"
    PORT_8090_DIR=$(lsof -p $PORT_8090_PID | grep -oP '/home/syrikx0/[^ ]+/build/web' | head -1)
    echo "  디렉토리: $PORT_8090_DIR"
fi

echo ""
echo -e "${YELLOW}[2단계] 기존 서버 중지...${NC}"

# 8080 포트 서버 중지
if [ ! -z "$PORT_8080_PID" ]; then
    echo "포트 8080 서버 중지 중... (PID: $PORT_8080_PID)"
    kill $PORT_8080_PID 2>/dev/null
    sleep 1
    if lsof -ti:8080 >/dev/null 2>&1; then
        echo -e "${RED}강제 종료 시도...${NC}"
        kill -9 $PORT_8080_PID 2>/dev/null
        sleep 1
    fi
    echo -e "${GREEN}✓ 포트 8080 서버 중지 완료${NC}"
fi

# 8090 포트 서버 중지
if [ ! -z "$PORT_8090_PID" ]; then
    echo "포트 8090 서버 중지 중... (PID: $PORT_8090_PID)"
    kill $PORT_8090_PID 2>/dev/null
    sleep 1
    if lsof -ti:8090 >/dev/null 2>&1; then
        echo -e "${RED}강제 종료 시도...${NC}"
        kill -9 $PORT_8090_PID 2>/dev/null
        sleep 1
    fi
    echo -e "${GREEN}✓ 포트 8090 서버 중지 완료${NC}"
fi

echo ""
echo -e "${YELLOW}[3단계] 서버 포트 스왑 시작...${NC}"

# 디렉토리 설정
OLD_VERSION_DIR="/home/syrikx0/reading-turtle/flutter/build/web"
NEW_VERSION_DIR="/home/syrikx0/reading-turtle-v2/flutter/build/web"

# 새 버전을 8080 포트에서 실행
echo "새 버전 (v2) → 포트 8080에서 시작..."
cd "$NEW_VERSION_DIR" && nohup python3 -m http.server 8080 --bind 0.0.0.0 > /tmp/server_8080.log 2>&1 &
NEW_PID=$!
sleep 2

if lsof -ti:8080 >/dev/null 2>&1; then
    echo -e "${GREEN}✓ 새 버전 시작 완료 (PID: $NEW_PID)${NC}"
    echo "  URL: http://localhost:8080"
    echo "  디렉토리: $NEW_VERSION_DIR"
else
    echo -e "${RED}❌ 새 버전 시작 실패${NC}"
fi

# 이전 버전을 8090 포트에서 실행
echo ""
echo "이전 버전 (v1) → 포트 8090에서 시작..."
cd "$OLD_VERSION_DIR" && nohup python3 -m http.server 8090 --bind 0.0.0.0 > /tmp/server_8090.log 2>&1 &
OLD_PID=$!
sleep 2

if lsof -ti:8090 >/dev/null 2>&1; then
    echo -e "${GREEN}✓ 이전 버전 시작 완료 (PID: $OLD_PID)${NC}"
    echo "  URL: http://localhost:8090"
    echo "  디렉토리: $OLD_VERSION_DIR"
else
    echo -e "${RED}❌ 이전 버전 시작 실패${NC}"
fi

echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  포트 스왑 완료!${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo -e "${GREEN}현재 실행 중인 서버:${NC}"
echo -e "  • ${GREEN}포트 8080${NC}: 새 버전 (reading-turtle-v2)"
echo -e "  • ${GREEN}포트 8090${NC}: 이전 버전 (reading-turtle)"
echo ""
echo -e "${YELLOW}웹 접속 URL:${NC}"
echo -e "  • 새 버전: ${GREEN}http://localhost:8080${NC} 또는 ${GREEN}https://v2.reading-turtle.com${NC}"
echo -e "  • 이전 버전: ${GREEN}http://localhost:8090${NC}"
echo ""
echo -e "${YELLOW}로그 확인:${NC}"
echo -e "  • tail -f /tmp/server_8080.log  (새 버전)"
echo -e "  • tail -f /tmp/server_8090.log  (이전 버전)"
echo ""
