FROM easytier/easytier:latest

# Alpine 系统使用 apk 安装工具
RUN apk add --no-cache iputils curl

# 启动 EasyTier
ENTRYPOINT ["sh", "-c", "easytier-core --network-name $ET_NETWORK_NAME --network-secret $ET_NETWORK_SECRET --peers $ET_PEERS --ipv4 10.49.1.200 --dhcp"]
