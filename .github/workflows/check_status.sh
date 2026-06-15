#!/bin/bash
# 检查机器状态的测试脚本
echo "Checking Machine Status..."
# 使用 flyctl 查询机器状态，这比直接请求 API 更稳定
flyctl status --app fly-easytier-ipv4 --json > status.json

# 如果 status.json 非空，说明读取成功
if [ -s status.json ]; then
    echo "读取成功！机器状态如下："
    cat status.json
    # 写入 GitHub 仓库记录
    git config --global user.name "github-actions"
    git config --global user.email "github-actions@github.com"
    git add status.json
    git commit -m "chore: update machine status [skip ci]"
    git push
else
    echo "读取失败，请检查 FLY_API_TOKEN 权限"
    exit 1
fi
