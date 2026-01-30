# 第一阶段：获取 cloudflared
FROM cloudflare/cloudflared:latest AS cloudflared

# 第二阶段：构建我们的代理镜像
FROM ginuerzh/gost:latest

# 从第一阶段拷贝 cloudflared 二进制文件到本镜像
COPY --from=cloudflared /usr/local/bin/cloudflared /usr/local/bin/cloudflared

# 创建一个启动脚本来同时运行 gost 和 cloudflared
RUN echo '#!/bin/sh\n\
# 启动 gost 并在后台运行，监听 8080 端口\n\
/bin/gost -L socks5://:8080 &\n\
\n\
# 启动 cloudflare 隧道\n\
# 注意：这里使用环境变量 TUNNEL_TOKEN\n\
exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}\n\
' > /start.sh && chmod +x /start.sh

# 告诉容器启动时运行该脚本
ENTRYPOINT ["/bin/sh", "/start.sh"]