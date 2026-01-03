#!/bin/bash

# Script tự động cài đặt n8n với Docker Compose (tối ưu cho PC)
# Yêu cầu: Docker và Docker Compose đã được cài đặt

echo "=========================================="
echo "   BẮT ĐẦU CÀI ĐẶT N8N"
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

# Tạo thư mục n8n và volumes
echo -e "${YELLOW}[3/6]${NC} Tạo thư mục n8n..."
N8N_DIR="$HOME/n8n"
mkdir -p "$N8N_DIR"
cd "$N8N_DIR" || exit 1
echo -e "${GREEN}✓ Thư mục đã sẵn sàng: $N8N_DIR${NC}"

echo ""
echo "--------- 🟢 Start creating folder -----------"
mkdir -p vol_n8n
sudo chown -R 1000:1000 vol_n8n
sudo chmod -R 755 vol_n8n
echo "--------- 🔴 Finish creating folder -----------"

echo ""
echo -e "${YELLOW}[4/6]${NC} Khởi chạy Cloudflare Tunnel..."
echo "--------- 🟢 Start Cloudflare Tunnel -----------"
sudo docker run -d --name cloudflare-tunnel \
  --restart unless-stopped \
  cloudflare/cloudflared:latest tunnel --no-autoupdate run \
  --token eyJhIjoiODg3MjFhNGQ4Y2E0ZjYyZmIyNGNkOWE3NTA3MWJhMTIiLCJ0IjoiZDRjYmNiMDUtYzI0Yi00OWZhLTk1YzItZjJjMzQ0NmIzMGJlIiwicyI6IllXVXpOV1E0TXpNdE16UXlPQzAwWVdNM0xUZzRNbVV0TmpnMk5XSXlNVFEzWTJFMyJ9
echo "--------- 🔴 Finish Cloudflare Tunnel -----------"

echo ""
# Tải file docker-compose.yml từ GitHub
echo -e "${YELLOW}[5/6]${NC} Tải file compose.yaml từ GitHub..."
wget https://raw.githubusercontent.com/huyngo92/self-n8n/refs/heads/main/n8n/compose-docker_n8n.yaml -O docker-compose.yml

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Không thể tải file compose.yaml${NC}"
    exit 1
fi

echo -e "${GREEN}✓ File compose.yaml đã được tải xuống (đã bao gồm giới hạn tài nguyên)${NC}"

# Khởi chạy n8n
echo ""
echo -e "${YELLOW}[6/6]${NC} Khởi chạy n8n..."
echo "--------- 🟢 Start docker compose up -----------"

# Export biến môi trường
export EXTERNAL_IP=https://hotromyss.site
export CURR_DIR=$(pwd)

# Chạy docker compose
if docker compose version &> /dev/null; then
    sudo -E docker compose up -d
else
    sudo -E docker-compose up -d
fi

if [ $? -eq 0 ]; then
    echo "--------- 🔴 Finish! Wait a few minutes and test in browser at url $EXTERNAL_IP for n8n UI -----------"
    echo ""
    echo -e "${GREEN}=========================================="
    echo "   ✓ CÀI ĐẶT THÀNH CÔNG!"
    echo -e "==========================================${NC}"
    echo ""
    echo -e "${GREEN}📍 n8n đang chạy tại:${NC} $EXTERNAL_IP"
    echo -e "${GREEN}📁 Thư mục cài đặt:${NC} $N8N_DIR"
    echo -e "${GREEN}💾 Dữ liệu được lưu tại:${NC} $N8N_DIR/vol_n8n"
    echo ""
    echo -e "${YELLOW}⚙️  Cấu hình tài nguyên:${NC}"
    echo "  • RAM tối đa: 2GB"
    echo "  • RAM tối thiểu: 512MB"
    echo "  • CPU tối đa: 2 cores"
    echo "  • CPU tối thiểu: 0.5 core"
    echo ""
    echo -e "${YELLOW}🔧 Các lệnh hữu ích:${NC}"
    echo "  • Xem logs:          docker logs -f cont_n8n"
    echo "  • Dừng n8n:          docker stop cont_n8n"
    echo "  • Khởi động lại:     docker restart cont_n8n"
    echo "  • Xóa container:     docker rm -f cont_n8n"
    echo "  • Xem tài nguyên:    docker stats cont_n8n"
    echo "  • Xem Cloudflare:    docker logs cloudflare-tunnel"
    echo "  • Dừng Cloudflare:   docker stop cloudflare-tunnel"
    echo ""
    echo -e "${YELLOW}📖 Lưu ý:${NC}"
    echo "  • Đăng nhập lần đầu sẽ yêu cầu tạo tài khoản admin"
    echo "  • Dữ liệu workflow được lưu trong thư mục vol_n8n"
    echo "  • Tham khảo: https://docs.n8n.io"
    echo ""
else
    echo -e "${RED}❌ Có lỗi xảy ra khi khởi chạy n8n${NC}"
    exit 1
fi
