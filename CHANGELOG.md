## 1.0.1 2023-03-10 <dave at tiredofit dot ca>

   ### Changed
      - Fix for Zabbix Backup Metrics getting merged into same line


## 1.0.0 2023-03-09 <dave at tiredofit dot ca>

   ### Added
      - Stable release
      - Add CLEANUP|PRUNE_MAX_REPACK_SIZE environment variables
      - Add CLEANUP|PRUNE_MAX_UNUSED environment variables
      - Add PRUNE_REPACK functionality


## 0.20.2 2023-03-09 <dave at tiredofit dot ca>

   ### Changed
      - Fix cleanup log analysis for metrics
      - Fix Month missing from Log "Start" files
      - Add light verbosity to tell what is being cleaned up on the console


## 0.20.1 2023-03-08 <dave at tiredofit dot ca>

   ### Added
      - Add Zabbix metrics and POST_HOOK statistics for CLEANUP function


## 0.20.0 2023-03-08 <dave at tiredofit dot ca>

   ### Added
      - Introduce CLEANUP_HOST setting to scope cleanups to a specific `HOST` or `REPOSITORY`
      - Introduce GROUP_BY command to allow for better cleanups to occur based on host, path, tag


## 0.19.3 2023-03-08 <dave at tiredofit dot ca>

   ### Changed
      - Make date formatting in top line of logs better human legible
      - Stop initting variables twice for Inventory
      - Minor formatting


## 0.19.2 2023-03-07 <dave at tiredofit dot ca>

   ### Added
      - Add Zabbix Autoregister support for automonitoring


## 0.19.1 2023-03-07 <dave at tiredofit dot ca>

   ### Changed
      - Bugfixes to some parameters
      - Properly make hooks work for INVENTORY


## 0.19.0 2023-03-07 <dave at tiredofit dot ca>

   ### Added
      - Add INVENTORY mode for storing a copy of snapshots locally on disk for reference

   ### Changed
      - Cleanup some errors in variables for check and prune
      - Add logfile suffix for some operations
      - Allow REPOSITORY_PATH and REPOSITORY_PASS to work for all operations
      - A more efficient and safer/compatible way of searching for creating scheduling jobs


## 0.18.1 2023-03-07 <dave at tiredofit dot ca>

   ### Changed
      - Fix edge case with labels being recreated multiple times when no exclusions exist


## 0.18.0 2023-03-07 <dave at tiredofit dot ca>

   ### Added
      - Add more detailed Zabbix Metrics and Post Hooks for CHECK and PRUNE oeprations


## 0.17.0 2023-03-04 <dave at tiredofit dot ca>

   ### Added
      - Pre and Post hooks for BACKUP, CHECK, CLEANUP, PRUNE, UNLOCK support


## 0.16.2 2023-03-04 <dave at tiredofit dot ca>

   ### Changed
      - Reset dir modified time on log directories (again)


## 0.16.1 2023-03-01 <dave at tiredofit dot ca>

   ### Changed
      - Fetch, store and replace last modified timestamp when doing logrotation


## 0.16.0 2023-03-01 <dave at tiredofit dot ca>

   ### Added
      - Add Notifications (Email, Matrix, Mattermost, Rocketchat, Custom script) on job exit code other than 0/OK


## 0.15.0 2023-02-28 <dave at tiredofit dot ca>

   ### Added
      - Add CACHE_PATH and expose cache to drastically speed up operations
      - Stop leaking repository password when repository needs to be unlocked
      - Moved around repostiory backup paths to a different level of the backup function for better seperation
      - Document SKIP_INIT environment variable to skip repository initialization routines (note: CACHE_PATH works wonders!)


## 0.14.8 2023-02-28 <dave at tiredofit dot ca>

   ### Changed
      - Sourcing the wrong defaults


## 0.14.7 2023-02-28 <dave at tiredofit dot ca>

   ### Changed
      - Safer logrotate


## 0.14.6 2023-02-28 <dave at tiredofit dot ca>

   ### Changed
      - Convert restic logrotate crontab to a script


## 0.14.5 2023-02-27 <dave at tiredofit dot ca>

   ### Changed
      - Cleanup "latest" symbolic link work and fix logrotate issues


## 0.14.4 2023-02-20 <dave at tiredofit dot ca>

   ### Changed
      - Fix during setup_container_mode function


## 0.14.3 2023-02-19 <dave at tiredofit dot ca>

   ### Added
      - Set NGINX_CLIENT_BODY_BUFFER_SIZE to 20m


## 0.14.2 2023-02-19 <dave at tiredofit dot ca>

   ### Changed
      - Unstick blackout mode


## 0.14.1 2023-02-17 <dave at tiredofit dot ca>

   ### Changed
      - Bugfix to 0.14.0


## 0.14.0 2023-02-17 <dave at tiredofit dot ca>

   ### Added
      - Revamp logging to write to foldered YYYMMDD areas. Folders 2 days and older automatically get each logfile zstd commpressed
      - Symbolic links created to point to "latest" log file
      - Add error counting for Zabbix monitoring
      - Code cleanup


## 0.13.2 2023-02-16 <dave at tiredofit dot ca>

   ### Changed
      - Log rotation permission fixes


## 0.13.1 2023-02-16 <dave at tiredofit dot ca>

   ### Changed
      - Refinement to blackout checks


## 0.13.0 2023-02-16 <dave at tiredofit dot ca>

   ### Added
      - Add BACKUP|CHECK|CLEANUP|PRUNE BLACKOUT_BEGIN / BLACKOUT_END variables to skip performing operations when in between these time frames


## 0.12.3 2023-02-16 <dave at tiredofit dot ca>

   ### Changed
      - Fix issue with adding tags
      - Fix verbosity level
      - Fix backup paths appearing multiple times in logs
      - Fix minor quoting issues


## 0.12.2 2023-02-15 <dave at tiredofit dot ca>

   ### Changed
      - Bugfixes with showing right output for Check, Cleanup, and Backup Errors


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


