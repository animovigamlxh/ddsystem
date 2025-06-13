#!/bin/bash

# 颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# DD脚本地址
SCRIPT_URL="https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh"

# 检查root权限
[ $(id -u) != "0" ] && { echo -e "${RED}错误: 必须使用root权限运行此脚本${NC}"; exit 1; }

# 安装wget（如果需要）
command -v wget >/dev/null 2>&1 || { 
    echo -e "${YELLOW}正在安装wget...${NC}"
    apt-get update && apt-get install -y wget
}

# 检查内存
total_mem=$(free -m | awk '/^Mem:/{print $2}')
if [ $total_mem -lt 1024 ]; then
    echo -e "${RED}警告: 建议至少有1GB内存${NC}"
    read -p "是否继续？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 显示警告
clear
echo -e "${RED}警告：此操作将清除服务器上的所有数据！请确保已备份重要数据！${NC}"
echo -e "${YELLOW}5秒后开始安装，按Ctrl+C取消...${NC}"
sleep 5

# 设置变量
echo -e "${GREEN}请选择要安装的系统：${NC}"
echo "1) Debian 11 (推荐)"
echo "2) Debian 12"
echo "3) Ubuntu 20.04"
echo "4) Ubuntu 22.04"
read -p "请选择 [1-4]: " sys_choice

case $sys_choice in
    1) SYSTEM_ARGS="-d 11 -v 64 -a";;
    2) SYSTEM_ARGS="-d 12 -v 64 -a";;
    3) SYSTEM_ARGS="-u 20.04 -v 64 -a";;
    4) SYSTEM_ARGS="-u 22.04 -v 64 -a";;
    *) echo -e "${RED}无效的选择，使用默认选项：Debian 11${NC}"
       SYSTEM_ARGS="-d 11 -v 64 -a";;
esac

# 设置密码
read -p "请设置root密码 (默认为 'password'): " root_password
root_password=${root_password:-password}
SYSTEM_ARGS="$SYSTEM_ARGS -p $root_password"

# 显示安装信息
echo -e "\n${BLUE}即将安装系统，配置如下：${NC}"
echo -e "系统参数: ${SYSTEM_ARGS}"
echo -e "root密码: ${root_password}"
echo -e "\n${YELLOW}3秒后开始安装...${NC}"
sleep 3

# 下载并执行DD脚本
echo -e "${GREEN}开始下载安装脚本...${NC}"
wget --no-check-certificate -qO InstallNET.sh ${SCRIPT_URL}
chmod +x InstallNET.sh
echo -e "${GREEN}开始安装系统，请耐心等待...${NC}"
bash InstallNET.sh ${SYSTEM_ARGS}

# 清理
rm -f InstallNET.sh
