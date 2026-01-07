FROM easytier/easytier:latest

# 安装基础工具
RUN apt-get update && apt-get install -y iputils-ping curl

# 启动 EasyTier
# --ipv4 10.49.1.200 是给 Fly.io 节点分配的虚拟网 IP
ENTRYPOINT ["sh", "-c", "easytier-core --network-name $ET_NETWORK_NAME --network-secret $ET_NETWORK_SECRET --peers $ET_PEERS --ipv4 10.49.1.200 --dhcp"]
