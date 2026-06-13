这是一个为你量身定制的 `README.md` 文档。它清晰地总结了项目的目标、防止超额扣费的核心策略以及工作流的具体配置，非常适合作为这个仓库的说明。

你可以直接将以下内容复制到你的 `README.md` 文件中：

---

# Fly.io EasyTier 自动部署与定时启停计划

本项目旨在通过 GitHub Actions 自动化部署 [EasyTier](https://github.com/EasyTier/EasyTier) 到 Fly.io 平台，并通过定时启停策略，最大化利用平台资源，将每月开销**严格控制在 1 美元以内**（配合 Fly.io 的免单机制可实现长期免费）。

---

## 🎯 核心控制策略：如何把费用压在 $1 以下？

由于 Fly.io 采用按秒计费的模式，长期挂机不可避免会产生账单。本项目摒弃了极度保守的“每周 2.5 小时”错误计算方案，基于真实账单数据制定了以下策略：

* **真实单价评估：** 基础配置 `shared-cpu-1x` (256MB) 的真实计算费用约为 **$0.0026/小时**，加上固定 1GB 硬盘费 $0.15/月及少量流量费。1 美元预算可支撑每月约 **300 小时** 的运行时长。
* **每日 10 小时工作制：** 设定系统在每天最核心的时间段（北京时间 09:00 - 19:00）运行，每月总计运行 300 小时，在用满预算的同时保证绝对不超标。
* **物理级防唤醒：** 彻底关闭 Fly.io 自带的 HTTP 流量唤醒机制，防止被互联网扫描器或客户端重连意外唤醒。

---

## 📂 仓库结构与工作流说明

本仓库的自动化调度完全由 GitHub Actions 接管，核心文件包含三个工作流和一份服务配置文件：

### 1. 部署脚本 (`.github/workflows/deploy.yml`)

* **触发条件：** 代码推送到 `main` 分支时自动触发。
* **核心特性：** 部署命令中附带了 `--ha=false` 参数，强制取消 Fly.io 默认的高可用（双实例）策略，避免双倍扣费。

### 2. 定时启动 (`.github/workflows/start.yml`)

* **执行逻辑：** 通过 `flyctl machines start` 唤醒指定机器。
* **执行时间：** 每天 UTC 01:00（北京时间 **09:00**）。

### 3. 定时停止 (`.github/workflows/stop.yml`)

* **执行逻辑：** 通过 `flyctl machines stop` 休眠指定机器。
* **执行时间：** 每天 UTC 11:00（北京时间 **19:00**）。

### 4. 配置文件 (`fly.toml`)

为了保证定时关机后机器不会被异常流量唤醒，`fly.toml` 必须严格包含以下配置：

```toml
[http_service]
  internal_port = 8080
  force_https = false
  auto_start_machines = false   # 【核心】彻底关闭流量自动唤醒
  auto_stop_machines = false    # 关闭平台自动休眠，交由 GitHub Actions 控制
  min_machines_running = 0      # 【核心】允许机器数量降为 0，防止强行保活
  processes = ["app"]

```

---

## 🚀 部署与使用指南

### 1. 配置 GitHub Secrets

在 GitHub 仓库的 `Settings > Secrets and variables > Actions` 中，添加以下环境变量：

* `FLY_API_TOKEN`：你的 Fly.io 访问令牌。
* `ET_NETWORK_NAME`：EasyTier 虚拟网络名称。
* `ET_NETWORK_SECRET`：EasyTier 虚拟网络密码。
* `ET_PEERS`：需要连接的对等节点地址。

### 2. 确认 Machine ID

在 `start.yml` 和 `stop.yml` 中，有一段指定启动机器 ID 的代码，例如 `1781e7e4a27328`。
如果你在 Fly.io 上重新部署或销毁了机器，**请务必更新为你最新的 Machine ID**，否则定时任务将无法找到目标实例。

### 3. 修改启停时间

如果你需要调整在线时间，请修改 `start.yml` 和 `stop.yml` 中的 `cron` 表达式。注意 GitHub Actions 使用的是 **UTC 时间**（比北京时间晚 8 小时）。

| 操作 | UTC 时间 (Cron) | 北京时间 |
| --- | --- | --- |
| **启动机器** | `0 1 * * *` | 每日 09:00 |
| **停止机器** | `0 11 * * *` | 每日 19:00 |

> **💡 贴士：** 只要每月的总运行时长不超过 **300 小时**，你的总账单预估就会稳定保持在 $0.90 - $0.99 左右。配合 Fly.io 每月 $5 以下的不成文免单规则，可以放心使用。
