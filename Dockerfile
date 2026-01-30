FROM ginuerzh/gost AS gost-bin

FROM alpine:latest
COPY --from=gost-bin /bin/gost /bin/gost

RUN apk add --no-cache curl
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# 1. 拷贝配置文件
COPY gost.yaml /etc/gost.yaml

# 2. 启动命令：彻底抛弃命令行参数，只读配置文件
# 重点：删掉 127.0.0.1，直接写 :8080。并且删掉 env -i，改回 unset。
ENTRYPOINT ["/bin/sh", "-c", "unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY && /bin/gost -L trojan://:8080?transport=ws&path=/fly-tunnel & sleep 3 && exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}"]