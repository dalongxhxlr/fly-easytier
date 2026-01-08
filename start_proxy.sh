#!/bin/bash

# --- 配置区 ---
APP_NAME="fly-easytier-ipv4"
LOCAL_PORT=21011
REMOTE_PORT=8080

echo "------------------------------------------"
echo "   Fly.io 代理启动器 (终极修复版)"
echo "------------------------------------------"

# 1. 环境预清理：杀掉旧进程，防止端口占用
pkill -f "fly proxy.*$LOCAL_PORT" 2>/dev/null

# 2. 核心步骤：弹出新窗口并强制清除代理环境变量
# 我们在 AppleScript 内部加入了 export 命令，确保 fly 直连 api.fly.io
osascript <<EOF
tell application "Terminal"
    do script "echo '--- Fly.io Proxy Tunnel ---'; \
               export http_proxy=''; \
               export https_proxy=''; \
               export all_proxy=''; \
               echo '已强制绕过本地环境代理...'; \
               echo '正在建立隧道...'; \
               fly proxy ${LOCAL_PORT}:${REMOTE_PORT} -a ${APP_NAME} --select=false"
    activate
end tell
EOF

echo "------------------------------------------"
echo "✨ 启动指令已发出！"
echo "📍 请观察新弹出的终端窗口："
echo "   - 如果显示 'Proxying local port...' -> 成功"
echo "   - 如果显示 'Error' -> 请检查 Fly.io 账号登录状态"
echo ""
echo "✅ 成功后，请开启 Karing (SOCKS5: 127.0.0.1:${LOCAL_PORT})"
echo "------------------------------------------"
