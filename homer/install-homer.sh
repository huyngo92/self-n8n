#!/bin/sh

# Script tự động cài đặt Homer Dashboard
# Yêu cầu: Docker và Docker Compose đã được cài đặt

echo "=========================================="
echo "   BẮT ĐẦU CÀI ĐẶT HOMER DASHBOARD"
echo "=========================================="
echo ""

# Màu sắc cho output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hỏi có muốn gỡ Dashy không
printf "${YELLOW}Bạn có muốn gỡ bỏ Dashy không? (y/n):${NC} "
read -r REMOVE_DASHY

if [ "$REMOVE_DASHY" = "y" ] || [ "$REMOVE_DASHY" = "Y" ]; then
    echo ""
    printf "${BLUE}[*] Đang gỡ bỏ Dashy...${NC}\n"
    
    # Dừng và xóa container
    docker stop dashy > /dev/null 2>&1
    docker rm dashy > /dev/null 2>&1
    
    # Xóa thư mục dashy
    if [ -d "$HOME/dashy" ]; then
        rm -rf "$HOME/dashy"
        printf "${GREEN}✓ Đã xóa thư mục ~/dashy${NC}\n"
    fi
    
    printf "${GREEN}✓ Đã gỡ bỏ Dashy hoàn toàn${NC}\n"
    echo ""
fi

# Kiểm tra Docker
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

# Tạo thư mục homer
printf "${YELLOW}[3/4]${NC} Tạo thư mục Homer...\n"
HOMER_DIR="$HOME/homer"
mkdir -p "$HOMER_DIR"
mkdir -p "$HOMER_DIR/homer-config"
cd "$HOMER_DIR" || exit 1
printf "${GREEN}✓ Thư mục đã sẵn sàng: $HOMER_DIR${NC}\n"

# Tải file cấu hình từ GitHub
printf "${YELLOW}[4/4]${NC} Tải file cấu hình từ GitHub...\n"

# Tải docker-compose.yml
wget https://raw.githubusercontent.com/huyngo92/self-n8n/refs/heads/main/homer/compose-docker_homer.yml -O docker-compose.yml > /dev/null 2>&1

if [ $? -ne 0 ]; then
    printf "${RED}❌ Không thể tải file docker-compose.yml${NC}\n"
    exit 1
fi

# Tải config.yml
wget https://raw.githubusercontent.com/huyngo92/self-n8n/refs/heads/main/homer/config.yml -O homer-config/config.yml > /dev/null 2>&1

if [ $? -ne 0 ]; then
    printf "${RED}❌ Không thể tải file config.yml${NC}\n"
    exit 1
fi

printf "${GREEN}✓ Đã tải file cấu hình${NC}\n"

# Khởi chạy Homer
echo ""
echo "--------- 🟢 Start docker compose up -----------"

# Chạy docker compose
if docker compose version > /dev/null 2>&1; then
    docker compose up -d
else
    docker-compose up -d
fi

if [ $? -eq 0 ]; then
    echo "--------- 🔴 Finish! -----------"
    echo ""
    printf "${GREEN}==========================================\n"
    echo "   ✓ CÀI ĐẶT HOMER THÀNH CÔNG!"
    printf "==========================================${NC}\n"
    echo ""
    printf "${GREEN}📍 Homer đang chạy tại:${NC} http://localhost:8081\n"
    printf "${GREEN}📁 Thư mục cài đặt:${NC} $HOMER_DIR\n"
    printf "${GREEN}⚙️  File cấu hình:${NC} $HOMER_DIR/homer-config/config.yml\n"
    echo ""
    printf "${YELLOW}⚙️  Cấu hình tài nguyên:${NC}\n"
    echo "  • RAM tối đa: 128MB (Siêu nhẹ!)"
    echo "  • RAM tối thiểu: 32MB"
    echo ""
    printf "${YELLOW}🔧 Các lệnh hữu ích:${NC}\n"
    echo "  • Xem logs:          docker logs -f homer"
    echo "  • Dừng Homer:        docker stop homer"
    echo "  • Khởi động lại:     docker restart homer"
    echo "  • Xóa container:     docker rm -f homer"
    echo "  • Chỉnh sửa config:  nano ~/homer/homer-config/config.yml"
    echo ""
    printf "${YELLOW}📖 Lưu ý:${NC}\n"
    echo "  • Sửa file config.yml để thêm/bớt ứng dụng"
    echo "  • Sau khi sửa config, chạy: docker restart homer"
    echo "  • Tham khảo: https://github.com/bastienwirtz/homer"
    echo ""
    printf "${BLUE}💡 Mẹo: Homer cực kỳ nhẹ, chỉ tốn ~30MB RAM!${NC}\n"
    echo ""
else
    printf "${RED}❌ Có lỗi xảy ra khi khởi chạy Homer${NC}\n"
    exit 1
fi
