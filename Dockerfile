FROM ginuerzh/gost AS gost-bin

FROM alpine:latest
COPY --from=gost-bin /bin/gost /bin/gost

RUN apk add --no-cache curl
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# 将配置文件打入镜像
COPY gost.yaml /etc/gost.yaml

# 关键：清除变量 + 延迟启动 cloudflared
ENTRYPOINT ["/bin/sh", "-c", "unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY && /bin/gost -C /etc/gost.yaml & sleep 2 && exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}"]