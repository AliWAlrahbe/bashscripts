# **Monitor Resources Script — Instructions & Usage Guide**

*A production-ready Linux monitoring utility for CPU, Memory, Disk, and automated alerting.*

## 📌 Overview

`01_monitor_resources.sh` is a lightweight monitoring agent designed for Linux servers.
It collects real-time usage for:

* CPU utilization (via `top`)
* Memory utilization (via `free`)
* Disk utilization (via `df`)
* Threshold-based alerting
* Email notifications via **Mailjet API**

The script is built with **production standards** in mind:

* `set -euo pipefail` for safety
* Error-resilient parsing
* Clear logging
* Automatic alert dispatch
* Fully parameterized paths

---

# 📥 **How to Use**

### **1. Make the script executable**

```bash
chmod +x 01_monitor_resources.sh
```

### **2. Run it manually**

```bash
./01_monitor_resources.sh
```

### **3. (Optional) Provide a custom log path**

```bash
./01_monitor_resources.sh /path/to/custom.log
```

If no argument is provided, the script defaults to:

```
/var/log/monitor_resources.log
```

---

# ⚙️ **What the Script Does**

### **✓ CPU Monitoring**

* Captures CPU idle value using `top -bn1`
* Converts it to actual usage: `100 - idle`
* Logs the result
* Compares against the CPU threshold (default: **80%**)

### **✓ Memory Monitoring**

* Reads used and total memory via `free -m`
* Computes percent usage
* Logs the result
* Compares against memory threshold (default: **80%**)

### **✓ Disk Monitoring**

* Inspects all file systems under `/dev`
* Extracts % usage from the `df -P` POSIX-safe output
* Flags the server if **any** disk exceeds the disk threshold (default: **80%**)
* Logs each filesystem clearly

### **✓ Email Notifications**

If **any** threshold is exceeded (CPU, Memory, or Disk):

The script automatically sends an alert using the Mailjet API:

* Includes hostname
* Includes all relevant resource metrics
* Includes a direct reference to the server’s log file

If Mailjet returns an error, `curl --fail` triggers `set -e` and stops the script — ensuring reliability and visibility.

---

# 📤 **Recommended Cron Setup**

To automate monitoring:

```bash
sudo crontab -e
```

Add:

```
*/5 * * * * /path/to/01_monitor_resources.sh >> /var/log/monitor_resources.log 2>&1
```

This checks your server every **5 minutes** and sends alerts only when needed.
