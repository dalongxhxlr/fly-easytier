FROM ginuerzh/gost AS gost-bin

FROM alpine:latest
COPY --from=gost-bin /bin/gost /bin/gost

RUN apk add --no-cache curl
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# 将配置文件打入镜像
COPY gost.yaml /etc/gost.yaml

# 关键：清除变量 + 延迟启动 cloudflared
# 显式指定 127.0.0.1 避免 IPv6 解析坑，并加上 5 秒等待
ENTRYPOINT ["/bin/sh", "-c", "unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY && /bin/gost -L trojan://@127.0.0.1:8080?transport=ws&path=/fly-tunnel & sleep 5 && exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}"]