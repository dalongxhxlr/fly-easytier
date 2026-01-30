# 第一阶段：获取 cloudflared
FROM cloudflare/cloudflared:latest AS cloudflared

# 第二阶段：构建我们的代理镜像
FROM ginuerzh/gost:latest

# 从第一阶段拷贝 cloudflared
COPY --from=cloudflared /usr/local/bin/cloudflared /usr/local/bin/cloudflared

# 使用 sh -c 直接在一行启动两个进程
# 1. gost 在后台运行 (&)
# 2. cloudflared 在前台运行 (exec)
# 增加一个路径 /fly-tunnel
# 关键：trojan+ws 模式，且不设置密码以排除认证干扰
# 显式使用 transport=ws 参数，不设密码
ENTRYPOINT ["/bin/sh", "-c", "/bin/gost -L trojan://@:8080?transport=ws&path=/fly-tunnel & exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}"]