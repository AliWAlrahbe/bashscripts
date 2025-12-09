A lightweight Bash script that analyzes SSH brute-force attempts by scanning your system’s authentication log.
It detects attacker IPs, counts failed login attempts, and prints a sorted list of the most active sources.

---

## 🚀 Features

* Auto-detects Linux OS family (Debian/Ubuntu or RHEL/CentOS)
* Selects the correct SSH log automatically

  * Debian/Ubuntu → `/var/log/auth.log`
  * RHEL/CentOS → `/var/log/secure`
* Extracts and counts failed SSH login attempts
* Minimum attempts threshold (default: **3**)
* Sorted attacker list (highest first)
* Clean separation between output and INFO messages

---

## 📦 Usage

```bash
./ali_script.sh [MIN_FAILS]
```

## 📊 Output Example

```
[INFO] Detected OS family: debian family
[INFO] Using auth log: /var/log/auth.log

192.168.1.10      33
185.22.56.10      12
45.180.3.99       7
```
