#!/bin/sh

# Script tự động cài đặt Dashy với Docker Compose
# Yêu cầu: Docker và Docker Compose đã được cài đặt

echo "=========================================="
echo "   BẮT ĐẦU CÀI ĐẶT DASHY"
echo "=========================================="
echo ""

# Màu sắc cho output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Kiểm tra Docker đã được cài đặt chưa
printf "${YELLOW}[1/4]${NC} Kiểm tra Docker...\n"
if ! which docker > /dev/null 2>&1 && ! [ -x /usr/bin/docker ]; then
    printf "${RED}❌ Docker chưa được cài đặt. Vui lòng cài Docker trước.${NC}\n"
    exit 1
fi
printf "${GREEN}✓ Docker đã được cài đặt${NC}\n"

# Kiểm tra Docker Compose
printf "${YELLOW}[2/4]${NC} Kiểm tra Docker Compose...\n"
if ! docker compose version > /dev/null 2>&1 && ! which docker-compose > /dev/null 2>&1; then
    printf "${RED}❌ Docker Compose chưa được cài đặt.${NC}\n"
    exit 1
fi
printf "${GREEN}✓ Docker Compose đã được cài đặt${NC}\n"

# Tạo thư mục dashy (nếu chưa có)
printf "${YELLOW}[3/4]${NC} Tạo thư mục dashy...\n"
DASHY_DIR="$HOME/dashy"
mkdir -p "$DASHY_DIR"
cd "$DASHY_DIR" || exit 1
printf "${GREEN}✓ Thư mục đã sẵn sàng: $DASHY_DIR${NC}\n"

# Tải file docker-compose.yml từ GitHub
printf "${YELLOW}[4/4]${NC} Tải file docker-compose.yml từ GitHub...\n"
wget https://raw.githubusercontent.com/huyngo92/self-n8n/refs/heads/main/dashy/compose-docker_dashy.yml -O docker-compose.yml

if [ $? -ne 0 ]; then
    printf "${RED}❌ Không thể tải file docker-compose.yml${NC}\n"
    exit 1
fi
printf "${GREEN}✓ File docker-compose.yml đã được tải xuống${NC}\n"

# Khởi chạy Dashy
echo ""
echo "--------- 🟢 Start docker compose up -----------"

# Export biến môi trường
export CURR_DIR=$(pwd)

# Chạy docker compose
if docker compose version > /dev/null 2>&1; then
    docker compose up -d
else
    docker-compose up -d
fi

if [ $? -eq 0 ]; then
    echo "--------- 🔴 Finish! Wait a few seconds and test in browser at url http://localhost:8080 for Dashy UI -----------"
    echo ""
    printf "${YELLOW}⏳ Kiểm tra container...${NC}\n"
    sleep 3
    if docker ps | grep -q dashy; then
        printf "${GREEN}✓ Container dashy đang chạy${NC}\n"
    else
        printf "${RED}⚠ Container dashy không chạy, xem logs:${NC}\n"
        docker logs dashy
    fi
    echo ""
    printf "${GREEN}==========================================\n"
    echo "   ✓ CÀI ĐẶT THÀNH CÔNG!"
    printf "==========================================${NC}\n"
    echo ""
    printf "${GREEN}📍 Dashy đang chạy tại:${NC} http://localhost:8080\n"
    printf "${GREEN}📁 Thư mục cài đặt:${NC} $DASHY_DIR\n"
    echo ""
    printf "${YELLOW}Các lệnh hữu ích:${NC}\n"
    echo "  • Xem logs:        docker logs dashy"
    echo "  • Dừng Dashy:      docker stop dashy"
    echo "  • Khởi động lại:   docker restart dashy"
    echo "  • Xóa container:   docker rm -f dashy"
    echo ""
    printf "${YELLOW}Lưu ý:${NC}\n"
    echo "  • Tạo file conf.yml trong thư mục $DASHY_DIR để tùy chỉnh dashboard"
    echo "  • Tham khảo: https://dashy.to/docs"
    echo ""
else
    printf "${RED}❌ Có lỗi xảy ra khi khởi chạy Dashy${NC}\n"
    exit 1
fi
