## **Overview**

This script creates timestamped backups of any configuration file and stores them in a specified backup directory.
It also logs all operations (info, errors, success messages) into a dedicated log file.

---

## **Usage**

```bash
./backup_config.sh <SOURCE_FILE> <BACKUP_DIR> <LOG_FILE>
```

### **Arguments**

| Argument      | Required | Description                               | Default                      |
| ------------- | -------- | ----------------------------------------- | ---------------------------- |
| `SOURCE_FILE` | No       | Path to the file you want to back up      | `/etc/nginx/nginx.conf`      |
| `BACKUP_DIR`  | No       | Directory where the backup will be stored | `/var/backups`               |
| `LOG_FILE`    | No       | Log file where events will be written     | `/var/log/backup_config.log` |

---

## **Example**

```bash
./backup_config.sh /etc/nginx/nginx.conf /opt/backups /var/log/my_backup.log
```
