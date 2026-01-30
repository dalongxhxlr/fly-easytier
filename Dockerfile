FROM ginuerzh/gost AS gost-bin

FROM alpine:latest
COPY --from=gost-bin /bin/gost /bin/gost

RUN apk add --no-cache curl
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# 核心改变：不仅 unset，还要给 gost 传递一个完全空的代理设置
ENTRYPOINT ["/bin/sh", "-c", "env -i PATH=$PATH TUNNEL_TOKEN=$TUNNEL_TOKEN /bin/gost -L trojan://@:8080?transport=ws&path=/fly-tunnel & sleep 5 && /usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}"]