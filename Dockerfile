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
# 设置用户名为 fly，密码为 tunnel123 (你可以自行修改)
# 使用 trojan 协议，设置密码为 flytunnel (trojan 必须有密码)
# 将认证信息和协议参数分开写，确保 Gost 100% 识别密码
ENTRYPOINT ["/bin/sh", "-c", "/bin/gost -L trojan://flytunnel@:8080?path=/fly-tunnel&transport=ws & exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}"]