## 0.12.1 2023-02-15 <dave at tiredofit dot ca>

   ### Changed
      - Reduce image size drastically by deleting build cache


## 0.12.0 2023-02-15 <dave at tiredofit dot ca>

   ### Added
      - Split CLEANUP into its own MODE due to the fact it requires exclusive repository access
      - Added Zabbix statistics for CLEANUP
      - Rework internal variables for consistency
      - Add CLEANUP_RETAIN_TAG to not remove specific tags
      - Add BACKUP_SNAPSHOT_TAG to add specific tag to snapshot
      - Change JOB_CONCURRENCY to BACKUP_JOB_CONCURRENCY for multiple snapshots at once


## 0.11.1 2023-02-14 <dave at tiredofit dot ca>

   ### Added
      - Add zabbix metrics sending for CHECK and PRUNE
      - Add DRY_RUN capabilities to CHECK and PRUNE


## 0.11.0 2023-02-13 <dave at tiredofit dot ca>

   ### Added
      - Multiple repository support per BACKUPXX_ CHECKXX_ PRUNEXX_ tasks
      - Add Nginx for reverse proxy to restic server for better logging and enhancements
      - CHECK and PRUNE can now be run multiple times and create their own schedulers
      - Automatically unlock the repository at the end of tasks.
      - Change the way repositories are initialized, don't do them multiple times if using multiple TASKXX vars and they end up to be going to the same place
      - Cleanup some logging weirdness.


## 0.10.0 2023-02-07 <dave at tiredofit dot ca>

   ### Added
      - Send backup metrics to Zabbix

   ### Changed
      - Disable Pre and Post Hooks support for time being
      - Cleanup Logs and avoid leaking potential secrets
      - Properly allow cleanup to operate rather than send multiple keep arguments


## 0.9.0 2023-02-06 <dave at tiredofit dot ca>

   ### Added
      - Add RESTIC rest server support
      - Add RCLONE rest server support


## 0.8.0 2023-02-06 <dave at tiredofit dot ca>

   ### Added
      - Multiple backup source scheduling support
      - Customizable retention post backups
      - Scheduled repository check support
      - Scheduled repository prune support


