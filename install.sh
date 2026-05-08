#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────────────────────
# WSO2 MI - BELAJAR WSO2 APPLICATION WIZARD INSTALLER & DEPLOYER
# ─────────────────────────────────────────────────────────────────────────────

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=========================================================================${NC}"
echo -e "${GREEN}      BelajarWso2 Application Installer - Production Ready${NC}"
echo -e "${CYAN}=========================================================================${NC}\n"

# 1. Setup .env file
echo -e "${BLUE}⚙️  Mengecek file konfigurasi .env ...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "✅ Berhasil men-generate file ${GREEN}.env${NC} dari .env.example"
else
    echo -e "✅ File ${GREEN}.env${NC} sudah ada."
fi

# 2. Build Carbon Application & Custom Docker Image
echo -e "\n${BLUE}📦 Mengompilasi proyek & membangun Custom Docker Image...${NC}"
mvn clean package -Pdocker -Dmaven.test.skip=true
echo -e "✅ Custom Docker Image berhasil dibangun."

# 3. Ask for Run
echo -e "\n${YELLOW}🐳 Apakah Anda ingin langsung menjalankan Container WSO2 MI BelajarWso2?${NC}"
read -p "👉 Jalankan (y/n) [default: y]: " RUN_DOCKER
if [ -z "$RUN_DOCKER" ] || [ "$RUN_DOCKER" == "y" ] || [ "$RUN_DOCKER" == "Y" ]; then
    echo -e "\n${GREEN}🚀 Menjalankan Docker Compose...${NC}"
    docker compose up -d --force-recreate micro-integrator
    echo -e "\n🎉 ${GREEN}Aplikasi BelajarWso2 Berhasil Dijalankan!${NC}"
    echo -e "Cek status kontainer dengan: ${CYAN}docker compose ps${NC}"
    echo -e "Cek log kontainer dengan:    ${CYAN}docker logs -f belajar-micro-integrator${NC}"
else
    echo -e "\n💾 Setup selesai. Untuk menjalankan secara manual, gunakan perintah:"
    echo -e "   ${CYAN}docker compose up -d${NC}"
fi
