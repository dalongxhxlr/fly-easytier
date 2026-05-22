import json
import subprocess
import datetime
import time

# Load platform limits
with open("platform_limits.json", "r") as f:
    limits = json.load(f)

now = datetime.datetime.now(datetime.UTC)
year = now.year
month = now.month

# Reset monthly usage if month changed
if limits["flyio"]["year"] != year or limits["flyio"]["month"] != month:
    limits["flyio"]["usage_minutes"] = 0
    limits["flyio"]["year"] = year
    limits["flyio"]["month"] = month
    limits["flyio"]["locked"] = False   # 解锁新月份
    print("New month detected. Resetting usage and unlock state.")

# 如果本月已经锁定（超过 1 美元），直接退出
if limits["flyio"].get("locked", False):
    print("This month already exceeded limit. Machine remains stopped.")
    exit(0)

# Query Fly.io usage with retry
usage_json = None
for i in range(3):
    result = subprocess.run(
        ["flyctl", "apps", "usage", "--json"],
        capture_output=True,
        text=True
    )
    stdout = result.stdout.strip()

    if stdout:
        try:
            usage_json = json.loads(stdout)
            break
        except json.JSONDecodeError:
            pass

    print(f"Fly.io usage API returned empty or invalid JSON, retrying ({i+1}/3)...")
    time.sleep(3)

if usage_json is None:
    print("Failed to fetch Fly.io usage after 3 retries. Exiting safely.")
    exit(0)

# Extract cost
current_cost = usage_json["current"]["total_cost"]

print(f"Current cost: ${current_cost:.2f}")

# Save updated usage
limits["flyio"]["usage_minutes"] = usage_json["current"]["cpu"]["seconds"] / 60

# 超过 1 美元 → 本月永久停机
if current_cost >= 1.0:
    print("Monthly cost exceeded $1. Stopping machine for the rest of the month...")
    limits["flyio"]["locked"] = True
    subprocess.run(["flyctl", "machines", "stop", "--app", "fly-easytier-ipv4"])
else:
    print("Cost OK. No action needed.")

# Save updated limits
with open("platform_limits.json", "w") as f:
    json.dump(limits, f, indent=2)
