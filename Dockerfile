FROM alpine:latest

# 安装 xray 和 cloudflared
RUN apk add --no-cache curl && \
    curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip && \
    unzip xray.zip xray && mv xray /usr/local/bin/ && rm xray.zip && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared /usr/local/bin/xray

# 拷贝 Xray 配置
COPY config.json /etc/config.json

# 启动脚本：彻底清除环境变量，强制 Xray 先动
ENTRYPOINT ["/bin/sh", "-c", "unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY && xray -c /etc/config.json & sleep 3 && exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}"]