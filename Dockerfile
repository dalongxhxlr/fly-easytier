FROM ginuerzh/gost AS gost-bin

FROM alpine:latest
COPY --from=gost-bin /bin/gost /bin/gost

RUN apk add --no-cache curl
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# 拷贝配置文件
COPY gost.yaml /etc/gost.yaml

# 绝杀启动命令：env -i 清除所有 Fly 注入的环境变量，只保留 token
ENTRYPOINT ["/bin/sh", "-c", "env -i PATH=/usr/local/bin:/usr/bin:/bin TUNNEL_TOKEN=$TUNNEL_TOKEN /bin/gost -C /etc/gost.yaml & sleep 5 && /usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}"]