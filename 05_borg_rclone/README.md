# Automated WordPress Backup Script

This script provides a robust, automated, and secure solution for backing up a WordPress website. It handles both the website files and the database, encrypts them, and syncs them to an offsite cloud storage location.

## Features

- **Comprehensive Backup:** Backs up both the entire WordPress file directory and the MySQL database.
- **Secure & Encrypted:**
    - Database credentials are not stored in the script; they are read from a secure `.my.cnf` file.
    - Borg passphrase is not stored in the script; it is read from a restricted file in `/root/`.
    - Backups are encrypted locally using BorgBackup.
- **Efficient Storage:** Uses BorgBackup for deduplicated backups, saving significant storage space over time.
- **Automated Offsite Sync:** Securely syncs the encrypted backup repository to a cloud storage provider using Rclone.
- **Intelligent Retention Policy:**
    - **Borg Archives:** Keeps all backups from the last 24 hours, then keeps one daily backup for 7 days, one weekly backup for 4 weeks, and one monthly backup for 6 months. This provides a rich history without using excessive space.
    - **Raw SQL Dumps:** The local SQL dump files are automatically deleted after 30 days to save local disk space.
- **Robust Logging & Error Handling:** The script logs all its actions and will stop immediately if any command fails.
- **Unique, Timestamped Backups:** Every backup run creates a unique, timestamped archive, preventing overwrites and allowing for multiple backups per day.

## Prerequisites

Before using this script, you must have the following software installed on your server:
- `mysql-client` (for `mysqldump`)
- `borgbackup`
- `rclone`

## Configuration

You must configure your environment and the script itself before the first run.

### 1. Database Credentials

The script is designed to get the database user and password from a `.my.cnf` file in the root user's home directory (`/root/.my.cnf`). This is more secure than hardcoding credentials.

Create or edit the file at `/root/.my.cnf` to contain the following:

```ini
[mysqldump]
user=your_db_user
password=your_db_password
```
**Important:** Secure this file by setting its permissions to `600`:
```sh
chmod 600 /root/.my.cnf
```

### 2. Borg Passphrase

Create a file to store your Borg repository passphrase. This passphrase is used to encrypt your backups.

```sh
# Choose a long, strong, and unique passphrase
echo 'your-super-secret-borg-passphrase' > /root/.borg_passphrase
# Secure the file
chmod 600 /root/.borg_passphrase
```

### 3. Rclone Remote

You need to configure an Rclone "remote" that points to your cloud storage provider (e.g., AWS S3, Google Cloud Storage, Backblaze B2, etc.).

Run the interactive configuration wizard:
```sh
rclone config
```
When creating the remote, the script expects its name to be `s3-encrypted`. If you name it something else, you must update the `RCLONE_REMOTE` variable in the script.

### 4. Script Variables

Review the configuration variables at the top of the `daily_backup.sh` script and edit them to match your setup if necessary.

- `DB_NAME`: The name of your WordPress database.
- `WP_FILES_PATH`: The absolute path to your WordPress files.
- `DB_BACKUP_PATH`: A temporary directory to store SQL dumps.
- `BORG_REPO`: The local path to your Borg backup repository.
- `RCLONE_REMOTE`: The name of your configured Rclone remote.
- `RCLONE_DESTINATION`: The folder on your remote where backups will be stored.

## Usage

### 1. Make the Script Executable
```sh
chmod +x .idx/daily_backup.sh
```

### 2. Run Manually (for testing)
You can run the script directly to perform a backup at any time.
```sh
./.idx/daily_backup.sh
```

### 3. Schedule with Cron (for automation)

To run the backup automatically every day, add it to the root user's crontab.

1.  Open the crontab editor:
    ```sh
    sudo crontab -e
    ```
2.  Add the following line to run the script every day at 2:00 AM and log the output. **Remember to use the absolute path to the script.**

    ```sh
    # Run the WordPress backup script every day at 2:00 AM
    0 2 * * * /path/to/your/project/.idx/daily_backup.sh >> /var/log/backup.log 2>&1
    ```

## Restoring from a Backup

This script is for creating backups. To restore, you will need to use Borg and Rclone manually.

1.  **Sync from Remote (if needed):** If your local repository is gone, sync it back from your cloud storage with `rclone sync`.
2.  **List Backups:** Use `borg list /path/to/borg/repo` to see all available backup archives.
3.  **Mount a Backup:** You can mount an archive as a filesystem to browse and copy files: `borg mount /path/to/borg/repo::archive-name /mnt/restore`.
4.  **Extract a Backup:** You can extract all files from an archive with `borg extract`.
5.  **Restore the Database:** The `.sql` file for each backup is located inside the archive. You can extract it and import it into MySQL.

For detailed restoration instructions, please consult the official [BorgBackup documentation](https://borgbackup.readthedocs.io/en/stable/usage/index.html).
