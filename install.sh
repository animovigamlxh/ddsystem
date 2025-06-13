#!/bin/bash

# 颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# DD脚本地址
SCRIPT_URL="https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh"

# 检查root权限
[ $(id -u) != "0" ] && { echo -e "${RED}错误: 必须使用root权限运行此脚本${NC}"; exit 1; }

# 显示警告
clear
echo -e "${RED}警告：此操作将安装Debian 9系统，并清除服务器上的所有数据！${NC}"
echo -e "${RED}请确保已备份重要数据！${NC}"
echo -e "${YELLOW}5秒后开始安装，按Ctrl+C取消...${NC}"
sleep 5

# 设置密码
read -p "请设置root密码 (默认为 'password'): " root_password
root_password=${root_password:-password}

# 设置参数
SYSTEM_ARGS="-d 9 -v 64 -a -p $root_password"

# 显示安装信息
echo -e "\n${GREEN}即将安装Debian 9系统，配置如下：${NC}"
echo -e "系统：Debian 9 x64"
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
