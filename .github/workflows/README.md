📄 .github/workflows/README.md
markdown
# GitHub Actions 自动运行说明（Fly.io 限额控制）

本目录包含本项目用于 Fly.io 自动化运行的 GitHub Actions 工作流文件。

## 1. 为什么不再使用 Fly.io usage API？

原方案通过 `limit.py` 调用：

flyctl apps usage --json

代码

来读取 Fly.io 的实时费用与 CPU 使用情况，并在超过限额时自动停机。

但 Fly.io 对 **新用户** 的 usage API 存在以下问题：

- 经常返回空 JSON  
- 经常返回无效数据  
- 在账单刷新期间（UTC 0 点前后）几乎必定不可用  
- 新用户账单延迟严重，可能 24 小时都不返回 usage  

导致 GitHub Actions 日志长期出现：

Fly.io usage API returned empty or invalid JSON
Failed to fetch usage

代码

因此旧方案无法可靠运行，已废弃。

相关文件（已删除）：

- `limit.yml`
- `limit.py`
- `platform_limits.json`

---

## 2. 新方案：不依赖 API，按“运行时间”控制费用

Fly.io 的计费方式为：

- shared-cpu-1x / 256MB  
- **$0.0864 / 小时**

因此：

1 美元 ≈ 11.5 小时运行时间

代码

为了保证 **绝不超过 1 美元**，并尽量用满额度，本项目采用：

### ✔ 每周六自动运行 2.5 小时  
### ✔ 周日不运行  
### ✔ 每月运行约 10 小时  
### ✔ 费用约 $0.86，不会超过 $1

此方案完全不依赖 Fly.io usage API，稳定可靠。

---

## 3. 当前工作流文件说明

### `start.yml`
- 每周六北京时间 09:00 自动启动 Fly.io Machine  
- 手动运行也可立即启动  

### `stop.yml`
- 每周六北京时间 11:30 自动停机  
- 保证单日运行 2.5 小时  
- 手动运行也可立即停机  

### `deploy.yml`
- 用于手动或自动部署 EasyTier 到 Fly.io  
- 与限额控制无关  

---

## 4. 本方案的优点

- ✔ 不依赖 Fly.io usage API（避免 API 不返回数据的问题）  
- ✔ 运行时间可控，费用可预测  
- ✔ 永远不会超过 1 美元  
- ✔ 自动化，无需人工干预  
- ✔ 下个月自动继续执行  

---

如需调整运行时长或运行日期，可修改 `start.yml` 与 `stop.yml` 的 cron 表达式。
