#!/bin/bash

# 颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查是否为root用户
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${RED}错误: 必须使用root权限运行此脚本${NC}"
        exit 1
    fi
}

# 检查系统要求
check_requirements() {
    echo -e "${BLUE}正在检查系统要求...${NC}"
    
    # 检查wget
    if ! command -v wget &> /dev/null; then
        echo -e "${YELLOW}正在安装wget...${NC}"
        apt-get update
        apt-get install -y wget
    fi
    
    # 检查可用内存
    total_mem=$(free -m | awk '/^Mem:/{print $2}')
    if [ $total_mem -lt 1024 ]; then
        echo -e "${RED}警告: 建议至少有1GB内存${NC}"
        read -p "是否继续？(y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 选择系统
select_system() {
    echo -e "${GREEN}请选择要安装的系统：${NC}"
    echo "1) Debian 11"
    echo "2) Debian 12"
    echo "3) Ubuntu 20.04"
    echo "4) Ubuntu 22.04"
    echo "5) 自定义镜像地址"
    
    read -p "请输入选项 [1-5]: " system_choice
    
    case $system_choice in
        1)
            DD_URL="https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh"
            SYSTEM_ARGS="-d 11 -v 64 -a"
            ;;
        2)
            DD_URL="https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh"
            SYSTEM_ARGS="-d 12 -v 64 -a"
            ;;
        3)
            DD_URL="https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh"
            SYSTEM_ARGS="-u 20.04 -v 64 -a"
            ;;
        4)
            DD_URL="https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh"
            SYSTEM_ARGS="-u 22.04 -v 64 -a"
            ;;
        5)
            read -p "请输入自定义镜像地址: " custom_url
            DD_URL=$custom_url
            read -p "请输入自定义参数（如果需要）: " custom_args
            SYSTEM_ARGS=$custom_args
            ;;
        *)
            echo -e "${RED}无效的选项${NC}"
            exit 1
            ;;
    esac
}

# 设置密码
set_password() {
    read -p "请设置root密码 (默认为 'password'): " root_password
    if [ -z "$root_password" ]; then
        root_password="password"
    fi
    SYSTEM_ARGS="$SYSTEM_ARGS -p $root_password"
}

# 确认信息
confirm_installation() {
    echo -e "\n${YELLOW}请确认以下信息：${NC}"
    echo -e "安装脚本: ${DD_URL}"
    echo -e "系统参数: ${SYSTEM_ARGS}"
    echo -e "root密码: ${root_password}"
    
    read -p "是否开始安装？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
}

# 开始安装
start_installation() {
    echo -e "${GREEN}开始安装系统...${NC}"
    
    # 下载安装脚本
    echo -e "${BLUE}下载安装脚本...${NC}"
    wget --no-check-certificate -qO InstallNET.sh ${DD_URL}
    
    # 添加执行权限
    chmod +x InstallNET.sh
    
    # 执行安装
    echo -e "${YELLOW}执行安装程序...${NC}"
    bash InstallNET.sh ${SYSTEM_ARGS}
}

# 主程序
main() {
    clear
    echo -e "${GREEN}欢迎使用一键DD系统脚本${NC}"
    echo -e "${YELLOW}警告：此操作将清除所有数据，请确保已备份重要数据！${NC}"
    echo "-----------------------------------"
    
    check_root
    check_requirements
    select_system
    set_password
    confirm_installation
    start_installation
}

# 运行主程序
main 
