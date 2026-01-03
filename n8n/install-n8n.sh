#!/bin/sh

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

# Tạo thư mục n8n và volumes
printf "${YELLOW}[3/6]${NC} Tạo thư mục n8n...\n"
N8N_DIR="$HOME/n8n"
mkdir -p "$N8N_DIR"
cd "$N8N_DIR" || exit 1
printf "${GREEN}✓ Thư mục đã sẵn sàng: $N8N_DIR${NC}\n"

echo ""
echo "--------- 🟢 Start creating folder -----------"
mkdir -p vol_n8n
sudo chown -R 1000:1000 vol_n8n
sudo chmod -R 755 vol_n8n
echo "--------- 🔴 Finish creating folder -----------"

echo ""
printf "${YELLOW}[4/6]${NC} Khởi chạy Cloudflare Tunnel...\n"
echo "--------- 🟢 Start Cloudflare Tunnel -----------"

# Xóa container cũ nếu tồn tại
docker rm -f cloudflare-tunnel > /dev/null 2>&1

# Tạo network nếu chưa có
docker network create n8n-network > /dev/null 2>&1 || true

sudo docker run -d --name cloudflare-tunnel \
  --network n8n-network \
  --restart unless-stopped \
  cloudflare/cloudflared:latest tunnel --no-autoupdate run \
  --token eyJhIjoiODg3MjFhNGQ4Y2E0ZjYyZmIyNGNkOWE3NTA3MWJhMTIiLCJ0IjoiZDRjYmNiMDUtYzI0Yi00OWZhLTk1YzItZjJjMzQ0NmIzMGJlIiwicyI6IllXVXpOV1E0TXpNdE16UXlPQzAwWVdNM0xUZzRNbVV0TmpnMk5XSXlNVFEzWTJFMyJ9

printf "${YELLOW}⏳ Đợi Cloudflare Tunnel kết nối (5 giây)...${NC}\n"
sleep 5
echo "--------- 🔴 Finish Cloudflare Tunnel -----------"

echo ""
# Tải file docker-compose.yml từ GitHub
printf "${YELLOW}[5/6]${NC} Tải file compose.yaml từ GitHub...\n"
wget https://raw.githubusercontent.com/huyngo92/self-n8n/refs/heads/main/n8n/compose-docker_n8n.yaml -O docker-compose.yml

if [ $? -ne 0 ]; then
    printf "${RED}❌ Không thể tải file compose.yaml${NC}\n"
    exit 1
fi

printf "${GREEN}✓ File compose.yaml đã được tải xuống (đã bao gồm giới hạn tài nguyên)${NC}\n"

# Khởi chạy n8n
echo ""
printf "${YELLOW}[6/6]${NC} Khởi chạy n8n...\n"
echo "--------- 🟢 Start docker compose up -----------"

# Export biến môi trường
export EXTERNAL_IP=https://flow.hotromyss.site
export CURR_DIR=$(pwd)

# Chạy docker compose
if docker compose version > /dev/null 2>&1; then
    sudo -E docker compose up -d
else
    sudo -E docker-compose up -d
fi

if [ $? -eq 0 ]; then
    echo "--------- 🔴 Finish! Wait a few minutes and test in browser at url $EXTERNAL_IP for n8n UI -----------"
    echo ""
    printf "${GREEN}==========================================\n"
    echo "   ✓ CÀI ĐẶT THÀNH CÔNG!"
    printf "==========================================${NC}\n"
    echo ""
    printf "${GREEN}📍 n8n đang chạy tại:${NC} $EXTERNAL_IP\n"
    printf "${GREEN}📁 Thư mục cài đặt:${NC} $N8N_DIR\n"
    printf "${GREEN}💾 Dữ liệu được lưu tại:${NC} $N8N_DIR/vol_n8n\n"
    echo ""
    printf "${YELLOW}⚙️  Cấu hình tài nguyên:${NC}\n"
    echo "  • RAM tối đa: 2GB"
    echo "  • RAM tối thiểu: 512MB"
    echo "  • CPU tối đa: 2 cores"
    echo "  • CPU tối thiểu: 0.5 core"
    echo ""
    printf "${YELLOW}🔧 Các lệnh hữu ích:${NC}\n"
    echo "  • Xem logs:          docker logs -f cont_n8n"
    echo "  • Dừng n8n:          docker stop cont_n8n"
    echo "  • Khởi động lại:     docker restart cont_n8n"
    echo "  • Xóa container:     docker rm -f cont_n8n"
    echo "  • Xem tài nguyên:    docker stats cont_n8n"
    echo "  • Xem Cloudflare:    docker logs cloudflare-tunnel"
    echo "  • Dừng Cloudflare:   docker stop cloudflare-tunnel"
    echo ""
    printf "${YELLOW}📖 Lưu ý:${NC}\n"
    echo "  • Đăng nhập lần đầu sẽ yêu cầu tạo tài khoản admin"
    echo "  • Dữ liệu workflow được lưu trong thư mục vol_n8n"
    echo "  • Tham khảo: https://docs.n8n.io"
    echo ""
else
    printf "${RED}❌ Có lỗi xảy ra khi khởi chạy n8n${NC}\n"
    exit 1
fi
