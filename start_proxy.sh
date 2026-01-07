#!/bin/bash

# --- 配置区 ---
APP_NAME="fly-easytier-ipv4"
LOCAL_PORT=21011
REMOTE_PORT=8080

echo "=========================================="
echo "    Fly.io 新加坡 SOCKS5 代理启动器"
echo "=========================================="

# 1. 登录认证检查与自动登录
check_login() {
    echo "[1/3] 检查 Fly.io 登录状态..."
    if ! fly auth whoami > /dev/null 2>&1; then
        echo "⚠️  未检测到登录或 Token 已失效，正在唤起浏览器登录..."
        fly auth login
        if [ $? -ne 0 ]; then
            echo "❌ 登录失败，请检查网络环境后重试。"
            exit 1
        fi
    else
        echo "✅ 已登录: $(fly auth whoami | head -n 1)"
    fi
}

# 2. 强力清理旧进程
cleanup() {
    echo "[2/3] 正在清理本地端口 $LOCAL_PORT 的残留进程..."
    lsof -ti:$LOCAL_PORT | xargs kill -9 > /dev/null 2>&1
    pkill -f "fly proxy.*$LOCAL_PORT" > /dev/null 2>&1
    sleep 1
}

# 执行初始化
check_login
cleanup

# 3. 启动隧道（带无限重试逻辑）
echo "[3/3] 正在尝试建立隧道: 本地 $LOCAL_PORT -> 新加坡 $REMOTE_PORT"
echo "提示: 遇到 Connection reset 脚本会自动重试"
echo "按下 Ctrl+C 彻底停止并退出"
echo "------------------------------------------"

while true; do
    # 使用 --select 强制弹出选择框（如果 API 连得上的话）
    # 如果你确定只有一台机器，可以去掉 --select 换成 -s
    fly proxy $LOCAL_PORT:$REMOTE_PORT -a $APP_NAME --select
    
    echo ""
    echo "⚠️  隧道掉线或连接被重置，5秒后自动尝试重连..."
    sleep 5
done
