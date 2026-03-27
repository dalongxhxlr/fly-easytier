FROM alpine:latest

# 安装基础工具
RUN apk add --no-cache curl unzip

# 安装 Xray
RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip \
    && unzip xray.zip xray \
    && mv xray /usr/local/bin/ \
    && rm xray.zip \
    && chmod +x /usr/local/bin/xray

# 安装 Cloudflared（官方二进制）
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    -o /usr/local/bin/cloudflared \
    && chmod +x /usr/local/bin/cloudflared

# 拷贝 Xray 配置
COPY config.json /etc/config.json

# 自动停机脚本 + 启动 Xray + 启动 Cloudflared
ENTRYPOINT ["/bin/sh", "-c", " \
  (sleep 2700 && kill 1) & \
  xray -c /etc/config.json & \
  sleep 3 && \
  exec cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN} \
"]
