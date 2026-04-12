import json
import subprocess
import datetime

# Load platform limits
with open("platform_limits.json", "r") as f:
    limits = json.load(f)

now = datetime.datetime.utcnow()
year = now.year
month = now.month

# Reset monthly usage if month changed
if limits["flyio"]["year"] != year or limits["flyio"]["month"] != month:
    limits["flyio"]["usage_minutes"] = 0
    limits["flyio"]["year"] = year
    limits["flyio"]["month"] = month

# Query Fly.io usage
cmd = ["flyctl", "apps", "usage", "--json"]
result = subprocess.run(cmd, capture_output=True, text=True)
usage = json.loads(result.stdout)

# Extract CPU seconds
cpu_seconds = usage["current"]["cpu"]["seconds"]
cpu_minutes = cpu_seconds / 60

limits["flyio"]["usage_minutes"] = cpu_minutes

# Save updated limits
with open("platform_limits.json", "w") as f:
    json.dump(limits, f, indent=2)

# Stop machine if limit exceeded
if cpu_minutes >= limits["flyio"]["monthly_limit_minutes"]:
    print("Monthly limit reached. Stopping Fly.io machine...")
    subprocess.run(["flyctl", "machines", "stop", "--app", "fly-easytier-ipv4"])
else:
    print(f"Usage OK: {cpu_minutes:.2f}/{limits['flyio']['monthly_limit_minutes']} minutes")
