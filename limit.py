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

# Extract CPU seconds
cpu_seconds = usage_json["current"]["cpu"]["seconds"]
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
