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

# 显示通用警告
clear
echo -e "${RED}警告：此操作将重装您的服务器操作系统！${NC}"
echo -e "${RED}这将清除服务器上的所有数据！请确保已备份重要数据！${NC}"
echo -e "${YELLOW}在继续之前，请三思而后行。${NC}"
echo ""

# 操作系统选择菜单
echo -e "${GREEN}请选择您想安装的操作系统：${NC}"
echo "1) Debian 12 (Bookworm) [推荐]"
echo "2) Debian 11 (Bullseye)"
echo "3) Ubuntu 22.04 (Jammy)"
echo "4) Alpine Linux (Latest)"
echo "5) 取消操作"
read -p "请输入选项 [1-5]: " os_choice

SYSTEM_ARGS=""
OS_NAME=""

case $os_choice in
    1)
        SYSTEM_ARGS="-d 12 -v 64"
        OS_NAME="Debian 12 (Bookworm) x64"
        ;;
    2)
        SYSTEM_ARGS="-d 11 -v 64"
        OS_NAME="Debian 11 (Bullseye) x64"
        ;;
    3)
        SYSTEM_ARGS="-u 22.04 -v 64"
        OS_NAME="Ubuntu 22.04 (Jammy) x64"
        ;;
    4)
        SYSTEM_ARGS="--alpine -v 64"
        OS_NAME="Alpine Linux (Latest) x64"
        ;;
    5)
        echo "操作已取消。"
        exit 0
        ;;
    *)
        echo -e "${RED}无效选项，脚本已中止。${NC}"
        exit 1
        ;;
esac

echo ""
# 设置密码
read -p "请为新系统设置root密码 (默认为 'password'): " root_password
root_password=${root_password:-password}

# 组合最终参数, 注意密码要用单引号包裹，防止特殊字符导致问题
SYSTEM_ARGS="$SYSTEM_ARGS -a -p '$root_password'"

# 显示最终确认信息
echo -e "\n${YELLOW}请最终确认您的安装配置：${NC}"
echo -e "----------------------------------"
echo -e "操作系统: ${GREEN}${OS_NAME}${NC}"
echo -e "root密码: ${GREEN}${root_password}${NC}"
echo -e "----------------------------------"
echo -e "${RED}警告：所有数据将被清除！安装过程不可逆！${NC}"
read -p "输入 'yes' 确认安装，输入其他任何内容取消: " confirm

if [ "$confirm" != "yes" ]; then
    echo "安装已取消。"
    exit 0
fi

echo -e "\n${YELLOW}3秒后开始安装...${NC}"
sleep 3

# 下载并执行DD脚本
echo -e "${GREEN}开始下载安装脚本...${NC}"
wget --no-check-certificate -qO InstallNET.sh ${SCRIPT_URL}
if [ $? -ne 0 ]; then
    echo -e "${RED}下载安装脚本失败，请检查网络或脚本URL是否有效。${NC}"
    exit 1
fi

chmod +x InstallNET.sh
echo -e "${GREEN}开始安装系统，这可能需要一些时间。您的SSH连接将会中断。${NC}"
echo -e "${GREEN}请在10-20分钟后尝试使用新设置的密码重新连接您的服务器。${NC}"
bash InstallNET.sh ${SYSTEM_ARGS}

# 清理 (这部分代码可能不会执行，因为DD脚本会重启)
rm -f InstallNET.sh
