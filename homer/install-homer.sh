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
printf "%s" "${YELLOW}Ban co muon go bo Dashy khong? (y/n):${NC} "
read -r REMOVE_DASHY

if [ "$REMOVE_DASHY" = "y" ] || [ "$REMOVE_DASHY" = "Y" ]; then
    echo ""
    printf "${BLUE}[*] Dang go bo Dashy...${NC}\n"
    
    # Dừng và xóa container
    docker stop dashy > /dev/null 2>&1
    docker rm dashy > /dev/null 2>&1
    
    # Xóa thư mục dashy
    if [ -d "$HOME/dashy" ]; then
        rm -rf "$HOME/dashy"
        printf "${GREEN}Da xoa thu muc ~/dashy${NC}\n"
    fi
    
    printf "${GREEN}Da go bo Dashy hoan toan${NC}\n"
    echo ""
fi

# Kiểm tra Docker
printf "${YELLOW}[1/4]${NC} Kiem tra Docker...\n"
if ! which docker > /dev/null 2>&1 && ! [ -x /usr/bin/docker ]; then
    printf "${RED}Docker chua duoc cai dat. Vui long cai Docker truoc.${NC}\n"
    exit 1
fi
printf "${GREEN}Docker da duoc cai dat${NC}\n"

# Kiểm tra Docker Compose
printf "${YELLOW}[2/4]${NC} Kiem tra Docker Compose...\n"
if ! docker compose version > /dev/null 2>&1 && ! which docker-compose > /dev/null 2>&1; then
    printf "${RED}Docker Compose chua duoc cai dat.${NC}\n"
    exit 1
fi
printf "${GREEN}Docker Compose da duoc cai dat${NC}\n"

# Tạo thư mục homer
printf "${YELLOW}[3/5]${NC} Tao thu muc Homer...\n"
HOMER_DIR="$HOME/homer"
mkdir -p "$HOMER_DIR"
mkdir -p "$HOMER_DIR/homer-config"
cd "$HOMER_DIR" || exit 1
printf "${GREEN}Thu muc da san sang: $HOMER_DIR${NC}\n"

# Tải file cấu hình từ GitHub
printf "${YELLOW}[4/5]${NC} Tai file cau hinh tu GitHub...\n"

# Tải docker-compose.yml
wget https://raw.githubusercontent.com/huyngo92/self-n8n/refs/heads/main/homer/compose-docker_homer.yml -O docker-compose.yml > /dev/null 2>&1

if [ $? -ne 0 ]; then
    printf "${RED}Khong the tai file docker-compose.yml${NC}\n"
    exit 1
fi

# Tải config.yml
wget https://raw.githubusercontent.com/huyngo92/self-n8n/refs/heads/main/homer/config.yml -O homer-config/config.yml > /dev/null 2>&1

if [ $? -ne 0 ]; then
    printf "${RED}Khong the tai file config.yml${NC}\n"
    exit 1
fi

# Tải compose-glances.yml
wget https://raw.githubusercontent.com/huyngo92/self-n8n/refs/heads/main/homer/compose-glances.yml -O compose-glances.yml > /dev/null 2>&1

if [ $? -ne 0 ]; then
    printf "${YELLOW}! Khong the tai file Glances, se bo qua${NC}\n"
fi

printf "${GREEN}Da tai file cau hinh${NC}\n"

# Khởi chạy Homer
echo ""
printf "${YELLOW}[5/5]${NC} Khoi chay Homer va Glances...\n"
echo "--------- Start docker compose up -----------"

# Chạy docker compose Homer
if docker compose version > /dev/null 2>&1; then
    docker compose up -d
    # Chạy Glances nếu file tồn tại
    if [ -f compose-glances.yml ]; then
        docker compose -f compose-glances.yml up -d
    fi
else
    docker-compose up -d
    if [ -f compose-glances.yml ]; then
        docker-compose -f compose-glances.yml up -d
    fi
fi

if [ $? -eq 0 ]; then
    echo "--------- Finish! -----------"
    echo ""
    printf "${GREEN}==========================================\n"
    echo "   CAI DAT HOMER THANH CONG!"
    printf "==========================================${NC}\n"
    echo ""
    printf "${GREEN}Homer dang chay tai:${NC} http://localhost:8081\n"
    printf "${GREEN}Glances Monitor:${NC} http://localhost:61208\n"
    printf "${GREEN}Thu muc cai dat:${NC} $HOMER_DIR\n"
    printf "${GREEN}File cau hinh:${NC} $HOMER_DIR/homer-config/config.yml\n"
    echo ""
    printf "${YELLOW}Cau hinh tai nguyen:${NC}\n"
    echo "  - Homer RAM: 128MB (Sieu nhe!)"
    echo "  - Glances RAM: 128MB"
    echo "  - Tong RAM: ~256MB"
    echo ""
    printf "${YELLOW}Cac lenh huu ich:${NC}\n"
    echo "  Homer:"
    echo "    - Xem logs:        docker logs -f homer"
    echo "    - Dung Homer:      docker stop homer"
    echo "    - Khoi dong lai:   docker restart homer"
    echo ""
    echo "  Glances:"
    echo "    - Xem logs:        docker logs -f glances"
    echo "    - Dung Glances:    docker stop glances"
    echo "    - Khoi dong lai:   docker restart glances"
    echo ""
    echo "  Chinh sua config:    nano ~/homer/homer-config/config.yml"
    echo ""
    printf "${YELLOW}Luu y:${NC}\n"
    echo "  - Homer: Dashboard chinh de quan ly ung dung"
    echo "  - Glances: Xem CPU, RAM, GPU, Disk real-time"
    echo "  - Sau khi sua config, chay: docker restart homer"
    echo "  - Tham khao Homer: https://github.com/bastienwirtz/homer"
    echo "  - Tham khao Glances: https://nicolargo.github.io/glances/"
    echo ""
    printf "${BLUE}Meo: Homer + Glances chi ton ~256MB RAM!${NC}\n"
    echo ""
else
    printf "${RED}Co loi xay ra khi khoi chay Homer${NC}\n"
    exit 1
fi
