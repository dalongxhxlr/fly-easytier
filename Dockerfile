# 第一阶段：获取 cloudflared
FROM cloudflare/cloudflared:latest AS cloudflared

# 第二阶段：构建我们的代理镜像
FROM ginuerzh/gost:latest

# 从第一阶段拷贝 cloudflared
COPY --from=cloudflared /usr/local/bin/cloudflared /usr/local/bin/cloudflared

# 使用 sh -c 直接在一行启动两个进程
# 1. gost 在后台运行 (&)
# 2. cloudflared 在前台运行 (exec)
# 修改后的 ENTRYPOINT
ENTRYPOINT ["/bin/sh", "-c", "/bin/gost -L mwss://:8080 & exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}"]