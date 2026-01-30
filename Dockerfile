# 使用官方镜像
FROM ginuerzh/gost AS gost-bin

FROM alpine:latest
COPY --from=gost-bin /bin/gost /bin/gost

# 安装 cloudflared
RUN apk add --no-cache curl
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# 将配置文件拷贝进去
COPY gost.yaml /etc/gost.yaml

# 关键：清除可能导致回环的环境变量，并指定配置文件启动
# 显式指定监听 0.0.0.0 避免 [::1] 无法识别的问题
ENTRYPOINT ["/bin/sh", "-c", "unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY && /bin/gost -L trojan://@0.0.0.0:8080?transport=ws&path=/fly-tunnel & sleep 2 && exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}"]