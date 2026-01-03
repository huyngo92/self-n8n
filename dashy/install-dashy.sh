#!/bin/bash

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
echo -e "${YELLOW}[1/4]${NC} Kiểm tra Docker..."
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker chưa được cài đặt. Vui lòng cài Docker trước.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker đã được cài đặt${NC}"

# Kiểm tra Docker Compose
echo -e "${YELLOW}[2/4]${NC} Kiểm tra Docker Compose..."
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose chưa được cài đặt.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose đã được cài đặt${NC}"

# Tạo thư mục dashy (nếu chưa có)
echo -e "${YELLOW}[3/4]${NC} Tạo thư mục dashy..."
DASHY_DIR="$HOME/dashy"
mkdir -p "$DASHY_DIR"
cd "$DASHY_DIR" || exit 1
echo -e "${GREEN}✓ Thư mục đã sẵn sàng: $DASHY_DIR${NC}"

# Tải file docker-compose.yml từ GitHub
echo -e "${YELLOW}[4/4]${NC} Tải file docker-compose.yml từ GitHub..."
wget https://raw.githubusercontent.com/huyngo92/self-n8n/refs/heads/main/dashy/compose-docker_dashy.yml -O docker-compose.yml

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Không thể tải file docker-compose.yml${NC}"
    exit 1
fi
echo -e "${GREEN}✓ File docker-compose.yml đã được tải xuống${NC}"

# Khởi chạy Dashy
echo ""
echo "--------- 🟢 Start docker compose up -----------"

# Export biến môi trường
export CURR_DIR=$(pwd)

# Chạy docker compose
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

if [ $? -eq 0 ]; then
    echo "--------- 🔴 Finish! Wait a few seconds and test in browser at url http://localhost:8080 for Dashy UI -----------"
    echo ""
    echo -e "${GREEN}=========================================="
    echo "   ✓ CÀI ĐẶT THÀNH CÔNG!"
    echo -e "==========================================${NC}"
    echo ""
    echo -e "${GREEN}📍 Dashy đang chạy tại:${NC} http://localhost:8080"
    echo -e "${GREEN}📁 Thư mục cài đặt:${NC} $DASHY_DIR"
    echo ""
    echo -e "${YELLOW}Các lệnh hữu ích:${NC}"
    echo "  • Xem logs:        docker logs dashy"
    echo "  • Dừng Dashy:      docker stop dashy"
    echo "  • Khởi động lại:   docker restart dashy"
    echo "  • Xóa container:   docker rm -f dashy"
    echo ""
    echo -e "${YELLOW}Lưu ý:${NC}"
    echo "  • Tạo file conf.yml trong thư mục $DASHY_DIR để tùy chỉnh dashboard"
    echo "  • Tham khảo: https://dashy.to/docs"
    echo ""
else
    echo -e "${RED}❌ Có lỗi xảy ra khi khởi chạy Dashy${NC}"
    exit 1
fi
