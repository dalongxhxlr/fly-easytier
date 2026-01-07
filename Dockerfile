FROM easytier/easytier:latest

# 安装基础工具以便排查问题
RUN apk add --no-cache iputils curl

# 这里的参数对应你之前的网络配置
# -n: 网络名称, -s: 网络密钥
# 我们不需要指定 -i，让它自动获取
ENTRYPOINT ["/usr/bin/easytier-core"]
CMD ["-n", "fly-net-hub", "-s", "2025@easytier"]