# 1. 部署新配置
fly deploy --strategy immediate --no-cache

# 2. 强制将实例数量缩减为 1（这一步非常重要，防止后台脚本选错机器）
fly scale count 1 --yes

脚本启动建议

在运行我之前给你的“优化版”控制面板脚本时，请先确保清理掉所有旧的代理进程：

Bash
# 彻底清理
pkill -f fly
pkill -f gost
rm /tmp/fly_proxy_21011.pid
然后再运行 ./start_proxy.sh 开启隧道。

# 1. 找到 Machine ID (第一列那个 14 位的字符串)
fly machine list -a fly-easytier-ipv4
1 machines have been retrieved from app fly-easytier-ipv4.
View them in the UI here (​https://fly.io/apps/fly-easytier-ipv4/machines/)

fly-easytier-ipv4
ID            	NAME            	STATE  	CHECKS	REGION	ROLE	IMAGE               	IP ADDRESS                      	VOLUME	CREATED             	LAST UPDATED        	PROCESS GROUP	SIZE                
6e8270d5c27628	muddy-smoke-7850	started	      	sin   	    	ginuerzh/gost:latest	fdaa:3c:aac9:a7b:5f8:e26f:fab5:2	      	2026-01-07T18:04:17Z	2026-01-08T02:30:55Z	app          	shared-cpu-1x:256MB	

fly machine restart 6e8270d5c27628 -a fly-easytier-ipv4

查看远端日志 (核心排查点)

重启后，立即执行：

Bash
fly logs -a fly-easytier-ipv4
重点看日志：

如果看到 SOCKS5 server on :8080 started，说明服务端正常。

如果看到 bind: address already in use 或其他报错，说明之前的 Gost 进程没死透。

清理本地“假死”隧道

重启脚本前，必须杀掉之前可能残留在后台的 fly 进程，否则端口被占用，新配置不生效：

Bash
pkill -f fly
./start_proxy.sh  # 然后选 1 启动

