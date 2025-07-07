#!/bin/bash

# 智能系统重装脚本，专为小内存 VPS 设计

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查 root 权限
if [ "$(id -u)" -ne 0 ]; then
   echo -e "${RED}错误：此脚本必须以 root 权限运行。${NC}" 1>&2
   exit 1
fi

# 检查当前操作系统信息
OS_ID=""
OS_VERSION_ID=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
    OS_VERSION_ID=$VERSION_ID
fi

# ====================
#  阶段二：在 Debian 9 环境下执行
# ====================
if [ "$OS_ID" = "debian" ] && [[ "$OS_VERSION_ID" == 9* ]]; then
    echo -e "${GREEN}阶段二：已检测到 Debian 9 环境。${NC}"
    echo -e "${GREEN}正在准备安装最终的操作系统...${NC}"

    echo -e "\n${YELLOW}步骤 1/2: 安装最终重装脚本所需的依赖...${NC}"
    apt-get update
    apt-get install -y xz-utils openssl gawk file wget screen
    if [ $? -ne 0 ]; then
        echo -e "${RED}依赖安装失败，请检查网络和apt源。脚本中止。${NC}"
        exit 1
    fi
    echo "依赖安装成功。"

    echo -e "\n${YELLOW}步骤 2/2: 下载并执行最终的重装脚本 (NewReinstall.sh)...${NC}"
    # 使用 screen 来运行，防止 SSH 断开连接导致的中断
    screen -S final_reinstall \
    wget --no-check-certificate -O NewReinstall.sh https://raw.githubusercontent.com/fcurrk/reinstall/master/NewReinstall.sh && \
    chmod a+x NewReinstall.sh && \
    bash NewReinstall.sh

    echo -e "\n${GREEN}最终重装脚本已启动。${NC}"
    echo "您现在应该看到了系统选择菜单。如果因SSH断开连接而未看到，"
    echo "可以尝试使用 'screen -r final_reinstall' 命令重新连接到该会话。"
    exit 0
fi

# ====================
#  阶段一：在原始环境下执行
# ====================
echo -e "${GREEN}阶段一：准备将系统重装为 Debian 9 (作为临时跳板系统)。${NC}"
echo -e "${RED}警告：此操作将清除服务器上的所有数据！${NC}"
echo "这是一个两阶段的过程。此为第一阶段。"
echo "在此阶段，系统将被重装为 Debian 9。"
echo "完成后，您需要重新连接服务器，并再次运行此脚本以进入第二阶段。"
echo -e "---------------------------------------------------------------------"
read -p "输入 'yes' 开始第一阶段的安装，输入其他任何内容取消: " confirm

if [ "$confirm" != "yes" ]; then
    echo "操作已取消。"
    exit 0
fi

echo -e "\n${YELLOW}正在执行 Debian 9 DD 安装...${NC}"
echo "您的 SSH 连接即将中断。请在约 5-10 分钟后尝试重新连接。"
echo -e "新系统的默认用户名为: ${GREEN}root${NC}, 默认密码为: ${GREEN}b.gs${NC}"
echo "重新连接后，请务必再次上传并运行此脚本以完成最终的安装！"

# 执行来自 git.beta.gs 的轻量级 DD 脚本
wget -qO- https://git.beta.gs/b-gs/dd/raw/branch/master/dd.sh | bash -s -- -d 9 -v 64

echo -e "\n${RED}如果脚本没有自动中断，说明 DD 命令可能已开始执行。${NC}"
echo "请手动断开连接，并等待服务器重启。"
